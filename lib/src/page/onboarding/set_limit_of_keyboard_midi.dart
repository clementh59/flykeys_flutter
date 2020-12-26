import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flykeys/src/bloc/bluetooth/bloc.dart';
import 'package:flykeys/src/bloc/bluetooth/bluetooth_bloc.dart';
import 'package:flykeys/src/page/bluetooth/connection_to_flykeys_object_page.dart';
import 'package:flykeys/src/utils/constants.dart';
import 'package:flykeys/src/utils/custom_style.dart';
import 'package:flykeys/src/utils/utils.dart';
import 'package:flykeys/src/widget/custom_widgets.dart';

const int NO_KEY_PRESSED = -1;

class SetLimitOfKeyboardMidi extends StatefulWidget {
  final Function onChoice;
  final Function goBack;
  final Map info;

  SetLimitOfKeyboardMidi(this.info, this.onChoice, this.goBack);

  @override
  _SetLimitOfKeyboardMidiState createState() => _SetLimitOfKeyboardMidiState();
}

class _SetLimitOfKeyboardMidiState extends State<SetLimitOfKeyboardMidi> {
  //J'ignore le close_sink ce dessous car sinon, je ne pourrais plus utiliser BluetoothBloc.of(context) dans toute l'appli car je l'aurais close!
  // ignore: close_sinks
  BluetoothBloc bluetoothBloc;
  ValueNotifier<int> valueNotifierNotePushed;
  int lastKeyPushed = NO_KEY_PRESSED;
  bool leftLimitOfKeyboardIsSetUp = false; // to know at which step I am
  bool iAskToBeConnectedToFlykeysDevice = false; // To know if I have already ask to be connected to the Flykeys device
  bool lightTheLeftLineOfLed = true; // To know if I have already light the line positioned on the left of the Flykeys device
  bool lightTheRightLineOfLed = true; // To know if I have already light the line positioned on the right of the Flykeys device
  ScrollController _scrollController = new ScrollController(); // To make the page scroll to the top when go to last page

  @override
  void initState() {
    super.initState();
    valueNotifierNotePushed = new ValueNotifier(0);
    valueNotifierNotePushed.addListener(onNotePushed);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bluetoothBloc = BlocProvider.of<BluetoothBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: StreamBuilder<BluetoothState>(
          stream: FlutterBlue.instance.state,
          initialData: BluetoothState.unknown,
          builder: (c, snapshot) {
            final state = snapshot.data;
            if (state == BluetoothState.on) {
              if (!iAskToBeConnectedToFlykeysDevice) {
                iAskToBeConnectedToFlykeysDevice = true;
                bluetoothBloc.add(FindFlyKeysDevice());
              }

              return BlocBuilder<BluetoothBloc, MyBluetoothState>(
                builder: (BuildContext context, MyBluetoothState state) {
                  if (state is BluetoothMainStateSettingUp) {
                    return Stack(
                      children: <Widget>[
                        Center(
                            child: SettingUpBluetoothPage(state, () {
                          bluetoothBloc.add(SetUpMidiKeyboardLimitEvent(valueNotifierNotePushed));
                        }, () {
                          widget.goBack();
                        })),
                      ],
                    );
                  }

                  if (state is SetLimitOfKeyboardState) {

                    if (lastKeyPushed == NO_KEY_PRESSED)
                      return objectInteractionPageIntroduction(); // I ask to press a key to check if the connection is working

                    // If !leftLimitOfKeyboardIsSetUp, I set up the left hand
                    // else, I set up the right hand
                    return objectInteractionPageSetUpLimit(!leftLimitOfKeyboardIsSetUp);
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
            return CustomWidgets.bluetoothIsOff();
          }),
    );
  }

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
              'L’application va communiquer avec l’objet pour vérifier que la communication avec le piano est valide. N\'hésitez pas à appuyer sur différentes touches pendant plusieurs secondes (parfois la connection met quelques secondes à se faire). Vous serez automatiquement redirigé lorsque l\'appuie d\'une touche sera detecté',
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
  Widget objectInteractionPageSetUpLimit(bool left) {
    int i = left ? 1 : 4;

    // If I ask to set the left limit but the Line on the left of the Flykeys device isn't light
    if (left && lightTheLeftLineOfLed) {
      lightTheLeftLineOfLed=false;
      bluetoothBloc.add(LightLedsEvent([0,1,2,3,4,5,6,7], true));
    }

    // If I ask to set the right limit but the Line on the right of the Flykeys device isn't light
    if (!left && lightTheRightLineOfLed) {
      lightTheRightLineOfLed=false;
      var last = Constants.lastLedIndex;
      bluetoothBloc.add(LightLedsEvent([last-7, last-6, last-5, last-4, last-3, last-2, last-1, last], true));
    }

    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
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
                  text: " (vous pouvez regarder les schémas ci-dessous pour mieux comprendre). Une fois cela effectué, il vous suffira d\'appuyez sur le bouton en bas de la page.",
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
                  text: " (" + Utils.getNoteNameFromKey(lastKeyPushed) +").",
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
                  leftLimitOfKeyboardIsSetUp = true;
                });
                _scrollController.animateTo(0, duration: Duration(milliseconds: 250), curve: Curves.easeIn);
                widget.info['leftLimit'] = lastKeyPushed;
              } else {
                widget.info['rightLimit'] = lastKeyPushed;
                bluetoothBloc.add(ClearLedsEvent());
                widget.onChoice();
              }
            }, fontSize: 16.0),
          ),
        ],
      ),
    );
  }

  /// [index] is the number of the schema.
  /// [description] is the description of the schema
  /// [imageAsset] is the path of the image
  Widget schemaWithExplanation(int index, String description, String imageAsset) {
    return Column(
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

  void onNotePushed() {
    setState(() {
      lastKeyPushed = valueNotifierNotePushed.value;
    });
  }

  @override
  void dispose() {
    super.dispose();
    print('dispose set_limit_of_keyboard_midi');
    bluetoothBloc.stopListeningToNotePushed();
    valueNotifierNotePushed?.removeListener(onNotePushed);
    valueNotifierNotePushed?.dispose();
  }
}
