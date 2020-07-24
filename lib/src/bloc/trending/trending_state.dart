import 'package:equatable/equatable.dart';

abstract class TrendingState extends Equatable {
  TrendingState();
}

class InitialTrendingState extends TrendingState {
  @override
  List<Object> get props => [];
}

class TrendingNetworkErrorState extends TrendingState {
  @override
  List<Object> get props => [];
}

