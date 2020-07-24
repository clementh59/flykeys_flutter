import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

abstract class ImageProviderRepository {
	Future<Widget> fetchImage(String imagePath);
}

class FirestoreImageProviderRepository extends ImageProviderRepository {

	@override
	Future<Widget> fetchImage(String imagePath) async {
		//todo : throw NetWork Error?
		Image m;
		await _loadImage(imagePath).then((downloadUrl) {
			m = Image.network(
				downloadUrl.toString(),
				fit: BoxFit.cover,
			);
		});
		return m;
	}

	static Future<dynamic> _loadImage(String imagePath) async {
		return await FirebaseStorage.instance.ref().child(imagePath).getDownloadURL();
	}

}

class NetworkError extends Error {}