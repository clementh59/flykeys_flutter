import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flykeys/src/bloc/bluetooth/bloc.dart';
import 'package:flykeys/src/bloc/bluetooth/bluetooth_bloc.dart';
import 'package:flykeys/src/page/bluetooth/connection_to_flykeys_object_page.dart';
import 'package:flykeys/src/utils/constants.dart';
import 'package:flykeys/src/utils/custom_colors.dart';
import 'package:flykeys/src/utils/custom_style.dart';
import 'package:flykeys/src/utils/utils.dart';
import 'package:flykeys/src/widget/custom_widgets.dart';

enum StepsForMidi { checkConnection, setUpLeftLimit, setUpRightLimit, verification }
enum StepsForAcoustic { placeTheObject, setUpFirstKey, verification }

var possibleNumberOfTouchesValues = List<int>.generate(77, (int index) => index + 12); // from 12 to 88

var possibleFirstKeyValues = List<int>.generate(88, (int index) => index + 12);

class SetLimitOfKeyboard extends StatefulWidget {
  final Function onChoice;
  final Function goBack;
  final Map info;

  SetLimitOfKeyboard(this.info, this.onChoice, this.goBack);

  @override
  _SetLimitOfKeyboardState createState() => _SetLimitOfKeyboardState();
}

class _SetLimitOfKeyboardState extends State<SetLimitOfKeyboard> {
  //region Variables

  ScrollController _scrollController = new ScrollController(); // To make the page scroll to the top when go to last page
  var step; // to know at which step I am

  //J'ignore le close_sink ce dessous car sinon, je ne pourrais plus utiliser BluetoothBloc.of(context) dans toute l'appli car je l'aurais close!
  // ignore: close_sinks
  BluetoothBloc bluetoothBloc;
  bool iAskedToBeConnectedToFlykeysDevice = false; // To know if I have already ask to be connected to the Flykeys device

  //region Midi
  ValueNotifier<int> valueNotifierNotePushed;
  int lastKeyPushed = 0;
  bool lightTheLeftLineOfLed = true; // To know if I have already light the line positioned on the left of the Flykeys device
  bool lightTheRightLineOfLed = true; // To know if I have already light the line positioned on the right of the Flykeys device
  //endregion

  //region Acoustic
  Map dropdownValues = new Map();

  //endregion

  //endregion

  //region Overrides

  @override
  void initState() {
    super.initState();
    valueNotifierNotePushed = new ValueNotifier(0);
    valueNotifierNotePushed.addListener(onNotePushed);
    if (widget.info['midiPort'])
      step = StepsForMidi.checkConnection;
    else
      step = StepsForAcoustic.placeTheObject;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bluetoothBloc = BlocProvider.of<BluetoothBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CustomWidgets.scrollViewWithBoundedHeight(
        scrollController: _scrollController,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: StreamBuilder<BluetoothState>(
              stream: FlutterBlue.instance.state,
              initialData: BluetoothState.unknown,
              builder: (c, snapshot) {
                final state = snapshot.data;
                if (state == BluetoothState.on) {
                  if (!iAskedToBeConnectedToFlykeysDevice) {
                    iAskedToBeConnectedToFlykeysDevice = true;
                    bluetoothBloc.add(FindFlyKeysDevice());
                  }

                  return BlocBuilder<BluetoothBloc, MyBluetoothState>(
                    builder: (BuildContext context, MyBluetoothState state) {
                      if (state is BluetoothMainStateSettingUp) {
                        return Stack(
                          children: <Widget>[
                            Center(
                                child: SettingUpBluetoothPage(state, () {
                              if (widget.info['midiPort'])
                                bluetoothBloc.add(SetUpMidiKeyboardLimitEvent(valueNotifierNotePushed));
                              else
                                bluetoothBloc.add(SetUpAcousticKeyboardLimitEvent());
                            }, () {
                              widget.goBack();
                            })),
                          ],
                        );
                      }

                      if (widget.info['midiPort'] && (state is SetLimitOfKeyboardState)) {
                        switch (step) {
                          case StepsForMidi.checkConnection: // I ask to press a key to check if the connection is working
                            return objectInteractionPageIntroduction();
                          case StepsForMidi.setUpLeftLimit:
                            return objectInteractionPageSetUpLimit(true);
                          case StepsForMidi.setUpRightLimit:
                            return objectInteractionPageSetUpLimit(false);
                          case StepsForMidi.verification:
                            return finalVerificationPage();
                        }
                      }

                      if (!widget.info['midiPort'] && (state is SetLimitOfKeyboardState)) {
                        switch (step) {
                          case StepsForAcoustic.placeTheObject:
                            return placeTheObjectCorrectlyPage();
                          case StepsForAcoustic.setUpFirstKey:
                            return setUpFirstKeyPage();
                          case StepsForAcoustic.verification:
                            return finalVerificationPage();
                        }
                      }

                      return Container(
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                          child: CustomWidgets.textWithLoadingIndicator("Préparation de la connection en cours ..."),
                        ),
                      );
                    },
                  );
                } else if (state == BluetoothState.off) {
                  bluetoothBloc.onDisconnect();
                }
                return CustomWidgets.bluetoothIsOffPage(context);
              }),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    bluetoothBloc.stopListeningToNotePushed();
    valueNotifierNotePushed?.removeListener(onNotePushed);
    valueNotifierNotePushed?.dispose();
  }

  //endregion

  //region Pages
  //region With Midi
  /// The page corresponding to Steps.checkConnection
  Widget objectInteractionPageIntroduction() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Appuie sur une touche du piano',
                style: CustomStyle.bigTextOnBoardingPage,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 26),
            Text(
              'L’application va communiquer avec l’objet pour vérifier que la communication avec le piano est valide. N\'hésitez pas à appuyer sur différentes touches pendant plusieurs secondes (parfois la connection met quelques secondes à se faire). Vous serez automatiquement redirigé lorsque l\'appuie d\'une touche sera detecté. Votre piano doit être branché pour que la connexion fonctionne.',
              style: CustomStyle.smallTextOnBoardingPage,
              textAlign: TextAlign.left,
            ),
            SizedBox(height: 31),
          ],
        ),
      ],
    );
  }

  /// [left] - true if it's the limit of the left - false if it is the right one
  /// The page corresponding to Steps.setUpLeftLimit if [left]
  /// The page corresponding to Steps.setUpRightLimit if [!left]
  Widget objectInteractionPageSetUpLimit(bool left) {
    int i = left ? 1 : 4;

    // If I ask to set the left limit but the Line on the left of the Flykeys device isn't light
    if (left && lightTheLeftLineOfLed) {
      lightTheLeftLineOfLed = false;
      bluetoothBloc.add(LightLedsEvent([0, 1, 2, 3, 4, 5, 6, 7], true));
    }

    // If I ask to set the right limit but the Line on the right of the Flykeys device isn't light
    if (!left && lightTheRightLineOfLed) {
      lightTheRightLineOfLed = false;
      var last = Constants.lastLedIndex;
      bluetoothBloc.add(LightLedsEvent([last - 7, last - 6, last - 5, last - 4, last - 3, last - 2, last - 1, last], true));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            left ? 'Super, la connection fonctionne!' : 'Plus qu\'une petite étape',
            style: CustomStyle.bigTextOnBoardingPage,
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 26),
        left
            ? RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Maintenant, appuie sur la touche la plus à gauche du piano.",
                      style: CustomStyle.smallTextOnBoardingPage,
                    ),
                    TextSpan(
                      text: " La première touche doit être aligné avec la ligne éclairée sur l’objet Flykeys",
                      style: CustomStyle.smallTextOnBoardingPage.copyWith(fontWeight: CustomStyle.BOLD),
                    ),
                    TextSpan(
                      text:
                          " (vous pouvez regarder les schémas ci-dessous pour mieux comprendre). Une fois cela effectué, il vous suffira d\'appuyez sur le bouton en bas de la page.",
                      style: CustomStyle.smallTextOnBoardingPage,
                    ),
                  ],
                ),
                textAlign: TextAlign.left,
              )
            : Text(
                'Maintenant, appuyez sur la touche la plus à droite du piano. Si l’objet Flykeys ne couvre pas la totalité du piano, appuyez sur la dernière touche que l’objet couvre (vous pouvez regarder les schémas ci-dessous pour mieux comprendre). Une fois cela effectué, il vous suffira d\'appuyez sur le bouton en bas de la page',
                style: CustomStyle.smallTextOnBoardingPage,
              ),
        SizedBox(height: 31),
        schemaWithExplanation(1, 'L\'objet fait exactement la taille du piano', 'assets/images/onboarding/schema' + i.toString() + '.png'),
        schemaWithExplanation(2, 'L\'objet est plus grand que mon piano', 'assets/images/onboarding/schema' + (i + 1).toString() + '.png'),
        schemaWithExplanation(3, 'L\'objet est plus petit que mon piano', 'assets/images/onboarding/schema' + (i + 2).toString() + '.png'),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "La dernière touche appuyée est ",
                style: CustomStyle.smallTextOnBoardingPage,
              ),
              TextSpan(
                text: lastKeyPushed.toString(),
                style: CustomStyle.smallTextOnBoardingPage.copyWith(fontWeight: CustomStyle.BOLD),
              ),
              TextSpan(
                text: " (" + Utils.getNoteNameFromKey(lastKeyPushed) + ").",
                style: CustomStyle.smallTextOnBoardingPage,
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 11),
        Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: CustomWidgets.buttonLoadMorePopularSongStyle("C'est fait", () {
            if (left) {
              setState(() {
                step = StepsForMidi.setUpRightLimit;
              });
              _scrollController.animateTo(0, duration: Duration(milliseconds: 250), curve: Curves.easeIn);
              widget.info['leftLimit'] = lastKeyPushed;
            } else {
              widget.info['rightLimit'] = lastKeyPushed;
              bluetoothBloc.add(ClearLedsEvent());
              setState(() {
                step = StepsForMidi.verification;
              });
              _scrollController.animateTo(0, duration: Duration(milliseconds: 250), curve: Curves.easeIn);
            }
          }, fontSize: 16.0),
        ),
      ],
    );
  }

  //endregion

  //region Without midi
  Widget placeTheObjectCorrectlyPage() {
    const i = 1;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Positionnement de l\'objet',
            style: CustomStyle.bigTextOnBoardingPage,
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 26),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "Maintenant, positionnez l’objet Flykeys comme présenté sur les schémas (selon votre cas).",
                style: CustomStyle.smallTextOnBoardingPage,
              ),
              TextSpan(
                text: " La première touche doit être aligné avec la ligne éclairée sur l’objet Flykeys.",
                style: CustomStyle.smallTextOnBoardingPage.copyWith(fontWeight: CustomStyle.BOLD),
              ),
            ],
          ),
          textAlign: TextAlign.left,
        ),
        SizedBox(height: 31),
        schemaWithExplanation(1, 'L\'objet fait exactement la taille du piano', 'assets/images/onboarding/schema' + i.toString() + '.png'),
        schemaWithExplanation(2, 'L\'objet est plus grand que mon piano', 'assets/images/onboarding/schema' + (i + 1).toString() + '.png'),
        schemaWithExplanation(3, 'L\'objet est plus petit que mon piano', 'assets/images/onboarding/schema' + (i + 2).toString() + '.png'),
        SizedBox(height: 11),
        Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: CustomWidgets.buttonLoadMorePopularSongStyle("C'est fait", () {
            bluetoothBloc.add(ClearLedsEvent());
            setState(() {
              step = StepsForAcoustic.setUpFirstKey;
            });
            _scrollController.animateTo(0, duration: Duration(milliseconds: 250), curve: Curves.easeIn);
          }, fontSize: 16.0),
        ),
      ],
    );
  }

  Widget setUpFirstKeyPage() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Positionnement de l\'objet',
                style: CustomStyle.bigTextOnBoardingPage,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 26),
            Text(
              "Vous allez maintenant devoir savoir quel est la première note de votre piano. Si vous le savez, vous pouvez remplir le champs ci-dessous. Si ce n’est pas le cas, vous pouvez nous envoyer un mail à " +
                  Constants.contact_mail +
                  " avec une photo de votre piano. On vous dira la valeur qu’il faut mettre.\n\nLa première note de mon piano est : ",
              style: CustomStyle.smallTextOnBoardingPage,
            ),
            _textInput('firstKey', possibleFirstKeyValues, (value) {
              return Utils.getNoteNameFromKey(value) + ' ' + Utils.getDecade(value).toString();
            }, 'Première touche'),
            Container(
              width: double.infinity,
              child: Text(
                "\nMon piano comporte :",
                style: CustomStyle.smallTextOnBoardingPage,
                textAlign: TextAlign.left,
              ),
            ),
            _textInput('numberOfKeys', possibleNumberOfTouchesValues, (value) {
              return value.toString() + ' touches';
            }, 'Nombre de touches'),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 20.0, top: 20),
          child: CustomWidgets.buttonLoadMorePopularSongStyle("C'est fait", () {
            if (dropdownValues.containsKey('firstKey') && dropdownValues.containsKey('numberOfKeys')) {
              widget.info['leftLimit'] = dropdownValues['firstKey'];
              widget.info['rightLimit'] = dropdownValues['firstKey'] + dropdownValues['numberOfKeys'] - 1;
              setState(() {
                step = StepsForAcoustic.verification;
              });
            } else {
              Scaffold.of(context).showSnackBar(SnackBar(content: Text('Vous devez remplir tous les champs!')));
            }
          }, fontSize: 16.0),
        ),
      ],
    );
  }

  //endregion

  /// The page corresponding to Steps.verification
  Widget finalVerificationPage() {
    Map touches = Utils.getNumberOfTouches(widget.info['leftLimit'], widget.info['rightLimit']);
    int nbTouchesBlanches = touches['blanches'];
    int nbTouchesNoires = touches['noires'];
    int nbTouches = nbTouchesBlanches + nbTouchesNoires;
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Récapitulatif',
                style: CustomStyle.bigTextOnBoardingPage,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 26),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "L’objet couvre ",
                    style: CustomStyle.smallTextOnBoardingPage,
                  ),
                  TextSpan(
                    text: nbTouches.toString(),
                    style: CustomStyle.smallTextOnBoardingPage.copyWith(fontWeight: CustomStyle.BOLD),
                  ),
                  TextSpan(
                    text: " touches (",
                    style: CustomStyle.smallTextOnBoardingPage,
                  ),
                  TextSpan(
                    text: nbTouchesBlanches.toString(),
                    style: CustomStyle.smallTextOnBoardingPage.copyWith(fontWeight: CustomStyle.BOLD),
                  ),
                  TextSpan(
                    text: " blanches et ",
                    style: CustomStyle.smallTextOnBoardingPage,
                  ),
                  TextSpan(
                    text: nbTouchesNoires.toString(),
                    style: CustomStyle.smallTextOnBoardingPage.copyWith(fontWeight: CustomStyle.BOLD),
                  ),
                  TextSpan(
                    text:
                        " noires). Pour être sûr que la configuration est valide, vous pouvez comparer le son de la première et de la dernière touche couverte par l’objet Flykeys avec les sons reconnus par l’application.",
                    style: CustomStyle.smallTextOnBoardingPage,
                  ),
                ],
              ),
              textAlign: TextAlign.left,
            ),
            SizedBox(height: 31),
            buttonCompareSound('Comparer le son de la première touche', widget.info['leftLimit']),
            SizedBox(
              height: 13,
            ),
            buttonCompareSound('Comparer le son de la dernière touche', widget.info['rightLimit']),
          ],
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            CustomWidgets.button('Oui, il s’agit bien du même son', CustomColors.blue, () {
              widget.onChoice();
            }),
            SizedBox(height: 10),
            CustomWidgets.button('Non, le son est différent', CustomColors.red, () {
              _showMaterialDialog();
            }),
            SizedBox(height: 20),
          ],
        ),
      ],
    );
  }

  //endregion

  //region Widgets

  /// [index] is the number of the schema.
  /// [description] is the description of the schema
  /// [imageAsset] is the path of the image
  Widget schemaWithExplanation(int index, String description, String imageAsset) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "Cas " + index.toString() + " ",
                style: CustomStyle.smallTextOnBoardingPage.copyWith(fontWeight: CustomStyle.BOLD),
              ),
              TextSpan(
                text: ": " + description,
                style: CustomStyle.smallTextOnBoardingPage,
              ),
            ],
          ),
          textAlign: TextAlign.left,
        ),
        SizedBox(
          height: 18,
        ),
        Image.asset(
          imageAsset,
          width: MediaQuery.of(context).size.width / 1.7,
        ),
        SizedBox(
          height: 25,
        ),
      ],
    );
  }

  Widget buttonCompareSound(text, key) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
            onTap: () {
              //todo: play midi sound
            },
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            child: CustomWidgets.playIconWithBlueCircle()),
        SizedBox(
          width: 16,
        ),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                text,
                style: CustomStyle.smallTextOnBoardingPage.copyWith(fontWeight: CustomStyle.MEDIUM),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _textInput(dropdownValueIndex, possibilities, mapValueToText, hintText) {
    return DropdownButton<int>(
      dropdownColor: CustomColors.darkerBlue,
      value: dropdownValues[dropdownValueIndex],
      icon: Icon(Icons.arrow_drop_down),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(color: CustomColors.white),
      underline: Container(
        height: 2,
        color: CustomColors.yellow,
      ),
      isExpanded: true,
      hint: Center(
          child: Text(
        hintText,
        style: CustomStyle.smallTextOnBoardingPage.copyWith(color: CustomColors.grey),
      )),
      onChanged: (int newValue) {
        setState(() {
          dropdownValues[dropdownValueIndex] = newValue;
        });
      },
      items: possibilities.map<DropdownMenuItem<int>>((int value) {
        return DropdownMenuItem<int>(
          value: value,
          child: Center(
              child: Text(
            mapValueToText(value),
            style: CustomStyle.smallTextOnBoardingPage.copyWith(fontWeight: CustomStyle.BOLD),
          )),
        );
      }).toList(),
    );
  }

  //endregion

  //region Logic

  void onNotePushed() {
    if (step == StepsForMidi.checkConnection){
      setState(() {
        step = StepsForMidi.setUpLeftLimit;
      });
    }
    setState(() {
      lastKeyPushed = valueNotifierNotePushed.value;
    });
  }

  void _showMaterialDialog() {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text("Veuillez réessayer de paramétrer les limites du piano"),
              content: new Text("Si vous n'arrivez toujours pas à paramétrer les limites, veuillez envoye une photo de votre piano par mail à " +
                  Constants.contact_mail),
              actions: <Widget>[
                FlatButton(
                  child: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 7, horizontal: 12),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: Colors.red),
                    child: Text('Ok'),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      if (widget.info['midiPort'])
                        step = StepsForMidi.setUpLeftLimit;
                      else
                        step = StepsForAcoustic.setUpFirstKey;
                      lightTheLeftLineOfLed = true;
                      lightTheRightLineOfLed = true;
                    });
                  },
                ),
              ],
            ));
  }

//endregion
}
