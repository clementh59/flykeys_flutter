import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flykeys/src/bloc/favorites/bloc.dart';
import 'package:flykeys/src/bloc/image_loading/bloc.dart';
import 'package:flykeys/src/model/artist.dart';
import 'package:flykeys/src/model/music.dart';
import 'package:flykeys/src/page/music_page.dart';
import 'package:flykeys/src/repository/image_provider_repository.dart';
import 'package:flykeys/src/utils/custom_size.dart';
import 'package:flykeys/src/utils/custom_style.dart';
import 'package:flykeys/src/utils/utils.dart';
import 'package:flykeys/src/widget/custom_widgets.dart';

/// Show a music tile with [music] info
/// if [onSelect] is defined, it will be called when the user clicks on the music tile (it won't override the normal behavior, it will just be called
/// on top of it)
class WidgetMusic extends StatefulWidget {
  final Music music;
  final bool showFromArtistList;
  final Function onSelect;

  WidgetMusic(this.music,{this.showFromArtistList=false, this.onSelect});

  @override
  _WidgetMusicState createState() => _WidgetMusicState();
}

class _WidgetMusicState extends State<WidgetMusic> {
  ImageLoadingBloc imageLoadingBloc =
      new ImageLoadingBloc(new FirestoreImageProviderRepository());

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    imageLoadingBloc.add(LoadImage(widget.music.imageName,"musics/"+widget.music.id+"/"));
  }

  @override
  Widget build(BuildContext context) {

    return InkWell(
      onTap: () {
        _tapOnMusic(widget.music);
        if (widget.onSelect!=null)
          widget.onSelect();
      },
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  height: CustomSize.heightOfMusicTile,
                  width: CustomSize.heightOfMusicTile,
                  child: BlocBuilder<ImageLoadingBloc, ImageLoadingState>(
                    bloc: imageLoadingBloc,
                    builder: (BuildContext context, ImageLoadingState state) {
                      Widget image;

                      if (widget.music.imageName == "") {
                        image = CustomWidgets.playIconWithBlueCircle();
                      } else if (widget.music.image == null) {
                        if (state is ImageLoadedState) {
                          image = state.image;
                          widget.music.image = image;
                        } else if (state is LoadingImageState)
                          image = _getLoadingImageWidget();
                        else
                          image = CustomWidgets.playIconWithBlueCircle();
                      } else
                        image = widget.music.image;

                      return image;
                    },
                  ),
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Container(
                height: CustomSize.heightOfMusicTile,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(widget.music.name,
                        style: CustomStyle.musicTileName)),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: widget.showFromArtistList?  _generateTranscriberText() : Row(
                          children: _generateAuthorsText(),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          widget.showFromArtistList? SizedBox() : CustomWidgets.starsWidget(widget.music.stars),
                          widget.showFromArtistList? SizedBox() : SizedBox(
                            width: 12.6,
                          ),
                          CustomWidgets.noteWidget(
                            widget.music.difficulty),
                        ],
                      )),
                  ],
                ),
              ),
            ],
          ),
          InkWell(
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: () {
              if (widget.music.liked) {
                setState(() {
                  widget.music.liked = false;
                });
                BlocProvider.of<FavoritesBloc>(context)
                  ..add(RemoveAFavoriteMusic(widget.music));
              } else {
                setState(() {
                  print("Set state!");
                  widget.music.liked = true;
                });
                BlocProvider.of<FavoritesBloc>(context)
                  ..add(AddAFavoriteMusic(widget.music));
              }
            },
            child: BlocBuilder<FavoritesBloc, FavoritesState>(
              builder: (BuildContext context, FavoritesState state) {
                if (state is ListsLoadedState){
                  if (state.musicsId.contains(widget.music.id)){
                    widget.music.liked = true;
                    return CustomWidgets.heartIcon(true);
                  }else{
                    widget.music.liked = false;
                    return CustomWidgets.heartIcon(false);
                  }
                }
                return CustomWidgets.heartIcon(false);
              })
          ),
        ],
      ),
    );
  }

  void _tapOnMusic(Music music) async {
    Navigator.push(
      context,
      Utils.createRoute(() => MusicPage(music)),
    );
  }

  List<Widget> _generateAuthorsText(){
    List<Widget> texts = [];
    for(int i=0; i<widget.music.auteurs.length;i++){
      String str = ",";
      if (i==widget.music.auteurs.length-1)
        str="";
      texts.add(
        InkWell(
          onTap: (){
            Artist.goToArtistPage(context,widget.music.auteurs[i]);
          },
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          child: Text(
            widget.music.auteurs[i].name.toString() + str,
            style: CustomStyle.auteurTileName
          ),
        ),
      );
      if (i!=widget.music.auteurs.length-1)
        texts.add(SizedBox(width: 4,));
    }
    return texts;
  }

  Widget _generateTranscriberText(){
    return InkWell(
      onTap: (){
        //todo: go to transcriber Page
      },
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Text(
        widget.music.transcriberName.toString(),
        style: CustomStyle.auteurTileName
      ),
    );
  }

}

class EmptyWidgetMusic extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Container(
                height: CustomSize.heightOfMusicTile,
                width: CustomSize.heightOfMusicTile,
                child: _getLoadingImageWidget(),
              ),
            ),
            SizedBox(
              width: 20,
            ),
            Container(
              height: CustomSize.heightOfMusicTile,
              child: Stack(
                children: [
                  Align(
                      alignment: Alignment.topLeft,
                      child: CustomWidgets.customShimmer(
                        child: Text("Song",
                            style: CustomStyle.musicTileName),
                      )),
                  CustomWidgets.customShimmer(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text("Artist",
                            style: CustomStyle.musicTileName),
                      ),
                    ),
                  ),
                  Align(
                      alignment: Alignment.bottomLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomWidgets.customShimmer(child: CustomWidgets.starsWidget(5)),
                          SizedBox(width: 12.6,),
                          CustomWidgets.customShimmer(child: CustomWidgets.noteWidget(3)),
                        ],
                      )),
                ],
              ),
            ),
          ],
        ),
        CustomWidgets.customShimmer(child: CustomWidgets.heartIcon(true)),
      ],
    );
  }
}

/// Generates a list of music tile from [musicList]
/// if [buttonLoadMore] isn't null, it will add it at the end of the list
/// if [onSelect] is defined, it will be called when the user clicks on a music tile (it won't override the normal behavior, it will just be called
/// on top of it)
class MusicListWidget extends StatefulWidget {
  final List<Music> musicList;
  final Widget buttonLoadMore;
  final bool showFromArtistList;
  final Function onSelect;

  MusicListWidget(this.musicList, this.buttonLoadMore,{this.showFromArtistList=false, this.onSelect});

  @override
  _MusicListWidgetState createState() => _MusicListWidgetState();
}

class _MusicListWidgetState extends State<MusicListWidget> {

  @override
  Widget build(BuildContext context) {
    List<Widget> musicWidgets = [];

    for (int i = 0; i < widget.musicList.length; i++) {
      musicWidgets.add(WidgetMusic(widget.musicList[i],showFromArtistList: widget.showFromArtistList,onSelect: () {
        widget.onSelect(widget.musicList[i]);
      },));
      if (i != widget.musicList.length - 1)
        musicWidgets.add(SizedBox(
          height: CustomSize.heightBetweenMusicTiles,
        ));
    }

    if (widget.musicList.length != 0) {
      musicWidgets.add(SizedBox(
        height: CustomSize.heightBetweenButtonLoadMorePopularSongsAndMusicTile,
      ));
      if (widget.buttonLoadMore != null) {
        musicWidgets.add(
          widget.buttonLoadMore,
        );
        musicWidgets.add(SizedBox(
          height:
              CustomSize.heightBetweenButtonLoadMorePopularSongsAndPlayForFun,
        ));
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: musicWidgets,
    );
  }
}

Widget _getLoadingImageWidget() {
  return CustomWidgets.customShimmer(
    child: Container(
      color: Colors.white, // we don't see it, it is with shimmer effect
    ),
  );
}