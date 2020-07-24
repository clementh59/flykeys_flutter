import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class ParsedFileRepository{

	static Future<File> fetchParsedFile(String id) async {
		final StorageReference ref = FirebaseStorage.instance.ref().child("musics/"+id).child('parsed.txt');
		return await downloadFile(ref);
	}

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
		FileDownloadTaskSnapshot taskSnapshot = await task.future;//J'attend que le fichier se télécharge bien
		return tempFile;
	}

}

class NetworkError extends Error {}