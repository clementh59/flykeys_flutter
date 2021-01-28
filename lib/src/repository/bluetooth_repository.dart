import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flykeys/src/model/midiReader/note.dart';
import 'package:flykeys/src/repository/bluetooth_constants.dart';
import 'package:flykeys/src/utils/constants.dart';
import 'package:flykeys/src/utils/strings.dart';
import 'package:flykeys/src/utils/utils.dart';

class BluetoothRepository {
  //region Variables
  BluetoothDevice flyKeysDevice;
  BluetoothCharacteristic mainBluetoothCharacteristic;
  BluetoothCharacteristic tickBluetoothCharacteristic;
  StreamSubscription streamSubscriptionTickListening;
  StreamSubscription streamSubscriptionNotePushedListening;
  StreamSubscription deviceStateSubscription;
  List<int> bytesSent = [];

  //endregion

  //region Trame morceau
  /// Create a List of byte that can be understood by the esp32 from a
  /// list of note
  /// [leftLimit] the first key of the user's piano
  List<int> createTrameFromListeNote(List<Note> listNotes, int leftLimit, int rightLimit) {
    List<Note> notesDejaEnvoyees = [];
    List<int> tramesAEnvoyer = [];
    int actualTick = -8;
    Note n;

    List<Note> lastKeysOn = List(128); //Pour savoir si on doit appuyer sur une touche deux fois alors que l'on voit juste deux LEDs
    List<Note> actualKeysOn; //Pour savoir si on doit appuyer sur une touche deux fois alors que l'on voit juste deux LEDs

    listNotes.forEach((element) {
      element.key -= (leftLimit);
    });

    while (listNotes.length > 0) {
      lastKeysOn = actualKeysOn;
      actualKeysOn = List(128);
      for (int i = 0; i < min(listNotes.length, 250); i++) {
        n = listNotes[i];

        // To know if the color is white or black, we need to get the value of the key before removing the leftLimit!
        int colorOffset = Utils.isWhiteKey(n.getKey() + leftLimit) ? 0 : BluetoothConstants.lastIndexOfColorDefine;

        if (n.getTimeOff() < actualTick) {
          //On ne voit plus la note
          notesDejaEnvoyees.add(n);
        } else {
          //La note est visible ou le sera encore, on continue de la traiter
          if (n.getTimeOn() < actualTick && n.getTimeOff() >= actualTick) {
            // alors c'est visible

            // With the midi offset of the piano, it is possible that some keys are <0.
            // If it's the case, it will throw an exception we can't send negative values via BLE here
            // And of course, if the key is higher than the size of the piano, we don't show it
            if (n.getKey() < 0 || n.getKey() > (rightLimit-leftLimit)) {
              // I do nothing -> I don't want to show it
              // I just wait for them to be remove by the check above
              continue;
            } else if (n.isReleaseAndPush()) {
              tramesAEnvoyer.add(n.key); //je la met en rouge
              tramesAEnvoyer.add(BluetoothConstants.mapStringColorToCode[n.getColor()] + colorOffset);
            } else if (lastKeysOn[n.getKey()] != null && lastKeysOn[n.getKey()] != n && lastKeysOn[n.getKey()].getColor() == n.getColor()) {
              tramesAEnvoyer.add(n.key); //je la met en rouge
              n.setIsReleaseAndPushColor();
              tramesAEnvoyer.add(BluetoothConstants.mapStringColorToCode[n.getColor()] + colorOffset);
            } else {
              tramesAEnvoyer.add(n.key); //Je l'envoi simplement
              tramesAEnvoyer.add(BluetoothConstants.mapStringColorToCode[n.getColor()] + colorOffset); //avec sa couleur
            }
            actualKeysOn[n.getKey()] = n;
          }
        }
      }

      tramesAEnvoyer.add(BluetoothConstants.CODE_NEW_TICK); //AFFICHAGE
      actualTick++;
      for (int i = 0; i < notesDejaEnvoyees.length; i++) listNotes.remove(notesDejaEnvoyees[i]);
      notesDejaEnvoyees.clear();
    }
    return tramesAEnvoyer;
  }

  /// Send a morceau to the esp32
  ///
  /// The [tramesAEnvoyer] needs to be a list of int. I reccomand you to create
  /// it with createTrameFromListeNote()
  ///
  /// It can be stopped during its process by setting the value of
  /// [valueNotifierStopSending] to true. The process will be stopped between
  /// two frames to send.
  ///
  /// The frame is cut into smaller frame to send it.
  /// Each time a smaller frame is sent, the function notifies it by sending the
  /// progress by the stream. It sends the index in the [tramesAEnvoyer] that
  /// it sends.
  ///
  /// For example, if your frame's length is 1000, and the smaller frames's
  /// length are 150, the function will send via the stream :
  /// - 150, once it will have sent the first frame
  /// - 300, once it will have sent the second frame
  /// ...
  ///
  /// [leftLimit] is the first key of the piano
  Stream<int> envoiLaTrameMorceau(List<int> tramesAEnvoyer, ValueNotifier valueNotifierStopSending, int leftLimit) async* {
    bytesSent = [];
    List<int> trameDeMaxMTU =
        []; // On envoi les bytes BluetoothConstants.MTU_SIZE par BluetoothConstants.MTU_SIZE, ce tableau les contient temporairement à chaque fois
    int actualIndextrameDeMaxMTU = 0; // Pour se repérer dans l'index du tableau de trame de BluetoothConstants.MTU_SIZE où on est

    await mainBluetoothCharacteristic
        .write([BluetoothConstants.CODE_MODE_APPRENTISSAGE_ENVOI_DU_MORCEAU, leftLimit]); //Je dis à l'esp que je lui envoi le morceau

    for (int i = 0; i < tramesAEnvoyer.length; i++) {
      trameDeMaxMTU.add(tramesAEnvoyer[i]);

      if (actualIndextrameDeMaxMTU == BluetoothConstants.MTU_SIZE || i == tramesAEnvoyer.length - 1) {
        //Si la trame est pleine, ou si on vient de remplir la dernière trame à envoyer
        actualIndextrameDeMaxMTU = 0;
        await envoiLaTrameMTU(trameDeMaxMTU, mainBluetoothCharacteristic); // J'envoi la trame
        bytesSent.addAll(trameDeMaxMTU);
        trameDeMaxMTU = []; //sinon la dernière trame peut contenir des valeurs indésirables
        yield i;
      } else
        actualIndextrameDeMaxMTU++;

      if (valueNotifierStopSending.value == true) {
        //j'arrete d'envoyer le morceau
        return;
      }
    }

    return;
  }

  //endregion

  //region Connection
  /// return true and assign the device to the global field [flyKeysDevice]
  /// if it finds the device - false otherwise
  Future<bool> findFlyKeysDevice(FlutterBlue flutterBlue) async {
    dev.log('begin', name: "findFlyKeysDevice");

    dev.log('fetching BLUETOOTH connected devices', name: "findFlyKeysDevice");
    List<BluetoothDevice> connectedDevices = await flutterBlue.connectedDevices;

    dev.log('checking if connected device list contains flykeys device', name: "findFlyKeysDevice");
    for (BluetoothDevice device in connectedDevices) {
      if (isFlyKeysDevice(device)) {
        flutterBlue.stopScan();
        return true;
      }
    }

    dev.log('checking through scan results', name: "findFlyKeysDevice");

    BluetoothDevice flyKeysDevice;

    bool isScanning = true;
    bool isCheckingResult = false;

    while (isScanning) {
      if (!isCheckingResult) {
        isCheckingResult = true;
        flutterBlue.scanResults.firstWhere((list) {
          for (ScanResult scanResult in list) {
            if (isFlyKeysDevice(scanResult.device)) {
              flyKeysDevice = scanResult.device;
            }
          }
          isCheckingResult = false;
          return true;
        });

        if (flyKeysDevice != null) {
          flutterBlue.stopScan();
          return true;
        }
      }

      await new Future.delayed(const Duration(seconds: 1));

      isScanning = await flutterBlue.isScanning.first;

      if (isScanning == null) isScanning = false;
    }

    dev.log('end', name: "findFlyKeysDevice");

    return false;
  }

  /// return true if [bluetoothDevice] is a Flykeys device
  bool isFlyKeysDevice(BluetoothDevice bluetoothDevice) {
    if (bluetoothDevice.name == "FLYKEYS") {
      dev.log('FlyKeys device found', name: "findFlyKeysDevice");
      // todo: try to remove since I do this asignment in the parent function...
      flyKeysDevice = bluetoothDevice;
      return true;
    }
    return false;
  }

  /// Récupère les deux characteristiques nécessaires et renvoie true si elles
  /// sont récupérées / renvoi false sinon
  Future<bool> hasTheRightCharacteristics() async {
    List<BluetoothService> services = await flyKeysDevice.discoverServices();

    for (BluetoothService service in services) {
      var characteristics = service.characteristics;
      for (BluetoothCharacteristic c in characteristics) {
        if (c.uuid.toString() == BluetoothConstants.uuidOfMainCommunication) {
          //todo:generate a new one for my purpose on a website generator
          mainBluetoothCharacteristic = c;
          dev.log("found the mainBluetoothCharacteristic", name: "hasTheGoodCharacteristics");
        } else if (c.uuid.toString() == BluetoothConstants.uuidOfTickCommunication) {
          tickBluetoothCharacteristic = c;
          dev.log("found the tickBluetoothCharacteristic", name: "hasTheGoodCharacteristics");
        }
      }
    }

    if (mainBluetoothCharacteristic != null && tickBluetoothCharacteristic != null) {
      return true;
    }
    return false;
  }

  /// Connect to the flykeys device. To be called, the [flyKeysDevice] need
  /// to contain a FlyKeys device. It can be done by calling FindFlyKeysDevice()
  ///
  /// The value notifier [onDisconnectNotifier] will be notified when the esp32
  /// will be disconnected from the esp32
  Future<bool> connectToDevice(ValueNotifier onDisconnectNotifier) async {
    try {
      await flyKeysDevice.connect();
      subscribeToConnectionStateChanges(onDisconnectNotifier);
      return true;
    } catch (id) {
      print("error : " + id.toString());
      if (id.toString() == "PlatformException(already_connected, connection with device already exists, null)") {
        subscribeToConnectionStateChanges(onDisconnectNotifier);
        return true; //je suis déjà connecté
      }
      return false;
    }
  }

  //endregion

  //region Send to esp32
  /// send the code that means PLAY to the esp32
  Future<void> play() async {
    await mainBluetoothCharacteristic.write([BluetoothConstants.CODE_PLAY]);
  }

  /// send the code that means PAUSE to the esp32
  Future<void> pause() async {
    await mainBluetoothCharacteristic.write([BluetoothConstants.CODE_PAUSE]);
  }

  /// send the code that means START THE LIGHTNING SHOW MODE to the esp32
  /// [firstKey] the first key of the piano (e.g 21)
  Future<void> lightningShow(int firstKey) async {
    await mainBluetoothCharacteristic.write([BluetoothConstants.CODE_MODE_LIGHTNING_SHOW, firstKey]); // PLAY
  }

  /// send the code that means START THE SET UP MIDI LIMIT to the esp32
  Future<void> setUpMidiKeyboardLimit() async {
    await mainBluetoothCharacteristic.write([BluetoothConstants.CODE_SET_UP_MIDI_KEYBOARD_LIMIT]); // PLAY
  }

  /// send the delay [delayDouble] to the esp32
  Future<void> sendDelay(double delayDouble) async {
    // if the delay to send is 10011100010
    // I need to cut it in two byte
    // 11100010 and then 100
    int delay = delayDouble.floor();
    int virguleFois100 = ((delayDouble - delay) * 100).round();

    ByteData byteData = new ByteData(2);
    byteData.setInt16(0, delay);
    //J'envoi les deux premier int qui correspondent à la partie entière de la vitesse puis une nombre de 0 à 99 qui correspond à la virgule
    await mainBluetoothCharacteristic.write([BluetoothConstants.CODE_DELAY, byteData.getUint8(1), byteData.getUint8(0), virguleFois100]); // PLAY
  }

  Future<void> sendColors() async {
    Color MD = await Utils.readColorFromSharedPreferences(Strings.COLOR_MD_SHARED_PREFS, Constants.DefaultMDColor);
    Color MG = await Utils.readColorFromSharedPreferences(Strings.COLOR_MG_SHARED_PREFS, Constants.DefaultMGColor);
    await mainBluetoothCharacteristic.write([
      BluetoothConstants.CODE_I_SEND_COLOR,
      BluetoothConstants.mapStringColorToCode['MD'],
      MD.red,
      MD.green,
      MD.blue,
      MD.red,
      MD.green,
      MD.blue,
      MD.red,
      MD.green,
      MD.blue,
      MD.red,
      MD.green,
      MD.blue,
      MD.red,
      MD.green,
      MD.blue,
      MD.red,
      MD.green,
      MD.blue,
      MD.red,
      MD.green,
      MD.blue,
      MD.red,
      MD.green,
      MD.blue,
      BluetoothConstants.mapStringColorToCode['MD_R&P'],
      189,
      255,
      177,
      189,
      255,
      177,
      189,
      255,
      177,
      189,
      255,
      177,
      189,
      255,
      177,
      189,
      255,
      177,
      189,
      255,
      177,
      189,
      255,
      177,
      BluetoothConstants.mapStringColorToCode['MG'],
      MG.red,
      MG.green,
      MG.blue,
      MG.red,
      MG.green,
      MG.blue,
      MG.red,
      MG.green,
      MG.blue,
      MG.red,
      MG.green,
      MG.blue,
      MG.red,
      MG.green,
      MG.blue,
      MG.red,
      MG.green,
      MG.blue,
      MG.red,
      MG.green,
      MG.blue,
      MG.red,
      MG.green,
      MG.blue,
      BluetoothConstants.mapStringColorToCode['MG_R&P'],
      255,
      191,
      28,
      255,
      191,
      28,
      255,
      191,
      28,
      255,
      191,
      28,
      255,
      191,
      28,
      255,
      191,
      28,
      255,
      191,
      28,
      255,
      191,
      28
    ]);
  }

  /// Utile pour le mode apprentissage, si je dois attendre que
  /// l'utilisateur appuie sur une touche pour faire défiler
  Future<void> askToWaitForUserInputInModeApprentissage() async {
    await mainBluetoothCharacteristic.write([BluetoothConstants.CODE_SET_I_HAVE_TO_WAIT_FOR_USER_INPUT]);
  }

  /// Utile pour le mode apprentissage, si je ne dois pas attendre que
  /// l'utilisateur appuie sur une touche pour faire défiler
  Future<void> askToNotWaitForUserInputInModeApprentissage() async {
    await mainBluetoothCharacteristic.write([BluetoothConstants.CODE_SET_I_DONT_HAVE_TO_WAIT_FOR_USER_INPUT]);
  }

  /// Si je souhaite que l'objet affiche uniquement la main droite du morceau
  Future<void> showOnlyTheRightHand() async {
    await mainBluetoothCharacteristic.write(BluetoothConstants.CODES_SHOW_ONLY_THE_RIGHT_HAND);
  }

  /// Si je souhaite que l'objet affiche uniquement la main gauche du morceau
  Future<void> showOnlyTheLeftHand() async {
    await mainBluetoothCharacteristic.write(BluetoothConstants.CODES_SHOW_ONLY_THE_LEFT_HAND);
  }

  /// Si je souhaite que l'objet affiche les deux mains du morceau
  Future<void> showTheTwoHands() async {
    await mainBluetoothCharacteristic.write(BluetoothConstants.CODES_SHOW_THE_TWO_HANDS);
  }

  /// Je demande à l'esp32 d'allumer une liste de LEDs
  Future<void> lightLeds(List<int> ledsToLight) async {
    List<int> trame = [BluetoothConstants.CODE_LIGHT_LEDS];

    ledsToLight.forEach((element) {
      ByteData byteData = new ByteData(2);
      byteData.setInt16(0, element);
      trame.add(byteData.getUint8(1));
      trame.add(byteData.getUint8(0));
    });

    if (trame.length >= BluetoothConstants.MTU_SIZE) {
      print('La liste de LEDs à allumer est trop longue!');
      return;
    }
    await mainBluetoothCharacteristic.write(trame);
  }

  /// I ask the esp32 to update the brightness of leds
  /// [brightness] needs to be between 0 and 255
  Future<void> updateBrightness(int brightness) async {
    await mainBluetoothCharacteristic.write([BluetoothConstants.CODE_CHANGE_BRIGHTNESS, brightness]);
  }

  /// Je demande à l'esp32 d'éteindre toute les LEDs
  Future<void> clearLeds() async {
    await mainBluetoothCharacteristic.write([BluetoothConstants.CODE_CLEAR_LEDS]);
  }

  Future<Null> envoiLaTrameMTU(List<int> trame, BluetoothCharacteristic bluetoothCharacteristicToSend) async {
    await bluetoothCharacteristicToSend.write(trame);
  }

  /// send to the esp32 the [tick] passed in parameter
  ///
  /// return true if it succeed
  /// false otherwise
  Future<bool> sendANewTick(int tick) async {
    int index = findTheIndexCorrespondToTheTick(tick);

    if (index == -1) {
      return false;
    }

    ByteData byteData = new ByteData(4);
    byteData.setInt32(0, index);
    ByteData byteData2 = new ByteData(4);
    byteData2.setInt32(0, tick);

    print("send new tick : j'envoi tick=$tick et index=$index");

    await envoiLaTrameMTU([
      byteData.getUint8(3),
      byteData.getUint8(2),
      byteData.getUint8(1),
      byteData.getUint8(0),
      byteData2.getUint8(3),
      byteData2.getUint8(2),
      byteData2.getUint8(1),
      byteData2.getUint8(0)
    ], tickBluetoothCharacteristic);
    return true;
  }

  //endregion

  //region Stream subscription
  /// The value notifier [onDisconnectNotifier] will be notified when the esp32
  /// will be disconnected from the esp32
  void subscribeToConnectionStateChanges(ValueNotifier onDisconnectNotifier) {
    deviceStateSubscription?.cancel();
    deviceStateSubscription = flyKeysDevice.state.listen((s) {
      print("#18 New state flykeys device : $s");
      if (s == BluetoothDeviceState.disconnected) {
        onDisconnectNotifier.value = true;
      }
    });
  }

  /// [valueNotifierActualTick] sera mis à jour à chaque fois que l'esp32 avance
  /// d'un tick dans le morceau
  ///
  /// Pour ce faire, la fonction listen to [tickBluetoothCharacteristic] et
  /// met à jour [valueNotifierActualTick] en fonction de la nouvelle valeur.
  /// Si la valeur dépasse un certain seul, [valueNotifierActualTick] sera mis à
  /// -1, ce qui signifie que le morceau doit être considéré comme finis.
  Future<int> subscribeWhenTickIsUpdated(ValueNotifier valueNotifierActualTick) async {
    await tickBluetoothCharacteristic.setNotifyValue(true);
    streamSubscriptionTickListening?.cancel();
    streamSubscriptionTickListening = tickBluetoothCharacteristic.value.listen((event) {
      dev.log("Value changed : " + tickBluetoothCharacteristic.value.toString(), name: "tickBluetoothCharacteristic");

      if (event.length == 4) {
        int value = event[0] + event[1] * 256 + event[2] * 256 * 256 + event[3] * 256 * 256 * 256;

        if (value > 1000000) {
          valueNotifierActualTick.value = -1; //Je notifie que le morceau est finis
        } else
          valueNotifierActualTick.value = value;
      }
    });

    return 0;
  }

  /// [valueNotifierNotePushed] sera mis à jour à chaque fois que l'esp32 indique
  /// une note pushed
  ///
  /// Pour ce faire, la fonction listen to [tickBluetoothCharacteristic] et
  /// met à jour [valueNotifierNotePushed] en fonction de la nouvelle valeur.
  Future<int> subscribeWhenNoteIsPushed(ValueNotifier valueNotifierNotePushed) async {
    await tickBluetoothCharacteristic.setNotifyValue(true);
    streamSubscriptionNotePushedListening?.cancel();
    streamSubscriptionNotePushedListening = tickBluetoothCharacteristic.value.listen((event) {

      if (event.length == 1) {
        // I receive a Note Pushed info
        int value = event[0];
        valueNotifierNotePushed.value = value;
      }
    });

    return 0;
  }

  void stopListeningToNotePushed() {
    try {
      streamSubscriptionNotePushedListening?.cancel();
    } catch (e) {}
  }

  //endregion

  //region Utils
  /// return the first index in the [bytesSent] corresponding to the [tickToGo]
  /// return -1 if none index corresponds to the [tickToGo]
  ///
  /// Example :
  /// If the [bytesSent] is
  /// [CODE_NEW_TICK, x,x,x, CODE_NEW_TICK, x,x,x CODE_NEW_TICK, x,x,x]
  /// And [tickToGo] is 2
  /// The function would return 5
  int findTheIndexCorrespondToTheTick(int tickToGo) {
    int tick = 0;
    for (int i = 0; i < bytesSent.length; i++) {
      if (tick == tickToGo) return i;
      if (bytesSent[i] == BluetoothConstants.CODE_NEW_TICK) {
        tick++;
      }
    }
    return -1;
  }

  //endregion

  void dispose() {
    mainBluetoothCharacteristic = null;
    tickBluetoothCharacteristic = null;
    streamSubscriptionTickListening?.cancel();
    streamSubscriptionNotePushedListening?.cancel();
    deviceStateSubscription?.cancel();
  }
}
