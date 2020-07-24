import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flykeys/src/bloc/music/bloc.dart';
import 'package:flykeys/src/bloc/transcribers/bloc.dart';
import 'package:flykeys/src/model/transcriber.dart';
import 'package:flykeys/src/repository/database_repository.dart';
import 'package:flykeys/src/utils/utils.dart';
import './bloc.dart';

class TrendingBloc extends Bloc<TrendingEvent, TrendingState> {

  final TranscriberBloc transcriberBloc;
  final MusicBloc musicBloc;
  final FirestoreRepository firestoreRepository;
  List<String> transcribersIds = [];
  List<String> trendingMusicsIds = [];
  List<String> musicsIdsFetched = [];

  TrendingBloc(this.transcriberBloc, this.musicBloc, this.firestoreRepository);

  @override
  TrendingState get initialState => InitialTrendingState();

  @override
  Stream<TrendingState> mapEventToState(
    TrendingEvent event,
  ) async* {

    if (event is GetTrendings){

      try{

        Map<String, dynamic> map = await firestoreRepository.fetchTrendings();
        List<dynamic> transcribersIdsdyn = map["transcribers"];
        List<dynamic> musicsIdsdyn = map["musics"];
        List<String> musicsIdsToFetch = [];

        for(var i in transcribersIdsdyn){
          transcribersIds.add(i);
        }

        for(var i in musicsIdsdyn){
          trendingMusicsIds.add(i);
        }

        for (int i=0; i<trendingMusicsIds.length && i<Utils.numberOfMusicLoadedFirstTrending; i++){
          musicsIdsToFetch.add(trendingMusicsIds[i]);
        }

        transcriberBloc.add(GetTranscribers(transcribersIds));
        musicBloc.add(GetTrendingMusics(musicsIdsToFetch));
        musicsIdsFetched = musicsIdsToFetch;

      } on NetworkError{
        yield TrendingNetworkErrorState();
      }
    }

    if (event is GetMoreTrendingMusic){

      int musicAdded = 0;
      List<String> musicsIdsToFetch = [];

      for (var i in trendingMusicsIds){
        if (!musicsIdsFetched.contains(i)){
          musicsIdsToFetch.add(i);
          musicAdded++;
          if (musicAdded==Utils.numberOfMusicLoadedWhenCLickLoadMoreMusic)
            break;
        }
      }

      bool itsTheLastTrendingToFetch = false;

      if ((musicsIdsToFetch.length + musicsIdsFetched.length) == trendingMusicsIds.length)
        itsTheLastTrendingToFetch = true;

      if (musicsIdsToFetch.length>0) {
        musicBloc.add(GetMoreTrendingMusics(musicsIdsToFetch, itsTheLastTrendingToFetch));
        musicsIdsFetched.addAll(musicsIdsToFetch);
      }
    }

  }
}
