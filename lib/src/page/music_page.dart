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
import 'package:flykeys/src/utils/utils.dart';
import 'package:flykeys/src/widget/custom_widgets.dart';

import 'bluetooth/connection_to_flykeys_object_page.dart';

class MusicPage extends StatefulWidget {
  Music music;

  MusicPage(this.music);

  @override
  _MusicPageState createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  BluetoothBloc bluetoothBloc;
  MusicBloc _musicBloc;

  @override
  void dispose() {
    super.dispose();
    bluetoothBloc.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bluetoothBloc = BlocProvider.of<BluetoothBloc>(context);
    _musicBloc = MusicBloc(FirestoreRepository());
    if (!widget.music.iLoadedAllInfos) {
      _musicBloc.add(GetMusic(widget.music.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: CustomColors.backgroundColor,
      body: SafeArea(
        child: BlocBuilder<MusicBloc, MusicState>(
            bloc: _musicBloc,
            builder: (BuildContext context, MusicState state) {
              if (state is MusicLoadedState) {
                widget.music = state.music;
              }

              if (widget.music.iLoadedAllInfos) {
                return WillPopScope(
                  onWillPop: () async {
                    BlocProvider.of<BluetoothBloc>(context)
                        .add(QuitMusicEvent());
                    return true;
                  },
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: StreamBuilder<BluetoothState>(
                        stream: FlutterBlue.instance.state,
                        initialData: BluetoothState.unknown,
                        builder: (c, snapshot) {
                          final state = snapshot.data;
                          if (state == BluetoothState.on) {
                            bluetoothBloc.initEverythingLearningMode();
                            bluetoothBloc.add(FindFlyKeysDevice());

                            return BlocBuilder<BluetoothBloc, MyBluetoothState>(
                              builder: (BuildContext context,
                                  MyBluetoothState state) {
                                dev.log("state is $state", name: "Blocbuilder");

                                if (state is BluetoothMainStateSettingUp) {
                                  return Stack(
                                    children: <Widget>[
                                      _topbar(),
                                      Center(
                                          child:
                                              SettingUpBluetoothPage(state, () {
                                        BlocProvider.of<BluetoothBloc>(context)
                                            .add(SendMorceauEvent(
                                                widget.music.id));
                                      })),
                                    ],
                                  );
                                }

                                if (state is BluetoothMainStateSendingMorceau) {
                                  return Stack(
                                    children: <Widget>[
                                      _topbar(),
                                      Center(
                                          child: SendingMorceauPage(
                                              state, widget.music)),
                                    ],
                                  );
                                }

                                if (state is BluetoothInteractWithMusic) {
                                  return InteractWithMorceauPage(
                                      state, widget.music);
                                }

                                return SizedBox();
                              },
                            );
                          } else if (state == BluetoothState.off) {
                            BlocProvider.of<BluetoothBloc>(context)
                                .onDisconnect();
                          }
                          return CustomWidgets.bluetoothIsOff();
                        }),
                  ),
                );
              }

              if (state is MusicLoadingState) {
                return Center(
                  child: CustomWidgets.circularProgressIndicator(),
                );
              }

              return SizedBox();
            }),
      ),
    );
  }

  Widget _topbar() {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        margin: EdgeInsets.only(top: 15, left: 15),
        child: InkWell(
          onTap: () {
            Navigator.of(context).pop();
          },
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          child: Icon(
            Icons.keyboard_arrow_left,
            size: 40,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/**
 * Télécharge le morceau sur firebase storage, le décrypte et l'envoi par bluetooth
 */
class SendingMorceauPage extends StatelessWidget {
  final MyBluetoothState state;
  final Music music;

  SendingMorceauPage(this.state, this.music);

  @override
  Widget build(BuildContext context) {
    if (state is FetchingMorceauState)
      return CustomWidgets.textWithLoadingIndicator(
          "Téléchargement du morceau");
    else if (state is DecodageMorceauState)
      return CustomWidgets.textWithLoadingIndicator("Decodage du morceau");
    else if (state is TraitementMorceauState)
      return CustomWidgets.textWithLoadingIndicator("Traitement du morceau");
    else if (state is SendingMorceauState) {
      SendingMorceauState _state = state;
      return envoiEnCoursPage(context, _state.avancement);
    }

    print(
        "!!!!!!!!!!!ERROR!!!!!!!!!! NOT HANDLED CASE IN SettingUpBluetoothPage");
    return SizedBox();
  }

  Widget envoiEnCoursPage(context, double avancement) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        CustomWidgets.textWithLoadingIndicator("Envoi du morceau en cours..."),
        SizedBox(
          height: 30,
        ),
        Stack(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width - 100,
              height: 40,
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.1)),
            ),
            Container(
              width: (MediaQuery.of(context).size.width - 100) *
                  min(1, avancement),
              height: 40,
              decoration: BoxDecoration(color: Colors.blue),
            ),
          ],
        ),
        SizedBox(
          height: 30,
        ),
        InkWell(
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          child: Container(
              margin: EdgeInsets.only(top: 30),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.blue, borderRadius: BorderRadius.circular(15)),
              child: Text("Jouer que cette partie!")),
          onTap: () {
            _stopSendingMorceau(context);
          },
        ),
      ],
    );
  }

  void _stopSendingMorceau(context) {
    //BlocProvider.of<BluetoothBloc>(context).add(StopSendingMorceauEvent());
    BlocProvider.of<BluetoothBloc>(context).stopSendingMorceau();
  }
}

/**
 * Je suis sur la page music, je peux faire play, changer la vitesse, ...
 */
class InteractWithMorceauPage extends StatefulWidget {
  final MyBluetoothState state;
  final Music music;

  InteractWithMorceauPage(this.state, this.music);

  @override
  _InteractWithMorceauPageState createState() =>
      _InteractWithMorceauPageState();
}

class _InteractWithMorceauPageState extends State<InteractWithMorceauPage> {
  static const int LOADING = 0;
  static const int PLAYING = 1;
  static const int PAUSE = 2;

  ValueNotifier<Duration> valueNotifierActualDuration;
  ValueNotifier<bool> valueNotifierUpdateTickInPage;
  Duration durationOfTheMorceau;

  double vitesseFactor = 1;
  double minSlideVitesse = 0.1;
  double maxSlideVitesse = 2;
  double lastDelaySent =
      -1; //Je l'initialise à -1 pour bien dire que je n'ai pas encore envoyé de delai lors de l'initialisation

  //lorsque j'essaie d'aller à une partie du morceau que je n'ai pas je montre
  //une snackbar, le soucis c'est que parfois, j'appelle une snackbar plusieurs
  //fois avant même que la premiere soit montrée, j'ai donc plusieurs snackbars
  //qui attendent de se montrer et qui se montre lorsque la précédente disparait
  bool _imActuallyShowingASnackbar = false;

  @override
  void initState() {
    super.initState();
    valueNotifierActualDuration = new ValueNotifier(Duration(seconds: 0));
    valueNotifierUpdateTickInPage = new ValueNotifier(true);
    initLaRecuperationDuActualTime();
  }

  @override
  Widget build(BuildContext context) {
    int buttonState = LOADING;

    if (widget.state is MorceauSentState) {
      //Je viens d'envoyer le morceau, je lui envoi donc le delay
      //De base je suis en pause
      _sendDelay(widget.music.speed);
      buttonState = PAUSE;
    } else if (widget.state is PlayingMusicState) {
      buttonState = PLAYING;
    } else if (widget.state is StoppedMusicState) {
      buttonState = PAUSE;
    } else if (widget.state is LoadingCommandMusicState) {
      buttonState = LOADING;
    } else if (widget.state is TickNotPossibleState) {
      buttonState = PAUSE;
    }

    return BlocListener<BluetoothBloc, MyBluetoothState>(
      listener: (BuildContext context, state) {
        if (state is TickNotPossibleState) {
          if (!_imActuallyShowingASnackbar) {
            _imActuallyShowingASnackbar = true;
            Scaffold.of(context)
                .showSnackBar(SnackBar(
                    content:
                        Text("Cette partie du morceau n'a pas été envoyée!")))
                .closed
                .then((value) {
              _imActuallyShowingASnackbar = false;
            });
          }
        }
      },
      child: _generatePage(buttonState),
    );
  }

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
              Icon(
                Icons.tune,
                size: 30,
                color: Colors.white,
              ),
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
                      BlocProvider.of<FavoritesBloc>(context)
                        ..add(RemoveAFavoriteMusic(widget.music));
                    } else {
                      setState(() {
                        widget.music.liked = true;
                      });
                      BlocProvider.of<FavoritesBloc>(context)
                        ..add(AddAFavoriteMusic(widget.music));
                    }
                  },
                  child: BlocBuilder<FavoritesBloc, FavoritesState>(
                      builder: (BuildContext context, FavoritesState state) {
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
          "Transcribed by ",
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
              "[" +
                  Utils.showNumber(widget.music.numberOfVotes.toString()) +
                  "]",
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

        if (nbSeconds > nbSecondsMax && nbMinutes == nbMinutesMax)
          nbSeconds = nbSecondsMax;

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
                  CustomWidgets.numberSlideBarText(nbMinutes.toString() +
                      ":" +
                      intSecondsToStringDuration(nbSeconds).toString()),
                  CustomWidgets.numberSlideBarText(nbMinutesMax.toString() +
                      ":" +
                      intSecondsToStringDuration(nbSecondsMax).toString()),
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
                    _sendNewTick(value);
                  },
                  divisions: durationOfTheMorceau.inSeconds,
                  //pour eviter erreur
                  value: min(durationOfTheMorceau.inSeconds.toDouble(),
                      (nbMinutes * 60 + nbSeconds).toDouble()),
                  onChanged: (newTime) {
                    if (valueNotifierUpdateTickInPage.value)
                      valueNotifierUpdateTickInPage.value = false;
                    valueNotifierActualDuration.value =
                        new Duration(seconds: newTime.floor());
                  },
                  min: 0,
                  max: durationOfTheMorceau.inSeconds.toDouble(),
                  label: nbMinutes.toString() +
                      ":" +
                      intSecondsToStringDuration(nbSeconds).toString(),
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
              CustomWidgets.numberSlideBarText(
                  "x" + minSlideVitesse.toString()),
              CustomWidgets.numberSlideBarText(
                  "x" + maxSlideVitesse.toString()),
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
                _sendDelay(widget.music.speed / vitesseFactor);
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
      padding: const EdgeInsets.symmetric(
          horizontal: CustomSize.leftAndRightPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          CustomWidgets.backArrowIcon(context),
          Text(
            "Learn",
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
        onTap: () {
          _stop();
        },
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
    //state==IDLE
    return InkWell(
      onTap: () {
        _play();
      },
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
	 * Convertis un nombre en string
	 * ex : si nb de second = 4, string = "04"
	 * si nb de second = 15, str = "15"
	 */
  String intSecondsToStringDuration(int seconds) {
    if (seconds < 10) return "0" + seconds.toString();
    return seconds.toString();
  }

  void _play() async {
    BlocProvider.of<BluetoothBloc>(context).add(PlayEvent());
  }

  void _stop() async {
    BlocProvider.of<BluetoothBloc>(context).add(StopEvent());
  }

  void _sendDelay(double delayDouble) {
    if (lastDelaySent != delayDouble) {
      lastDelaySent = delayDouble;
      BlocProvider.of<BluetoothBloc>(context).add(SendSpeedEvent(delayDouble));
    }
  }

  void _sendNewTick(double second) {
    int tick = (second * 1000 / widget.music.speed).floor();
    BlocProvider.of<BluetoothBloc>(context).add(SendNewTickEvent(tick));
  }

  void initLaRecuperationDuActualTime() {
    BlocProvider.of<BluetoothBloc>(context)
      ..setSpeedX1(widget.music.speed); //je lui indique la speed_x1
    BlocProvider.of<BluetoothBloc>(context)
      ..setValueNotifierActualDuration(valueNotifierActualDuration);
    BlocProvider.of<BluetoothBloc>(context)
      ..setValueNotifierUpdateTickInPage(valueNotifierUpdateTickInPage);
    durationOfTheMorceau =
        BlocProvider.of<BluetoothBloc>(context).getDurationOfTheMorceau();
  }
}
