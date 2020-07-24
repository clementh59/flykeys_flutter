import 'package:equatable/equatable.dart';
import 'package:flykeys/src/model/artist.dart';

abstract class ArtistState extends Equatable {
  ArtistState();
}

class InitialArtistState extends ArtistState {
  @override
  List<Object> get props => [];
}

class ArtistListLoadingState extends ArtistState {
  @override
  List<Object> get props => [];
}

class ArtistListLoadedState extends ArtistState {

  final List<Artist> artists;

  ArtistListLoadedState(this.artists);

  @override
  List<Object> get props => [artists];
}

class ArtistLoadingState extends ArtistState {
  @override
  List<Object> get props => [];
}

class ArtistLoadedState extends ArtistState {

  final Artist artist;

  ArtistLoadedState(this.artist);

  @override
  List<Object> get props => [artist];
}



class ArtistNetworkErrorState extends ArtistState {

  ArtistNetworkErrorState();

  @override
  List<Object> get props => [];
}