import 'package:equatable/equatable.dart';

abstract class AuthentificationState extends Equatable {
  AuthentificationState();
}

class InitialAuthentificationState extends AuthentificationState {
  @override
  List<Object> get props => [];
}

class AuthentificateSucceedState extends AuthentificationState {
  @override
  List<Object> get props => [];
}

class AuthentificateFailedState extends AuthentificationState {

  final String result;

  AuthentificateFailedState(this.result);

  @override
  List<Object> get props => [result];
}

