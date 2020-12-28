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

enum Steps { checkConnection, setUpLeftLimit, setUpRightLimit, verification }

class SetLimitOfKeyboardMidi extends StatefulWidget {
  final Function onChoice;
  final Function goBack;
  final Map info;

  SetLimitOfKeyboardMidi(this.info, this.onChoice, this.goBack);

  @override
  _SetLimitOfKeyboardMidiState createState() => _SetLimitOfKeyboardMidiState();
}

class _SetLimitOfKeyboardMidiState extends State<SetLimitOfKeyboardMidi> {
  //region Variables

  //J'ignore le close_sink ce dessous car sinon, je ne pourrais plus utiliser BluetoothBloc.of(context) dans toute l'appli car je l'aurais close!
  // ignore: close_sinks
  BluetoothBloc bluetoothBloc;
  ValueNotifier<int> valueNotifierNotePushed;
  var step = Steps.checkConnection; // to know at which step I am
  int lastKeyPushed = 0;
  bool iAskToBeConnectedToFlykeysDevice = false; // To know if I have already ask to be connected to the Flykeys device
  bool lightTheLeftLineOfLed = true; // To know if I have already light the line positioned on the left of the Flykeys device
  bool lightTheRightLineOfLed = true; // To know if I have already light the line positioned on the right of the Flykeys device
  ScrollController _scrollController = new ScrollController(); // To make the page scroll to the top when go to last page

  //endregion

  //region Overrides

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
                        print(step);
                        switch (step) {
                          case Steps.checkConnection: // I ask to press a key to check if the connection is working
                            return objectInteractionPageIntroduction();
                          case Steps.setUpLeftLimit:
                            return objectInteractionPageSetUpLimit(true);
                          case Steps.setUpRightLimit:
                            return objectInteractionPageSetUpLimit(false);
                          case Steps.verification:
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
                return CustomWidgets.bluetoothIsOff();
              }),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    print('dispose set_limit_of_keyboard_midi');
    bluetoothBloc.stopListeningToNotePushed();
    valueNotifierNotePushed?.removeListener(onNotePushed);
    valueNotifierNotePushed?.dispose();
  }

  //endregion

  //region Pages
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
                step = Steps.setUpRightLimit;
              });
              _scrollController.animateTo(0, duration: Duration(milliseconds: 250), curve: Curves.easeIn);
              widget.info['leftLimit'] = lastKeyPushed;
            } else {
              widget.info['rightLimit'] = lastKeyPushed;
              bluetoothBloc.add(ClearLedsEvent());
              setState(() {
                step = Steps.verification;
              });
              _scrollController.animateTo(0, duration: Duration(milliseconds: 250), curve: Curves.easeIn);
            }
          }, fontSize: 16.0),
        ),
      ],
    );
  }

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
              // todo:
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

  //endregion

  //region Logic

  void onNotePushed() {
    setState(() {
      lastKeyPushed = valueNotifierNotePushed.value;
    });
  }

//endregion
}
