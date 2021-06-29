import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flykeys/src/repository/authentification_repository.dart';
import 'package:flykeys/src/utils/strings.dart';
import './bloc.dart';

class AuthentificationBloc extends Bloc<AuthentificationEvent, AuthentificationState> {
  AuthentificationBloc() : super(InitialAuthentificationState());

  AuthentificationRepository authentificationRepository = AuthentificationRepository();

  @override
  Stream<AuthentificationState> mapEventToState(
    AuthentificationEvent event,
  ) async* {

    if (event is SignUp){
      String result = await authentificationRepository.handleSignUp(event.email, event.pwd, event.name);

      if (result == "OK")
        yield AuthentificateSucceedState();
      else
        yield AuthentificateFailedState(result);

    }

    if (event is AuthentificateByMail){
      String result = await authentificationRepository.handleSignInEmail(event.email, event.pwd);

      if (result == "OK")
        yield AuthentificateSucceedState();
      else
        yield AuthentificateFailedState(result);

    }

    if (event is AuthentificateWithGoogle){
      int result = await authentificationRepository.signInWithGoogle();
      if (result==0){
        yield AuthentificateSucceedState();
      }else{
        yield AuthentificateFailedState(Strings.authenticate_google_failed);
      }
    }

    if (event is ForgotPassword){
      await authentificationRepository.sendForgotPasswordMail(event.mail);
    }

    if (event is CheckIfHeIsLogin){
      if (await authentificationRepository.checkIfHeIsLoggedIn())
        yield AuthentificateSucceedState();
    }

    if (event is DisconnectAuthEvent){
      await authentificationRepository.disconnect();
      yield InitialAuthentificationState();
    }

  }

}
