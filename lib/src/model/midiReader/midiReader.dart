import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'note.dart';

class MidiReader{

	File midiFile;
	File dataFile;
	int nbDeTickDuMorceau = -1;

	MidiReader({this.midiFile, this.dataFile});

	Future<List<Note>> readDataFile() async {
		String data = dataFile.readAsStringSync();
		List<String> lines = data.split("\n");
		List<Note> notes = [];
		for(String line in lines){
			List<String> info = line.split(" ");
			if (info.length==4) {
				//todo : changer le -12!!
				Note n = Note(int.parse(info[0])-12, int.parse(info[1]), int.parse(info[2]), info[3]);
				notes.add(n);
			}

		}
		nbDeTickDuMorceau = getTickMaxDuMorceau(notes);
		return notes;
	}

	String getStringFromBytes(ByteData data) {
		final buffer = data.buffer;
		var list = buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
		return utf8.decode(list);
	}

	int getNbDeTickDuMorceau(){
		return nbDeTickDuMorceau;
	}

  int getTickMaxDuMorceau(List<Note> notes) {
		int tickMax = 0;

		for(Note n in notes){
			tickMax = max(tickMax, n.getTimeOff());
		}

		return tickMax;

	}

}