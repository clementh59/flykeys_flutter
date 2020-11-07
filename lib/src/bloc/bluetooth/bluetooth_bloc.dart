import 'dart:async';
import 'dart:io';
import 'package:async/async.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flykeys/src/model/midiReader/midiReader.dart';
import 'package:flykeys/src/model/midiReader/note.dart';
import 'package:flykeys/src/repository/bluetooth_repository.dart';
import 'package:flykeys/src/repository/parsed_file_repository.dart';
import 'bloc.dart';
import 'dart:developer' as dev;

class BluetoothBloc extends Bloc<BluetoothEvent, MyBluetoothState> {
  final BluetoothRepository bluetoothRepository;
  FlutterBlue flutterBlue;
  ValueNotifier valueNotifierStopSendingMorceau;
  ValueNotifier valueNotifierOnDisconnect;
  StreamSubscription streamSubscription;

  //Concerne l'état du morceau
  ValueNotifier<int> valueNotifierActualTick;
  ValueNotifier<Duration> valueNotifierActualDuration;
  ValueNotifier<bool>
      valueNotifierUpdateTickInPage; //always true except when the user slide the time slide bar : we don't want that the slider update
  int nbDeTickMax; //le nb de tick total sert dans le calcul du temps actuel lorsque l'on recoit le tick actuel
  double
      speed_x1; //la speed_x1 sert dans le calcul du temps actuel lorsque l'on recoit le tick actuel
  bool isPlaying = false;
  int lastSecondSentToMusicPage;//me sert pour updateTimeBarWithLastSecondsSentbyTheDevice()

  BluetoothBloc(this.bluetoothRepository) {
    flutterBlue = FlutterBlue.instance;
  }

  @override
  MyBluetoothState get initialState => InitialBluetoothState();

  void initEverythingLearningMode() {
    valueNotifierStopSendingMorceau = ValueNotifier(false);
    valueNotifierActualTick = ValueNotifier(0);
    speed_x1 = 0;
    nbDeTickMax = 0;
    isPlaying = false;
  }

  @override
  Stream<MyBluetoothState> mapEventToState(
    BluetoothEvent event,
  ) async* {
    dev.log("new event : $event",name: "Bluetooth bloc");
    print("Bluetooth bloc : $event");

    //find device
    if (event is FindFlyKeysDevice) {
      valueNotifierOnDisconnect = ValueNotifier(false);

      if (bluetoothRepository.tickBluetoothCharacteristic != null &&
          bluetoothRepository.tickBluetoothCharacteristic != null) {
        yield BluetoothIsSetUpState();
        return;
      }

      yield SearchingForFlyKeysDeviceState();
      FlutterBlue.instance.startScan(
          timeout: Duration(seconds: BluetoothRepository.SCAN_TIMEOUT));
      bool deviceFound =
          await bluetoothRepository.findFlyKeysDevice(flutterBlue);
      if (!deviceFound) {
        yield FlyKeysDeviceNotFoundState();
        return;
      }
      yield FlyKeysDeviceFoundState();
      bool connected =
          await bluetoothRepository.connectToDevice(valueNotifierOnDisconnect);
      valueNotifierOnDisconnect.addListener(() {
        dev.log("Value changed : " + valueNotifierOnDisconnect.value.toString(),name:"valueNotifierOnDisconnect");
        if (valueNotifierOnDisconnect.value == true) {
          print("#15482 : disconnect!!!!!");
          add(DisconnectEvent());
        }
      });
      if (!connected) {
        yield FailedToConnectState();
        return;
      }

      yield SucceedToConnectState();
      bool hasTheRightCharacteristics =
          await bluetoothRepository.hasTheRightCharacteristics();
      if (!hasTheRightCharacteristics) {
        yield FailedToConnectState();
        return;
      }

      yield BluetoothIsSetUpState();

      return;
    }

    if (event is DisconnectEvent) {
      valueNotifierStopSendingMorceau.value = true; //si il y a un envoit, je l'arrete / sinon, ca change rien
      onDisconnect();
      yield FlyKeysDeviceDisconnectedState();
    }

    if (event is QuitMusicEvent) {
      valueNotifierStopSendingMorceau?.value = true; //si il y a un envoit, je l'arrete / sinon, ca change rien
      if (isPlaying)
        await bluetoothRepository.stop();
      yield InitialBluetoothState();
    }

    //sending morceau
    if (event is SendMorceauEvent) {
      yield* reactToSendMorceauEvent(event);
    }

    if (event is StopSendingMorceauEvent) {
      valueNotifierStopSendingMorceau.value = true;
    }

    //interact with morceau
    if (event is SendSpeedEvent) {
      bluetoothRepository.sendDelay(event.speed);
      return;
    }

    if (event is AskToWaitForTheUserInputEvent){
    	bluetoothRepository.askToWaitForUserInputInModeApprentissage();
    	return;
		}

		if (event is AskToNotWaitForTheUserInputEvent){
			bluetoothRepository.askToNotWaitForUserInputInModeApprentissage();
			return;
		}

    if (event is SendNewTickEvent) {
      bool res = await bluetoothRepository.sendANewTick(event.tick);
      if (!res) {
        yield TickNotPossibleState(new DateTime.now().millisecondsSinceEpoch);
        if (isPlaying) {
          await bluetoothRepository.stop();
          isPlaying = false;
        }
        valueNotifierUpdateTickInPage.value = true;
        updateTimeBarWithLastSecondsSentbyTheDevice();
      } else
        valueNotifierUpdateTickInPage.value = true;
      return;
    }

    if (event is PlayEvent) {
      yield LoadingCommandMusicState();
      await bluetoothRepository.play();
      isPlaying = true;
      yield PlayingMusicState();
      await bluetoothRepository
          .subscribeToTickCharacteristic(valueNotifierActualTick);
      updateDurationListenerWhenTickListenerUpdate();
    }

    if (event is StopEvent) {
      yield LoadingCommandMusicState();
      await bluetoothRepository.stop();
      isPlaying = false;
      yield StoppedMusicState();
    }

    if (event is MorceauIsFinishEvent) {
      yield StoppedMusicState();
      isPlaying = false;
    }


    //other modes!!

    if (event is LightningShowEvent){
      yield LoadingCommandMusicState();
      await bluetoothRepository.lightningShow();
      yield LightningShowModeState();
    }

    //private events that are send in this class

    //private event that is send when the stream in reactToSendMorceauEvent have a new value
    if (event is _SendingMorceauStepEvent) {
      yield SendingMorceauState(event.progress);
    }

    if (event is _SendingMorceauFinishEvent) {
      yield MorceauSentState();
    }
  }

  Stream<MyBluetoothState> reactToSendMorceauEvent(
      SendMorceauEvent event) async* {
    valueNotifierStopSendingMorceau.value =
        false; //j'indique que je ne veux pas arrêter l'envoi du morceau
    yield FetchingMorceauState();
    File parsedFile = await ParsedFileRepository.fetchParsedFile(event.id);

    if (valueNotifierStopSendingMorceau.value) {
      yield SendingMorceauAbortedState();
      return;
    }

    yield DecodageMorceauState();
    MidiReader midiReader = MidiReader(dataFile: parsedFile);
    List<Note> listNotes = await midiReader.readDataFile();
    nbDeTickMax = midiReader.getNbDeTickDuMorceau();

    if (valueNotifierStopSendingMorceau.value) {
      yield SendingMorceauAbortedState();
      return;
    }

    yield TraitementMorceauState();
    List<int> trameToSend =
        bluetoothRepository.createTrameFromListeNote(listNotes);

    if (valueNotifierStopSendingMorceau.value) {
      yield SendingMorceauAbortedState();
      return;
    }

    yield SendingMorceauState(0);

    streamSubscription = bluetoothRepository
        .envoiLaTrameMorceau(trameToSend, valueNotifierStopSendingMorceau)
        .listen((value) {
      dev.log("Sending in progress : " + value.toString() + "/" + trameToSend.length.toString(), name: "New event in bluetooth bloc");
      add(_SendingMorceauStepEvent(
          (value.toDouble() / trameToSend.length.toDouble())));
    });

    streamSubscription.onDone(() {
      add(_SendingMorceauFinishEvent());
    });

    return;
  }

  /**
	 *  Des que ActualTick change, j'update ActualTime pour que la page puisse mettre à jour sa timeBar
	 */
  void updateDurationListenerWhenTickListenerUpdate() {
    valueNotifierActualTick.addListener(() {
      //je dois diviser par 1000 la speed_x1 car elle est en ms et je la veux en s

      dev.log("Value changed : " + valueNotifierActualTick.value.toString(),name:"valueNotifierActualTick");

      if (valueNotifierActualTick.value < 0) {
        //Le morceau est finis!
        add(MorceauIsFinishEvent());
      } else {
        int nbSeconds =
            (valueNotifierActualTick.value * speed_x1 / 1000).floor();
        if (valueNotifierUpdateTickInPage.value) {
          print("#35 j'update le value notifier avec $nbSeconds");
          valueNotifierActualDuration.value = new Duration(seconds: nbSeconds);
          lastSecondSentToMusicPage = nbSeconds;
        }
      }
    });
  }

  void setSpeedX1(double speed) {
    speed_x1 = speed;
  }

  void stopSendingMorceau() {
    valueNotifierStopSendingMorceau.value = true;
  }

  Duration getDurationOfTheMorceau() {
    int nbSeconds = (nbDeTickMax * speed_x1 / 1000).floor();
    Duration duration = new Duration(seconds: nbSeconds);
    return duration;
  }

  void setValueNotifierActualDuration(ValueNotifier<Duration> valueNotifierActualDuration) {
    this.valueNotifierActualDuration = valueNotifierActualDuration;
  }

  void setValueNotifierUpdateTickInPage(ValueNotifier<bool> valueNotifierUpdateTickInPage) {
    this.valueNotifierUpdateTickInPage = valueNotifierUpdateTickInPage;
  }

  /**
	 * Lorsque je bouge la time bar, je n'ai plus la réelle seconde à laquelle je suis dans le morceau.
	 * C'est pour cela que cette fonction me renvoi cette info
	 * Je l'utilise lorsque la seconde à laquelle j'essaie d'aller n'est pas chargé dans le device (Je n'ai pas envoyé tout le morceau)
	 */
  void updateTimeBarWithLastSecondsSentbyTheDevice() {
    if (valueNotifierUpdateTickInPage.value) {
      if (lastSecondSentToMusicPage==null)
        lastSecondSentToMusicPage = 0;
      valueNotifierActualDuration.value = new Duration(seconds: lastSecondSentToMusicPage);
    }
  }

  void onDisconnect() {
    dispose();
  }

  void dispose() {
    dev.log("dispose bluetooth bloc", name: "Bluetooth bloc");
    flutterBlue.stopScan();
    bluetoothRepository?.dispose();
    valueNotifierOnDisconnect?.removeListener(() {});
    valueNotifierActualTick?.removeListener(() {});
    streamSubscription?.cancel();
  }
}

/****************     PRIVATE EVENTS    ******************/

class _SendingMorceauStepEvent extends BluetoothEvent {
  final double progress;

  _SendingMorceauStepEvent(this.progress);

  @override
  List<Object> get props => [progress];
}

/**
 * Est appele lorsque l'envoi est finis ou lorsque on la stoppé
 */
class _SendingMorceauFinishEvent extends BluetoothEvent {
  _SendingMorceauFinishEvent();

  @override
  List<Object> get props => [];
}
