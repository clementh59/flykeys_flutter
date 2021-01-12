import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flykeys/src/bloc/bluetooth/bloc.dart';
import 'package:flykeys/src/bloc/bluetooth/bluetooth_state.dart';
import 'dart:developer' as dev;

import 'package:flykeys/src/widget/custom_widgets.dart';

/**
 * Donne des infos sur l'état de la recherche/connection à l'objet
 */
class SettingUpBluetoothPage extends StatefulWidget {
	final MyBluetoothState state;
	final Function onConnected;
	final Function onDisconnected;

	SettingUpBluetoothPage(this.state, this.onConnected, this.onDisconnected);

	@override
	_SettingUpBluetoothPageState createState() => _SettingUpBluetoothPageState();
}

class _SettingUpBluetoothPageState extends State<SettingUpBluetoothPage> {

	int secondsLeft = 2;

	void scanAgain() {
		BlocProvider.of<BluetoothBloc>(context).add(FindFlyKeysDevice());
	}

	@override
	Widget build(BuildContext context) {
		dev.log("state is ${widget.state}",
			name: "music_page setting up blue build");
		if (widget.state is InitialBluetoothState) {
			return CustomWidgets.textWithoutLoadingIndicator(
				"La recherche de l'objet FlyKeys n'a pas encore commencée!");
		} else if (widget.state is SearchingForFlyKeysDeviceState) {
			return CustomWidgets.textWithLoadingIndicator(
				"Je cherche l'objet FlyKeys!");
		} else if (widget.state is FlyKeysDeviceFoundState) {
			return CustomWidgets.textWithLoadingIndicator("Objet FlyKeys trouvé!");
		} else if (widget.state is SucceedToConnectState) {
			return CustomWidgets.textWithLoadingIndicator(
				"Connection à l'objet réussie!");
		} else if (widget.state is BluetoothIsSetUpState) {
			//Je lui demande maintenant d'envoyer le morceau
			widget.onConnected();
			dev.log("Bluetooth is set up",
				name: "Je demande au bloc la prochaine action");
			return CustomWidgets.textWithLoadingIndicator(
				"Récupération des informations de l'objet réussie!");
		} else if (widget.state is FlyKeysDeviceDisconnectedState) {
			Future.delayed(new Duration(seconds: 2), () {
				//J'ai deux possibilités en arrivant ici, soit j'ai eu FlyKeysDeviceDisconnectedState car je viens de me déconnecter
				// et je dois donc revenir à la page précédente
				// dans ce cas, le state ne bouge pas au bout de 2s, et donc le if et true
				// l'autre cas est que j'ai eu la deconnection une fois et que j'ai recliquer sur une musique,
				// le dernier state était FlyKeysDeviceDisconnectedState et donc j'appelle le future.delayed
				// Cependant le state change tout de suite et passe à findFlyKeys device state
				// Le if suivant ne se fait donc pas
				if (widget.state is FlyKeysDeviceDisconnectedState)
					widget.onDisconnected();
			});
			Future.delayed(new Duration(seconds: 1), () {
				setState(() {
					secondsLeft = 1;
				});
			});
			return CustomWidgets.textWithLoadingIndicator(
				"Une deconnexion est survenu! La page se fermera automatiquement dans " + secondsLeft.toString() + "s");
		}

		//Error :
		else if (widget.state is FlyKeysDeviceNotFoundState) {
			return Center(
				child: Column(
					mainAxisSize: MainAxisSize.min,
					children: <Widget>[
						CustomWidgets.textWithoutLoadingIndicator(
							"Objet FlyKeys non trouvé!"),
						SizedBox(
							height: 15,
						),
						CustomWidgets.buttonLoadMorePopularSongStyle("Chercher de nouveau", scanAgain),
					],
				),
			);
		} else if (widget.state is FailedToConnectState) {
			return CustomWidgets.textWithoutLoadingIndicator(
				"La connection à l'appareil a échouée");
		}

		print(
			"!!!!!!!!!!!ERROR!!!!!!!!!! NOT HANDLED CASE IN SettingUpBluetoothPage");
		return SizedBox();
	}

}