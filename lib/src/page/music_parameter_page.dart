import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flykeys/src/bloc/bluetooth/bloc.dart';
import 'package:flykeys/src/utils/custom_colors.dart';
import 'package:flykeys/src/utils/custom_size.dart';
import 'package:flykeys/src/utils/custom_style.dart';
import 'package:flykeys/src/utils/strings.dart';
import 'package:flykeys/src/utils/utils.dart';
import 'package:flykeys/src/model/music.dart';

const MAIN_DROITE = 0;
const MAIN_GAUCHE = 1;

class MusicParameterPage extends StatefulWidget {
  final Music music;

  const MusicParameterPage(this.music);

  @override
  _MusicParameterPageState createState() => _MusicParameterPageState();
}

class _MusicParameterPageState extends State<MusicParameterPage> {
  bool waitForUserInput =
      false; // state of the switch to know if I have to wait for the user input to make the morceau fall down or not
  bool expandChooseHandParameter =
      true; // If I expand the option block that allow me to choose the hand I want to play
  List<bool> selectedHands = [true, true]; //[MAIN_DROITE, MAIN_GAUCHE]

  @override
  void initState() {
    super.initState();
    initWaitForUserInput();
    initLaMainSelectionnee();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.backgroundColor,
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: CustomSize.leftAndRightPadding),
              child: _topBar("Settings"),
            ),
            SizedBox(
              height: 31,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: CustomSize.leftAndRightPadding),
              child: _tilesParameterWidget(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tileParameterWidget(String name, Widget imageAsset, Function callBack,
      {bool showRightArrow = false,
      bool showSwitch = false,
      bool switchState = false}) {
    return InkWell(
      onTap: callBack,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 9.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 32,
                width: 32,
                child: imageAsset,
              ),
            ),
            SizedBox(
              width: 15,
            ),
            Expanded(
              child: Text(
                name,
                style: CustomStyle.notificationNameParameterPage,
              ),
            ),
            showRightArrow
                ? Icon(
                    Icons.arrow_forward_ios,
                    color: CustomColors.white,
                    size: 18,
                  )
                : SizedBox(),
            showSwitch
                ? Switch(
                    onChanged: (bool) {
                      callBack();
                    },
                    activeColor: CustomColors.blue,
                    value: switchState,
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }

  String getTextCorrespondingToHands() {
    if (selectedHands[MAIN_GAUCHE] && selectedHands[MAIN_DROITE])
      return 'les deux mains';
    if (selectedHands[MAIN_DROITE]) return 'la main droite';
    return 'la main gauche';
  }

  Widget _handCard(
      String imageAsset, String handName, Function callback, bool selected) {
    return InkWell(
      onTap: callback,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Container(
        width: 71,
        decoration: BoxDecoration(
          color: selected ? CustomColors.darkerBlue : Colors.transparent,
          border: Border.all(
              color: selected ? CustomColors.blue : Colors.transparent),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Image.asset(imageAsset),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Text(
                handName,
                style: CustomStyle.handNameMusicParameterPage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _handsCards() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _handCard('assets/images/icons/hands/left_hand.png', 'GAUCHE', () {
            setState(() {
              selectedHands[MAIN_GAUCHE] = !selectedHands[MAIN_GAUCHE];
              if (!selectedHands[MAIN_GAUCHE] && !selectedHands[MAIN_DROITE])
                selectedHands[MAIN_DROITE] = true;
            });
            envoiLeChangementDeMain();
          }, selectedHands[MAIN_GAUCHE]),
          SizedBox(
            width: 18,
          ),
          _handCard('assets/images/icons/hands/right_hand.png', 'DROITE', () {
            setState(() {
              selectedHands[MAIN_DROITE] = !selectedHands[MAIN_DROITE];
              if (!selectedHands[MAIN_GAUCHE] && !selectedHands[MAIN_DROITE])
                selectedHands[MAIN_GAUCHE] = true;
            });
            envoiLeChangementDeMain();
          }, selectedHands[MAIN_DROITE]),
        ],
      ),
    );
  }

  Widget _chooseHandWidget() {
    return Padding(
      padding: EdgeInsets.only(bottom: 9),
      child: Column(
        children: <Widget>[
          InkWell(
            onTap: () {
              setState(() {
                expandChooseHandParameter = !expandChooseHandParameter;
              });
            },
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            child: Row(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: 32,
                    width: 32,
                    child: Image.asset(
                        "assets/images/icons/parameter/hand_icon.png"),
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                Expanded(
                    child: RichText(
                  text: TextSpan(
                    style: CustomStyle.notificationNameParameterPage,
                    children: <TextSpan>[
                      TextSpan(text: 'Je travaille '),
                      TextSpan(
                          text: getTextCorrespondingToHands(),
                          style: TextStyle(fontWeight: CustomStyle.BOLD)),
                    ],
                  ),
                )),
                Transform.rotate(
                  angle: expandChooseHandParameter ? -pi / 2 : pi / 2,
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: CustomColors.white,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
          if (expandChooseHandParameter) _handsCards()
        ],
      ),
    );
  }

  Widget _topBar(String text) {
    return Stack(
      children: [
        Align(
            alignment: Alignment.topLeft,
            child: InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              child: Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 24,
              ),
            )),
        Align(
            alignment: Alignment.topCenter,
            child: Text(
              text,
              style: CustomStyle.pageTitle,
            )),
      ],
    );
  }

  Widget _tilesParameterWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tileParameterWidget(
            "Attendre que j'appuie pour continuer",
            Image.asset(
                "assets/images/icons/parameter/wait_for_user_input_icon.png"),
            clickOnWaitForUserInput,
            showSwitch: true,
            switchState: waitForUserInput),
        _chooseHandWidget(),
      ],
    );
  }

  void clickOnWaitForUserInput() {
    if (waitForUserInput) {
      BlocProvider.of<BluetoothBloc>(context)
          .add(AskToNotWaitForTheUserInputEvent());
    } else {
      BlocProvider.of<BluetoothBloc>(context)
          .add(AskToWaitForTheUserInputEvent());
    }

    setState(() {
      waitForUserInput = !waitForUserInput;
    });

    Utils.saveBooleanFromSharedPreferences(
        Strings.WAIT_FOR_USER_INPUT, waitForUserInput);
  }

  void initWaitForUserInput() async {
    bool _tempoWaitForUserInput = await Utils.getBooleanFromSharedPreferences(
        Strings.WAIT_FOR_USER_INPUT,
        defaultValue: false);
    setState(() {
      waitForUserInput = _tempoWaitForUserInput;
    });
  }

  void initLaMainSelectionnee() async {
    bool md = await Utils.getBooleanFromSharedPreferences(widget.music.id + '_MD', defaultValue: true);
    bool mg = await Utils.getBooleanFromSharedPreferences(widget.music.id + '_MG', defaultValue: true);
    setState(() {
      selectedHands[MAIN_DROITE] = md;
      selectedHands[MAIN_GAUCHE] = mg;
    });
  }

  void envoiLeChangementDeMain() async {
    if (selectedHands[MAIN_GAUCHE] && selectedHands[MAIN_DROITE]){
      BlocProvider.of<BluetoothBloc>(context)
          .add(ShowMeTheTwoHands());
    }
    else if (selectedHands[MAIN_DROITE]) {
      BlocProvider.of<BluetoothBloc>(context)
          .add(ShowMeOnlyTheRightHand());
    }
    else {
      BlocProvider.of<BluetoothBloc>(context)
          .add(ShowMeOnlyTheLeftHand());
    }
    Utils.saveBooleanFromSharedPreferences(widget.music.id + '_MD', selectedHands[MAIN_DROITE]);
    Utils.saveBooleanFromSharedPreferences(widget.music.id + '_MG', selectedHands[MAIN_GAUCHE]);
  }

}
