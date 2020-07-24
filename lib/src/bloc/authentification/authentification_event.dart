import 'package:equatable/equatable.dart';

abstract class AuthentificationEvent extends Equatable {
  AuthentificationEvent();
}

class AuthentificateByMail extends AuthentificationEvent {

  final String email;
  final String pwd;

  AuthentificateByMail(this.email, this.pwd);

  @override
  List<Object> get props => [email, pwd];

}

class SignUp extends AuthentificationEvent {

  final String email;
  final String pwd;
  final String name;

  SignUp(this.email, this.pwd, this.name);

  @override
  List<Object> get props => [email, pwd];

}

class AuthentificateWithGoogle extends AuthentificationEvent{

  AuthentificateWithGoogle();

  @override
  List<Object> get props => [];

}

class ForgotPassword extends AuthentificationEvent{

  final String mail;

  ForgotPassword(this.mail);

  @override
  List<Object> get props => [mail];

}

class CheckIfHeIsLogin extends AuthentificationEvent{

  CheckIfHeIsLogin();

  @override
  List<Object> get props => [];

}

class DisconnectAuthEvent extends AuthentificationEvent{

  DisconnectAuthEvent();

  @override
  List<Object> get props => [];

}