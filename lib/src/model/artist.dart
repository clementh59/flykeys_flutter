import 'package:flutter/material.dart';
import 'package:flykeys/src/page/artist_page.dart';
import 'package:flykeys/src/utils/utils.dart';

import 'music.dart';

class Artist{

	String name;
	String id;
	List<Music> musics;
	String backgroundImage;
	String profilImage;
	bool iLoadedAllInfo;

	Widget image;

	Artist.fromMapObject(Map<String,dynamic> map){
		name = map["name"];
		id = map["id"];
		backgroundImage = map["backgroundImage"];
		profilImage = map["profilImage"];
		List<dynamic> listMapMusicsDyn = map["musics"];
		List<Map<String, dynamic>> listMapMusics = [];
		listMapMusicsDyn.forEach((element) {
			listMapMusics.add(element);
		});
		musics = [];
		listMapMusics.forEach((element) {
			musics.add(Music.fromArtistMapObject(element));
		});
		iLoadedAllInfo = true;
	}

	Artist.fromSmallerMapObject(Map<String,dynamic> map){
		name = map["name"];
		id = map["id"];
		iLoadedAllInfo = false;
	}


	/// Generate an Artist instance with dummy values
	Artist.fromDummyValues() {
		//todo: fill all values and not only smaller artist object
		name = 'Dummy Artist';
		id = 'Dummy ID';
		iLoadedAllInfo = false;
	}

	@override
  String toString() {
    return 'Artist{name: $name, musics: $musics}';
  }

	static void goToArtistPage(context,Artist a){
		if (a.id==""){
			Scaffold.of(context)
				.showSnackBar(SnackBar(
				content:
				Text("Cet artiste n'a pas encore sa page attitrée!")));
			return;
		}
		Navigator.push(context,
			Utils.createRoute(() => ArtistPage(a)),
		);
	}

}