import 'package:equatable/equatable.dart';

abstract class TranscriberEvent extends Equatable {
  TranscriberEvent();
}

class GetTranscriber extends TranscriberEvent {

  final String id;

  GetTranscriber(this.id);

  @override
  List<Object> get props => [id];

}

class GetTranscribers extends TranscriberEvent {

  final List<String> ids;

  GetTranscribers(this.ids);

  @override
  List<Object> get props => [ids];

}

class SearchTranscriber extends TranscriberEvent {

  final String searchTerm;

  SearchTranscriber(this.searchTerm);

  @override
  List<Object> get props => [searchTerm];

}