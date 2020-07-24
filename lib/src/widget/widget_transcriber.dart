import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flykeys/src/bloc/favorites/bloc.dart';
import 'package:flykeys/src/bloc/image_loading/bloc.dart';
import 'package:flykeys/src/model/transcriber.dart';
import 'package:flykeys/src/page/transcriber_page.dart';
import 'package:flykeys/src/repository/image_provider_repository.dart';
import 'package:flykeys/src/utils/custom_size.dart';
import 'package:flykeys/src/utils/custom_style.dart';
import 'package:flykeys/src/utils/utils.dart';
import 'package:flykeys/src/widget/custom_widgets.dart';
import 'package:visibility_detector/visibility_detector.dart';

class WidgetTranscriber extends StatefulWidget {
  final Transcriber transcriber;
  final int pageIndex;
  final ValueNotifier valueNotifierActivePage;

  WidgetTranscriber(
      this.transcriber, this.pageIndex, this.valueNotifierActivePage);

  @override
  _WidgetTranscriberState createState() => _WidgetTranscriberState();
}

class _WidgetTranscriberState extends State<WidgetTranscriber> {

  ImageLoadingBloc imageLoadingBloc =
      new ImageLoadingBloc(new FirestoreImageProviderRepository());

  @override
  void initState() {
    super.initState();
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    imageLoadingBloc.add(LoadImage(widget.transcriber.profileImageName,"transcribers/"+widget.transcriber.id));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(right: CustomSize.widthBetweenTranscribersTile),
      child: VisibilityDetector(
        key: Key("ts" + widget.transcriber.id.toString()),
        onVisibilityChanged: (VisibilityInfo visibilityInfo) {
          if (visibilityInfo.visibleFraction == 1)
            widget.valueNotifierActivePage.value = widget.pageIndex;
        },
        child: InkWell(
          onTap: (){
            navigateToTranscriberPage(context, widget.transcriber);
          },
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          child: BlocBuilder<ImageLoadingBloc, ImageLoadingState>(
              bloc: imageLoadingBloc,
              builder: (BuildContext context, ImageLoadingState state) {
                Widget image;

                if (state is ImageLoadedState)
                  image = state.image;
                else if (state is LoadingImageState)
                  image = _getLoadingImageWidget();
                else
                  image = _getDefaultImage();

                widget.transcriber.image = image;

                return ClipRRect(
                  borderRadius: BorderRadius.circular(23),
                  child: Container(
                    height: CustomSize.heightOfTranscriberTile,
                    width: CustomSize.widthOfTranscriberTile,
                    child: Stack(
                      children: <Widget>[
                        Container(
                          width: CustomSize.widthOfTranscriberTile,
                          height: CustomSize.heightOfTranscriberTile,
                          child: image,
                        ),
                        Positioned(
                          top: CustomSize.heightOfTranscriberTile -
                              CustomSize.heightOfBackgroundBlurTranscriberTile,
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaY: 5, sigmaX: 5),
                              child: Container(
                                color: Colors.black.withOpacity(0.38),
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Container(
                            width: CustomSize.widthOfTranscriberTile,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 32.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text(
                                        widget.transcriber.name,
                                        style: CustomStyle.transcriberTileName,
                                      ),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      widget.transcriber.isVerified
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 2.0),
                                              child: CustomWidgets
                                                  .smallPastilleBleu(),
                                            )
                                          : SizedBox()
                                    ],
                                  ),
                                  SizedBox(
                                    height: 1,
                                  ),
                                  Text(
                                    Utils.showNumber(widget
                                            .transcriber.nbFollowers
                                            .toString()) +
                                        " followers",
                                    style: CustomStyle.transcriberTileFollowers,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
        ),
      ),
    );
  }
}

class WidgetTranscriberTile extends StatefulWidget {
  final Transcriber transcriber;

  WidgetTranscriberTile(this.transcriber);

  @override
  _WidgetTranscriberTileState createState() => _WidgetTranscriberTileState();
}

class _WidgetTranscriberTileState extends State<WidgetTranscriberTile> {

  ImageLoadingBloc imageLoadingBloc =
      new ImageLoadingBloc(new FirestoreImageProviderRepository());

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.transcriber.image == null)
      imageLoadingBloc.add(LoadImage(widget.transcriber.profileImageName,"transcribers/"+widget.transcriber.id));
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        navigateToTranscriberPage(context, widget.transcriber);
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

                      if (widget.transcriber.image == null) {
                        if (state is ImageLoadedState) {
                          image = state.image;
                          widget.transcriber.image = image;
                        } else if (state is LoadingImageState)
                          image = _getLoadingImageWidgetForTile();
                        else
                          image = _getDefaultImageForTile();
                      } else
                        image = widget.transcriber.image;

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
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          children: [
                            Text(widget.transcriber.name,
                              style:
                              CustomStyle.transcriberSmallTileName),
                            SizedBox(
                              width: 5,
                            ),
                            widget.transcriber.isVerified
                              ? CustomWidgets.smallPastilleBleu()
                              : SizedBox(),
                          ],
                        ),
                      )),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(
                          Utils.showNumber(widget.transcriber.nbFollowers
                            .toString()) +
                            " followers",
                          style:
                          CustomStyle.transcriberSmallTileFollowers),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          BlocBuilder<FavoritesBloc, FavoritesState>(
            builder: (BuildContext context, FavoritesState state) {
              if (state is ListsLoadedState){
                if (state.transcribersId.contains(widget.transcriber.id)){
                  widget.transcriber.iFollow = true;
                  return _unfollowButton();
                }else{
                  widget.transcriber.iFollow = false;
                  return _followButton();
                }
              }
              return _followButton();
            }),
        ],
      ),
    );
  }

  Widget _followButton(){
    return CustomWidgets.tileFollowButton(() {
      setState(() {
        widget.transcriber.iFollow = true;
      });
      BlocProvider.of<FavoritesBloc>(context)
        ..add(AddAFollowedTranscriber(widget.transcriber));
    });
  }

  Widget _unfollowButton(){
    return CustomWidgets.tileUnfollowButton(() {
      setState(() {
        widget.transcriber.iFollow = false;
      });
      BlocProvider.of<FavoritesBloc>(context)
        ..add(RemoveAFollowedTranscriber(widget.transcriber));
    });
  }

}

void navigateToTranscriberPage(context, Transcriber transcriber){
  Navigator.push(context,
    MaterialPageRoute(builder: (context) => TranscriberPage(transcriber)),
  );
}

class TranscriberListWidget extends StatefulWidget {
  final List<Transcriber> transcriberList;
  final Widget buttonLoadMore;

  TranscriberListWidget(this.transcriberList, this.buttonLoadMore);

  @override
  _TranscriberListWidgetState createState() => _TranscriberListWidgetState();
}

class _TranscriberListWidgetState extends State<TranscriberListWidget> {
  @override
  Widget build(BuildContext context) {
    List<Widget> transcriberWidgets = [];

    for (int i = 0; i < widget.transcriberList.length; i++) {
      transcriberWidgets.add(WidgetTranscriberTile(widget.transcriberList[i]));
      if (i != widget.transcriberList.length - 1)
        transcriberWidgets.add(SizedBox(
          height: CustomSize.heightBetweenMusicTiles,
        ));
    }

    if (widget.transcriberList.length != 0) {
      transcriberWidgets.add(SizedBox(
        height: CustomSize.heightBetweenButtonLoadMorePopularSongsAndMusicTile,
      ));
      if (widget.buttonLoadMore != null) {
        transcriberWidgets.add(
          widget.buttonLoadMore,
        );
        transcriberWidgets.add(SizedBox(
          height:
              CustomSize.heightBetweenButtonLoadMorePopularSongsAndPlayForFun,
        ));
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: transcriberWidgets,
    );
  }
}

Widget _getDefaultImage() {
  return Image.asset(
    "assets/images/transcriber_image.png",
    fit: BoxFit.cover,
  );
}

Widget _getLoadingImageWidget() {
  return Center(
    child: CircularProgressIndicator(),
  );
}

Widget _getDefaultImageForTile() {
  return _getDefaultImage();
}

Widget _getLoadingImageWidgetForTile() {
  return _getLoadingImageWidget();
}