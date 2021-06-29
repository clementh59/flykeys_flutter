import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flykeys/src/model/transcriber.dart';
import 'package:flykeys/src/repository/database_repository.dart';
import './bloc.dart';
import 'dart:developer' as dev;


class TranscriberBloc extends Bloc<TranscriberEvent, TranscriberState> {

  final DatabaseRepository transcribersRepository;

  TranscriberBloc(this.transcribersRepository) : super(InitialTranscriberState());

  @override
  Stream<TranscriberState> mapEventToState(
    TranscriberEvent event,
  ) async* {

    dev.log("$event",name: "New event in transcriber bloc");
    if (event is GetTranscribers){
      yield TranscriberListLoadingState();
      try {
        List<Transcriber> transcriberList = await transcribersRepository.fetchTranscribers(event.ids);
        yield TranscriberListLoadedState(transcriberList);
      } on NetworkError {
        yield TranscriberNetworkErrorState();
      }
    }

    if (event is SearchTranscriber){
      yield TranscriberListLoadingState();
      try {
        List<Transcriber> transcriberList = await transcribersRepository.fetchTranscriberWithThisPattern(event.searchTerm);
        yield TranscriberListLoadedState(transcriberList);
      } on NetworkError {
        yield TranscriberNetworkErrorState();
      }
    }

  }
}
