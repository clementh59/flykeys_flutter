import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flykeys/src/bloc/image_loading/bloc.dart';
import 'package:flykeys/src/page/parameter_page.dart';
import 'package:flykeys/src/utils/custom_colors.dart';
import 'package:flykeys/src/utils/custom_style.dart';

class CustomWidgets {

  //region Icons
  static Widget settingsIcon(context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ParameterPage()),
        );
      },
      child: Icon(
        Icons.settings,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  static Widget backArrowIcon(context) {
    return InkWell(
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
    );
  }

  static Widget playIconWithBlueCircle() {
    return Container(
      height: 45,
      width: 45,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(150), border: Border.all(color: CustomColors.blue, width: 1.25)),
      child: Center(
        child: Container(
          width: 22,
          height: 22,
          child: Image.asset('assets/images/icons/play_icon.png')
        )
      ),
    );
  }

  //region Pastilles bleu
  static Widget smallPastilleBleu() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        color: CustomColors.blue,
        child: Padding(
          padding: const EdgeInsets.all(1.5),
          child: Icon(
            Icons.check,
            color: Colors.white,
            size: 11,
          ),
        ),
      ),
    );
  }

  static Widget bigPastilleBleu() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Container(
        color: CustomColors.blue,
        child: Padding(
          padding: const EdgeInsets.all(1.5),
          child: Icon(
            Icons.check,
            color: Colors.white,
            size: 25,
          ),
        ),
      ),
    );
  }
  //endregion

  static Widget ytWidget(double height) {
    return Image.asset(
      "assets/images/icons/logo_yt.png",
      height: height,
    );
  }

  static Widget heartIcon(bool liked) {
    if (liked)
      return Icon(
        Icons.favorite,
        color: CustomColors.heartColor,
        size: 30,
      );
    return Image.asset(
      "assets/images/icons/heart_border.png",
      height: 30,
    );
  }

  static Widget blueNumberIndicator(String number, bool fill) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: fill
        ? BoxDecoration(color: CustomColors.blue, borderRadius: BorderRadius.circular(15))
        : BoxDecoration(border: Border.all(color: CustomColors.grey), borderRadius: BorderRadius.circular(15)),
      child: Center(
        child: Text(
          number,
          style: CustomStyle.numberResultChosen,
        ),
      ),
    );
  }

  //endregion

  //region Stars Widgets
  static Widget starsWidget(double starsNumber) {
    List<Widget> stars = [];

    for (int i = 1; i <= 5; i++) {
      if (starsNumber > i)
        stars.add(_starWidget(1, 11));
      else
        stars.add(_starWidget(starsNumber - (i - 1), 11));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: stars,
    );
  }

  static Widget biggerStarsWidget(double starsNumber) {
    List<Widget> stars = [];

    for (int i = 1; i <= 5; i++) {
      if (starsNumber > i)
        stars.add(_starWidget(1, 14));
      else
        stars.add(_starWidget(starsNumber - (i - 1), 14));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: stars,
    );
  }

  static Widget _starWidget(double remplissage, double size) {
    if (remplissage > 0.66)
      return Icon(
        Icons.star,
        color: CustomColors.yellow,
        size: size,
      );
    if (remplissage < 0.33)
      return Icon(
        Icons.star_border,
        color: CustomColors.yellow,
        size: size,
      );
    return Icon(
      Icons.star_half,
      color: CustomColors.yellow,
      size: size,
    );
  }
  //endregion

  //region Note widgets
  static Widget noteWidget(int difficulty) {
    List<Widget> notes = [];

    for (int i = 0; i < difficulty; i++) {
      notes.add(_noteWidget(8));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: notes,
    );
  }

  static Widget biggerNoteWidget(int difficulty) {
    List<Widget> notes = [];

    for (int i = 0; i < difficulty; i++) {
      notes.add(_noteWidget(14));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: notes,
    );
  }

  static Widget _noteWidget(double height) {
    return Padding(
      padding: const EdgeInsets.only(left: 3.0),
      child: Image.asset(
        "assets/images/icons/note_icon.png",
        height: height,
      ),
    );
  }
  //endregion

  //region Text
  static Widget detailPageNumberCategories(String text1, String category1, String text2, String category2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      mainAxisSize: MainAxisSize.max,
      children: [
        CustomWidgets.detailPageNumberCategory(text1, category1),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: CustomColors.grey,
          ),
          width: 1,
          height: 45,
        ),
        CustomWidgets.detailPageNumberCategory(text2, category2),
      ],
    );
  }

  static Widget detailPageNumberCategory(String text, String category) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: CustomStyle.numberFollowersDetailPage,
        ),
        SizedBox(
          height: 7,
        ),
        Text(
          category,
          style: CustomStyle.labelFollowersDetailPage,
        ),
      ],
    );
  }

  static Widget numberSlideBarText(String text) {
    return Text(
      text,
      style: CustomStyle.numberSlideBarMusicPage,
    );
  }
  //endregion

  //region Utils for connection
  static Widget textWithLoadingIndicator(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _textWidget(text),
          SizedBox(
            height: 30,
          ),
          Container(
            height: 35,
            child: circularProgressIndicator(),
          )
        ],
      ),
    );
  }

  static Widget circularProgressIndicator() {
    return CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(CustomColors.blue));
  }

  static Widget textWithoutLoadingIndicator(String text) {
    return _textWidget(text);
  }

  static Widget bluetoothIsOff() {
    return Center(
      child: CustomWidgets.textWithoutLoadingIndicator("Bluetooth is off!"),
    );
  }

  static Widget _textWidget(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: CustomStyle.loadingTextMusicPage,
    );
  }
  //endregion

  //region Images
  /// returns a Row containing two images showing what is a MIDI port
  static Widget midiImages() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        SizedBox(),
        Image.asset('assets/images/onboarding/midi-input.png', width: 94),
        Image.asset('assets/images/onboarding/midi-cable.png', width: 108),
        SizedBox(),
      ],
    );
  }

  static Widget detailPageBackgroundImage(ImageLoadingBloc imageLoadingBloc, context) {
    return Stack(
      children: [
        BlocBuilder<ImageLoadingBloc, ImageLoadingState>(
          bloc: imageLoadingBloc,
          builder: (BuildContext context, ImageLoadingState state) {
            Widget image;

            if (state is ImageLoadedState) {
              image = state.image;
            } else
              image = null;

            if (image != null) {
              return image;
            }
            return SizedBox();
          }),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
                CustomColors.backgroundColor.withOpacity(0.7),
                CustomColors.backgroundColor.withOpacity(1),
              ]),
            ),
          ),
        ),
        Positioned(
          //Sinon j'ai une petite ligne non voulu en bas de la stack
          bottom: 0,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 2,
            color: CustomColors.backgroundColor,
          ),
        ),
      ],
    );
  }

  //endregion

  //region Buttons
  static Widget button(String text, Color borderColor, Function callback, {double width = double.infinity}) {
    return InkWell(
      onTap: callback,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(31),
        ),
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        child: Text(
          text,
          style: CustomStyle.smallButtonTextOnBoardingPage,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  static Widget buttonWithText(String text, Function onClick) {
    return Center(
      child: InkWell(
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: onClick,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: CustomColors.blue, width: 2),
          ),
          child: Text(
            text,
            style: CustomStyle.morePopularSongStyle,
          ),
        ),
      ),
    );
  }

  static Widget buttonLoadMorePopularSongStyle(String text, Function callback, {fontSize = 0}) {
    TextStyle style = CustomStyle.morePopularSongStyle;

    if (fontSize != 0) style = style.copyWith(fontSize: fontSize);

    return InkWell(
      onTap: callback,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(12.0),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: CustomColors.blue, width: 2),
        ),
        child: Center(
          child: Text(
            text,
            style: style,
          ),
        ),
      ),
    );
  }

  static Widget tileFollowButton(Function onTap) {
    return InkWell(
      onTap: () {
        onTap();
      },
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
        decoration: BoxDecoration(color: CustomColors.blue, borderRadius: BorderRadius.circular(20)),
        child: Text(
          "Follow",
          style: CustomStyle.followTextTileTranscriber,
        ),
      ),
    );
  }

  static Widget tileUnfollowButton(Function onTap) {
    return InkWell(
      onTap: () {
        onTap();
      },
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
        decoration: BoxDecoration(border: Border.all(color: CustomColors.grey), borderRadius: BorderRadius.circular(20)),
        child: Text(
          "Unfollow",
          style: CustomStyle.followTextTileTranscriber,
        ),
      ),
    );
  }

  static Widget detailPageFollowButton(Function onTap) {
    return InkWell(
      onTap: () {
        onTap();
      },
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Container(
        height: 44,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), color: CustomColors.blue),
        child: Center(
          child: Text(
            "Follow",
            style: CustomStyle.followButtonTextDetailPage,
          ),
        ),
      ),
    );
  }

  static Widget detailPageUnfollowButton(Function onTap) {
    return InkWell(
      onTap: () {
        onTap();
      },
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: CustomColors.grey),
        ),
        child: Center(
          child: Text(
            "Unfollow",
            style: CustomStyle.followButtonTextDetailPage,
          ),
        ),
      ),
    );
  }
  //endregion

  //region Custom Layouts
  /// returns a ScrollView that can contain things like Column with max size, Expanded, ...
  /// And of course, the scrollView will be scrollable only if the items are overflowing the screen.
  static Widget scrollViewWithBoundedHeight({child, scrollController}) {

    if (scrollController==null)
      scrollController = new ScrollController();

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          controller: scrollController,
          child: ConstrainedBox(
            constraints: constraints.copyWith(
              minHeight: constraints.maxHeight,
              maxHeight: double.infinity,
            ),
            child: IntrinsicHeight(
              child: child,
            ),
          ),
        );
      },
    );
  }
//endregion
}
