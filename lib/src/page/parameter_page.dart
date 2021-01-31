import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flykeys/src/bloc/authentification/authentification_bloc.dart';
import 'package:flykeys/src/bloc/authentification/authentification_event.dart';
import 'package:flykeys/src/utils/constants.dart';
import 'package:flykeys/src/utils/custom_colors.dart';
import 'package:flykeys/src/utils/custom_size.dart';
import 'package:flykeys/src/utils/custom_style.dart';
import 'package:flykeys/src/utils/strings.dart';
import 'package:flykeys/src/utils/utils.dart';
import 'package:flykeys/src/widget/custom_widgets.dart';

class ParameterPage extends StatefulWidget {
  @override
  _ParameterPageState createState() => _ParameterPageState();
}

class _ParameterPageState extends State<ParameterPage> {
  static const int parameterIndex = 0;
  static const int choixDesCouleursIndex = 1;
  static const int profilIndex = 2;

  int _indexedStackIndex = 0;

  //variables pour notification
  bool notificationActive;

  //variable pour luminosité
  int selectedRadioLuminosity = 0;

  @override
  void initState() {
    super.initState();
    notificationActive = true;
    loadColorsFromSharedPrefs();
    loadBrightnessFromSharedPrefs();
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
        child: WillPopScope(
          onWillPop: () async {
            if (_indexedStackIndex == parameterIndex) return true;
            setState(() {
              _indexedStackIndex = parameterIndex;
            });
            return false;
          },
          child: IndexedStack(
            index: _indexedStackIndex,
            children: [
              SingleChildScrollView(child: parameterPage()),
              choixDesCouleursPage(),
              profilPage(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tileParameterWidget(String name, Widget imageAsset, Function callBack,
      {bool showRightArrow = false, bool showSwitch = false, bool switchState = false}) {
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

  /***************    PARAMETER PAGE   *************/

  Widget parameterPage() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: CustomSize.leftAndRightPadding),
          child: _topBar("Settings"),
        ),
        SizedBox(
          height: 31,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: CustomSize.leftAndRightPadding),
          child: _profileWidget(true),
        ),
        SizedBox(
          height: 25,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: CustomSize.leftAndRightPadding),
          child: _tilesParameterWidget(),
        ),
      ],
    );
  }

  Widget _topBar(String text) {
    return Stack(
      children: [
        Align(
            alignment: Alignment.topLeft,
            child: InkWell(
              onTap: () {
                if (_indexedStackIndex == parameterIndex) Navigator.of(context).pop();
                setState(() {
                  _indexedStackIndex = parameterIndex;
                });
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

  Widget _profileWidget(bool arrow) {
    return InkWell(
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () {
        setState(() {
          _indexedStackIndex = profilIndex;
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Container(
              width: 77,
              height: 77,
              child: Image.asset("assets/images/temporary/clement.jpg"),
            ),
          ),
          SizedBox(
            width: 8,
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Clément Hecquet",
                  style: CustomStyle.personNameParameterPage,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  "clementhecquet@gmail.com",
                  style: CustomStyle.emailParameterPage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(
            width: 8,
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: arrow ? CustomColors.white : CustomColors.backgroundColor,
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget _tilesParameterWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tileParameterWidget("Notifications", Image.asset("assets/images/icons/parameter/notification_icon.png"), activeNotification,
            showSwitch: true, switchState: notificationActive),
        _tileParameterWidget("Choix des couleurs", Image.asset("assets/images/icons/parameter/color_wheel_icon.png"), () {
          setState(() {
            _indexedStackIndex = choixDesCouleursIndex;
          });
        }, showRightArrow: true),
        _tileParameterWidget("Luminosité de Flykeys", Image.asset("assets/images/icons/parameter/luminosity_icon.png"), () {
          showChooseLuminosityDialog();
        }, showRightArrow: true),
        _tileParameterWidget(
          "FAQ",
          Image.asset("assets/images/icons/parameter/faq_icon.png"),
          () {},
          showRightArrow: true,
        ),
        _tileParameterWidget(
          "Contact",
          Image.asset("assets/images/icons/parameter/contact_icon.png"),
          () {
            //todo: popup avec link twitter,...
          },
        ),
        _tileParameterWidget("Informations légales", Image.asset("assets/images/icons/parameter/info_icon.png"), () {
          showAboutDialog(
              context: context, applicationLegalese: Constants.legalPhrase, applicationVersion: Constants.app_version, applicationName: 'FlyKeys');
        }),
      ],
    );
  }

  void activeNotification() {
    setState(() {
      notificationActive = !notificationActive;
    });
  }

  //region brightness
  void loadBrightnessFromSharedPrefs() async {
    int brightness = await Utils.getIntegerFromSharedPreferences(Strings.BRIGHTNESS_SHARED_PREFS, defaultValue: Constants.DefaultBrightness);
    setState(() {
      switch (brightness) {
        case Constants.lightBrightness:
          selectedRadioLuminosity = 0;
          break;
        case Constants.mediumBrightness:
          selectedRadioLuminosity = 1;
          break;
        case Constants.strongBrightness:
          selectedRadioLuminosity = 2;
          break;
        default:
          selectedRadioLuminosity = 0;
          break;
      }
    });
  }

  void showChooseLuminosityDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: List<Widget>.generate(3, (int index) {
                  return ListTile(
                    title: Text(getBrightnessText(index)),
                    leading: Radio(
                      value: index,
                      groupValue: selectedRadioLuminosity,
                      onChanged: (value) {
                        Utils.saveIntegerToSharedPreferences(Strings.BRIGHTNESS_SHARED_PREFS, mapIndexToBrightness(index));
                        setState(() {
                          selectedRadioLuminosity = value;
                        });
                      },
                    ),
                  );
                }),
              );
            },
          ),
        );
      });
  }

  /// return 'Faible' for 0, 'Élevée' for 2, ...
  String getBrightnessText(int index) {
    if (index == 0)
      return 'Faible';
    if (index == 2)
      return 'Élevée';
    return 'Moyen';
  }

  /// return an integer corresponding to the brightness corresponding to the index of the radio buttons
  int mapIndexToBrightness(int index) {
    if (index == 0)
      return Constants.lightBrightness;
    if (index == 1)
      return Constants.mediumBrightness;
    return Constants.strongBrightness;
  }
  //endregion

  /***************    CHOIX DES COULEURS PAGE   *************/

  //pour la page couleur
  Color couleurMD = Colors.blue;
  Color couleurMG = Colors.red;

  Widget choixDesCouleursPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: CustomSize.leftAndRightPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _topBar("Choix des couleurs"),
              SizedBox(
                height: 31,
              ),
              _tilesChoixCouleurWidget(),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CustomWidgets.buttonLoadMorePopularSongStyle("SAUVEGARDER MES COULEURS", saveColorChanges, fontSize: 14.0),
              SizedBox(
                height: 31,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tilesChoixCouleurWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tileChoixCouleur("Couleur main droite", couleurMD, (color) {
          setState(() {
            couleurMD = color;
          });
        }),
        _tileChoixCouleur("Couleur main gauche", couleurMG, (color) {
          setState(() {
            couleurMG = color;
          });
        }),
      ],
    );
  }

  Widget _tileChoixCouleur(String name, Color c, Function callback) {
    return _tileParameterWidget(
      name,
      Container(
        decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white)),
      ),
      () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              titlePadding: const EdgeInsets.all(0.0),
              contentPadding: const EdgeInsets.all(0.0),
              content: SingleChildScrollView(
                child: ColorPicker(
                  pickerColor: c,
                  onColorChanged: (color) {
                    callback(color);
                  },
                  colorPickerWidth: 300.0,
                  pickerAreaHeightPercent: 0.7,
                  enableAlpha: false,
                  displayThumbColor: true,
                  showLabel: true,
                  paletteType: PaletteType.hsv,
                  pickerAreaBorderRadius: const BorderRadius.only(
                    topLeft: const Radius.circular(2.0),
                    topRight: const Radius.circular(2.0),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// save the colors to shared prefs
  void saveColorChanges() async {
    Utils.saveStringToSharedPreferences(Strings.COLOR_MD_SHARED_PREFS, couleurMD.toString());
    Utils.saveStringToSharedPreferences(Strings.COLOR_MG_SHARED_PREFS, couleurMG.toString());
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text('Les couleurs sont sauvegardées'),
    ));
    setState(() {
      _indexedStackIndex = parameterIndex;
    });
  }

  /// load the colors from shared prefs
  void loadColorsFromSharedPrefs() async {
    Color colorMd = await Utils.readColorFromSharedPreferences(Strings.COLOR_MD_SHARED_PREFS, Constants.DefaultMDColor);
    Color colorMg = await Utils.readColorFromSharedPreferences(Strings.COLOR_MG_SHARED_PREFS, Constants.DefaultMGColor);
    setState(() {
      couleurMD = colorMd;
      couleurMG = colorMg;
    });
  }

  /***************    PROFIL PAGE   *************/

  Widget profilPage() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: CustomSize.leftAndRightPadding),
          child: _topBar("Profil"),
        ),
        SizedBox(
          height: 31,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: CustomSize.leftAndRightPadding),
          child: _profileWidget(false),
        ),
        SizedBox(
          height: 33,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: CustomSize.leftAndRightPadding),
          child: _tileParameterWidget(Strings.deconnection, Image.asset("assets/images/icons/parameter/deconnect_icon.png"), () {
            BlocProvider.of<AuthentificationBloc>(context).add(DisconnectAuthEvent());
            Navigator.pop(context);
          }),
        ),
      ],
    );
  }
}
