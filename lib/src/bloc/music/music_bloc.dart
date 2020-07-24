import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flykeys/src/model/music.dart';
import 'package:flykeys/src/repository/database_repository.dart';
import 'dart:developer' as dev;
import 'bloc.dart';

class MusicBloc extends Bloc<MusicEvent, MusicState> {
  final DatabaseRepository musicRepository;

  //to keep trending musics that are already loaded
  List<Music> trendingMusic = [];

  MusicBloc(this.musicRepository);

  @override
  MusicState get initialState => InitialMusicState();

  @override
  Stream<MusicState> mapEventToState(
    MusicEvent event,
  ) async* {

    dev.log("$event",name: "New event in music bloc");

    if (event is GetAllMusic) {
      yield MusicListLoadingState();
      try {
        List<Music> musicList = await musicRepository.fetchAllMusics();
        yield MusicListLoadedState(musicList);
      } on NetworkError {
        yield MusicNetworkErrorState();
      }
    }

    if (event is GetTrendingMusics){
      yield MusicListLoadingState();
      try {
        List<Music> musicList = await musicRepository.fetchMusics(event.ids);
        trendingMusic = musicList;
        yield MusicTrendingListLoadedState(musicList, false);
      } on NetworkError {
        yield MusicNetworkErrorState();
      }
    }

    if (event is GetMoreTrendingMusics){
      yield MusicTrendingListLoadingState(trendingMusic);
      try {
        List<Music> musicList = await musicRepository.fetchMusics(event.ids);
        trendingMusic.addAll(musicList);
        yield MusicTrendingListLoadedState(trendingMusic, event.itsTheLastTrendings);
      } on NetworkError {
        yield MusicNetworkErrorState();
      }
    }

    if (event is SearchMusic){
      yield MusicListLoadingState();
      try {
        List<Music> musicList = await musicRepository.fetchMusicWithThisPattern(event.searchTerm);
        yield MusicListLoadedState(musicList);
      } on NetworkError {
        yield MusicNetworkErrorState();
      }
    }

    if (event is GetMusic){
      yield MusicLoadingState();
      try {
        Music music = await musicRepository.fetchMusic(event.id);
        yield MusicLoadedState(music);
      } on NetworkError {
        yield MusicNetworkErrorState();
      }
    }

  }
}