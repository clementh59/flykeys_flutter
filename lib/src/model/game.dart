import 'package:flutter/material.dart';
import 'package:flykeys/src/utils/utils.dart';

class Game{

	String name;
	int nbPlayers;
	double stars;
	String id;
	String imagePath;
	Widget page;

	Game({this.name, this.nbPlayers, this.stars, this.id, this.imagePath, this.page});

	Game.fromMapObject(Map<String, dynamic> map) {
		name = map['name'];
		id = map['key'];
		nbPlayers = map["nb_players"];
		stars = Utils.getIntOrDouble(map["stars"]);
		imagePath = map["image"];
		page = map["page"];
	}

}