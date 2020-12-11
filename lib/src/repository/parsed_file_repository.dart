import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class ParsedFileRepository{

	/// Returns the parsed file of the music corresponding to the id passed
	static Future<File> fetchParsedFile(String id) async {
		final StorageReference ref = FirebaseStorage.instance.ref().child("musics/"+id).child('parsed.txt');
		return await downloadFile(ref);
	}

	/// Returns the file pointing to the ref in firebase storage
	/// Example of ref : FirebaseStorage.instance.ref().child("musics/THE_MUSIC_ID").child('parsed.txt')
	static Future<File> downloadFile(StorageReference ref) async {
		final String url = await ref.getDownloadURL();
		final Directory systemTempDir = Directory.systemTemp;
		final File tempFile = File('${systemTempDir.path}/tmp.txt');
		if (tempFile.existsSync()) {
			await tempFile.delete();
		}

		//todo: throw network error if ...

		await tempFile.create();
		assert(await tempFile.readAsString() == "");
		final StorageFileDownloadTask task = ref.writeToFile(tempFile);
		await task.future; // J'attend que le fichier se télécharge bien
		return tempFile;
	}

}

class NetworkError extends Error {}