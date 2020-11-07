import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flykeys/src/model/artist.dart';
import 'package:flykeys/src/model/music.dart';
import 'package:flykeys/src/model/transcriber.dart';
import 'package:flykeys/src/utils/utils.dart';

abstract class DatabaseRepository {

  Future<Music> fetchMusic(String id);

  Future<List<Music>> fetchAllMusics();

  Future<List<Music>> fetchMusics(List<String> ids);

  Future<List<Music>> fetchMusicWithThisPattern(String text);

  Future<List<Transcriber>> fetchTranscriberWithThisPattern(String text);

  Future<List<Artist>> fetchArtistWithThisPattern(String text);

  Future<List<Transcriber>> fetchTranscribers(List<String> ids);

  Future<Artist> fetchArtist(String id);

  List<Transcriber> fetchTranscribersByQuery(QuerySnapshot qs);

  List<Artist> fetchArtistsByQuery(QuerySnapshot qs);

  Artist fetchArtistByQuery(DocumentSnapshot ds);

  List<Music> fetchMusicsByQuery(QuerySnapshot qs);

  Music fetchMusicByQuery(DocumentSnapshot qs);
}

class FirestoreRepository extends DatabaseRepository {

  String uid = "t8QDyOeKSYFR1lYKOGqa";//todo : remove...

  @override
  Future<Music> fetchMusic(String id) async {
    DocumentSnapshot qs = await Firestore.instance.collection("music").document(id).get();
    return fetchMusicByQuery(qs);
  }

  @override
  Future<List<Music>> fetchAllMusics() async {
    QuerySnapshot qs =
        await Firestore.instance.collection("music").getDocuments();
    return fetchMusicsByQuery(qs);

  }

  @override
  Future<List<Transcriber>> fetchTranscribers(List<String> ids) async {

    if (ids.length==0){
      return [];
    }

    QuerySnapshot qs = await Firestore.instance
        .collection("transcribers")
        .where(FieldPath.documentId, whereIn: ids)
        .getDocuments();
    return fetchTranscribersByQuery(qs);
  }

  @override
  Future<List<Music>> fetchMusics(List<String> ids) async {

    if (ids.length==0){
      return [];
    }

    QuerySnapshot qs = await Firestore.instance
        .collection("music")
        .where(FieldPath.documentId, whereIn: ids)
        .getDocuments();
    return fetchMusicsByQuery(qs);

  }

  Future<Map<String, dynamic>> fetchTrendings() async {
    DocumentSnapshot ds = await Firestore.instance
        .collection("trending")
        .document("trending")
        .get();

    Map<String, dynamic> data = ds.data;
    print(data);

    return data;
  }

  @override
  Future<List<Music>> fetchMusicWithThisPattern(String text) async {
    QuerySnapshot qs = await Firestore.instance.collection("music").where("searchKeys", arrayContains: text).limit(Utils.numberOfElementLoadedWhenSearch).getDocuments();
    return fetchMusicsByQuery(qs);
  }

  @override
  Future<List<Transcriber>> fetchTranscriberWithThisPattern(String text) async {
    QuerySnapshot qs = await Firestore.instance.collection("transcribers").where("searchKeys", arrayContains: text).limit(Utils.numberOfElementLoadedWhenSearch).getDocuments();
    return fetchTranscribersByQuery(qs);
  }

  @override
  Future<List<Artist>> fetchArtistWithThisPattern(String text) async {
    QuerySnapshot qs = await Firestore.instance.collection("artists").where("searchKeys", arrayContains: text).limit(Utils.numberOfElementLoadedWhenSearch).getDocuments();
    return fetchArtistsByQuery(qs);
  }

  @override
  List<Transcriber> fetchTranscribersByQuery(QuerySnapshot qs) {
    List<Transcriber> transcribers = [];

    //todo : throw NetWork Error
    for (int i = 0; i < qs.documents.length; i++) {
      DocumentSnapshot ds = qs.documents[i];
      Map<String, dynamic> data = ds.data;
      data["key"] = ds.documentID;
      data["iFollow"]=false;

      transcribers.add(Transcriber.fromMapObject(data));
    }

    return transcribers;
  }

  @override
  List<Music> fetchMusicsByQuery(QuerySnapshot qs) {
    List<Music> musics = [];

    //todo : throw NetWork Error

    for (int i = 0; i < qs.documents.length; i++) {
      DocumentSnapshot ds = qs.documents[i];
      musics.add(fetchMusicByQuery(ds));
    }

    return musics;
  }

  @override
  Music fetchMusicByQuery(DocumentSnapshot ds) {
    Map<String, dynamic> data = ds.data;
    data["key"] = ds.documentID;
    data["liked"] = false;

    //todo:ajout bdd
    data["stars"] = 5;
    return Music.fromMapObject(data);
  }

  Future<List<String>> fetchFollowedTranscribersIds() async {
    //todo: change
    DocumentSnapshot ds = await Firestore.instance.collection("users").document("t8QDyOeKSYFR1lYKOGqa").get();
    Map<String, dynamic> data = ds.data;
    return Utils.listDynamicToStringList(data["followedTranscribers"]);
  }

  Future<List<String>> fetchLikedMusicIds() async {
    //todo:change
    DocumentSnapshot ds = await Firestore.instance.collection("users").document(uid).get();
    Map<String, dynamic> data = ds.data;
    return Utils.listDynamicToStringList(data["liked"]);
  }

  void removeFromFavorite(Music music) async {
    Firestore.instance.collection("users").document(uid).updateData({"liked":FieldValue.arrayRemove([music.id])});
  }

  void removeFromFollowed(Transcriber transcriber) async {
    Firestore.instance.collection("users").document(uid).updateData({"followedTranscribers":FieldValue.arrayRemove([transcriber.id])});
  }

  void addToFollowed(Transcriber transcriber) async {
    Firestore.instance.collection("users").document(uid).updateData({"followedTranscribers":FieldValue.arrayUnion([transcriber.id])});
  }

  void addToFavorite(Music music) async {
    Firestore.instance.collection("users").document(uid).updateData({"liked":FieldValue.arrayUnion([music.id])});
  }

  @override
  Future<Artist> fetchArtist(String id) async {
    DocumentSnapshot qs = await Firestore.instance.collection("artists").document(id).get();
    return fetchArtistByQuery(qs);
  }

  @override
  List<Artist> fetchArtistsByQuery(QuerySnapshot qs) {
    List<Artist> artists = [];

    //todo : throw NetWork Error

    for (int i = 0; i < qs.documents.length; i++) {
      DocumentSnapshot ds = qs.documents[i];
      artists.add(fetchArtistByQuery(ds));
    }

    return artists;
  }

  @override
  Artist fetchArtistByQuery(DocumentSnapshot ds) {
    Map<String, dynamic> data = ds.data;
    data["id"] = ds.documentID;
    return Artist.fromMapObject(data);
  }

}

class SharedPrefsRepository extends DatabaseRepository{
  @override
  Future<List<Music>> fetchAllMusics() {
    // TODO: implement fetchAllMusics
    throw UnimplementedError();
  }

  @override
  Future<Music> fetchMusic(String id) {
    // TODO: implement fetchMusic
    throw UnimplementedError();
  }

  @override
  Future<List<Music>> fetchMusicWithThisPattern(String text) {
    // TODO: implement fetchMusicWithThisPattern
    throw UnimplementedError();
  }

  @override
  Future<List<Music>> fetchMusics(List<String> ids) {
    // TODO: implement fetchMusics
    throw UnimplementedError();
  }

  @override
  List<Music> fetchMusicsByQuery(QuerySnapshot qs) {
    // TODO: implement fetchMusicsByQuery
    throw UnimplementedError();
  }

  @override
  Future<List<Transcriber>> fetchTranscriberWithThisPattern(String text) {
    // TODO: implement fetchTranscriberWithThisPattern
    throw UnimplementedError();
  }

  @override
  Future<List<Transcriber>> fetchTranscribers(List<String> ids) {
    // TODO: implement fetchTranscribers
    throw UnimplementedError();
  }

  @override
  List<Transcriber> fetchTranscribersByQuery(QuerySnapshot qs) {
    // TODO: implement fetchTranscribersByQuery
    throw UnimplementedError();
  }

  @override
  List<Artist> fetchArtistsByQuery(QuerySnapshot qs) {
    // TODO: implement fetchArtistsByQuery
    throw UnimplementedError();
  }

  @override
  Future<Artist> fetchArtist(String id) {
    // TODO: implement fetchArtists
    throw UnimplementedError();
  }

  @override
  Artist fetchArtistByQuery(DocumentSnapshot ds) {
    // TODO: implement fetchArtistByQuery
    throw UnimplementedError();
  }

  @override
  Music fetchMusicByQuery(DocumentSnapshot qs) {
    // TODO: implement fetchMusicByQuery
    throw UnimplementedError();
  }

  @override
  Future<List<Artist>> fetchArtistWithThisPattern(String text) {
    // TODO: implement fetchArtistWithThisPattern
    throw UnimplementedError();
  }



}

class NetworkError extends Error {}
