import 'package:flutter/material.dart';
import 'package:flykeys/src/utils/custom_colors.dart';
import 'package:flykeys/src/utils/custom_style.dart';
import 'package:flykeys/src/widget/custom_widgets.dart';

//region Global variables
const explanationText = {
  'acoustic':
      'Cela signifie que vous n’avez pas besoin de brancher votre piano pour le faire fonctionner (ou de le recharger).\n\nCela signifie également que vous n’avez pas de port comme celui-ci sur votre piano pour relier l’objet Flykeys au piano.',
  'numeric':
      'Cela signifie que vous avez besoin de brancher votre piano pour le faire fonctionner (ou de le recharger).\n\nCela signifie également que vous avez un port comme celui-ci sur votre piano pour relier l’objet Flykeys au piano.',
};

const pianoTypeStrings = {
  'acoustic': 'Acoustique',
  'numeric': 'Numérique',
};

const buttonsText = {
  'acoustic': ['Si, mon piano possède un port pour brancher ce type de câble', 'Non, mon piano ne possède pas de port pour brancher ce type de câble'],
  'numeric': ['Oui, mon piano possède un port pour brancher ce type de câble', 'Non, mon piano ne possède pas de port pour brancher ce type de câble'],
};
//endregion

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
                      text: 'Votre type de piano est ',
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
