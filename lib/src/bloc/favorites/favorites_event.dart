import 'package:equatable/equatable.dart';
import 'package:flykeys/src/model/music.dart';
import 'package:flykeys/src/model/transcriber.dart';

abstract class FavoritesEvent extends Equatable {
  FavoritesEvent();
}

class GetAllFavorites extends FavoritesEvent {

  GetAllFavorites();

  @override
  List<Object> get props => [];

}

class AddAFavoriteMusic extends FavoritesEvent {

  final Music music;

  AddAFavoriteMusic(this.music);

  @override
  List<Object> get props => [music];

}

class RemoveAFavoriteMusic extends FavoritesEvent {

  final Music music;

  RemoveAFavoriteMusic(this.music);

  @override
  List<Object> get props => [music];

}

class RemoveAFollowedTranscriber extends FavoritesEvent {

  final Transcriber transcriber;

  RemoveAFollowedTranscriber(this.transcriber);

  @override
  List<Object> get props => [transcriber];

}

class AddAFollowedTranscriber extends FavoritesEvent {

  final Transcriber transcriber;

  AddAFollowedTranscriber(this.transcriber);

  @override
  List<Object> get props => [transcriber];

}
