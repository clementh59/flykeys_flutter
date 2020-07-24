import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flykeys/src/model/music.dart';
import 'package:flykeys/src/model/transcriber.dart';
import 'package:flykeys/src/repository/database_repository.dart';
import './bloc.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {

  final SharedPrefsRepository sharedPrefsRepository;
  final FirestoreRepository firestoreRepository;

  List<String> likedMusicsIds;
  List<String> likedTranscribersIds;
  List<Music> musics = [];
  List<Transcriber> transcribers = [];

  FavoritesBloc(this.sharedPrefsRepository, this.firestoreRepository);

  @override
  FavoritesState get initialState => InitialFavoritesState();

  @override
  Stream<FavoritesState> mapEventToState(
    FavoritesEvent event,
  ) async* {

    if (event is GetAllFavorites){
      yield ListsLoadingState();
      try {
        likedMusicsIds = await firestoreRepository.fetchLikedMusicIds();
        likedTranscribersIds = await firestoreRepository.fetchFollowedTranscribersIds();
        musics = await firestoreRepository.fetchMusics(likedMusicsIds);
        transcribers = await firestoreRepository.fetchTranscribers(likedTranscribersIds);
        yield ListsLoadedState(musics, transcribers, likedMusicsIds, likedTranscribersIds);
      } on NetworkError {
        yield FavoritesNetworkErrorState();
      }
    }

    if (event is AddAFavoriteMusic){
      yield ListsLoadingState();
      likedMusicsIds.add(event.music.id);
      if (event.music.stars==null){
        yield ListsLoadedState(
          musics, transcribers, likedMusicsIds, likedTranscribersIds);
        Music m = await firestoreRepository.fetchMusic(event.music.id);
        musics.add(m);
        yield ListsLoadedState(
          musics, transcribers, likedMusicsIds, likedTranscribersIds);
      }else {
        yield ListsLoadedState(
          musics, transcribers, likedMusicsIds, likedTranscribersIds);
      }
      firestoreRepository.addToFavorite(event.music);
    }

    if (event is AddAFollowedTranscriber){
      yield ListsLoadingState();
      transcribers.add(event.transcriber);
      likedTranscribersIds.add(event.transcriber.id);
      yield ListsLoadedState(musics, transcribers,likedMusicsIds,likedTranscribersIds);
      firestoreRepository.addToFollowed(event.transcriber);
    }

    if (event is RemoveAFavoriteMusic){
      yield ListsLoadingState();
      musics.remove(event.music);
      likedMusicsIds.remove(event.music.id);
      yield ListsLoadedState(musics, transcribers,likedMusicsIds,likedTranscribersIds);
      firestoreRepository.removeFromFavorite(event.music);
    }

    if (event is RemoveAFollowedTranscriber){
      yield ListsLoadingState();
      transcribers.remove(event.transcriber);
      likedTranscribersIds.remove(event.transcriber.id);
      yield ListsLoadedState(musics, transcribers,likedMusicsIds,likedTranscribersIds);
      firestoreRepository.removeFromFollowed(event.transcriber);
    }

  }
}
