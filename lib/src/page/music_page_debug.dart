import 'dart:developer' as dev;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flykeys/src/bloc/bluetooth/bloc.dart';
import 'package:flykeys/src/bloc/favorites/bloc.dart';
import 'package:flykeys/src/bloc/music/bloc.dart';
import 'package:flykeys/src/model/music.dart';
import 'package:flykeys/src/page/music_parameter_page.dart';
import 'package:flykeys/src/repository/database_repository.dart';
import 'package:flykeys/src/utils/custom_colors.dart';
import 'package:flykeys/src/utils/custom_size.dart';
import 'package:flykeys/src/utils/custom_style.dart';
import 'package:flykeys/src/utils/strings.dart';
import 'package:flykeys/src/utils/utils.dart';
import 'package:flykeys/src/widget/customProgressCircle.dart';
import 'package:flykeys/src/widget/custom_widgets.dart';

import 'bluetooth/connection_to_flykeys_object_page.dart';

/// This page is helpful if you want to add feature on music page without testing with bluetooth

/**
 * Je suis sur la page music, je peux faire play, changer la vitesse, ...
 */
class MusicDebugPage extends StatefulWidget {
  final Music music;

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

  bool waitForUserInput;
  double vitesseFactor = 1;
  double minSlideVitesse = 0.1;
  double maxSlideVitesse = 2;
  double lastDelaySent = -1; //Je l'initialise à -1 pour bien dire que je n'ai pas encore envoyé de delai lors de l'initialisation

  //lorsque j'essaie d'aller à une partie du morceau que je n'ai pas je montre
  //une snackbar, le soucis c'est que parfois, j'appelle une snackbar plusieurs
  //fois avant même que la premiere soit montrée, j'ai donc plusieurs snackbars
  //qui attendent de se montrer et qui se montre lorsque la précédente disparait
  bool _imActuallyShowingASnackbar = false;
  //endregion

  //region Overrides
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int buttonState = PAUSE;

    return Scaffold(resizeToAvoidBottomInset: false, backgroundColor: CustomColors.backgroundColor, body: SafeArea(child: _generatePage(buttonState)));
  }

  //endregion

  //region Widget
  Widget _generatePage(int buttonState) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 20),
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
            child: widget.music.image,
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
                    print('Change end ' + value.toString());
                  },
                  divisions: durationOfTheMorceau.inSeconds,
                  //pour eviter erreur
                  value: min(durationOfTheMorceau.inSeconds.toDouble(), (nbMinutes * 60 + nbSeconds).toDouble()),
                  onChanged: (newTime) {
                    if (valueNotifierUpdateTickInPage.value) valueNotifierUpdateTickInPage.value = false;
                    valueNotifierActualDuration.value = new Duration(seconds: newTime.floor());
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
        Navigator.push(
          context,
          Utils.createRoute(() => MusicParameterPage(widget.music, this.durationOfTheMorceau)),
        );
      },
      child: Icon(
        Icons.tune,
        size: 30,
        color: Colors.white,
      ),
    );
  }

  //endregion

//endregion
}
