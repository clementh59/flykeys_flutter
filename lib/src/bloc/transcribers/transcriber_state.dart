import 'package:equatable/equatable.dart';
import 'package:flykeys/src/model/transcriber.dart';

abstract class TranscriberState extends Equatable {
  TranscriberState();
}

class InitialTranscriberState extends TranscriberState {

  @override
  List<Object> get props => [];

}

class TranscriberListLoadingState extends TranscriberState {
  @override
  List<Object> get props => [];
}

class TranscriberListLoadedState extends TranscriberState {

  final List<Transcriber> transcribers;

  TranscriberListLoadedState(this.transcribers);

  @override
  List<Object> get props => [transcribers];
}

class TranscriberNetworkErrorState extends TranscriberState {

  TranscriberNetworkErrorState();

  @override
  List<Object> get props => [];
}