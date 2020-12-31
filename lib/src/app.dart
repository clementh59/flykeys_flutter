import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flykeys/src/bloc/authentification/authentification_bloc.dart';
import 'package:flykeys/src/page/main_page.dart';
import 'package:flykeys/src/repository/bluetooth_repository.dart';
import 'package:flykeys/src/repository/database_repository.dart';

import 'bloc/bluetooth/bloc.dart';
import 'bloc/favorites/bloc.dart';

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MultiBlocProvider(
      providers: [
        BlocProvider<BluetoothBloc>(create: (BuildContext context) {
          return BluetoothBloc(BluetoothRepository());
        }),
        BlocProvider<FavoritesBloc>(create: (BuildContext context) {
          return FavoritesBloc(SharedPrefsRepository(), FirestoreRepository());
        }),
        BlocProvider<AuthentificationBloc>(create: (BuildContext context) {
          return AuthentificationBloc();
        }),
      ],
      child: MaterialApp(
        theme: ThemeData.dark(),
        debugShowCheckedModeBanner: false,
        home: MainPage()/*LoginPage()*/,
      ),
    );
  }
}
