import 'package:equatable/equatable.dart';
import 'package:flykeys/src/model/music.dart';

abstract class MusicState extends Equatable {
  MusicState();
}

class InitialMusicState extends MusicState {

  InitialMusicState();

  @override
  List<Object> get props => [];
}

class MusicListLoadingState extends MusicState {

  MusicListLoadingState();

  @override
  List<Object> get props => [];
}

class MusicLoadingState extends MusicState {

  MusicLoadingState();

  @override
  List<Object> get props => [];
}

class MusicLoadedState extends MusicState {

  final Music music;

  MusicLoadedState(this.music);

  @override
  List<Object> get props => [music];
}

class MusicTrendingListLoadingState extends MusicState {

  final List<Music> alreadyLoadedMusics;

  MusicTrendingListLoadingState(this.alreadyLoadedMusics);

  @override
  List<Object> get props => [alreadyLoadedMusics];
}

class MusicTrendingListLoadedState extends MusicState {

  final List<Music> musics;
  final bool itsTheLastTrendingToFetch;

  MusicTrendingListLoadedState(this.musics, this.itsTheLastTrendingToFetch);

  @override
  List<Object> get props => [musics, itsTheLastTrendingToFetch];
}



class MusicListLoadedState extends MusicState {

  final List<Music> musics;

  MusicListLoadedState(this.musics);

  @override
  List<Object> get props => [musics];
}

class MusicNetworkErrorState extends MusicState {

  MusicNetworkErrorState();

  @override
  List<Object> get props => [];
}