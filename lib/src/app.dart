import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flykeys/src/bloc/authentification/authentification_bloc.dart';
import 'package:flykeys/src/page/loading_page.dart';
import 'package:flykeys/src/page/login_page.dart';
import 'package:flykeys/src/page/main_page.dart';
import 'package:flykeys/src/page/music_page_debug.dart';
import 'package:flykeys/src/page/onboarding/onboarding_page.dart';
import 'package:flykeys/src/repository/authentification_repository.dart';
import 'package:flykeys/src/repository/bluetooth_repository.dart';
import 'package:flykeys/src/repository/database_repository.dart';
import 'package:flykeys/src/utils/strings.dart';
import 'package:flykeys/src/utils/utils.dart';

import 'bloc/bluetooth/bloc.dart';
import 'bloc/favorites/bloc.dart';
import 'model/music.dart';

enum possiblePages { loading, mainPage, login, onBoarding }

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  var pageToShow = possiblePages.loading;

  @override
  void initState() {
    super.initState();
    checkWhichPageIShow();
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
        home: getPageToShow(),
      ),
    );
  }

  /// [returns] the page to show according to [pageToShow]
  Widget getPageToShow() {
    return MusicDebugPage(Music.fromDummyValues());
    switch (pageToShow) {
      case possiblePages.loading:
        return LoadingPage();
      case possiblePages.mainPage:
        return MainPage();
      case possiblePages.login:
        return LoginPage();
      case possiblePages.onBoarding:
        return OnBoardingPage(
          nextPage: LoginPage(),
        );
    }
    return SizedBox();
  }

  /// It updates the variable [pageToShow] to the page to show
  /// If the user didn't do the onBoarding phase, we show it
  /// else if the user isn't logged in, we show the login page
  /// else we show the main page
  void checkWhichPageIShow() async {
    var results = await Future.wait([
      Utils.getBooleanFromSharedPreferences(Strings.I_DID_ONBOARDING_SHARED_PREFS),
      AuthentificationRepository().checkIfHeIsLoggedIn(),
    ]);

    bool iDidOnBoarding = results[0];
    bool iAmLogin = results[1];

    if (!iDidOnBoarding) {
      setState(() {
        pageToShow = possiblePages.onBoarding;
      });
    } else if (!iAmLogin) {
      setState(() {
        pageToShow = possiblePages.login;
      });
    } else {
      setState(() {
        pageToShow = possiblePages.mainPage;
      });
    }
  }
}
