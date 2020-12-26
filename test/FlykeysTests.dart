import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flykeys/src/model/midiReader/parsedFileReader.dart';
import 'package:flykeys/src/model/midiReader/note.dart';
import 'package:flykeys/src/repository/bluetooth_constants.dart';
import 'package:flykeys/src/repository/bluetooth_repository.dart';
import 'package:flykeys/src/utils/utils.dart';
import 'package:test/test.dart';

void main() {
  group('Parsed file', () {

    final BluetoothRepository bluetoothRepository = new BluetoothRepository();

    const String PARSED_FILE_CONTENT = "480;240\n" +
        "64 0 3 MD\n" +
        "71 0 3 MD\n" +
        "52 0 8 MG\n" +
        "64 3 6 MD\n" +
        "71 3 6 MD\n" +
        "64 6 8 MD\n" +
        "71 6 8 MD\n" +
        "64 8 11 MD\n" +
        "72 8 11 MD\n" +
        "48 8 16 MG\n" +
        "64 11 14 MD\n" +
        "72 11 14 MD\n" +
        "64 14 16 MD\n" +
        "72 14 16 MD\n" +
        "62 16 19 MD\n" +
        "71 16 19 MD\n" +
        "43 16 24 MG\n" +
        "62 19 22 MD\n" +
        "71 19 22 MD\n" +
        "62 22 24 MD\n" +
        "71 22 24 MD\n" +
        "62 24 27 MD\n" +
        "69 24 27 MD";

    List<Note> expectedListeNote = [
      Note(64, 0, 3, 'MD'),
      Note(71, 0, 3, 'MD'),
      Note(52, 0, 8, 'MG'),
      Note(64, 3, 6, 'MD'),
      Note(71, 3, 6, 'MD'),
      Note(64, 6, 8, 'MD'),
      Note(71, 6, 8, 'MD'),
      Note(64, 8, 11, 'MD'),
      Note(72, 8, 11, 'MD'),
      Note(48, 8, 16, 'MG'),
      Note(64, 11, 14, 'MD'),
      Note(72, 11, 14, 'MD'),
      Note(64, 14, 16, 'MD'),
      Note(72, 14, 16, 'MD'),
      Note(62, 16, 19, 'MD'),
      Note(71, 16, 19, 'MD'),
      Note(43, 16, 24, 'MG'),
      Note(62, 19, 22, 'MD'),
      Note(71, 19, 22, 'MD'),
      Note(62, 22, 24, 'MD'),
      Note(71, 22, 24, 'MD'),
      Note(62, 24, 27, 'MD'),
      Note(69, 24, 27, 'MD'),
    ];

    const String PARSED_FILE_CONTENT_SMALLER = "480;240\n" +
      "64 0 1 MD\n" +
      "71 0 1 MD\n" +
      "52 0 4 MG\n" +
      "64 1 2 MD\n" +
      "71 1 2 MG\n" +
      "64 2 3 MD\n" +
      "71 2 4 MG\n";

    int MD = BluetoothConstants.mapStringColorToCode['MD'];
    int MG = BluetoothConstants.mapStringColorToCode['MG'];
    int MD_RP = BluetoothConstants.mapStringColorToCode['MD_R&P'];
    int MG_RP = BluetoothConstants.mapStringColorToCode['MG_R&P'];
    int NT = BluetoothConstants.CODE_NEW_TICK;

    List<int> expectedTrame = [
      64-12,MD,71-12,MD,52-12,MG,NT,
      52-12,MG,64-12,MD_RP,71-12,MG,NT,
      52-12,MG,64-12,MD,71-12,MG_RP,NT,
      52-12,MG,71-12,MG_RP
    ];

    File createFileFromString(String str) {
      File parsedFile = File('file.txt');
      parsedFile.writeAsStringSync(str);
      return parsedFile;
    }

    setUpAll((){
      WidgetsFlutterBinding.ensureInitialized();
    });

    test('should create a list of notes from a parsed file', () async {
      ParsedFileReader midiReader =
      ParsedFileReader(dataFile: createFileFromString(PARSED_FILE_CONTENT));
      List<Note> listNotes = await midiReader.readDataFile();

      expect(listNotes, expectedListeNote);
    });

    test('should throw an error since the parsed file isn\'t good', () async {
      ParsedFileReader midiReader =
      ParsedFileReader(dataFile: createFileFromString(PARSED_FILE_CONTENT+"\n7845"));
      expect(() async => await midiReader.readDataFile(), throwsException);
    });

    test('should create a trame to send from a parsed file', () async {
      ParsedFileReader midiReader =
      ParsedFileReader(dataFile: createFileFromString(PARSED_FILE_CONTENT_SMALLER));
      List<Note> listNotes = await midiReader.readDataFile();
      List<int> trameToSend = bluetoothRepository.createTrameFromListeNote(listNotes);

      // I remove all the CODE_NEW_TICK that are at the beginning of the trame to send
      int i=0;
      while (trameToSend[i++]==BluetoothConstants.CODE_NEW_TICK);
      trameToSend.removeRange(0, i-1);

      // I remove all the CODE_NEW_TICK that are at the end of the trame to send
      while (trameToSend[trameToSend.length-1]==BluetoothConstants.CODE_NEW_TICK){
        trameToSend.removeLast();
      }


      expect(trameToSend, expectedTrame);
    });

  });

  group('Utils', () {

    test('It should return the name of the note corresponding to the MIDI key', () async {

      expect(Utils.getNoteNameFromKey(24),'Do');
      expect(Utils.getNoteNameFromKey(25),'Do#');
      expect(Utils.getNoteNameFromKey(26),'Ré');
      expect(Utils.getNoteNameFromKey(59),'Si');
    });

  });
}
