import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flykeys/src/bloc/bluetooth/bloc.dart';
import 'package:flykeys/src/page/bluetooth/connection_to_flykeys_object_page.dart';
import 'package:flykeys/src/utils/custom_colors.dart';
import 'package:flykeys/src/widget/custom_widgets.dart';

class LightningShowPage extends StatefulWidget {
  @override
  _LightningShowPageState createState() => _LightningShowPageState();
}

class _LightningShowPageState extends State<LightningShowPage> {
  //J'ignore le close_sink ce dessous car sinon, je ne pourrais plus utiliser BluetoothBloc.of(context) dans toute l'appli car je l'aurais close!
// ignore: close_sinks
  BluetoothBloc bluetoothBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bluetoothBloc = BlocProvider.of<BluetoothBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: CustomColors.backgroundColor,
      body: SafeArea(
          child: WillPopScope(
        onWillPop: () async {
          //todo:
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
                  BlocProvider.of<BluetoothBloc>(context).add(FindFlyKeysDevice()); //changer la place de ça parce que ça nique tout lorsque ça rebuild

                  return BlocBuilder<BluetoothBloc, MyBluetoothState>(
                    builder: (BuildContext context, MyBluetoothState state) {
                      if (state is BluetoothMainStateSettingUp) {
                        return Stack(
                          children: <Widget>[
                            Center(
                                child: SettingUpBluetoothPage(state, () {
                              BlocProvider.of<BluetoothBloc>(context).add(LightningShowEvent());
                            }, () {
                              Navigator.of(context).pop();
                            })),
                          ],
                        );
                      }

                      if (state is LightningShowModeState) {
                        return LightningShowModePage();
                      }

                      return Container(
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                          child: CustomWidgets.textWithLoadingIndicator("Chargement du mode en cours ..."),
                        ),
                      );
                    },
                  );
                } else if (state == BluetoothState.off) {
                  BlocProvider.of<BluetoothBloc>(context).onDisconnect();
                }
                return CustomWidgets.bluetoothIsOff();
              }),
        ),
      )),
    );
  }
}

class LightningShowModePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: CustomWidgets.textWithoutLoadingIndicator("Mode animation visuelle"),
      ),
    );
  }
}
