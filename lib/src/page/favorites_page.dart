import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flykeys/src/bloc/favorites/bloc.dart';
import 'package:flykeys/src/utils/custom_size.dart';
import 'package:flykeys/src/utils/custom_style.dart';
import 'package:flykeys/src/widget/custom_widgets.dart';
import 'package:flykeys/src/widget/profile_image.dart';
import 'package:flykeys/src/widget/search_type_element.dart';
import 'package:flykeys/src/widget/widget_music.dart';
import 'package:flykeys/src/widget/widget_transcriber.dart';

class FavoritesPage extends StatefulWidget {
  @override
	_FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {

	int _selectedCategory = 0;

	@override
  void didChangeDependencies() {
    super.didChangeDependencies();
		BlocProvider.of<FavoritesBloc>(context)..add(GetAllFavorites());
	}

  @override
  Widget build(BuildContext context) {
		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			mainAxisSize: MainAxisSize.max,
			children: [
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
				  			"Favorites",
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
				  child: _searchTypeBar(),
				),
				SizedBox(
					height: 33,
				),
				Padding(
				  padding: const EdgeInsets.symmetric(horizontal: CustomSize.leftAndRightPadding),
				  child: _selectedCategory==0? _likedMusicsView() : _followedTranscribersView(),
				)
			],
		);
  }

	Widget _searchTypeBar(){
		return Padding(
			padding: EdgeInsets.symmetric(vertical: 10),
			child: Row(
				mainAxisAlignment: MainAxisAlignment.spaceAround,
				mainAxisSize: MainAxisSize.max,
				children: [
					SearchTypeElement("SONGS", _selectedCategory == 0, () {
						changeSelectedCategory(0);
					}),
					SearchTypeElement("TRANSCRIBERS", _selectedCategory == 1, () {
						changeSelectedCategory(1);
					}),
				],
			),
		);
	}

	void changeSelectedCategory(int category){
		setState(() {
			_selectedCategory = category;
		});
	}

	Widget _likedMusicsView(){
  	return BlocBuilder<FavoritesBloc,FavoritesState>(
			builder: (BuildContext context, FavoritesState state) {
				if (state is ListsLoadingState){
					return Center(
						child: CircularProgressIndicator(),
					);
				}
				if (state is ListsLoadedState){
					if (state.musics.length>0) {
						return SingleChildScrollView(
							child: MusicListWidget(state.musics, null),
						);
					}
					return Center(
						child: Text("No Liked music"),
					);
				}
				return SizedBox();
			}
		);
	}

	Widget _followedTranscribersView(){
		return BlocBuilder<FavoritesBloc,FavoritesState>(
			builder: (BuildContext context, FavoritesState state) {
				if (state is ListsLoadingState){
					return Center(
						child: CircularProgressIndicator(),
					);
				}
				if (state is ListsLoadedState){
					if (state.transcribers.length>0) {
						return SingleChildScrollView(
							child: TranscriberListWidget(state.transcribers, null),
						);
					}
					return Center(
						child: Text("No Followed transcribers"),
					);
				}
				return SizedBox();
			}
		);
	}

}
