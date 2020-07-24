import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flykeys/src/bloc/favorites/bloc.dart';
import 'package:flykeys/src/bloc/image_loading/bloc.dart';
import 'package:flykeys/src/model/transcriber.dart';
import 'package:flykeys/src/repository/image_provider_repository.dart';
import 'package:flykeys/src/utils/custom_colors.dart';
import 'package:flykeys/src/utils/custom_size.dart';
import 'package:flykeys/src/utils/custom_style.dart';
import 'package:flykeys/src/utils/utils.dart';
import 'package:flykeys/src/widget/custom_widgets.dart';
import 'package:flykeys/src/widget/profile_image.dart';
import 'package:flykeys/src/widget/widget_music.dart';

class TranscriberPage extends StatefulWidget {

	final Transcriber transcriber;

	TranscriberPage(this.transcriber);

	@override
	_TranscriberPageState createState() => _TranscriberPageState();
}

class _TranscriberPageState extends State<TranscriberPage> {

	ImageLoadingBloc imageLoadingBloc = new ImageLoadingBloc(
		new FirestoreImageProviderRepository());

	@override
	void didChangeDependencies() {
		super.didChangeDependencies();
		imageLoadingBloc.add(LoadImage(widget.transcriber.backgroundImageName,"transcribers/"+widget.transcriber.id));
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: CustomColors.backgroundColor,
			body: SafeArea(
				child: SingleChildScrollView(
					child: Column(
						mainAxisSize: MainAxisSize.min,
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Stack(
								children: [
									CustomWidgets.detailPageBackgroundImage(imageLoadingBloc,context),
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
													mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
													mainAxisAlignment: MainAxisAlignment.spaceBetween,
													children: [
														Row(
															crossAxisAlignment: CrossAxisAlignment.start,
															children: [
																Container(
																	height: 100,
																	width: 100,
																	decoration: BoxDecoration(
																		borderRadius: BorderRadius.circular(50)),
																	child: Stack(
																		children: [
																			ClipRRect(
																				borderRadius:
																				BorderRadius.circular(50),
																				child: widget.transcriber.image),
																			widget.transcriber.isVerified
																				? Align(
																				alignment: Alignment.bottomRight,
																				child: CustomWidgets
																					.bigPastilleBleu(),
																			)
																				: SizedBox(),
																		],
																	),
																),
																SizedBox(
																	width: 20,
																),
																Container(
																	height: 100,
																	child: Column(
																		mainAxisSize: MainAxisSize.max,
																		mainAxisAlignment:
																		MainAxisAlignment.spaceAround,
																		crossAxisAlignment:
																		CrossAxisAlignment.start,
																		children: [
																			Padding(
																				padding:
																				const EdgeInsets.only(top: 10.0),
																				child: Text(
																					widget.transcriber.name,
																					style: CustomStyle.detailPageName,
																				),
																			),
																			Padding(
																				padding:
																				const EdgeInsets.only(bottom: 10.0),
																				child: Row(
																					mainAxisSize: MainAxisSize.min,
																					crossAxisAlignment:
																					CrossAxisAlignment.start,
																					children: [
																						CustomWidgets.biggerStarsWidget(
																							widget.transcriber.stars),
																						SizedBox(
																							width: 5,
																						),
																						Text(
																							"[" +
																								Utils.showNumber(widget
																									.transcriber.numberOfVotes
																									.toString()) +
																								"]",
																							style: CustomStyle.numberOfVote,
																						)
																					],
																				),
																			),
																		],
																	),
																),
															],
														),
														widget.transcriber.youtubeLink != ""
															? Padding(
															padding: EdgeInsets.only(top: 66),
															child: CustomWidgets.ytWidget(17),
														)
															: SizedBox(),
													],
												),
												SizedBox(
													height: 27,
												),
												CustomWidgets.detailPageNumberCategories(Utils.showNumber(widget
													.transcriber.nbFollowers
													.toString()), "Followers",Utils.showNumber(widget
													.transcriber.nbPlays
													.toString()), "Plays"),
												SizedBox(
													height: 27,
												),
												Row(
													mainAxisSize: MainAxisSize.max,
                          children: [
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
                            SizedBox(width: 27,),
                            Icon(
                              Icons.more_vert,
                              color: CustomColors.white,
                              size: 32,
                            )
                          ],
												),
                        SizedBox(
                          height: 21,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Songs",
                              style: CustomStyle.title,
                            ),
                            SizedBox(
                              width: 7,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top:3.0),
                              child: CustomWidgets.blueNumberIndicator(Utils.showNumber(widget.transcriber.songs.length.toString()), true),
                            ),
                          ],
                        ),
												SizedBox(
													height: 23,
												),
												MusicListWidget(widget.transcriber.songs,null,),
											],
										),
									),
								],
							),
						],
					),
				),
			),
		);
	}

	Widget _followButton(){
		return Expanded(
		  child: CustomWidgets.detailPageFollowButton((){
		  	setState(() {
		  		widget.transcriber.iFollow = false;
		  	});
		  	BlocProvider.of<FavoritesBloc>(context)
		  		..add(AddAFollowedTranscriber(widget.transcriber));
		  }),
		);
	}

	Widget _unfollowButton(){
		return Expanded(
		  child: CustomWidgets.detailPageUnfollowButton((){
		  	setState(() {
		  		widget.transcriber.iFollow = true;
		  	});
		  	BlocProvider.of<FavoritesBloc>(context)
		  		..add(RemoveAFollowedTranscriber(widget.transcriber));
		  }),
		);
	}

}
