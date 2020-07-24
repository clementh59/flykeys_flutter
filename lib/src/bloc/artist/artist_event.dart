import 'package:equatable/equatable.dart';

abstract class ArtistEvent extends Equatable {
  ArtistEvent();
}

class GetArtist extends ArtistEvent {

  final String id;

  GetArtist(this.id);

  @override
  List<Object> get props => [id];

}

class SearchArtist extends ArtistEvent {

  final String searchTerm;

  SearchArtist(this.searchTerm);

  @override
  List<Object> get props => [searchTerm];

}