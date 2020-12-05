import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flykeys/src/bloc/authentification/authentification_bloc.dart';
import 'package:flykeys/src/page/favorites_page.dart';
import 'package:flykeys/src/page/home_page.dart';
import 'package:flykeys/src/page/login_page.dart';
import 'package:flykeys/src/page/main_page.dart';
import 'package:flykeys/src/page/music_page.dart';
import 'package:flykeys/src/page/music_parameter_page.dart';
import 'package:flykeys/src/page/search_page.dart';
import 'package:flykeys/src/repository/bluetooth_repository.dart';
import 'package:flykeys/src/repository/database_repository.dart';
import 'package:flykeys/src/utils/custom_colors.dart';
import 'package:flykeys/src/utils/custom_size.dart';
import 'package:flykeys/src/widget/custom_bottom_navigation_bar.dart';

import 'bloc/bluetooth/bloc.dart';
import 'bloc/favorites/bloc.dart';
import 'model/music.dart';

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
