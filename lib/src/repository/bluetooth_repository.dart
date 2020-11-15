import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flykeys/src/model/midiReader/note.dart';
import 'package:flykeys/src/repository/bluetooth_constants.dart';

class BluetoothRepository {
  static const int MTU_SIZE = 254;
  static const int SCAN_TIMEOUT = 6; //time out de 6s pour le scan
  static const String uuidOfMainCommunication =
      "beb5483e-36e1-4688-b7f5-ea07361b26a8";
  static const String uuidOfTickCommunication =
      "beb5483e-36e1-4688-b7f5-ea07361b26a7";

  List<int> console = [];//todo : remove, it's just for printing to the console all the bytes that I send

  BluetoothDevice flyKeysDevice;
  BluetoothCharacteristic mainBluetoothCharacteristic;
  BluetoothCharacteristic tickBluetoothCharacteristic;
  StreamSubscription streamSubscriptionTickListening;
  StreamSubscription deviceStateSubscription;
  List<int> bytesSent = [];

  List<int> createTrameFromListeNote(List<Note> listNotes) {
    List<Note> notesDejaEnvoyees = [];
    List<int> tramesAEnvoyer = [];
    int actualTick = -8;
    Note n;

    List<Note> lastKeysOn = List(
        128); //Pour savoir si on doit appuyer sur une touche deux fois alors que l'on voit juste deux LEDs
    List<Note>
        actualKeysOn; //Pour savoir si on doit appuyer sur une touche deux fois alors que l'on voit juste deux LEDs

    while (listNotes.length > 0) {
      lastKeysOn = actualKeysOn;
      actualKeysOn = List(128);
      for (int i = 0; i < min(listNotes.length, 250); i++) {
        n = listNotes[i];

        if (n.getKey() > 88) {
          //je fais rien car elle ne sera pas visible sur le clavier!! //todo: changer avec les dimensions du piano que l'user a paramétrer dans l'app
          notesDejaEnvoyees.add(n);
        } else if (n.getTimeOff() < actualTick) {
          //On ne voit plus la note
          notesDejaEnvoyees.add(n);
        } else {
          //La note est visible ou le sera encore, on continue de la traiter
          if (n.getTimeOn() < actualTick && n.getTimeOff() >= actualTick) {
            //alors c'est visible

            if (n.isReleaseAndPush()) {
              tramesAEnvoyer.add(n.key); //je la met en rouge
              tramesAEnvoyer.add(BluetoothConstants.mapStringColorToCode[n.getColor()]);
            } else if (lastKeysOn[n.getKey()] != null &&
                lastKeysOn[n.getKey()] != n &&
                !lastKeysOn[n.getKey()].isReleaseAndPush()) {
              tramesAEnvoyer.add(n.key); //je la met en rouge
              tramesAEnvoyer.add(BluetoothConstants.mapStringColorToCode[n.getColor()]);
              n.setIsReleaseAndPushColor();
            } else {
              tramesAEnvoyer.add(n.key); //Je l'envoi simplement
              tramesAEnvoyer.add(BluetoothConstants.mapStringColorToCode[n.getColor()]); //avec sa couleur
            }
            actualKeysOn[n.getKey()] = n;
          }
        }
      }
      tramesAEnvoyer.add(BluetoothConstants.CODE_NEW_TICK); //AFFICHAGE
      actualTick++;
      for (int i = 0; i < notesDejaEnvoyees.length; i++)
        listNotes.remove(notesDejaEnvoyees[i]);
      notesDejaEnvoyees.clear();
    }
    print(tramesAEnvoyer);
    return tramesAEnvoyer;
  }

  /**
	 * Envoi une liste de byte en trames de BluetoothConstants.MTU_SIZE bytes par BluetoothConstants.MTU_SIZE bytes
	 * stream : indique par le biai du stream à quel niveau d'envoi elle est!
	 */
  Stream<int> envoiLaTrameMorceau(
      List<int> tramesAEnvoyer, ValueNotifier valueNotifierStopSending) async* {
    int begin = new DateTime.now().millisecondsSinceEpoch;
    bytesSent = [];
    List<int> trameDeMaxMTU =
        []; // On envoi les bytes BluetoothConstants.MTU_SIZE par BluetoothConstants.MTU_SIZE, ce tableau les contient temporairement à chaque fois
    int actualIndextrameDeMaxMTU =
        0; // Pour se repérer dans l'index du tableau de trame de BluetoothConstants.MTU_SIZE où on est

    await mainBluetoothCharacteristic
        .write([BluetoothConstants.CODE_MODE_APPRENTISSAGE_ENVOI_DU_MORCEAU]); //Je dis à l'esp que je lui envoi le morceau

    for (int i = 0; i < tramesAEnvoyer.length; i++) {
      trameDeMaxMTU.add(tramesAEnvoyer[i]);

      if (actualIndextrameDeMaxMTU == MTU_SIZE ||
          i == tramesAEnvoyer.length - 1) {
        //Si la trame est pleine, ou si on vient de remplir la dernière trame à envoyer
        actualIndextrameDeMaxMTU = 0;
        await envoiLaTrameMTU(trameDeMaxMTU,
            mainBluetoothCharacteristic); //Je dis à l'esp que je lui envoi le morceau
        bytesSent.addAll(trameDeMaxMTU);
        trameDeMaxMTU =
            []; //sinon la dernière trame peut contenir des valeurs indésirables
        yield i;
      } else
        actualIndextrameDeMaxMTU++;

      if (valueNotifierStopSending.value == true) {
        //j'arrete d'envoyer le morceau
        return;
      }
    }

    int end = new DateTime.now().millisecondsSinceEpoch;
    print("TTS time to send : " + ((end - begin) / 1000).toString() + "s");
    for (int i=0; i<console.length; i+=100){
      String str = "";
      for (int c = i; c<i+100 && c<console.length; c++){
        str+=console[c].toString()+",";
      }
      print(str);
    }
    return;
  }

  Future<Null> envoiLaTrameMTU(List<int> trame,
      BluetoothCharacteristic bluetoothCharacteristicToSend) async {
    //print("J'envoi la trame $trame");
    console.addAll(trame);
    await bluetoothCharacteristicToSend.write(trame);
  }

  Future<bool> findFlyKeysDevice(FlutterBlue flutterBlue) async {
    dev.log('begin', name: "findFlyKeysDevice");

    dev.log('fetching BLUETOOTH connected devices', name: "findFlyKeysDevice");
    List<BluetoothDevice> connectedDevices = await flutterBlue.connectedDevices;

    dev.log('checking if connected device list contains flykeys device',
        name: "findFlyKeysDevice");
    for (BluetoothDevice device in connectedDevices) {
      if (isFlyKeysDevice(device)) {
        flutterBlue.stopScan();
        return true;
      }
    }

    dev.log('checking through scan results', name: "findFlyKeysDevice");

    BluetoothDevice flyKeysDevice;

    int i = 0;
    bool isScanning = true;
    bool isCheckingResult = false;

    while (isScanning) {
      if (!isCheckingResult) {
        isCheckingResult = true;
        i++;
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

  bool isFlyKeysDevice(BluetoothDevice bluetoothDevice) {
    //todo: check more...
    if (bluetoothDevice.name == "FLYKEYS") {
      dev.log('FlyKeys device found', name: "findFlyKeysDevice");
      flyKeysDevice = bluetoothDevice;
      return true;
    }
    return false;
  }

  Future<bool> connectToDevice(ValueNotifier onDisconnectNotifier) async {
    try {
      await flyKeysDevice.connect();
      subscribeToConnectionStateChanges(onDisconnectNotifier);

      return true;
    } catch (id) {
      print("error : " + id.toString());
      if (id.toString() ==
          "PlatformException(already_connected, connection with device already exists, null)") {
        subscribeToConnectionStateChanges(onDisconnectNotifier);
        return true; //je suis déjà connecté
      }
      return false;
    }
  }

  void subscribeToConnectionStateChanges(ValueNotifier onDisconnectNotifier) {
    deviceStateSubscription?.cancel();
    deviceStateSubscription = flyKeysDevice.state.listen((s) {
      print("#18 New state flykeys device : $s");
      if (s == BluetoothDeviceState.disconnected) {
        onDisconnectNotifier.value = true;
      }
    });
  }

  /**
	 * Récupère les deux characteristiques nécessaire et renvoie true si elles sont récupérée / renvoit false sinon
	 */
  Future<bool> hasTheRightCharacteristics() async {
    List<BluetoothService> services = await flyKeysDevice.discoverServices();

    for (BluetoothService service in services) {
      var characteristics = service.characteristics;
      for (BluetoothCharacteristic c in characteristics) {
        print(c.uuid);
        if (c.uuid.toString() == uuidOfMainCommunication) {
          //todo:generate a new one for my purpose on a website generator
          mainBluetoothCharacteristic = c;
          dev.log("found the mainBluetoothCharacteristic",
              name: "hasTheGoodCharacteristics");
        } else if (c.uuid.toString() == uuidOfTickCommunication) {
          tickBluetoothCharacteristic = c;
          dev.log("found the tickBluetoothCharacteristic",
              name: "hasTheGoodCharacteristics");
        }
      }
    }

    if (mainBluetoothCharacteristic != null &&
        tickBluetoothCharacteristic != null) {
      return true;
    }
    return false;
  }

  Future<void> play() async {
    await mainBluetoothCharacteristic.write([BluetoothConstants.CODE_PLAY]);
  }

  Future<void> pause() async {
    await mainBluetoothCharacteristic.write([BluetoothConstants.CODE_PAUSE]);
  }

  /**
   * Ask the BLE device to start the mode lightning show
   */
  Future<void> lightningShow() async {
    await mainBluetoothCharacteristic.write([BluetoothConstants.CODE_MODE_LIGHTNING_SHOW]); // PLAY
  }

  Future<void> sendDelay(double delayDouble) async {
    //10011100010
    //je veux envoyer
    //11100010
    //puis 100
    int delay = delayDouble.floor();
    int virguleFois100 = ((delayDouble - delay) * 100).round();

    print("Je dois envoyer le delay : " + delay.toString());
    ByteData byteData = new ByteData(2);
    byteData.setInt16(0, delay);
    //J'envoi les deux premier int qui correspondent à la partie entière de la vitesse puis une nombre de 0 à 99 qui correspond à la virgule
    await mainBluetoothCharacteristic.write([
      BluetoothConstants.CODE_DELAY,
      byteData.getUint8(1),
      byteData.getUint8(0),
      virguleFois100
    ]); // PLAY
  }

  Future<void> sendColors() async {
    await mainBluetoothCharacteristic.write([BluetoothConstants.CODE_I_SEND_COLOR,
      BluetoothConstants.mapStringColorToCode['MD'],
      79,235,52,79,235,52,79,235,52,79,235,52,79,235,52,79,235,52,79,235,52,79,235,52,
      BluetoothConstants.mapStringColorToCode['MD_R&P'],
      189,255,177,189,255,177,189,255,177,189,255,177,189,255,177,189,255,177,189,255,177,189,255,177,
      BluetoothConstants.mapStringColorToCode['MG'],
      52,152,235,52,152,235,52,152,235,52,152,235,52,152,235,52,152,235,52,152,235,52,152,235,
      BluetoothConstants.mapStringColorToCode['MG_R&P'],
      183,222,255,183,222,255,183,222,255,183,222,255,183,222,255,183,222,255,183,222,255,183,222,255,
    ]);
  }

  /**
   * Utile pour le mode apprentissage, si je dois ou non attendre que
   * l'utilisateur appuie sur une touche pour faire défiler
   */
  Future<void> askToWaitForUserInputInModeApprentissage() async {
    await mainBluetoothCharacteristic.write([BluetoothConstants.CODE_SET_I_HAVE_TO_WAIT_FOR_USER_INPUT]);
  }

  /**
   * Utile pour le mode apprentissage, si je dois ou non attendre que
   * l'utilisateur appuie sur une touche pour faire défiler
   */
  Future<void> askToNotWaitForUserInputInModeApprentissage() async {
    await mainBluetoothCharacteristic.write([BluetoothConstants.CODE_SET_I_DONT_HAVE_TO_WAIT_FOR_USER_INPUT]);
  }

  Future<int> subscribeToTickCharacteristic(
      ValueNotifier valueNotifierActualTick) async {
    await tickBluetoothCharacteristic.setNotifyValue(true);
    streamSubscriptionTickListening?.cancel();
    streamSubscriptionTickListening =
        tickBluetoothCharacteristic.value.listen((event) {
      dev.log("Value changed : " + tickBluetoothCharacteristic.value.toString(),
          name: "tickBluetoothCharacteristic");

      if (event.length == 4) {
        int value = event[0] + event[1] * 256 + event[2] * 256 * 256 + event[3] * 256 * 256 * 256;

        if (value > 1000000) {
          valueNotifierActualTick.value =
              -1; //Je notifie que le morceau est finis, j'enlève le signe play et je le met sur pause
        } else
          valueNotifierActualTick.value = value;
      }
    });

    return 0;
  }

  Future<bool> sendANewTick(int tick) async {
    int index = findTheIndexCorrespondToTheTick(tick);

    if (index == -1) {
      print("!!!!!!!!!!!!!!!ERROR!!!!!!!!!!!!!!!!!");
      print("!!!!!!!!!!!!!!!ERROR!!!!!!!!!!!!!!!!!");
      print("sendANewTick index is -1");
      print(tick);
      print(bytesSent);
      print("!!!!!!!!!!!!!!!ERROR!!!!!!!!!!!!!!!!!");
      print("!!!!!!!!!!!!!!!ERROR!!!!!!!!!!!!!!!!!");
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

  int findTheIndexCorrespondToTheTick(int tickToGo) {
    int tick = 0;
    print("tick to go is $tickToGo");
    for (int i = 0; i < bytesSent.length; i++) {
      if (tick == tickToGo) return i;
      if (bytesSent[i] == BluetoothConstants.CODE_NEW_TICK) {
        tick++;
      }
    }
    print("tick max is $tick");
    return -1;
  }

  void dispose() {
    mainBluetoothCharacteristic = null;
    tickBluetoothCharacteristic = null;
    streamSubscriptionTickListening?.cancel();
    deviceStateSubscription?.cancel();
  }
}
