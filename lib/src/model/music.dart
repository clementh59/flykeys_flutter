import 'package:flutter/material.dart';
import 'package:flykeys/src/utils/utils.dart';

import 'artist.dart';

class Music{

	String name;
	List<Artist> auteurs;
	String imageName;
	String id;
	double speed;
	double stars;
	int difficulty;
	bool liked;
	bool iLoadedAllInfos;
	String transcriberName;
	String transcriberId;
	int numberOfVotes;

	Widget image;

	Music.fromMapObject(Map<String, dynamic> map) {
		name = map['name'];
		imageName = map['image'];
		id = map['key'];
		difficulty = map["difficulte"];
		liked = map["liked"];

		speed = Utils.getIntOrDouble(map["speed"]);
		stars = Utils.getIntOrDouble(map["stars"]);

		numberOfVotes = 8521;
		transcriberName = "Peter PlutaX";

		List<dynamic> listMapAuteursDyn = map["auteur"];
		List<Map<String, dynamic>> listMapAuteurs = [];
		listMapAuteursDyn.forEach((element) {
			listMapAuteurs.add(element);
		});
		auteurs = [];
		listMapAuteurs.forEach((element) {
			auteurs.add(Artist.fromSmallerMapObject(element));
		});

		iLoadedAllInfos = true;

	}

	Music.fromTranscriberMapObject(Map<String,dynamic> map){
		name = map['name'];
		id = map['id'];
		difficulty = map["difficulte"];
		stars = Utils.getIntOrDouble(map["stars"]);
		List<dynamic> listMapAuteursDyn = map["auteur"];
		List<Map<String, dynamic>> listMapAuteurs = [];
		listMapAuteursDyn.forEach((element) {
			listMapAuteurs.add(element);
		});
		numberOfVotes = 8521;
		transcriberName = "Peter PlutaX";

		auteurs = [];
		listMapAuteurs.forEach((element) {
			auteurs.add(Artist.fromSmallerMapObject(element));
		});
		imageName = "";
		liked = false;
		iLoadedAllInfos = false;
	}

	Music.fromArtistMapObject(Map<String,dynamic> map){
		name = map['name'];
		id = map['id'];
 		difficulty = map["difficulte"];
		Map<String, dynamic> mapTranscriber = map["transcriber"];
		transcriberId = mapTranscriber["id"];
		transcriberName = mapTranscriber["name"];
		imageName = "";
		liked = false;
		iLoadedAllInfos = false;
		numberOfVotes = 8521;
		transcriberName = "Peter PlutaX";
	}

	@override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Music && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Music{name: $name}';
  }

}