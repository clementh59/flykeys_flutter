import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flykeys/src/model/artist.dart';
import 'package:flykeys/src/repository/database_repository.dart';
import './bloc.dart';
import 'dart:developer' as dev;

class ArtistBloc extends Bloc<ArtistEvent, ArtistState> {

  final DatabaseRepository artistsRepository;

  ArtistBloc(this.artistsRepository);

  @override
  ArtistState get initialState => InitialArtistState();

  @override
  Stream<ArtistState> mapEventToState(
    ArtistEvent event,
  ) async* {
      dev.log("$event",name: "New event in artist bloc");
      if (event is GetArtist){
        yield ArtistLoadingState();
        try {
          Artist artist = await artistsRepository.fetchArtist(event.id);
          yield ArtistLoadedState(artist);
        } on NetworkError {
          yield ArtistNetworkErrorState();
        }
      }

      if (event is SearchArtist){
        yield ArtistListLoadingState();
        try {
          List<Artist> artistList = await artistsRepository.fetchArtistWithThisPattern(event.searchTerm);
          yield ArtistListLoadedState(artistList);
        } on NetworkError {
          yield ArtistNetworkErrorState();
        }
      }
  }
}
