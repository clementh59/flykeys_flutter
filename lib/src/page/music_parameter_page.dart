import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flykeys/src/bloc/authentification/authentification_bloc.dart';
import 'package:flykeys/src/bloc/authentification/authentification_event.dart';
import 'package:flykeys/src/bloc/bluetooth/bloc.dart';
import 'package:flykeys/src/utils/custom_colors.dart';
import 'package:flykeys/src/utils/custom_size.dart';
import 'package:flykeys/src/utils/custom_style.dart';
import 'package:flykeys/src/utils/strings.dart';
import 'package:flykeys/src/utils/utils.dart';

class MusicParameterPage extends StatefulWidget {
  @override
  _MusicParameterPageState createState() => _MusicParameterPageState();
}

class _MusicParameterPageState extends State<MusicParameterPage> {

	bool waitForUserInput = false;

	@override
  void initState() {
    super.initState();
    initWaitForUserInput();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
            Image.asset("assets/images/icons/parameter/notification_icon.png"),
            clickOnWaitForUserInput,
            showSwitch: true,
            switchState: waitForUserInput),
      ],
    );
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

		Utils.saveBooleanFromSharedPreferences(Strings.WAIT_FOR_USER_INPUT, waitForUserInput);
	}

	void initWaitForUserInput() async {
		bool _tempoWaitForUserInput = await Utils.getBooleanFromSharedPreferences(Strings.WAIT_FOR_USER_INPUT);
		if (_tempoWaitForUserInput == null)
			_tempoWaitForUserInput = false;
		setState(() {
			waitForUserInput = _tempoWaitForUserInput;
		});
	}

}
