import 'package:equatable/equatable.dart';

abstract class MyBluetoothState extends Equatable {
  MyBluetoothState();
}

//abstract

abstract class BluetoothMainStateSendingMorceau extends MyBluetoothState{
  BluetoothMainStateSendingMorceau();
}

abstract class BluetoothMainStateSettingUp extends MyBluetoothState{
  BluetoothMainStateSettingUp();
}

abstract class BluetoothInteractWithMusic extends MyBluetoothState{
  BluetoothInteractWithMusic();
}

class InitialBluetoothState extends BluetoothMainStateSettingUp {
  @override
  List<Object> get props => [];
}

class FlyKeysDeviceDisconnectedState extends BluetoothMainStateSettingUp {
  @override
  List<Object> get props => [];
}

/********************* Looking for flyKeys object and connecting... ***************************/

class SearchingForFlyKeysDeviceState extends BluetoothMainStateSettingUp{

  SearchingForFlyKeysDeviceState();

  @override
  List<Object> get props => [];

}

class FlyKeysDeviceFoundState extends BluetoothMainStateSettingUp{

  FlyKeysDeviceFoundState();

  @override
  List<Object> get props => [];

}

class FlyKeysDeviceNotFoundState extends BluetoothMainStateSettingUp{

  FlyKeysDeviceNotFoundState();

  @override
  List<Object> get props => [];

}

/**
 * Si je n'arrive pas à me connecter ou si les characteristiques présent dans le device ne sont pas les bonnes
 */
class FailedToConnectState extends BluetoothMainStateSettingUp{

  FailedToConnectState();

  @override
  List<Object> get props => [];

}

class SucceedToConnectState extends BluetoothMainStateSettingUp{

  SucceedToConnectState();

  @override
  List<Object> get props => [];

}

/**
 * Lorsque je suis connecté et que j'ai recupéré les caractéristiques
 */
class BluetoothIsSetUpState extends BluetoothMainStateSettingUp{

  BluetoothIsSetUpState();

  @override
  List<Object> get props => [];

}

/********************************  Sending data ***********************************/

class SendingMorceauState extends BluetoothMainStateSendingMorceau{

  final double avancement;

  SendingMorceauState(this.avancement);

  @override
  List<Object> get props => [avancement];
}

class FetchingMorceauState extends BluetoothMainStateSendingMorceau{

  FetchingMorceauState();

  @override
  List<Object> get props => [];
}

class DecodageMorceauState extends BluetoothMainStateSendingMorceau{

  DecodageMorceauState();

  @override
  List<Object> get props => [];
}

class TraitementMorceauState extends BluetoothMainStateSendingMorceau{

  TraitementMorceauState();

  @override
  List<Object> get props => [];
}

/**
 * Je return cet event si j'abandonne l'envoi du morceau avant même de l'avoir envoyé à l'esp32 (lors du téléchargement,du traitement, ...)
 */
class SendingMorceauAbortedState extends BluetoothMainStateSendingMorceau{

  SendingMorceauAbortedState();

  @override
  List<Object> get props => [];
}

/********************************  Interact With music ***********************************/

class MorceauSentState extends BluetoothInteractWithMusic{

  MorceauSentState();

  @override
  List<Object> get props => [];
}

class PlayingMusicState extends BluetoothInteractWithMusic{

  PlayingMusicState();

  @override
  List<Object> get props => [];
}

class StoppedMusicState extends BluetoothInteractWithMusic{

  StoppedMusicState();

  @override
  List<Object> get props => [];
}

/**
 * Lorsque je demande à aller à un endroit du morceau que je n'ai pas envoyer à l'esp
 * Je dois mettre un id car sinon, si je yield plusieurs fois TickNotPossibleState, je ne build que la premiere étant donnée que le state reste le même
 * Je ne montre donc la snackbar une seule fois, ce qui n'est pas ce que je veux!
 * Je rajoute un id pour voir des states différents et donc pour build une nouvelle fois et montrer de nouveau la snackbar!
 */
class TickNotPossibleState extends BluetoothInteractWithMusic{

  int id;

  TickNotPossibleState(this.id);

  @override
  List<Object> get props => [id];
}

/**
 * When you send play or stop, there is a delay between the time that you send and the time that the device read it. Between this delay, the state is loadingCommandMusicState
 */
class LoadingCommandMusicState extends BluetoothInteractWithMusic{

  LoadingCommandMusicState();

  @override
  List<Object> get props => [];
}