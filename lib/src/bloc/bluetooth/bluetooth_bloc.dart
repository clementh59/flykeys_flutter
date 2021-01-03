import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flykeys/src/model/midiReader/note.dart';
import 'package:flykeys/src/model/midiReader/parsedFileReader.dart';
import 'package:flykeys/src/repository/bluetooth_constants.dart';
import 'package:flykeys/src/repository/bluetooth_repository.dart';
import 'package:flykeys/src/repository/parsed_file_repository.dart';
import 'package:flykeys/src/utils/strings.dart';
import 'package:flykeys/src/utils/utils.dart';

import 'bloc.dart';

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
      valueNotifierUpdateTickInPage; //always true except when the user slide the time slide bar and we don't want the slider to update
  int nbDeTickMax; //le nb de tick total sert dans le calcul du temps actuel lorsque l'on recoit le tick actuel
  double
      speedX1; //la speedX1 sert dans le calcul du temps actuel lorsque l'on recoit le tick actuel
  bool isPlaying = false;
  int lastSecondSentToMusicPage; //me sert pour updateTimeBarWithLastSecondsSentbyTheDevice()

  // To know which note has been pushed
  ValueNotifier<int> valueNotifierNotePushed;

  BluetoothBloc(this.bluetoothRepository) {
    flutterBlue = FlutterBlue.instance;
  }

  @override
  MyBluetoothState get initialState => InitialBluetoothState();

  void initEverythingLearningMode() {
    valueNotifierStopSendingMorceau = ValueNotifier(false);
    valueNotifierActualTick = ValueNotifier(0);
    speedX1 = 0;
    nbDeTickMax = 0;
    isPlaying = false;
  }

  @override
  Stream<MyBluetoothState> mapEventToState(
    BluetoothEvent event,
  ) async* {
    dev.log("new event : $event", name: "Bluetooth bloc");
    print("Bluetooth bloc : $event");

    //region Connection / disconnection
    if (event is FindFlyKeysDevice) {
      valueNotifierOnDisconnect = ValueNotifier(false);

      if (bluetoothRepository.tickBluetoothCharacteristic != null &&
          bluetoothRepository.tickBluetoothCharacteristic != null) {
        yield BluetoothIsSetUpState();
        return;
      }

      yield SearchingForFlyKeysDeviceState();
      FlutterBlue.instance.startScan(
          timeout: Duration(seconds: BluetoothConstants.SCAN_TIMEOUT));
      bool deviceFound =
          await bluetoothRepository.findFlyKeysDevice(flutterBlue);
      if (!deviceFound) {
        yield FlyKeysDeviceNotFoundState();
        return;
      }
      yield FlyKeysDeviceFoundState();
      bool connected =
          await bluetoothRepository.connectToDevice(valueNotifierOnDisconnect);
      valueNotifierOnDisconnect.addListener(valueNotifierOnDisconnectListener);
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
      valueNotifierStopSendingMorceau?.value =
          true; //si il y a un envoit, je l'arrete / sinon, ca change rien
      onDisconnect();
      yield FlyKeysDeviceDisconnectedState();
      return;
    }
    //endregion

    //region Sending morceau
    if (event is SendMorceauEvent) {
      yield* reactToSendMorceauEvent(event);
      return;
    }

    if (event is StopSendingMorceauEvent) {
      valueNotifierStopSendingMorceau.value = true;
      return;
    }
    //endregion

    //region Interact with morceau
    if (event is SendSpeedEvent) {
      await bluetoothRepository.sendDelay(event.speed);
      return;
    }

    if (event is EnvoiMesCouleursEvent) {
      await bluetoothRepository.sendColors(); // si je le met
      return;
    }

    if (event is AskToWaitForTheUserInputEvent) {
      await bluetoothRepository.askToWaitForUserInputInModeApprentissage();
      return;
    }

    if (event is AskToNotWaitForTheUserInputEvent) {
      await bluetoothRepository.askToNotWaitForUserInputInModeApprentissage();
      return;
    }

    if (event is ShowMeTheTwoHands) {
      await bluetoothRepository.showTheTwoHands();
      return;
    }

    if (event is ShowMeOnlyTheLeftHand) {
      await bluetoothRepository.showOnlyTheLeftHand();
      return;
    }

    if (event is ShowMeOnlyTheRightHand) {
      await bluetoothRepository.showOnlyTheRightHand();
      return;
    }

    if (event is SendNewTickEvent) {
      bool res = await bluetoothRepository.sendANewTick(event.tick);
      if (!res) {
        yield TickNotPossibleState(new DateTime.now().millisecondsSinceEpoch);
        if (isPlaying) {
          await bluetoothRepository.pause();
          isPlaying = false;
        }
        valueNotifierUpdateTickInPage.value = true;
        updateTimeBarWithLastSecondsSentByTheDevice();
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
          .subscribeWhenTickIsUpdated(valueNotifierActualTick);
      updateDurationListenerWhenTickListenerUpdate();
      return;
    }

    if (event is StopEvent) {
      yield LoadingCommandMusicState();
      await bluetoothRepository.pause();
      isPlaying = false;
      yield StoppedMusicState();
      return;
    }

    if (event is MorceauIsFinishEvent) {
      yield StoppedMusicState();
      isPlaying = false;
      return;
    }
    //endregion

    //region Quit morceau
    if (event is QuitMusicEvent) {
      valueNotifierStopSendingMorceau?.value =
      true; //si il y a un envoit, je l'arrete / sinon, ca change rien
      if (isPlaying) await bluetoothRepository.pause();
      yield InitialBluetoothState();
      return;
    }
    //endregion

    //region Other Modes (Lightning show, Set up limit of keyboard, ...)
    if (event is LightningShowEvent) {
      await bluetoothRepository.lightningShow();
      yield LightningShowModeState();
      return;
    }

    if (event is SetUpMidiKeyboardLimitEvent) {
			valueNotifierNotePushed = event.valueNotifierNotePushed;
      await bluetoothRepository.setUpMidiKeyboardLimit();
      await bluetoothRepository
          .subscribeWhenNoteIsPushed(valueNotifierNotePushed);
      yield SetLimitOfKeyboardState();
      return;
    }

    if (event is SetUpAcousticKeyboardLimitEvent) {
      await bluetoothRepository.lightLeds([0,1,2,3,4,5,6,7]);
      yield SetLimitOfKeyboardState();
      return;
    }
    //endregion

    //region Control leds events
    if (event is LightLedsEvent) {
      if (event.clearLeds)
        await bluetoothRepository.clearLeds();
      await bluetoothRepository.lightLeds(event.ledsToLight);
    }

		if (event is ClearLedsEvent) {
			await bluetoothRepository.clearLeds();
		}
    //endregion

    //region Private events
    //private event that is send when the stream in reactToSendMorceauEvent have a new value
    if (event is _SendingMorceauStepEvent) {
      yield SendingMorceauState(event.progress);
    }

    if (event is _SendingMorceauFinishEvent) {
      yield MorceauSentState();
    }
    //endregion
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
    ParsedFileReader midiReader = ParsedFileReader(dataFile: parsedFile);
    Map pianoInfo = await Utils.getMapFromSharedPreferences(Strings.PIANO_INFOS_SHARED_PREFS);
    List<Note> listNotes = await midiReader.readDataFile();
    nbDeTickMax = midiReader.getNbDeTickDuMorceau();

    if (valueNotifierStopSendingMorceau.value) {
      yield SendingMorceauAbortedState();
      return;
    }

    yield TraitementMorceauState();
    List<int> trameToSend =
        bluetoothRepository.createTrameFromListeNote(listNotes, pianoInfo['leftLimit'], pianoInfo['rightLimit']);

    if (valueNotifierStopSendingMorceau.value) {
      yield SendingMorceauAbortedState();
      return;
    }

    yield SendingMorceauState(0);

    streamSubscription = bluetoothRepository
        .envoiLaTrameMorceau(trameToSend, valueNotifierStopSendingMorceau)
        .listen((value) {
      dev.log(
          "Sending in progress : " +
              value.toString() +
              "/" +
              trameToSend.length.toString(),
          name: "New event in bluetooth bloc");
      add(_SendingMorceauStepEvent(
          (value.toDouble() / trameToSend.length.toDouble())));
    });

    streamSubscription.onDone(() {
      add(_SendingMorceauFinishEvent());
    });

    return;
  }

	/// Des que ActualTick change, j'update ActualTime pour que la page puisse mettre à jour sa timeBar
  void updateDurationListenerWhenTickListenerUpdate() {
    valueNotifierActualTick.addListener(valueNotifierActualTickListener);
  }

  void stopSendingMorceau() {
    valueNotifierStopSendingMorceau.value = true;
  }

  Duration getDurationOfTheMorceau() {
    int nbSeconds = (nbDeTickMax * speedX1 / 1000).floor();
    Duration duration = new Duration(seconds: nbSeconds);
    return duration;
  }

  /// Lorsque je bouge la time bar, je n'ai plus la réelle seconde à laquelle je suis dans le morceau.
  /// C'est pour cela que cette fonction me renvoi cette info
  /// Je l'utilise lorsque la seconde à laquelle j'essaie d'aller n'est pas chargé dans le device (Je n'ai pas envoyé tout le morceau)
  void updateTimeBarWithLastSecondsSentByTheDevice() {
    if (valueNotifierUpdateTickInPage.value) {
      if (lastSecondSentToMusicPage == null) lastSecondSentToMusicPage = 0;
      valueNotifierActualDuration.value =
      new Duration(seconds: lastSecondSentToMusicPage);
    }
  }

  //region Setters
  void setSpeedX1(double speed) {
    speedX1 = speed;
  }

  void setValueNotifierActualDuration(
      ValueNotifier<Duration> valueNotifierActualDuration) {
    this.valueNotifierActualDuration = valueNotifierActualDuration;
  }

  void setValueNotifierUpdateTickInPage(
      ValueNotifier<bool> valueNotifierUpdateTickInPage) {
    this.valueNotifierUpdateTickInPage = valueNotifierUpdateTickInPage;
  }
  //endregion

  //region Value notifier handlers
  valueNotifierOnDisconnectListener() {
    dev.log("Value changed : " + valueNotifierOnDisconnect.value.toString(),
        name: "valueNotifierOnDisconnect");
    if (valueNotifierOnDisconnect.value == true) {
      print("#15482 : disconnect!!!!!");
      add(DisconnectEvent());
    }
  }

  valueNotifierActualTickListener() {
		//je dois diviser par 1000 la speed_x1 car elle est en ms et je la veux en s

		dev.log("Value changed : " + valueNotifierActualTick.value.toString(),
			name: "valueNotifierActualTick");

		if (valueNotifierActualTick.value < 0) {
			//Le morceau est finis!
			add(MorceauIsFinishEvent());
		} else {
			int nbSeconds =
			(valueNotifierActualTick.value * speedX1 / 1000).floor();
			if (valueNotifierUpdateTickInPage.value) {
				valueNotifierActualDuration.value = new Duration(seconds: nbSeconds);
				lastSecondSentToMusicPage = nbSeconds;
			}
		}
	}
  //endregion

  //region Stop properly
  void stopListeningToNotePushed() {
  	bluetoothRepository.stopListeningToNotePushed();
	}

  void onDisconnect() {
    dispose();
  }

  void dispose() {
    dev.log("dispose bluetooth bloc", name: "Bluetooth bloc");
    flutterBlue.stopScan();
    bluetoothRepository?.dispose();
    valueNotifierOnDisconnect?.removeListener(valueNotifierOnDisconnectListener);
    valueNotifierActualTick?.removeListener(valueNotifierActualTickListener);
    streamSubscription?.cancel();
  }
//endregion
}

//region Private events
class _SendingMorceauStepEvent extends BluetoothEvent {
  final double progress;

  _SendingMorceauStepEvent(this.progress);

  @override
  List<Object> get props => [progress];
}

///Est appele lorsque l'envoi est finis ou lorsque on la stoppé
class _SendingMorceauFinishEvent extends BluetoothEvent {
  _SendingMorceauFinishEvent();

  @override
  List<Object> get props => [];
}
//endregion
