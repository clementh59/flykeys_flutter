import 'package:flutter/material.dart';
import 'package:flykeys/src/utils/custom_colors.dart';

class CustomStyle{

	//region Font weights
	static const FontWeight EXTRALIGHT = FontWeight.w100;
	static const FontWeight THIN = FontWeight.w200;
	static const FontWeight LIGHT = FontWeight.w300;
	static const FontWeight REGULAR = FontWeight.w400;
	static const FontWeight MEDIUM = FontWeight.w500;
	static const FontWeight SEMIBOLD = FontWeight.w600;
	static const FontWeight BOLD = FontWeight.w700;
	static const FontWeight EXTRABOLD = FontWeight.w800;
	static const FontWeight BLACK = FontWeight.w900;
	//endregion

	//region titles and subtitles
	static TextStyle pageTitle = TextStyle(
		color: CustomColors.white,
		fontSize: 20,
		fontFamily: 'Poppins',
		fontWeight: BOLD,
	);

	static TextStyle title = TextStyle(
		color: CustomColors.white,
		fontSize: 24,
		fontFamily: 'Poppins',
		fontWeight: BOLD,
	);

	static TextStyle greySubtitle = TextStyle(
		color: CustomColors.grey,
		fontSize: 15,
		fontFamily: 'Poppins',
		fontWeight: REGULAR,
	);
	//endregion

	//region Music tiles
	static TextStyle musicTileName = TextStyle(
		color: CustomColors.white,
		fontSize: 14,
		fontFamily: 'Poppins',
		fontWeight: MEDIUM,
	);

	static TextStyle auteurTileName = TextStyle(
		color: CustomColors.blue,
		fontSize: 12,
		fontFamily: 'Poppins',
		fontWeight: MEDIUM,
	);
	//endregion

	//region Game tile
	static TextStyle gameTileName = TextStyle(
		color: CustomColors.white,
		fontSize: 11,
		fontFamily: 'Poppins',
		fontWeight: SEMIBOLD,
	);

	static TextStyle gameTileNbPlayers = TextStyle(
		color: CustomColors.blue,
		fontSize: 11,
		fontFamily: 'Poppins',
		fontWeight: MEDIUM,
	);
	//endregion

	//region Transcribers
	static TextStyle transcriberTileName = TextStyle(
		color: CustomColors.white,
		fontSize: 17,
		fontFamily: 'Poppins',
		fontWeight: SEMIBOLD,
	);

	static TextStyle transcriberTileFollowers = TextStyle(
		color: CustomColors.white,
		fontSize: 11,
		fontFamily: 'Poppins',
		fontWeight: LIGHT,
	);

	static TextStyle transcriberSmallTileName = TextStyle(
		color: CustomColors.white,
		fontSize: 14,
		fontFamily: 'Poppins',
		fontWeight: MEDIUM,
	);

	static TextStyle transcriberSmallTileFollowers = TextStyle(
		color: CustomColors.grey,
		fontSize: 11,
		fontFamily: 'Poppins',
		fontWeight: LIGHT,
	);
	//endregion

	//region Search page
	//search field hint text
	static TextStyle searchFieldHintText = TextStyle(
		color: CustomColors.grey,
		fontSize: 15,
		fontFamily: 'Poppins',
		fontWeight: MEDIUM,
	);
	//search field text
	static TextStyle searchFieldText = TextStyle(
		color: CustomColors.white,
		fontSize: 15,
		fontFamily: 'Poppins',
		fontWeight: MEDIUM,
	);

	static TextStyle textResultNotChosen = TextStyle(
		color: CustomColors.grey,
		fontSize: 12,
		fontFamily: 'Poppins',
		fontWeight: MEDIUM,
	);

	static TextStyle textResultChosen = TextStyle(
		color: CustomColors.white,
		fontSize: 12,
		fontFamily: 'Poppins',
		fontWeight: BOLD,
	);

	static TextStyle noResultText = TextStyle(
		color: CustomColors.white,
		fontSize: 20,
		fontFamily: 'Poppins',
		fontWeight: SEMIBOLD,
	);

	static TextStyle followTextTileTranscriber = TextStyle(
		color: CustomColors.white,
		fontSize: 13,
		fontFamily: 'Poppins',
		fontWeight: MEDIUM,
	);

	//region Blue number with background
	static TextStyle numberResultChosen = TextStyle(
		color: CustomColors.white,
		fontSize: 11,
		fontFamily: 'Poppins',
		fontWeight: SEMIBOLD,
	);

	static TextStyle numberResultNotChosen = TextStyle(
		color: CustomColors.grey,
		fontSize: 11,
		fontFamily: 'Poppins',
		fontWeight: SEMIBOLD,
	);
	//endregion
	//endregion

	//region Detail page
	static TextStyle detailPageName = TextStyle(
		color: CustomColors.white,
		fontSize: 22,
		fontFamily: 'Poppins',
		fontWeight: BOLD,
	);

	static TextStyle numberOfVote = TextStyle(
		color: CustomColors.blueGrey,
		fontSize: 11,
		fontFamily: 'Poppins',
		fontWeight: REGULAR,
	);

	static TextStyle numberFollowersDetailPage = TextStyle(
		color: CustomColors.white,
		fontSize: 16,
		fontFamily: 'Poppins',
		fontWeight: SEMIBOLD,
	);

	static TextStyle labelFollowersDetailPage = TextStyle(
		color: CustomColors.grey,
		fontSize: 12,
		fontFamily: 'Poppins',
		fontWeight: SEMIBOLD,
	);

	static TextStyle followButtonTextDetailPage = TextStyle(
		color: CustomColors.white,
		fontSize: 16,
		fontFamily: 'Poppins',
		fontWeight: SEMIBOLD,
	);
	//endregion

	//region Sending morceau page
	static TextStyle loadingProgressMusicPage = TextStyle(
		color: CustomColors.white,
		fontSize: 24,
		fontFamily: 'Poppins',
		fontWeight: BLACK,
	);

	static TextStyle loadingTextMusicPage = TextStyle(
		color: CustomColors.white,
		fontSize: 18,
		fontFamily: 'Poppins',
		fontWeight: MEDIUM,
	);

	static TextStyle loadingTextSkipSendingStep = TextStyle(
		color: CustomColors.blue,
		fontSize: 12,
		fontFamily: 'Poppins',
		fontWeight: BOLD,
	);
	//endregion

	//region Music page
	static TextStyle musicNameMusicPage = TextStyle(
		color: CustomColors.white,
		fontSize: 20,
		fontFamily: 'Poppins',
		fontWeight: BOLD,
	);

	static TextStyle authorNameMusicPage = TextStyle(
		color: CustomColors.blue,
		fontSize: 16,
		fontFamily: 'Poppins',
		fontWeight: BOLD,
	);

	static TextStyle numberSlideBarMusicPage = TextStyle(
		color: CustomColors.white,
		fontSize: 10,
		fontFamily: 'Poppins',
		fontWeight: MEDIUM,
	);

	static TextStyle transcriberNameMusicPage = TextStyle(
		color: CustomColors.white,
		fontSize: 10,
		fontFamily: 'Poppins',
		fontWeight: SEMIBOLD,
	);

	static TextStyle transcriberColorNameMusicPage = TextStyle(
		color: CustomColors.blue,
		fontSize: 10,
		fontFamily: 'Poppins',
		fontWeight: SEMIBOLD,
	);
	//endregion

	//region Parameter page
	static TextStyle personNameParameterPage = TextStyle(
		color: CustomColors.white,
		fontSize: 20,
		fontFamily: 'Poppins',
		fontWeight: MEDIUM,
	);

	static TextStyle emailParameterPage = TextStyle(
		color: CustomColors.grey,
		fontSize: 12,
		fontFamily: 'Poppins',
		fontWeight: LIGHT,
	);

	static TextStyle notificationNameParameterPage = TextStyle(
		color: CustomColors.white,
		fontSize: 14,
		fontFamily: 'Poppins',
		fontWeight: MEDIUM,
	);

	static TextStyle handNameMusicParameterPage = TextStyle(
		color: CustomColors.white,
		fontSize: 11,
		fontFamily: 'Poppins',
		fontWeight: BOLD,
	);
	//endregion

	//region Login page
	static TextStyle labelLoginPage = TextStyle(
		color: CustomColors.white,
		fontSize: 12,
		fontFamily: 'Poppins',
		fontWeight: REGULAR
	);

	static TextStyle errorLoginPage = TextStyle(
		color: CustomColors.errorColor,
		fontSize: 12,
		fontFamily: 'Poppins',
		fontWeight: REGULAR
	);

	static BoxDecoration boxDecorationStyleLoginPage = BoxDecoration(
		color: CustomColors.white.withOpacity(0.10),
		borderRadius: BorderRadius.circular(10.0),
		boxShadow: [
			BoxShadow(
				color: Colors.black12,
				blurRadius: 6.0,
				offset: Offset(0, 2),
			),
		],
	);

	static TextStyle hintTextLoginPage = TextStyle(
		color: CustomColors.white.withOpacity(0.7),
		fontFamily: 'Poppins',
	);

	static TextStyle loginButtonLoginPage = TextStyle(
		color: Color(0xFF527DAA),
		letterSpacing: 1.5,
		fontSize: 18.0,
		fontWeight: FontWeight.bold,
		fontFamily: 'Poppins',
	);

	static TextStyle signInLoginPage = TextStyle(
		color: Colors.white,
		fontFamily: 'Poppins',
		fontSize: 25.0,
		fontWeight: FontWeight.bold,
	);
	//endregion

	//region OnBoarding page
	static TextStyle titleOnBoardingPage = TextStyle(
		color: CustomColors.white,
		fontSize: 16,
		fontFamily: 'Poppins',
		fontWeight: REGULAR,
	);

	static TextStyle bigTextOnBoardingPage = TextStyle(
		color: CustomColors.white,
		fontSize: 25,
		fontFamily: 'Poppins',
		fontWeight: MEDIUM,
		height: 1.3
	);

	static TextStyle smallTextOnBoardingPage = TextStyle(
		color: CustomColors.white,
		fontSize: 16,
		fontFamily: 'Poppins',
		fontWeight: LIGHT,
	);

	static TextStyle smallButtonTextOnBoardingPage = TextStyle(
		color: CustomColors.white,
		fontSize: 14,
		fontFamily: 'Poppins',
		fontWeight: MEDIUM,
	);

	static TextStyle bigButtonTextOnBoardingPage = TextStyle(
		color: CustomColors.white,
		fontSize: 20,
		fontFamily: 'Poppins',
		fontWeight: BOLD,
	);
	//endregion

	//region buttons
	static TextStyle morePopularSongStyle = TextStyle(
		color: CustomColors.white,
		fontSize: 12,
		fontFamily: 'Poppins',
		fontWeight: BOLD,
	);
	//endregion
}