import 'package:flutter/material.dart';
import 'package:flykeys/src/utils/custom_style.dart';
import 'package:flykeys/src/widget/custom_widgets.dart';

class AskToPlugTheObject extends StatelessWidget {

	final Function onChoice;

	AskToPlugTheObject(this.onChoice);

	@override
	Widget build(BuildContext context) {
		return Padding(
			padding: const EdgeInsets.symmetric(horizontal: 30),
			child: Column(
				mainAxisSize: MainAxisSize.max,
				mainAxisAlignment: MainAxisAlignment.spaceBetween,
				crossAxisAlignment: CrossAxisAlignment.center,
				children: <Widget>[
					Column(
						mainAxisSize: MainAxisSize.min,
						children: <Widget>[
							Padding(
								padding: const EdgeInsets.symmetric(horizontal: 28),
								child: Text(
									'Branchez l’objet Flykeys',
									style: CustomStyle.bigTextOnBoardingPage,
									textAlign: TextAlign.center,
								),
							),
							SizedBox(height: 26),
							Text(
								'L’application va communiquer avec l’objet pour configurer les limites de votre piano. Pour cela, il faut brancher l\'objet Flykeys sur une prise électrique.',
								style: CustomStyle.smallTextOnBoardingPage,
								textAlign: TextAlign.left,
							),
						],
					),
					Padding(
						padding: const EdgeInsets.symmetric(vertical: 20.0),
						child: CustomWidgets.buttonLoadMorePopularSongStyle("C'est fait", onChoice, fontSize: 16.0),
					),
				],
			),
		);
	}

}