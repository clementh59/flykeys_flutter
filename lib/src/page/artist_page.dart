import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flykeys/src/bloc/artist/artist_bloc.dart';
import 'package:flykeys/src/bloc/artist/artist_event.dart';
import 'package:flykeys/src/bloc/artist/artist_state.dart';
import 'package:flykeys/src/bloc/image_loading/bloc.dart';
import 'package:flykeys/src/model/artist.dart';
import 'package:flykeys/src/repository/database_repository.dart';
import 'package:flykeys/src/repository/image_provider_repository.dart';
import 'package:flykeys/src/utils/custom_colors.dart';
import 'package:flykeys/src/utils/custom_size.dart';
import 'package:flykeys/src/utils/custom_style.dart';
import 'package:flykeys/src/utils/utils.dart';
import 'package:flykeys/src/widget/custom_widgets.dart';
import 'package:flykeys/src/widget/profile_image.dart';
import 'package:flykeys/src/widget/widget_music.dart';

class ArtistPage extends StatefulWidget {
  Artist artist;

  ArtistPage(this.artist);

  @override
  _ArtistPageState createState() => _ArtistPageState();
}

class _ArtistPageState extends State<ArtistPage> {
  ImageLoadingBloc imageLoadingBlocBackground =
      new ImageLoadingBloc(new FirestoreImageProviderRepository());
  ImageLoadingBloc imageLoadingProfile =
      new ImageLoadingBloc(new FirestoreImageProviderRepository());
  ArtistBloc artistBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    artistBloc = new ArtistBloc(new FirestoreRepository());
    if (!widget.artist.iLoadedAllInfo)
      artistBloc.add(new GetArtist(widget.artist.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.backgroundColor,
      body: SafeArea(
        child: BlocBuilder<ArtistBloc, ArtistState>(
          bloc: artistBloc,
          builder: (BuildContext context, ArtistState state) {

            if (state is ArtistLoadedState){
              widget.artist = state.artist;
            }

            if (widget.artist.iLoadedAllInfo) {

              imageLoadingBlocBackground.add(
                  LoadImage(widget.artist.backgroundImage, "artists/" + widget.artist.id));
              if (widget.artist.image==null)
                imageLoadingProfile
                    .add(LoadImage(widget.artist.profilImage, "artists/" + widget.artist.id));
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        CustomWidgets.detailPageBackgroundImage(
                            imageLoadingBlocBackground, context),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: CustomSize.leftAndRightPadding,
                              right: CustomSize.leftAndRightPadding),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  CustomWidgets.backArrowIcon(context),
                                  Text(
                                    "Transcriber",
                                    style: CustomStyle.pageTitle,
                                  ),
                                  ProfileImage(),
                                ],
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 100,
                                        width: 100,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(50)),
                                        child: BlocBuilder<ImageLoadingBloc,
                                                ImageLoadingState>(
                                            bloc: imageLoadingProfile,
                                            builder: (BuildContext context,
                                                ImageLoadingState state) {
                                              Widget image;

                                              if (state is ImageLoadedState) {
                                                image = state.image;
                                              } else
                                                image = null;

                                              if (widget.artist.image!=null)
                                                image = widget.artist.image;

                                              if (image != null) {
                                                return ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                    child: image);
                                              }

                                              return Center(
                                                child: CircularProgressIndicator(),
                                              );
                                            }),
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Container(
                                        height: 100,
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                top: 10.0),
                                            child: Text(
                                              widget.artist.name,
                                              style: CustomStyle.detailPageName,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 25,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Musiques",
                                    style: CustomStyle.title,
                                  ),
                                  SizedBox(
                                    width: 7,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 3.0),
                                    child: CustomWidgets.blueNumberIndicator(
                                        Utils.showNumber(
                                          widget.artist.musics.length.toString()),
                                        true),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 23,
                              ),
                              MusicListWidget(widget.artist.musics,null,showFromArtistList: true,),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }

            if (state is ArtistLoadingState) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            return SizedBox();
          },
        ),
      ),
    );
  }
}
