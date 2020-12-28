import 'package:flutter/material.dart';
import 'package:flykeys/src/utils/custom_colors.dart';
import 'package:flykeys/src/utils/custom_style.dart';
import 'package:flykeys/src/widget/custom_widgets.dart';

const explanationText = {
  'acoustic':
      'Cela signifie que tu n’as pas besoin de brancher ton piano pour le faire fonctionner (ou de le recharger).\n\nCela signifie également que tu n’as pas de port comme celui-ci sur ton piano pour relier l’objet Flykeys au piano.',
  'numeric':
      'Cela signifie que tu as besoin de brancher ton piano pour le faire fonctionner (ou de le recharger).\n\nCela signifie également que tu as un port comme celui-ci sur ton piano pour relier l’objet Flykeys au piano.',
};

const pianoTypeStrings = {
  'acoustic': 'Acoustique',
  'numeric': 'Numérique',
};

const buttonsText = {
  'acoustic': ['Si, mon piano possède un port pour brancher ce type de câble', 'Non, mon piano ne possède pas de port pour brancher ce type de câble'],
  'numeric': ['Oui, mon piano possède un port pour brancher ce type de câble', 'Non, mon piano ne possède pas de port pour brancher ce type de câble'],
};

class ValidateTheChoiceOfKindOfPiano extends StatelessWidget {
  final Map info;
  final Function onChoice;

  ValidateTheChoiceOfKindOfPiano(this.info, this.onChoice);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(children: [
                    TextSpan(
                      text: 'Ton type de piano est ',
                      style: CustomStyle.bigTextOnBoardingPage,
                    ),
                    TextSpan(
                      text: pianoTypeStrings[info['kindOfPiano']],
                      style: CustomStyle.bigTextOnBoardingPage.copyWith(fontWeight: CustomStyle.BOLD),
                    ),
                  ]),
                ),
              ),
              SizedBox(height: 26),
              Text(
                explanationText[info['kindOfPiano']],
                style: CustomStyle.smallTextOnBoardingPage,
                textAlign: TextAlign.left,
              ),
              SizedBox(height: 31),
              CustomWidgets.midiImages(),
              SizedBox(height: 31),
            ],
          ),
          Column(
            children: <Widget>[
              CustomWidgets.button(buttonsText[info['kindOfPiano']][0], CustomColors.blue, () {
                info['midiPort'] = true;
                onChoice();
              }),
              SizedBox(height: 10),
              CustomWidgets.button(buttonsText[info['kindOfPiano']][1], CustomColors.red, () {
                info['midiPort'] = false;
                onChoice();
              }),
              SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }
}
