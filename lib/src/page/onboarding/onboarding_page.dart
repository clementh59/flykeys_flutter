import 'package:flutter/material.dart';
import 'package:flykeys/src/page/onboarding/choose_the_kind_of_piano.dart';
import 'package:flykeys/src/page/onboarding/set_the_limit_of_the_piano_with_midi.dart';
import 'package:flykeys/src/page/onboarding/validate_the_choice_of_kind_of_piano.dart';
import 'package:flykeys/src/utils/custom_colors.dart';
import 'package:flykeys/src/utils/custom_style.dart';

class OnBoardingPage extends StatefulWidget {
  @override
  _OnBoardingPageState createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {

  Map info = {}; // This map will contains the info passed by the child pages
  Map onBoardingSteps; // All the possible steps
  Map step; // The actual step

  @override
  void initState() {
    super.initState();
    onBoardingSteps = {
      /**
       * 'key' : {
       *    'index': {int} number of the page,
       *    'page': {Widget} the Widget that will be shown
       *    'next': {String|Function} - the key of next page (if function - it should return the key of the next page)
       *    'helpPage': {Widget} the widget that is show when click on help (if null, help icon isn't shown)
       *  }
       **/
      'chooseTheKindOfPiano': {
        'index': 0,
        'page': ChooseTheKindOfPiano(info,goToNextStep),
        'next': 'validateTheChoiceOfKindOfPiano',
        /*'helpPage': ChooseTheKindOfPianoPage(),*/ //TODO: help page
      },
      'validateTheChoiceOfKindOfPiano': {
        'index': 1,
        'page': ValidateTheChoiceOfKindOfPiano(info,goToNextStep),
        'previous': 'chooseTheKindOfPiano',
        'next': (){if (info['midiPort']) return 'setTheLimitOfThePiano'; return 'explanationModeApprentissage';},
      },
      'setTheLimitOfThePiano': {
        'index': 2,
        'page': SetTheLimitOfThePianoWithMidi(info,goToNextStep),
        'previous': 'validateTheChoiceOfKindOfPiano',
        'next': 'explanationModeApprentissage'
      },
      'explanationModeApprentissage': {
        'index': 3,
        'previous': 'validateTheChoiceOfKindOfPiano',
        'next': 'explanationModeLightningShow'
      },
      'explanationModeLightningShow': {
        'index': 4,
        'previous': 'explanationModeApprentissage'
      },
    };
    step = onBoardingSteps['setTheLimitOfThePiano'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.backgroundColor,
      body: SafeArea(
        child: WillPopScope(
          onWillPop: () async {
            if (goToPreviousStep()) return false;
            return true;
          },
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      header(),
                      step['page'],
                    ],
                  ),
                ),
                footer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /***************      WIDGETS   ********************/

  Widget header() {

    bool showBackIcon = step['previous']!=null;

    return Container(
      padding: const EdgeInsets.only(top: 30.0, bottom: 34),
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: <Widget>[
          if (showBackIcon)
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: (){
                  goToPreviousStep();
                },
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.only(left:31.0),
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          Align(
            alignment: Alignment.center,
            child: Text(
              'Bienvenue',
              style: CustomStyle.titleOnBoardingPage,
            ),
          ),
        ],
      ),
    );
  }

  Widget footer() {

    bool showHelpIcon = step['helpPage']!=null;

    return Container(
      padding: const EdgeInsets.only(bottom: 30.0),
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: Container(
              height: 23,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  bottomPoint(0),
                  SizedBox(width: 5,),
                  bottomPoint(1),
                  SizedBox(width: 5,),
                  bottomPoint(2),
                  SizedBox(width: 5,),
                  bottomPoint(3),
                ],
              ),
            ),
          ),
          if (showHelpIcon)
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'AIDE',
                    style: CustomStyle.smallTextOnBoardingPage,
                  ),
                  SizedBox(width: 9,),
                  Image.asset('assets/images/onboarding/help_icon.png', width: 20,),
                  SizedBox(width: 31,),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget bottomPoint(int num){
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: num==step['index']? CustomColors.blue : CustomColors.grey,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  /***************      STEPS LOGIC   ********************/

  /// Go to the previous step of the onboarding process
  /// Returns false if there isn't previous step - true otherwise
  bool goToPreviousStep() {
    if (step['previous']==null) return false;

    setState(() {
      step = onBoardingSteps[step['previous']];
    });

    return true;
  }

  /// Go to the previous step of the onboarding process
  /// Returns false if there isn't next step - true otherwise
  bool goToNextStep() {
    if (step['next']==null) return false;

    String next;

    if (step['next'] is String)
      next = step['next'];
    else
      next = step['next']();

    setState(() {
      step = onBoardingSteps[next];
    });

    return true;
  }
}
