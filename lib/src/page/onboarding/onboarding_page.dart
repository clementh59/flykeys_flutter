import 'package:flutter/material.dart';
import 'package:flykeys/src/page/main_page.dart';
import 'package:flykeys/src/page/onboarding/ask_to_plug_the_cable.dart';
import 'package:flykeys/src/page/onboarding/choose_the_kind_of_piano.dart';
import 'package:flykeys/src/page/onboarding/set_limit_of_keyboard.dart';
import 'package:flykeys/src/page/onboarding/validate_the_choice_of_kind_of_piano.dart';
import 'package:flykeys/src/utils/custom_colors.dart';
import 'package:flykeys/src/utils/custom_style.dart';
import 'package:flykeys/src/utils/strings.dart';
import 'package:flykeys/src/utils/utils.dart';
import 'package:flykeys/src/widget/custom_widgets.dart';

import 'ask_to_plug_the_object.dart';
import 'package:flykeys/src/utils/custom_size.dart';

class OnBoardingPage extends StatefulWidget {
  final Widget nextPage;

  OnBoardingPage({@required this.nextPage});

  @override
  _OnBoardingPageState createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  //region Variables
  Map info = {}; // This map will contains the info passed by the child pages
  // e.g {
  //    'kindOfPiano': 'numeric',
  //    'midiPort': true,
  //    'leftLimit': 21,
  //    'rightLimit': 108,
  // }

  Map onBoardingSteps; // All the possible steps
  Map step; // The actual step
  var history = []; // The history of the steps, to where how to go back
  //endregion

  //region Overrided
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
			 *    'customScroll' : {bool} if the page will handle itself the scroll of the page
			 *  }
			 **/
      'chooseTheKindOfPiano': {
        'index': 0,
        'page': ChooseTheKindOfPiano(info, goToNextStep),
        'next': 'validateTheChoiceOfKindOfPiano',
        /*'helpPage': ChooseTheKindOfPianoPage(),*/ //TODO: help page
      },
      'validateTheChoiceOfKindOfPiano': {
        'index': 1,
        'page': ValidateTheChoiceOfKindOfPiano(info, goToNextStep),
        'next': 'askToPlugTheObject',
      },
      'askToPlugTheObject': {
        'index': 2,
        'page': AskToPlugTheObject(goToNextStep),
        'next': () {
          if (info['midiPort']) return 'askToPlugTheCable';
          return 'setLimitOfKeyboard';
        },
      },
      'askToPlugTheCable': {
        'index': 3,
        'page': AskToPlugTheCable(goToNextStep),
        'next': 'setLimitOfKeyboard',
      },
      'setLimitOfKeyboard': {
        'index': 4,
        'page': SetLimitOfKeyboard(info, goToNextStep, goToPreviousStep),
        //'next': 'explanationModeApprentissage',
        'customScroll': true,
      },
      /*'explanationModeApprentissage': {
        'index': 5,
        'next': 'explanationModeLightningShow',
      },
      'explanationModeLightningShow': {
        'index': 6,
      },*/
    };
    step = onBoardingSteps['chooseTheKindOfPiano'];
    history.add(step);
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
                    children: [
                      header(),
                      body(),
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

  //endregion

  //region Widgets
  Widget header() {
    bool showBackIcon = history.length > 1;

    return Container(
      padding: const EdgeInsets.only(bottom: 34, top: CustomSize.topMarginTopBar),
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: <Widget>[
          if (showBackIcon)
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () {
                  goToPreviousStep();
                },
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.only(left: 31.0),
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

  Widget body() {
    if (step['customScroll'] == true) {
      return step['page'];
    }

    return Expanded(
      child: CustomWidgets.scrollViewWithBoundedHeight(child: step['page']),
    );
  }

  Widget footer() {
    bool showHelpIcon = step['helpPage'] != null;

    return Container(
      padding: const EdgeInsets.only(bottom: 30.0, top: 10),
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
                  SizedBox(
                    width: 5,
                  ),
                  bottomPoint(1),
                  SizedBox(
                    width: 5,
                  ),
                  bottomPoint(2),
                  SizedBox(
                    width: 5,
                  ),
                  bottomPoint(3),
                  SizedBox(
                    width: 5,
                  ),
                  bottomPoint(4),
                  SizedBox(
                    width: 5,
                  ),
                  bottomPoint(5),
                  SizedBox(
                    width: 5,
                  ),
                  bottomPoint(6),
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
                  SizedBox(
                    width: 9,
                  ),
                  Image.asset(
                    'assets/images/onboarding/help_icon.png',
                    width: 20,
                  ),
                  SizedBox(
                    width: 31,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget bottomPoint(int num) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: num == step['index'] ? CustomColors.blue : CustomColors.grey,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  //endregion

  //region Logic
  /// Go to the previous step of the onboarding process
  /// Returns false if there isn't previous step - true otherwise
  bool goToPreviousStep() {
    if (history.length == 0) return false;

    history.removeLast();

    setState(() {
      step = history[history.length - 1];
    });

    return true;
  }

  /// Go to the previous step of the onboarding process
  /// Returns false if there isn't next step - true otherwise
  bool goToNextStep() {
    if (step['next'] == null) { // it means I've finished the onBoarding process
      onOnBoardingFinish();
      return false;
    }

    String next;

    if (step['next'] is String)
      next = step['next'];
    else
      next = step['next']();

    setState(() {
      step = onBoardingSteps[next];
    });

    history.add(step);

    return true;
  }

  void onOnBoardingFinish() {
		Navigator.pushReplacement(
			context,
			Utils.createRoute(() => widget.nextPage),
		);
		Utils.saveBooleanToSharedPreferences(Strings.I_DID_ONBOARDING_SHARED_PREFS, true);
		Utils.saveMapToSharedPreferences(Strings.PIANO_INFOS_SHARED_PREFS, info);
	}
//endregion
}
