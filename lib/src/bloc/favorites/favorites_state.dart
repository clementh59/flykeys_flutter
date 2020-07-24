import 'package:equatable/equatable.dart';
import 'package:flykeys/src/model/music.dart';
import 'package:flykeys/src/model/transcriber.dart';

abstract class FavoritesState extends Equatable {
  FavoritesState();
}

class InitialFavoritesState extends FavoritesState {
  @override
  List<Object> get props => [];
}

class ListsLoadingState extends FavoritesState {

  ListsLoadingState();

  @override
  List<Object> get props => [];
}

class ListsLoadedState extends FavoritesState {

  final List<Transcriber> transcribers;
  final List<Music> musics;
  final List<String> musicsId;
  final List<String> transcribersId;

  ListsLoadedState(this.musics, this.transcribers, this.musicsId, this.transcribersId);

  @override
  List<Object> get props => [];
}

class FavoritesNetworkErrorState extends FavoritesState {

  FavoritesNetworkErrorState();

  @override
  List<Object> get props => [];
}
