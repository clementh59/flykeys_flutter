import 'package:flutter/material.dart';

import 'music.dart';

class Transcriber{

	String id;
	String name;
	String profileImageName;
	String backgroundImageName;
	int nbFollowers;
	bool isVerified;
	bool iFollow;
	Widget image;
	double stars;
	int numberOfVotes;
	int nbPlays;
	String youtubeLink;
	List<Music> songs;

	Transcriber({this.id, this.name, this.profileImageName, this.nbFollowers, this.isVerified, this.backgroundImageName, this.iFollow, this.stars, this.numberOfVotes, this.nbPlays, this.youtubeLink});

	Transcriber.fromMapObject(Map<String, dynamic> map) {
		name = map['name'];
		profileImageName = map['profilImage'];
		backgroundImageName = map['backgroundImage'];
		id = map['key'];
		nbFollowers = map["nb_followers"];
		isVerified = map["isVerified"];
		iFollow = map["iFollow"];
		List<dynamic> listMapSongsDyn = map["songs"];
		List<Map<String, dynamic>> listMapSongs = [];
		listMapSongsDyn.forEach((element) {
			listMapSongs.add(element);
		});
		songs = [];
		listMapSongs.forEach((element) {
			songs.add(Music.fromTranscriberMapObject(element));
		});

		stars = 5;//todo: faire la moyenne de toutes les chansons
		numberOfVotes = 1530;
		nbPlays = 530;
		youtubeLink = "https://youtube.com";
	}

	@override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transcriber &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Transcriber{name: $name}';
  }
}