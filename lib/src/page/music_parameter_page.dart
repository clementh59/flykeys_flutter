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
import 'package:flykeys/src/widget/custom_widgets.dart';

const MAIN_DROITE = 0;
const MAIN_GAUCHE = 1;

class MusicParameterPage extends StatefulWidget {
  final Music music;
  final Duration durationOfTheMorceau;

  const MusicParameterPage(this.music, this.durationOfTheMorceau);

  @override
  _MusicParameterPageState createState() => _MusicParameterPageState();
}

class _MusicParameterPageState extends State<MusicParameterPage> {
  //region Variables
  bool waitForUserInput = false; // state of the switch to know if I have to wait for the user input to make the morceau fall down or not
  bool expandChooseHandParameter = true; // If I expand the option block that allow me to choose the hand I want to play
  bool repeatAPartOfTheMorceau = false; // Si je répète une partie en double ou non
  List<bool> selectedHands = [true, true]; //[MAIN_DROITE, MAIN_GAUCHE]

  RangeValues _currentRepeatRangeValues;

  //endregion

  //region Overrides
  @override
  void initState() {
    super.initState();
    initWaitForUserInput();
    initLaMainSelectionnee();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initRepeatRangeValues();
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
              padding: const EdgeInsets.symmetric(horizontal: CustomSize.leftAndRightPadding),
              child: _topBar("Paramètres"),
            ),
            SizedBox(
              height: 31,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: CustomSize.leftAndRightPadding),
              child: _tilesParameterWidget(),
            ),
          ],
        ),
      ),
    );
  }

  //endregion

  //region Widget
  Widget _tileParameterWidget(String name, Widget imageAsset, Function callBack, {bool showRightArrow = false, bool showSwitch = false, bool switchState = false}) {
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

  //region hand
  Widget _handCard(String imageAsset, String handName, Function callback, bool selected) {
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
          border: Border.all(color: selected ? CustomColors.blue : Colors.transparent),
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
              if (!selectedHands[MAIN_GAUCHE] && !selectedHands[MAIN_DROITE]) selectedHands[MAIN_DROITE] = true;
            });
            envoiLeChangementDeMain();
          }, selectedHands[MAIN_GAUCHE]),
          SizedBox(
            width: 18,
          ),
          _handCard('assets/images/icons/hands/right_hand.png', 'DROITE', () {
            setState(() {
              selectedHands[MAIN_DROITE] = !selectedHands[MAIN_DROITE];
              if (!selectedHands[MAIN_GAUCHE] && !selectedHands[MAIN_DROITE]) selectedHands[MAIN_GAUCHE] = true;
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
                    child: Image.asset("assets/images/icons/parameter/hand_icon.png"),
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
                      TextSpan(text: getTextCorrespondingToHands(), style: TextStyle(fontWeight: CustomStyle.BOLD)),
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

  //endregion

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
        _tileParameterWidget("Attendre que j'appuie pour continuer", Image.asset("assets/images/icons/parameter/wait_for_user_input_icon.png"), clickOnWaitForUserInput,
            showSwitch: true, switchState: waitForUserInput),
        _chooseHandWidget(),
        _chooseRepeatRangeWidget(),
      ],
    );
  }

  Widget _chooseRepeatRangeWidget() {
    return Column(
      children: <Widget>[
        _tileParameterWidget('Répéter une partie en boucle', Image.asset("assets/images/icons/parameter/repeat_a_part_icon.png"), clickOnRepeatAPartToggle, showSwitch: true, switchState: repeatAPartOfTheMorceau),
        repeatAPartOfTheMorceau? _repeatRangeSlider() : SizedBox()
      ],
    );
  }

  Widget _repeatRangeSlider() {
    int nbSecondsLabelStart = _currentRepeatRangeValues.start.round() % 60;
    int nbMinutesLabelStart = (_currentRepeatRangeValues.start.round() / 60).floor();
    int nbMinutesMaxLabelStart = (widget.durationOfTheMorceau.inSeconds / 60).floor();
    int nbSecondsMaxLabelStart = widget.durationOfTheMorceau.inSeconds % 60;
    int nbSecondsLabelEnd = _currentRepeatRangeValues.end.round() % 60;
    int nbMinutesLabelEnd = (_currentRepeatRangeValues.end.round() / 60).floor();
    int nbMinutesMaxLabelEnd = (widget.durationOfTheMorceau.inSeconds / 60).floor();
    int nbSecondsMaxLabelEnd = widget.durationOfTheMorceau.inSeconds % 60;

    if (nbMinutesLabelStart > nbMinutesMaxLabelStart) nbMinutesLabelStart = nbMinutesMaxLabelStart;

    if (nbSecondsLabelStart > nbSecondsMaxLabelStart && nbMinutesLabelStart == nbMinutesMaxLabelStart) nbSecondsLabelStart = nbSecondsMaxLabelStart;

    if (nbSecondsLabelStart < 0) nbSecondsLabelStart = 0;

    if (nbMinutesLabelStart < 0) nbMinutesLabelStart = 0;

    if (nbMinutesLabelEnd > nbMinutesMaxLabelEnd) nbMinutesLabelEnd = nbMinutesMaxLabelEnd;

    if (nbSecondsLabelEnd > nbSecondsMaxLabelEnd && nbMinutesLabelEnd == nbMinutesMaxLabelEnd) nbSecondsLabelEnd = nbSecondsMaxLabelEnd;

    if (nbSecondsLabelEnd < 0) nbSecondsLabelEnd = 0;

    if (nbMinutesLabelEnd < 0) nbMinutesLabelEnd = 0;

    return Padding(
      padding: const EdgeInsets.only(top : 10.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                CustomWidgets.numberSlideBarText(nbMinutesLabelStart.toString() + ":" + Utils.intSecondsToStringDuration(nbSecondsLabelStart).toString()),
                CustomWidgets.numberSlideBarText(nbMinutesLabelEnd.toString() + ":" + Utils.intSecondsToStringDuration(nbSecondsLabelEnd).toString()),
              ],
            ),
          ),
          Container(
            transform: Matrix4.translationValues(0.0, -16.0, 0.0),
            child: SliderTheme(
              data: SliderThemeData(
                  thumbColor: CustomColors.blue,
                  activeTrackColor: CustomColors.blue,
                  inactiveTrackColor: CustomColors.slideBarBackgroundColor,
                  trackHeight: 3.0,
                  activeTickMarkColor: Colors.transparent,
                  inactiveTickMarkColor: Colors.transparent,
                  showValueIndicator: ShowValueIndicator.always,
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 2),
                  rangeThumbShape: RoundRangeSliderThumbShape(enabledThumbRadius: 2)),
              child: RangeSlider(
                values: _currentRepeatRangeValues,
                min: 0,
                max: widget.durationOfTheMorceau.inSeconds.toDouble(),
                divisions: widget.durationOfTheMorceau.inSeconds,
                labels: RangeLabels(
                  nbMinutesLabelStart.toString() + ":" + Utils.intSecondsToStringDuration(nbSecondsLabelStart).toString(),
                  nbMinutesLabelEnd.toString() + ":" + Utils.intSecondsToStringDuration(nbSecondsLabelEnd).toString(),
                ),
                onChangeEnd: (RangeValues values) {
                  saveRepeatRangeValues(values);
                  envoiLaBoucleARepeter(values);
                },
                onChanged: (RangeValues values) {
                  setState(() {
                    _currentRepeatRangeValues = values;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  //endregion

  //region Logic
  String getTextCorrespondingToHands() {
    if (selectedHands[MAIN_GAUCHE] && selectedHands[MAIN_DROITE]) return 'les deux mains';
    if (selectedHands[MAIN_DROITE]) return 'la main droite';
    return 'la main gauche';
  }

  void clickOnWaitForUserInput() {
    if (waitForUserInput) {
      BlocProvider.of<BluetoothBloc>(context).add(AskToNotWaitForTheUserInputEvent());
    } else {
      BlocProvider.of<BluetoothBloc>(context).add(AskToWaitForTheUserInputEvent());
    }

    setState(() {
      waitForUserInput = !waitForUserInput;
    });

    Utils.saveBooleanToSharedPreferences(Strings.WAIT_FOR_USER_INPUT_SHARED_PREFS, waitForUserInput);
  }

  /// Called when the user clicks on the toggle of 'Repeat a part'
  void clickOnRepeatAPartToggle() {
    setState(() {
      repeatAPartOfTheMorceau = !repeatAPartOfTheMorceau;
    });

    if (repeatAPartOfTheMorceau)
      envoiLaBoucleARepeter(_currentRepeatRangeValues);
    else
      envoiStopLeModeBoucle();
  }

  void initWaitForUserInput() async {
    bool _tempoWaitForUserInput = await Utils.getBooleanFromSharedPreferences(Strings.WAIT_FOR_USER_INPUT_SHARED_PREFS, defaultValue: false);
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

  void initRepeatRangeValues() async {
    int start = await Utils.getIntegerFromSharedPreferences(widget.music.id+Strings.REPEAT_RANGE_SHARED_PREFS_START, defaultValue: 0);
    int end = await Utils.getIntegerFromSharedPreferences(widget.music.id+Strings.REPEAT_RANGE_SHARED_PREFS_END, defaultValue: widget.durationOfTheMorceau.inSeconds);
    _currentRepeatRangeValues = RangeValues(start.toDouble(), end.toDouble());
  }

  void saveRepeatRangeValues(RangeValues values) async {
    await Utils.saveIntegerToSharedPreferences(widget.music.id+Strings.REPEAT_RANGE_SHARED_PREFS_START, values.start.floor());
    await Utils.saveIntegerToSharedPreferences(widget.music.id+Strings.REPEAT_RANGE_SHARED_PREFS_END, values.end.floor());
  }

  void envoiLeChangementDeMain() async {
    if (selectedHands[MAIN_GAUCHE] && selectedHands[MAIN_DROITE]) {
      BlocProvider.of<BluetoothBloc>(context).add(ShowMeTheTwoHands());
    } else if (selectedHands[MAIN_DROITE]) {
      BlocProvider.of<BluetoothBloc>(context).add(ShowMeOnlyTheRightHand());
    } else {
      BlocProvider.of<BluetoothBloc>(context).add(ShowMeOnlyTheLeftHand());
    }
    Utils.saveBooleanToSharedPreferences(widget.music.id + '_MD', selectedHands[MAIN_DROITE]);
    Utils.saveBooleanToSharedPreferences(widget.music.id + '_MG', selectedHands[MAIN_GAUCHE]);
  }

  void envoiLaBoucleARepeter(RangeValues values) async {
    //todo
  }

  /// demande à l'esp32 d'arrêter le mode boucle
  void envoiStopLeModeBoucle() {
    //todo
  }
//endregion

}
