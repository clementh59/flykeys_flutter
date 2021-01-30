import 'dart:developer' as dev;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flykeys/src/bloc/bluetooth/bloc.dart';
import 'package:flykeys/src/bloc/favorites/bloc.dart';
import 'package:flykeys/src/bloc/music/bloc.dart';
import 'package:flykeys/src/model/music.dart';
import 'package:flykeys/src/repository/database_repository.dart';
import 'package:flykeys/src/utils/custom_colors.dart';
import 'package:flykeys/src/utils/custom_size.dart';
import 'package:flykeys/src/utils/custom_style.dart';
import 'package:flykeys/src/utils/strings.dart';
import 'package:flykeys/src/utils/utils.dart';
import 'package:flykeys/src/widget/customProgressCircle.dart';
import 'package:flykeys/src/widget/custom_widgets.dart';

import 'bluetooth/connection_to_flykeys_object_page.dart';

const MAIN_DROITE = 0;
const MAIN_GAUCHE = 1;

/// This page is helpful if you want to add feature on music page without testing with bluetooth
//todo: remove at final build
/**
 * Je suis sur la page music, je peux faire play, changer la vitesse, ...
 */
class MusicDebugPage extends StatefulWidget {
  final Music music;
  final double _expandedBottomPanelBottomPosition = 0;
  final double _completeCollapsedbottomPanelBottomPosition = -1000;

  MusicDebugPage(this.music);

  @override
  _MusicDebugPageState createState() => _MusicDebugPageState();
}

class _MusicDebugPageState extends State<MusicDebugPage> {
  //region Variables
  static const int LOADING = 0;
  static const int PLAYING = 1;
  static const int PAUSE = 2;

  ValueNotifier<Duration> valueNotifierActualDuration = new ValueNotifier(Duration(seconds: 0));
  ValueNotifier<bool> valueNotifierUpdateTickInPage = new ValueNotifier(false);
  Duration durationOfTheMorceau = Duration(seconds: 59, minutes: 1);

  double vitesseFactor = 1;
  double minSlideVitesse = 0.1;
  double maxSlideVitesse = 2;
  double lastDelaySent = -1; //Je l'initialise à -1 pour bien dire que je n'ai pas encore envoyé de delai lors de l'initialisation

  //lorsque j'essaie d'aller à une partie du morceau que je n'ai pas je montre
  //une snackbar, le soucis c'est que parfois, j'appelle une snackbar plusieurs
  //fois avant même que la premiere soit montrée, j'ai donc plusieurs snackbars
  //qui attendent de se montrer et qui se montre lorsque la précédente disparait
  bool _imActuallyShowingASnackbar = false;

  //region bottomPanel
  bool bottomPanelIsCollapsed = true; //false if the bottom bar is expanded, true otherwise
  double _bottomPanelBottomPosition;

  //endregion
  //endregion

  //region Overrides
  @override
  void initState() {
    super.initState();
    _bottomPanelBottomPosition = widget._completeCollapsedbottomPanelBottomPosition;
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
    int buttonState = PAUSE;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: CustomColors.backgroundColor,
        body: SafeArea(child: _generatePage(buttonState)));
  }
  //endregion

  //region Widget
  Widget _generatePage(int buttonState) {
    return WillPopScope(
      onWillPop: () async {
        if (!bottomPanelIsCollapsed) {
          hideBottomPanel();
          return false;
        }
        return true;
      },
      child: Stack(
        children: <Widget>[
          CustomWidgets.scrollViewWithBoundedHeight(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: _topBar(context),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: _generateInfoMusic(),
                ),
                Container(
                  transform: Matrix4.translationValues(0.0, -16.0, 0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _generateMusicParameterButton(),
                      _generateBottomCenterButton(buttonState),
                      InkWell(
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          onTap: () {
                            if (widget.music.liked) {
                              setState(() {
                                widget.music.liked = false;
                              });
                            } else {
                              setState(() {
                                widget.music.liked = true;
                              });
                            }
                          },
                          child: BlocBuilder<FavoritesBloc, FavoritesState>(builder: (BuildContext context, FavoritesState state) {
                            if (state is ListsLoadedState) {
                              if (state.musicsId.contains(widget.music.id)) {
                                widget.music.liked = true;
                                return CustomWidgets.heartIcon(true);
                              } else {
                                widget.music.liked = false;
                                return CustomWidgets.heartIcon(false);
                              }
                            }
                            return CustomWidgets.heartIcon(false);
                          })),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: _generateTranscriber(),
                ),
              ],
            ),
          ),
          if (!bottomPanelIsCollapsed)
            InkWell(
              onTap: () {
                hideBottomPanel();
              },
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
              ),
            ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.decelerate,
            bottom: _bottomPanelBottomPosition,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(left: 1, right: 1, top: 1),
              decoration: BoxDecoration(
                color: CustomColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30), bottom: Radius.circular(0)),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: CustomColors.backgroundColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30), bottom: Radius.circular(0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        hideBottomPanel();
                      },
                      child: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        height: 80,
                        child: Text(
                          "Paramètres",
                          style: CustomStyle.pageTitle,
                        ),
                      ),
                    ),
                    _bottomPanelChilds(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomPanelChilds() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: CustomSize.leftAndRightPadding),
          child: _tilesParameterWidget(),
        ),
      ],
    );
  }

  Widget _generateTranscriber() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Transcrit par ",
          style: CustomStyle.transcriberNameMusicPage,
        ),
        Text(
          widget.music.transcriberName,
          style: CustomStyle.transcriberColorNameMusicPage,
        ),
      ],
    );
  }

  Widget _generateInfoMusic() {
    return Column(
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Container(
            height: 185,
            width: 185,
            child: Image.asset("assets/images/music_icon.png"),
          ),
        ),
        SizedBox(
          height: 9,
        ),
        Text(
          widget.music.name,
          style: CustomStyle.musicNameMusicPage,
        ),
        Container(
          transform: Matrix4.translationValues(0.0, -2.0, 0.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: _generateAuthorsText(),
          ),
        ),
        SizedBox(
          height: 3,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomWidgets.biggerStarsWidget(widget.music.stars),
            SizedBox(
              width: 5,
            ),
            Text(
              "[" + Utils.showNumber(widget.music.numberOfVotes.toString()) + "]",
              style: CustomStyle.numberOfVote,
            )
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomWidgets.biggerNoteWidget(widget.music.difficulty),
            SizedBox(
              width: 15,
            ),
            CustomWidgets.ytWidget(15),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _timeSlider(),
              Container(
                transform: Matrix4.translationValues(0.0, -16.0, 0.0),
                child: _generateSpeedSlider(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _generateAuthorsText() {
    List<Widget> texts = [];
    for (int i = 0; i < widget.music.auteurs.length; i++) {
      String str = ",";
      if (i == widget.music.auteurs.length - 1) str = "";
      texts.add(
        Text(
          widget.music.auteurs[0].name.toString() + str,
          style: CustomStyle.authorNameMusicPage,
        ),
      );
    }
    return texts;
  }

  Widget _timeSlider() {
    return ValueListenableBuilder(
      valueListenable: valueNotifierActualDuration,
      builder: (BuildContext context, value, Widget child) {
        // This builder will only get called when the _counter
        // is updated.

        int nbSeconds = value.inSeconds % 60;
        int nbMinutes = (value.inSeconds / 60).floor();
        int nbMinutesMax = (durationOfTheMorceau.inSeconds / 60).floor();
        int nbSecondsMax = durationOfTheMorceau.inSeconds % 60;

        if (nbMinutes > nbMinutesMax) nbMinutes = nbMinutesMax;

        if (nbSeconds > nbSecondsMax && nbMinutes == nbMinutesMax) nbSeconds = nbSecondsMax;

        if (nbSeconds < 0) nbSeconds = 0;

        if (nbMinutes < 0) nbMinutes = 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  CustomWidgets.numberSlideBarText(nbMinutes.toString() + ":" + Utils.intSecondsToStringDuration(nbSeconds).toString()),
                  CustomWidgets.numberSlideBarText(nbMinutesMax.toString() + ":" + Utils.intSecondsToStringDuration(nbSecondsMax).toString()),
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
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 2)),
                child: Slider(
                  onChangeEnd: (value) {

                  },
                  divisions: durationOfTheMorceau.inSeconds,
                  //pour eviter erreur
                  value: min(durationOfTheMorceau.inSeconds.toDouble(), (nbMinutes * 60 + nbSeconds).toDouble()),
                  onChanged: (newTime) {
                    if (!repeatAPartOfTheMorceau) {
                      if (valueNotifierUpdateTickInPage.value) valueNotifierUpdateTickInPage.value = false;
                      valueNotifierActualDuration.value = new Duration(seconds: newTime.floor());
                    } else {
                      if (!_imActuallyShowingASnackbar) {
                        _imActuallyShowingASnackbar = true;
                        Scaffold
                            .of(context)
                            .showSnackBar(SnackBar(content: Text("Il est impossible d'aller à un endroit choisi lorsque le mode répétition en boucle est activé")))
                            .closed
                            .then((value) {
                          _imActuallyShowingASnackbar = false;
                        });
                      }
                    }
                  },
                  min: 0,
                  max: durationOfTheMorceau.inSeconds.toDouble(),
                  label: nbMinutes.toString() + ":" + Utils.intSecondsToStringDuration(nbSeconds).toString(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _generateSpeedSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 25),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              CustomWidgets.numberSlideBarText("x" + minSlideVitesse.toString()),
              CustomWidgets.numberSlideBarText("x" + maxSlideVitesse.toString()),
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
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 2)),
            child: Slider(
              onChangeEnd: (value) {
                vitesseFactor = value;
              },
              divisions: 20,
              value: vitesseFactor,
              onChanged: (newVitesse) {
                setState(() {
                  vitesseFactor = newVitesse;
                });
              },
              min: minSlideVitesse.roundToDouble(),
              max: maxSlideVitesse.roundToDouble(),
              label: "x$vitesseFactor",
            ),
          ),
        ),
      ],
    );
  }

  Widget _topBar(context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: CustomSize.leftAndRightPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          CustomWidgets.backArrowIcon(context),
          Text(
            "Apprentissage",
            style: CustomStyle.pageTitle,
          ),
          CustomWidgets.settingsIcon(context),
        ],
      ),
    );
  }

  Widget _generateBottomCenterButton(int state) {
    if (state == LOADING)
      return ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                  color: CustomColors.white,
                )),
            child: CustomWidgets.circularProgressIndicator()),
      );
    if (state == PLAYING)
      return InkWell(
        onTap: () {},
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                  color: CustomColors.white,
                )),
            child: Icon(
              Icons.pause,
              size: 40,
              color: Colors.white,
            ),
          ),
        ),
      );
    //state==PAUSE (or initial state)
    return InkWell(
      onTap: () {},
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Container(
        height: 80,
        width: 80,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: CustomColors.white,
            )),
        child: Icon(
          Icons.play_arrow,
          size: 40,
          color: Colors.white,
        ),
      ),
    );
  }

  /**
   * Generate the music parameter button
   * When you click on it, it opens the MusicParameterPage
   */
  Widget _generateMusicParameterButton() {
    return InkWell(
      onTap: () {
        showBottomPanel();
      },
      child: Icon(
        Icons.tune,
        size: 30,
        color: Colors.white,
      ),
    );
  }

  //endregion

  //region Logic
  void hideBottomPanel() {
    setState(() {
      bottomPanelIsCollapsed = true;
      _bottomPanelBottomPosition = widget._completeCollapsedbottomPanelBottomPosition;
    });
  }

  void showBottomPanel() {
    setState(() {
      bottomPanelIsCollapsed = false;
      _bottomPanelBottomPosition = widget._expandedBottomPanelBottomPosition;
    });
  }

//endregion

//region bottomPanel

  //region Variables
  bool waitForUserInput = false; // state of the switch to know if I have to wait for the user input to make the morceau fall down or not
  bool expandChooseHandParameter = true; // If I expand the option block that allow me to choose the hand I want to play
  bool repeatAPartOfTheMorceau = false; // Si je répète une partie en double ou non
  List<bool> selectedHands = [true, true]; //[MAIN_DROITE, MAIN_GAUCHE]

  RangeValues _currentRepeatRangeValues;

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
                SizedBox(
                  width: 12,
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

  Widget _tilesParameterWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tileParameterWidget("Attendre que j'appuie pour continuer", Image.asset("assets/images/icons/parameter/wait_for_user_input_icon.png"), clickOnWaitForUserInput,
            showSwitch: true, switchState: waitForUserInput),
        _chooseHandWidget(),
        _chooseRepeatRangeWidget(),
        SizedBox(),
      ],
    );
  }

  Widget _chooseRepeatRangeWidget() {
    return Column(
      children: <Widget>[
        _tileParameterWidget('Répéter une partie en boucle', Image.asset("assets/images/icons/parameter/repeat_a_part_icon.png"), clickOnRepeatAPartToggle,
            showSwitch: true, switchState: repeatAPartOfTheMorceau),
        repeatAPartOfTheMorceau ? _repeatRangeSlider() : SizedBox()
      ],
    );
  }

  Widget _repeatRangeSlider() {
    int nbSecondsLabelStart = _currentRepeatRangeValues.start.round() % 60;
    int nbMinutesLabelStart = (_currentRepeatRangeValues.start.round() / 60).floor();
    int nbMinutesMaxLabelStart = (durationOfTheMorceau.inSeconds / 60).floor();
    int nbSecondsMaxLabelStart = durationOfTheMorceau.inSeconds % 60;
    int nbSecondsLabelEnd = _currentRepeatRangeValues.end.round() % 60;
    int nbMinutesLabelEnd = (_currentRepeatRangeValues.end.round() / 60).floor();
    int nbMinutesMaxLabelEnd = (durationOfTheMorceau.inSeconds / 60).floor();
    int nbSecondsMaxLabelEnd = durationOfTheMorceau.inSeconds % 60;

    if (nbMinutesLabelStart > nbMinutesMaxLabelStart) nbMinutesLabelStart = nbMinutesMaxLabelStart;

    if (nbSecondsLabelStart > nbSecondsMaxLabelStart && nbMinutesLabelStart == nbMinutesMaxLabelStart) nbSecondsLabelStart = nbSecondsMaxLabelStart;

    if (nbSecondsLabelStart < 0) nbSecondsLabelStart = 0;

    if (nbMinutesLabelStart < 0) nbMinutesLabelStart = 0;

    if (nbMinutesLabelEnd > nbMinutesMaxLabelEnd) nbMinutesLabelEnd = nbMinutesMaxLabelEnd;

    if (nbSecondsLabelEnd > nbSecondsMaxLabelEnd && nbMinutesLabelEnd == nbMinutesMaxLabelEnd) nbSecondsLabelEnd = nbSecondsMaxLabelEnd;

    if (nbSecondsLabelEnd < 0) nbSecondsLabelEnd = 0;

    if (nbMinutesLabelEnd < 0) nbMinutesLabelEnd = 0;

    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
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
                max: durationOfTheMorceau.inSeconds.toDouble(),
                divisions: durationOfTheMorceau.inSeconds,
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
    int start = await Utils.getIntegerFromSharedPreferences(widget.music.id + Strings.REPEAT_RANGE_SHARED_PREFS_START, defaultValue: 0);
    int end = await Utils.getIntegerFromSharedPreferences(widget.music.id + Strings.REPEAT_RANGE_SHARED_PREFS_END, defaultValue: durationOfTheMorceau.inSeconds);
    _currentRepeatRangeValues = RangeValues(start.toDouble(), end.toDouble());
  }

  void saveRepeatRangeValues(RangeValues values) async {
    await Utils.saveIntegerToSharedPreferences(widget.music.id + Strings.REPEAT_RANGE_SHARED_PREFS_START, values.start.floor());
    await Utils.saveIntegerToSharedPreferences(widget.music.id + Strings.REPEAT_RANGE_SHARED_PREFS_END, values.end.floor());
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
//endregion

//endregion
}
