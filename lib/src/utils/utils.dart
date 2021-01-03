import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Utils{

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
		return value;
	}

	static Future<void> saveStringToSharedPreferences(String key, String value) async {
		final prefs = await SharedPreferences.getInstance();
		await prefs.setString(key, value);
		//print('saved $value');
	}

	static Future<void> saveListOfStringToSharedPreferences(String key, List<String> value) async {
		final prefs = await SharedPreferences.getInstance();
		await prefs.setStringList(key, value);
	}

	/// Returns the boolean corresponding to the [key] in the shared prefs
	/// If the boolean doesn't exist, it returns [defaultValue] which is false
	/// by default and can be configured with {defaultValue = YOUR_VALUE}
	static Future<bool> getBooleanFromSharedPreferences(String key, {defaultValue=false}) async {
		final prefs = await SharedPreferences.getInstance();
		return prefs.getBool(key) ?? defaultValue;
	}

	static Future<void> saveBooleanToSharedPreferences(String key, bool value) async {
		final prefs = await SharedPreferences.getInstance();
		await prefs.setBool(key, value);
	}

	/// Returns the map corresponding to the [key] in the shared prefs
	/// If the key doesn't exist, it returns [defaultValue]
	static Future<Map> getMapFromSharedPreferences(String key, defaultValue) async {
		String res = await readStringFromSharedPreferences(key);
		if (res == '')
			return defaultValue;
		return json.decode(res);
	}

	static Future<void> saveMapToSharedPreferences(String key, Map value) async {
		await saveStringToSharedPreferences(key, json.encode(value));
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
		await prefs.setString(key, value.toString());
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

	static int getDecade(int key) {
		return (key/12).floor()-1;
	}

	/// [firstKey] e.g 21
	/// [lastKey] e.g 108
	/// [returns] a Map with 'noires' and 'blanches' that are the numbers of corresponding keys
	static Map getNumberOfTouches(int firstKey, int lastKey) {

		int numberOfTouchesNoires = 0;
		int numberOfTouchesBlanches = 0;

		for(int key = firstKey; key<=lastKey; key++) {
			String nameOfNote = noteNames[key%12];
			if (nameOfNote.contains('#'))
				numberOfTouchesNoires++;
			else
				numberOfTouchesBlanches++;
		}

		return {'noires':numberOfTouchesNoires,'blanches':numberOfTouchesBlanches};

	}

	//endregion

}