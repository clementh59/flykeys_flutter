import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flykeys/src/bloc/image_loading/bloc.dart';
import 'package:flykeys/src/model/artist.dart';
import 'package:flykeys/src/repository/image_provider_repository.dart';
import 'package:flykeys/src/utils/custom_size.dart';
import 'package:flykeys/src/utils/custom_style.dart';
import 'package:flykeys/src/utils/utils.dart';

class WidgetArtistTile extends StatefulWidget {
  final Artist artist;

  WidgetArtistTile(this.artist);

  @override
  _WidgetArtistTileState createState() => _WidgetArtistTileState();
}

class _WidgetArtistTileState extends State<WidgetArtistTile> {
  ImageLoadingBloc imageLoadingBloc =
      new ImageLoadingBloc(new FirestoreImageProviderRepository());

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.artist.image == null)
      imageLoadingBloc.add(
          LoadImage(widget.artist.profilImage, "artists/" + widget.artist.id));
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Artist.goToArtistPage(context, widget.artist);
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

                        if (widget.artist.image == null) {
                          if (state is ImageLoadedState) {
                            image = state.image;
                            widget.artist.image = image;
                          } else if (state is LoadingImageState)
                            image = _getLoadingImageWidget();
                          else
                            image = _getDefaultImage();
                        } else
                        	image = widget.artist.image;

                        return image;

                      }),
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
                        child: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(widget.artist.name,
                                style: CustomStyle.transcriberSmallTileName))),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(
                            Utils.showNumber(
                                    widget.artist.musics.length.toString()) +
                                " musiques",
                            style: CustomStyle.transcriberSmallTileFollowers),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ArtistListWidget extends StatefulWidget {

	final List<Artist> artists;
	final Widget buttonLoadMore;

	ArtistListWidget(this.artists, this.buttonLoadMore);

  @override
  _ArtistListWidgetState createState() => _ArtistListWidgetState();
}

class _ArtistListWidgetState extends State<ArtistListWidget> {
  @override
  Widget build(BuildContext context) {
		List<Widget> artistList = [];

		for (int i = 0; i < widget.artists.length; i++) {
			artistList.add(WidgetArtistTile(widget.artists[i]));
			if (i != widget.artists.length - 1)
				artistList.add(SizedBox(
					height: CustomSize.heightBetweenMusicTiles,
				));
		}

		if (widget.artists.length != 0) {
			artistList.add(SizedBox(
				height: CustomSize.heightBetweenButtonLoadMorePopularSongsAndMusicTile,
			));
			if (widget.buttonLoadMore != null) {
				artistList.add(
					widget.buttonLoadMore,
				);
				artistList.add(SizedBox(
					height:
					CustomSize.heightBetweenButtonLoadMorePopularSongsAndPlayForFun,
				));
			}
		}

		return Column(
			mainAxisSize: MainAxisSize.min,
			crossAxisAlignment: CrossAxisAlignment.start,
			children: artistList,
		);
  }
}


Widget _getDefaultImage() {
	return Image.asset(
		"assets/images/music_icon.png",
		fit: BoxFit.cover,
	);
}

Widget _getLoadingImageWidget() {
	return Center(
		child: CircularProgressIndicator(),
	);
}