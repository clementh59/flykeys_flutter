import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flykeys/src/bloc/music/bloc.dart';
import 'package:flykeys/src/bloc/transcribers/bloc.dart';
import 'package:flykeys/src/bloc/trending/bloc.dart';
import 'package:flykeys/src/model/game.dart';
import 'package:flykeys/src/repository/database_repository.dart';
import 'package:flykeys/src/utils/constants.dart';
import 'package:flykeys/src/utils/custom_colors.dart';
import 'package:flykeys/src/utils/custom_size.dart';
import 'package:flykeys/src/utils/custom_style.dart';
import 'package:flykeys/src/utils/utils.dart';
import 'package:flykeys/src/widget/profile_image.dart';
import 'package:flykeys/src/widget/custom_widgets.dart';
import 'package:flykeys/src/widget/widget_music.dart';
import 'package:flykeys/src/widget/widget_transcriber.dart';
import 'package:flykeys/database.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ValueNotifier valueNotifierActivePageTranscriber =
      new ValueNotifier(0); //sert pour les dots indicators
  int dotIndicatorIndex = 0;

  TrendingBloc _trendingBloc;
  MusicBloc _musicBloc;
  TranscriberBloc _transcriberBloc;

  @override
  void initState() {
    super.initState();
    valueNotifierActivePageTranscriber.addListener(() {
      setState(() {
        dotIndicatorIndex = valueNotifierActivePageTranscriber.value;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _musicBloc = MusicBloc(FirestoreRepository());
    _transcriberBloc = TranscriberBloc(FirestoreRepository());
    _trendingBloc =
        TrendingBloc(_transcriberBloc, _musicBloc, FirestoreRepository())
          ..add(GetTrendings());
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: CustomSize.leftAndRightPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                CustomWidgets.settingsIcon(context),
                Text(
                  "Home",
                  style: CustomStyle.pageTitle,
                ),
                ProfileImage(),
              ],
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: CustomSize.leftAndRightPadding),
            child: Text(
              "Hi Clément",
              style: CustomStyle.greySubtitle,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: CustomSize.leftAndRightPadding),
            child: Text(
              "Popular transcribers",
              style: CustomStyle.title,
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: CustomSize.leftAndRightPadding),
            child: PageIndicator(dotIndicatorIndex),
          ),
          SizedBox(
            height: 15,
          ),
          popularTranscribersView(valueNotifierActivePageTranscriber),
          SizedBox(
            height: 25,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: CustomSize.leftAndRightPadding),
            child: Text(
              "Popular songs",
              style: CustomStyle.title,
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: CustomSize.leftAndRightPadding),
            child: popularMusicView(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: CustomSize.leftAndRightPadding),
            child: Text(
              "Play for fun",
              style: CustomStyle.title,
            ),
          ),
          SizedBox(
            height: 13,
          ),
          gameTiles(),
          SizedBox(
            height: 35,
          ),
        ],
      ),
    );
  }

  Widget popularTranscribersView(ValueNotifier valueNotifierActivePage) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: BlocBuilder<TranscriberBloc, TranscriberState>(
        bloc: _transcriberBloc,
        builder: (BuildContext context, TranscriberState state) {
          if (state is TranscriberListLoadedState) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(width: CustomSize.leftAndRightPadding,),
                for (int i = 0; i < state.transcribers.length; i++)
                  WidgetTranscriber(
                      state.transcribers[i], i, valueNotifierActivePage)
              ],
            );
          }
          if (state is TranscriberListLoadingState) {
            return Container(height: CustomSize.heightOfTranscriberTile, width: MediaQuery.of(context).size.width,child: Center(child: CircularProgressIndicator()));
          }
          return SizedBox();
        },
      ),
    );
  }

  Widget popularMusicView() {
    return BlocBuilder<MusicBloc, MusicState>(
      bloc: _musicBloc,
      builder: (BuildContext context, MusicState state) {
        print("New state in bloc builder $state");

        if (state is MusicTrendingListLoadedState) {

          if (!state.itsTheLastTrendingToFetch) {
            return MusicListWidget(state.musics, _buttonLoadMorePopular());
          }

          return MusicListWidget(state.musics, null);

        }//lorsque les musiques sont chargées

        if (state is MusicTrendingListLoadingState){
          List<Widget> musicWidgets = [];

          for (int i = 0; i < state.alreadyLoadedMusics.length; i++) {
            musicWidgets.add(WidgetMusic(state.alreadyLoadedMusics[i]));
            if (i != state.alreadyLoadedMusics.length - 1)
              musicWidgets.add(SizedBox(
                height: CustomSize.heightBetweenMusicTiles,
              ));
          }

          musicWidgets.add(Center(child: CircularProgressIndicator(),));

          musicWidgets.add(SizedBox(
            height: CustomSize.heightBetweenButtonLoadMorePopularSongsAndPlayForFun,
          ));

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: musicWidgets,
          );

        }//lorsque je viens de demander plus de musique

        if (state is MusicListLoadingState) {

          double height = CustomSize
            .heightBetweenButtonLoadMorePopularSongsAndMusicTile +
            CustomSize.heightBetweenButtonLoadMorePopularSongsAndPlayForFun +
            CustomSize.heightOfMusicTile *
              Constants.numberOfMusicLoadedFirstTrending +
            CustomSize.heightBetweenMusicTiles *
              (Constants.numberOfMusicLoadedFirstTrending -
                1); //il manque la height du button load more songs mais comme je n'ai pas proprement défini de height, je le prend pas en compte
          return Container(width: MediaQuery
            .of(context)
            .size
            .width,
            height: height,
            child: Center(child: CircularProgressIndicator()));
        }//lorsque je charge la premiere tournée de musique


        return SizedBox();
      },
    );
  }

  Widget _buttonLoadMorePopular() {
    return CustomWidgets.buttonLoadMorePopularSongStyle('MORE POPULAR SONGS', (){_trendingBloc.add(GetMoreTrendingMusic());});
  }

  Widget gameTiles() {
    List<Widget> gameTiles = [];

    gameTiles.add(SizedBox(width: CustomSize.leftAndRightPadding,));

    for (int i = 0; i < games.length; i++) {
      gameTiles.add(gameTile(Game.fromMapObject(games[i])));
      if (i != games.length - 1)
        gameTiles.add(SizedBox(
          width: 26,
        ));
    }

    gameTiles.add(SizedBox(width: CustomSize.leftAndRightPadding,));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: gameTiles,
      ),
    );
  }

  Widget gameTile(Game game) {
    return InkWell(
      onTap: (){
        if (game.page!=null){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => game.page),
          );
        }
      },
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(17),
              child: Image.asset(
                game.imagePath,
                height: 100,
                width: 100,
              )),
          SizedBox(
            height: 4,
          ),
          Text(
            game.name,
            style: CustomStyle.gameTileName,
          ),
          Text(
            Utils.showNumber(game.nbPlayers.toString()) + " players",
            style: CustomStyle.gameTileNbPlayers,
          ),
          SizedBox(
            height: 1,
          ),
          CustomWidgets.starsWidget(game.stars),
        ],
      ),
    );
  }
}

class PageIndicator extends StatelessWidget {
  final int index;

  PageIndicator(this.index);

  @override
  Widget build(BuildContext context) {
    List<Widget> dots = [];

    for (int i = 0; i < 5; i++) {
      if (i == index)
        dots.add(_blueIndicator());
      else if (i < index - 3 || i > index + 3)
        dots.add(_greyIndicator(3.5));
      else if (i < index - 2 || i > index + 2)
        dots.add(_greyIndicator(4.75));
      else
        dots.add(_greyIndicator(6));
      dots.add(SizedBox(
        width: 6,
      ));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: dots,
    );
  }

  Widget _blueIndicator() {
    return Container(
      height: 9,
      width: 9,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5), color: CustomColors.blue),
      child: Center(
        child: Container(
          height: 6,
          width: 6,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: CustomColors.backgroundColor),
        ),
      ),
    );
  }

  Widget _greyIndicator(double size) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5), color: CustomColors.blueGrey),
    );
  }
}
