import 'package:flykeys/src/repository/database_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Utils{

	static const String app_version = "1.0";
	static const String app_name = "FlyKeys";
	static const String legalPhrase = "Thanks to : \nMatt Wojtaś for the app design inspiration\n";
	static const int numberOfMusicLoadedFirstTrending = 4;
	static const int numberOfMusicLoadedWhenCLickLoadMoreMusic = 6;
	static const int numberOfElementLoadedWhenSearch = 5;

	static double getIntOrDouble(var val){
		if (val is double){
			return val;
		}
		if (val is int){
			return val.toDouble();
		}
		return 0;
	}

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

	static List<String> listDynamicToStringList(List<dynamic> listDyn){
		List<String> list = [];
		for(var i in listDyn){
			list.add(i);
		}
		return list;
	}

	/************		SharedPrefs *************/

	static Future<String> readStringFromSharedPreferences(String key) async {
		final prefs = await SharedPreferences.getInstance();
		final value = prefs.getString(key) ?? "none";
		//print('read: $value');
		return value;
	}

	static Future<List<String>> readListOfStringFromSharedPreferences(String key) async {
		final prefs = await SharedPreferences.getInstance();
		final value = prefs.getStringList(key) ?? "none";
		//print('read: $value');
		return value;
	}

	static Future<void> saveStringFromSharedPreferences(String key, String value) async {
		final prefs = await SharedPreferences.getInstance();
		prefs.setString(key, value);
		//print('saved $value');
	}

	static Future<void> saveListOfStringFromSharedPreferences(String key, List<String> value) async {
		final prefs = await SharedPreferences.getInstance();
		prefs.setStringList(key, value);
		//print('saved $value');
	}

}