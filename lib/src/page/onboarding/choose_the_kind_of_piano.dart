import 'package:flutter/material.dart';
import 'package:flykeys/src/utils/custom_colors.dart';
import 'package:flykeys/src/utils/custom_style.dart';

class ChooseTheKindOfPiano extends StatelessWidget {

  final Map info; // The map that will contain the choice of piano
  final Function onChoice;

  ChooseTheKindOfPiano(this.info, this.onChoice);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 58),
          child: Text(
            'De quel type est ton piano?',
            style: CustomStyle.bigTextOnBoardingPage,
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 58),
        _numericButton(context),
        SizedBox(height: 25),
        _orLine(),
        SizedBox(height: 25),
        _acousticButton(context),
      ],
    );
  }

  Widget _numericButton(context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 58),
        child: InkWell(
          onTap: () {
            info['kindOfPiano'] = 'numeric';
            onChoice();
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Color.fromRGBO(255, 255, 255, 0.1),
            ),
            child: Column(
              children: <Widget>[
                SizedBox(height: 10),
                Image.asset('assets/images/onboarding/piano-numerique.png', width: 87),
                SizedBox(height: 5),
                Text(
                  'Numérique',
                  style: CustomStyle.bigButtonTextOnBoardingPage,
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _acousticButton(context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 58),
        child: InkWell(
          onTap: () {
            info['kindOfPiano'] = 'acoustic';
            onChoice();
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Color.fromRGBO(255, 255, 255, 0.1),
            ),
            child: Column(
              children: <Widget>[
                SizedBox(height: 14),
                Image.asset('assets/images/onboarding/grand-piano.png', width: 77,),
                SizedBox(height: 12),
                Text(
                  'Acoustique',
                  style: CustomStyle.bigButtonTextOnBoardingPage,
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _orLine() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Container(
              height: 1,
              color: CustomColors.blue,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 45.0),
            child: Text(
              'OU',
              style: CustomStyle.bigTextOnBoardingPage,
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              color: CustomColors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
