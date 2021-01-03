import 'package:flutter/material.dart';
import 'package:flykeys/src/page/search_page.dart';
import 'package:flykeys/src/utils/custom_colors.dart';
import 'package:flykeys/src/widget/custom_bottom_navigation_bar.dart';
import 'favorites_page.dart';
import 'home_page.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  int _selectedItem = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: SafeArea(
        child: CustomBottomNavigationBar((val) {
          setState(() {
            _selectedItem = val;
          });
        }),
      ),
      backgroundColor: CustomColors.backgroundColor,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedItem,
          children: [
            HomePage(),
            SearchPage(),
            FavoritesPage(),
          ],
        )),
    );
  }
}
