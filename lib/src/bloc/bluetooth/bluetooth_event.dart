import 'package:equatable/equatable.dart';

abstract class BluetoothEvent extends Equatable {
  BluetoothEvent();
}

class FindFlyKeysDevice extends BluetoothEvent{
  @override
  List<Object> get props => [];

  FindFlyKeysDevice();
}

class SendMorceauEvent extends BluetoothEvent{

  final String id;

  SendMorceauEvent(this.id);

  @override
  List<Object> get props => [id];
}

class StopSendingMorceauEvent extends BluetoothEvent{

  StopSendingMorceauEvent();

  @override
  List<Object> get props => [];
}

class PlayEvent extends BluetoothEvent{
  PlayEvent();

  @override
  List<Object> get props => [];
}

class StopEvent extends BluetoothEvent{
  StopEvent();

  @override
  List<Object> get props => [];
}

class MorceauIsFinishEvent extends BluetoothEvent{
  MorceauIsFinishEvent();

  @override
  List<Object> get props => [];
}

class SendSpeedEvent extends BluetoothEvent{

  final double speed;

  SendSpeedEvent(this.speed);

  @override
  List<Object> get props => [speed];
}

/**
 * Utile pour le mode apprentissage, si je dois ou non attendre que
 * l'utilisateur appuie sur une touche pour faire défiler
 */
class AskToWaitForTheUserInputEvent extends BluetoothEvent{

	AskToWaitForTheUserInputEvent();

  @override
  List<Object> get props => [];
}

/**
 * Utile pour le mode apprentissage, si je dois ou non attendre que
 * l'utilisateur appuie sur une touche pour faire défiler
 */
class AskToNotWaitForTheUserInputEvent extends BluetoothEvent{

	AskToNotWaitForTheUserInputEvent();

  @override
  List<Object> get props => [];
}

/**
 * Si je souhaite que l'objet affiche les deux mains du morceau
 */
class ShowMeTheTwoHands extends BluetoothEvent{

  ShowMeTheTwoHands();

  @override
  List<Object> get props => [];
}

/**
 * Si je souhaite que l'objet affiche uniquement la main gauche du morceau
 */
class ShowMeOnlyTheLeftHand extends BluetoothEvent{

  ShowMeOnlyTheLeftHand();

  @override
  List<Object> get props => [];
}

/**
 * Si je souhaite que l'objet affiche uniquement la main droite du morceau
 */
class ShowMeOnlyTheRightHand extends BluetoothEvent{

  ShowMeOnlyTheRightHand();

  @override
  List<Object> get props => [];
}

/**
 * Envoi mes couleurs à l'esp32
 */
class EnvoiMesCouleursEvent extends BluetoothEvent{

	EnvoiMesCouleursEvent();

	@override
	List<Object> get props => [];
}

class SendNewTickEvent extends BluetoothEvent{

  final int tick;

  SendNewTickEvent(this.tick);

  @override
  List<Object> get props => [tick];
}

class DisconnectEvent extends BluetoothEvent{

  DisconnectEvent();

  @override
  List<Object> get props => [];
}

class LightningShowEvent extends BluetoothEvent{

  LightningShowEvent();

  @override
  List<Object> get props => [];

}

/**
 * Lorsque je quitte la musique pour revenir au choix de la musique
 */
class QuitMusicEvent extends BluetoothEvent{

  QuitMusicEvent();

  @override
  List<Object> get props => [];
}