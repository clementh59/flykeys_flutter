import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'note.dart';

class ParsedFileReader{

	File dataFile;
	int nbDeTickDuMorceau = -1;

	ParsedFileReader({this.dataFile});

	Future<List<Note>> readDataFile() async {
		String data = dataFile.readAsStringSync();
		List<String> lines = data.split("\n");
		List<Note> notes = [];

		String musicInfos = lines.removeAt(0);

		for(String line in lines){
			List<String> info = line.split(" ");

			if (info.length==4) {
				Note n = Note(int.parse(info[0]), int.parse(info[1]), int.parse(info[2]), info[3]);
				notes.add(n);
			} else if (info.length != 0 && !(info.length == 1 && info[0]=='')){ // Si la ligne n'est pas vide mais quelle ne respecte pas le format (4 " "), c'est que le fichier n'est pas bon!
				throw new Exception("The music file hasn't a good format (#2)");
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