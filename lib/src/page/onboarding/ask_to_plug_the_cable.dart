import 'package:flutter/material.dart';
import 'package:flykeys/src/utils/custom_style.dart';
import 'package:flykeys/src/widget/custom_widgets.dart';

class AskToPlugTheCable extends StatelessWidget {

  final Function onChoice;

  AskToPlugTheCable(this.onChoice);

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
                  'Branchez le cable MIDI à votre piano',
                  style: CustomStyle.bigTextOnBoardingPage,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 26),
              Text(
                'L’application va communiquer avec l’objet pour vérifier que la communication avec le piano est valide.',
                style: CustomStyle.smallTextOnBoardingPage,
                textAlign: TextAlign.left,
              ),
              SizedBox(height: 31),
              CustomWidgets.midiImages(),
              SizedBox(height: 58),
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