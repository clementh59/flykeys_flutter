import 'package:equatable/equatable.dart';

abstract class TrendingEvent extends Equatable {
  TrendingEvent();
}

class GetTrendings extends TrendingEvent{

  GetTrendings();

  @override
  List<Object> get props => [];
}

class GetMoreTrendingMusic extends TrendingEvent{

  GetMoreTrendingMusic();

  @override
  List<Object> get props => [];
}

