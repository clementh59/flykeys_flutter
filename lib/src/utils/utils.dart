import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Utils{

	static const String app_version = "1.0";
	static const String app_name = "FlyKeys";
	static const String legalPhrase = "Thanks to : \nMatt Wojtaś for the app design inspiration\nDinosoftLabs, Flat icons, Icongeek26, Freepik,  for icons";
	static const int numberOfMusicLoadedFirstTrending = 4;
	static const int numberOfMusicLoadedWhenCLickLoadMoreMusic = 6;
	static const int numberOfElementLoadedWhenSearch = 5;
	static const noteNames = ['Do','Do#','Ré','Ré#','Mi','Fa','Fa#','Sol','Sol#','La','La#','Si'];

	/// This function is useful when you retrieve a value from Firestore and you don't know if it is an int or a double
	/// It [returns] the value casted to double
	static double getIntOrDouble(var val){
		if (val is double){
			return val;
		}
		if (val is int){
			return val.toDouble();
		}
		return 0;
	}

	/// returns a String corresponding to the number, but with spaces between
	/// each 3 numbers
	static String showNumber(String number){
		int numberInt = int.parse(number);
		if (numberInt<1000)
			return number;
		if (numberInt<1000000){
			return (numberInt/1000).floor().toString() + " " + (numberInt%1000).toString();
		}

		//je suis supérieur à 1 million
		String str = "";
		int reste;
		str = (numberInt/1000000).floor().toString();
		reste = numberInt%1000000;

		return str + " " + (reste/1000).floor().toString() + " " + (reste%1000).toString();
	}

	/// This function is useful when you retrieve a list of string from Firestore (because the type in dart is dynamic by default)
	/// It [returns] a list of string
	static List<String> listDynamicToStringList(List<dynamic> listDyn){
		List<String> list = [];
		for(var i in listDyn){
			list.add(i);
		}
		return list;
	}

	//region Shared prefs
	/// Returns the string corresponding to the [key] in the shared prefs
	/// If the string doesn't exist, it returns [defaultValue] which is an empty
	/// string by default and can be configured with {defaultValue = YOUR_VALUE}
	static Future<String> readStringFromSharedPreferences(String key, {defaultValue = ''}) async {
		final prefs = await SharedPreferences.getInstance();
		final value = prefs.getString(key) ?? defaultValue;
		return value;
	}

	/// Returns the strings corresponding to the [key] in the shared prefs
	/// If the list doesn't exist, it returns [defaultValue] which is an empty
	/// list by default and can be configured with {defaultValue = YOUR_VALUE}
	static Future<List<String>> readListOfStringFromSharedPreferences(String key, {defaultValue}) async {
		final prefs = await SharedPreferences.getInstance();
		final value = prefs.getStringList(key) ?? defaultValue ? defaultValue : [];
		//print('read: $value');
		return value;
	}

	static Future<void> saveStringToSharedPreferences(String key, String value) async {
		final prefs = await SharedPreferences.getInstance();
		prefs.setString(key, value);
		//print('saved $value');
	}

	static Future<void> saveListOfStringToSharedPreferences(String key, List<String> value) async {
		final prefs = await SharedPreferences.getInstance();
		prefs.setStringList(key, value);
		//print('saved $value');
	}

	/// Returns the boolean corresponding to the [key] in the shared prefs
	/// If the boolean doesn't exist, it returns [defaultValue] which is an false
	/// by default and can be configured with {defaultValue = YOUR_VALUE}
	static Future<bool> getBooleanFromSharedPreferences(String key, {defaultValue=false}) async {
		final prefs = await SharedPreferences.getInstance();
		return prefs.getBool(key) ?? defaultValue;
	}

	static Future<void> saveBooleanToSharedPreferences(String key, bool value) async {
		final prefs = await SharedPreferences.getInstance();
		prefs.setBool(key, value);
	}

	/****	  Colors in shared prefs	*****/

	/// Returns the color corresponding to the [key] in the shared prefs
	/// If the color doesn't exist, it returns [defaultValue]
	static Future<Color> readColorFromSharedPreferences(String key, defaultValue) async {
		final prefs = await SharedPreferences.getInstance();
		final value = prefs.getString(key) ?? '';

		if (value == '') {
			return defaultValue;
		}

		final hexColor = value.split('x')[1].split(')')[0];

		return _fromHex(hexColor);
	}

	static Future<void> saveColorToSharedPreferences(String key, Color value) async {
		final prefs = await SharedPreferences.getInstance();
		prefs.setString(key, value.toString());
	}

	static Color _fromHex(String hexString) {
		final buffer = StringBuffer();
		if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
		buffer.write(hexString.replaceFirst('#', ''));
		return Color(int.parse(buffer.toString(), radix: 16));
	}
	//endregion

	//region MIDI

	static String getNoteNameFromKey(int key) {
		return noteNames[key%12];
	}

	//endregion

}