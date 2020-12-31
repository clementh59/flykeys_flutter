import 'package:flutter/material.dart';
import 'package:flykeys/src/utils/custom_colors.dart';
import 'package:flykeys/src/utils/custom_size.dart';
import 'package:flykeys/src/utils/custom_style.dart';

typedef callBackFunction = void Function(int);

//region Bottom nav bar
TextStyle bottomNavBarTitle = TextStyle(
  color: CustomColors.white,
  fontSize: 10,
  fontFamily: 'Poppins',
  fontWeight: CustomStyle.LIGHT,
);
//endregion

class CustomBottomNavigationBar extends StatefulWidget {

  final callBackFunction callBack;

  CustomBottomNavigationBar(this.callBack);

  @override
  _CustomBottomNavigationBarState createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  int _selectedItem = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 1,
          color: CustomColors.grey,
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            InkWell(
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                onTap: () {
                  setState(() {
                    _selectedItem = 0;
                  });
                  widget.callBack(0);
                },
                child: CustomNavBarItem(
                    "Home",
                    Image.asset(
                      "assets/images/icons/home_icon.png",
                      width: CustomSize.sizeOfIcons,
                    ),
                    _selectedItem == 0)),
            InkWell(
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                onTap: () {
                  setState(() {
                    _selectedItem = 1;
                  });
                  widget.callBack(1);
                },
                child: CustomNavBarItem(
                    "Search",
                    Image.asset(
                      "assets/images/icons/search_icon.png",
                      width: CustomSize.sizeOfIcons,
                    ),
                    _selectedItem == 1)),
            InkWell(
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                onTap: () {
                  setState(() {
                    _selectedItem = 2;
                  });
                  widget.callBack(2);
                },
                child: CustomNavBarItem(
                    "Favorites",
                    Image.asset(
                      "assets/images/icons/heart_icon.png",
                      width: CustomSize.sizeOfIcons,
                    ),
                    _selectedItem == 2)),
          ],
        ),
      ],
    );
  }
}

class CustomNavBarItem extends StatelessWidget {
  final String label;
  final Widget icon;
  final bool chosen;

  CustomNavBarItem(this.label, this.icon, this.chosen);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 5,
          width: CustomSize.widthOfBlueIndicator,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: chosen ? CustomColors.blue : Colors.transparent),
        ),
        SizedBox(
          height: 5,
        ),
        icon,
        SizedBox(
          height: 4,
        ),
        Text(
          label,
          style: bottomNavBarTitle,
        ),
        SizedBox(
          height: 4,
        ),
      ],
    );
  }
}
