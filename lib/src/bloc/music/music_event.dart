import 'package:equatable/equatable.dart';

abstract class MusicEvent extends Equatable {
  MusicEvent();
}

class GetMusic extends MusicEvent {

  final String id;

  GetMusic(this.id);

  @override
  List<Object> get props => [id];

}

class GetMusics extends MusicEvent {

  final List<String> ids;

  GetMusics(this.ids);

  @override
  List<Object> get props => [ids];

}

class GetTrendingMusics extends MusicEvent {

  final List<String> ids;

  GetTrendingMusics(this.ids);

  @override
  List<Object> get props => [ids];

}

class GetMoreTrendingMusics extends MusicEvent {

  final List<String> ids;
  final bool itsTheLastTrendings;

  GetMoreTrendingMusics(this.ids, this.itsTheLastTrendings);

  @override
  List<Object> get props => [ids];

}

class SearchMusic extends MusicEvent {

  final String searchTerm;

  SearchMusic(this.searchTerm);

  @override
  List<Object> get props => [searchTerm];

}

class GetAllMusic extends MusicEvent {

  GetAllMusic();

  @override
  List<Object> get props => [];

}