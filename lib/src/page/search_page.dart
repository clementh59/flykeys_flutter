import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flykeys/src/bloc/artist/artist_bloc.dart';
import 'package:flykeys/src/bloc/artist/artist_event.dart';
import 'package:flykeys/src/bloc/artist/artist_state.dart';
import 'package:flykeys/src/bloc/music/bloc.dart';
import 'package:flykeys/src/bloc/transcribers/bloc.dart';
import 'package:flykeys/src/model/music.dart';
import 'package:flykeys/src/repository/database_repository.dart';
import 'package:flykeys/src/utils/custom_colors.dart';
import 'package:flykeys/src/utils/custom_size.dart';
import 'package:flykeys/src/utils/custom_style.dart';
import 'package:flykeys/src/utils/strings.dart';
import 'package:flykeys/src/utils/utils.dart';
import 'package:flykeys/src/widget/custom_widgets.dart';
import 'package:flykeys/src/widget/profile_image.dart';
import 'package:flykeys/src/widget/search_type_element.dart';
import 'package:flykeys/src/widget/widget_artist.dart';
import 'package:flykeys/src/widget/widget_music.dart';
import 'package:flykeys/src/widget/widget_transcriber.dart';
import 'package:visibility_detector/visibility_detector.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  //region Variables
  String _searchtext = "";
  MusicBloc _musicBloc;
  MusicBloc _recentMusicBloc;
  TranscriberBloc _transcriberBloc;
  ArtistBloc _artistBloc;
  bool _isSearching = false;
  TextEditingController _searchFieldController = TextEditingController();
  int _selectedCategory = 0;

  List<bool> _categoryIsAlreadyLoaded;

  //endregion

  //region Overrides
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    _initCategoryAreLoadedBoolean();
    _musicBloc = MusicBloc(FirestoreRepository());
    _recentMusicBloc = MusicBloc(FirestoreRepository());
    _transcriberBloc = TranscriberBloc(FirestoreRepository());
    _artistBloc = ArtistBloc(FirestoreRepository());
    _loadRecentSearchs();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('searchPageKey'),
      onVisibilityChanged: (VisibilityInfo info) {
        if (info.visibleFraction == 0) {
          unfocusTextField();
        }
      },
      child: GestureDetector(
        onTap: () {
          unfocusTextField();
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              CustomWidgets.topBar('Recherche', CustomWidgets.settingsIcon(context), ProfileImage()),
              SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: CustomSize.leftAndRightPadding),
                child: Text(
                  "Découvrir",
                  style: CustomStyle.greySubtitle,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: CustomSize.leftAndRightPadding),
                child: Text(
                  "Prêt à explorer?",
                  style: CustomStyle.title,
                ),
              ),
              SizedBox(
                height: 25,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: CustomSize.leftAndRightPadding),
                child: _searchBar(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: CustomSize.leftAndRightPadding),
                child: _isSearching ? _searchResult() : _recentElements(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //endregion

  //region Widget
  Widget _searchBar() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              onTap: () {
                _search(_searchtext);
              },
              child: Image.asset(
                "assets/images/icons/search_icon_blue.png",
                height: 25,
              ),
            ),
            SizedBox(
              width: 20,
            ),
            Expanded(
              child: TextField(
                controller: _searchFieldController,
                style: CustomStyle.searchFieldText,
                maxLines: 1,
                onChanged: (text) {
                  _searchtext = text;
                  if (text == "") {
                    setState(() {
                      _isSearching = false;
                    });
                  }
                  _initCategoryAreLoadedBoolean();
                },
                onEditingComplete: () {
                  _search(_searchtext);
                },
                decoration: InputDecoration(border: InputBorder.none, hintText: "Recherche", hintStyle: CustomStyle.searchFieldHintText),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            InkWell(
              onTap: () {
                _searchFieldController.text = "";
                _searchtext = "";
                setState(() {
                  _isSearching = false;
                });
              },
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              child: Icon(
                Icons.close,
                color: CustomColors.blue,
                size: 34,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 5,
        ),
        Container(
          height: 1,
          color: CustomColors.lighterGrey,
        ),
      ],
    );
  }

  Widget _searchResult() {
    Widget _result = _searchMessage("Not implemented");

    switch (_selectedCategory) {
      case 0:
        _result = BlocBuilder<MusicBloc, MusicState>(
          bloc: _musicBloc,
          builder: (BuildContext context, MusicState state) {
            if (state is MusicListLoadedState) {
              if (state.musics.length > 0)
                return MusicListWidget(
                  state.musics,
                  null,
                  onSelect: onMusicSelect,
                );
              return _searchMessage("Aucun résultat");
            }
            if (state is MusicListLoadingState) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return SizedBox();
          },
        );
        break;
      case 1:
        _result = BlocBuilder<TranscriberBloc, TranscriberState>(
          bloc: _transcriberBloc,
          builder: (BuildContext context, TranscriberState state) {
            if (state is TranscriberListLoadedState) {
              if (state.transcribers.length > 0) return TranscriberListWidget(state.transcribers, null);
              return _searchMessage("Aucun résultat");
            }
            if (state is TranscriberListLoadingState) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return SizedBox();
          },
        );
        break;
      case 2:
        _result = BlocBuilder<ArtistBloc, ArtistState>(
          bloc: _artistBloc,
          builder: (BuildContext context, ArtistState state) {
            if (state is ArtistListLoadedState) {
              if (state.artists.length > 0) return ArtistListWidget(state.artists, null);
              return _searchMessage("Aucun résultat");
            }
            if (state is ArtistListLoadingState) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return SizedBox();
          },
        );
        break;
      case 3:
        break;
      case 4:
        break;
      case 5:
        break;
      case 6:
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 15,
        ),
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: _searchTypeBar()),
        SizedBox(
          height: 8,
        ),
        _result,
      ],
    );
  }

  Widget _recentElements() {
    return BlocBuilder<MusicBloc, MusicState>(
      bloc: _recentMusicBloc,
      builder: (BuildContext context, MusicState state) {
        if (state is MusicListLoadedState && state.musics.length > 0) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 20,
              ),
              Text(
                "RÉCENT",
                style: TextStyle(
                  color: CustomColors.white,
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  fontWeight: CustomStyle.MEDIUM,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              MusicListWidget(
                state.musics,
                null,
                onSelect: onMusicSelect,
              )
            ],
          );
        }
        if (state is MusicListLoadingState) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return SizedBox();
      },
    );
  }

  Widget _searchTypeBar() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SearchTypeElement("MUSIQUES", _selectedCategory == 0, () {
            changeSelectedCategory(0);
          }),
          SizedBox(
            width: 31,
          ),
          SearchTypeElement("TRANSCRIBERS", _selectedCategory == 1, () {
            changeSelectedCategory(1);
          }),
          SizedBox(
            width: 31,
          ),
          SearchTypeElement("ARTISTES", _selectedCategory == 2, () {
            changeSelectedCategory(2);
          }),
          SizedBox(
            width: 31,
          ),
          SearchTypeElement("FILMS", _selectedCategory == 3, () {
            changeSelectedCategory(3);
          }),
          SizedBox(
            width: 31,
          ),
          SearchTypeElement("SERIES", _selectedCategory == 4, () {
            changeSelectedCategory(4);
          }),
          SizedBox(
            width: 31,
          ),
          SearchTypeElement("ANIMES", _selectedCategory == 5, () {
            changeSelectedCategory(5);
          }),
          SizedBox(
            width: 31,
          ),
          SearchTypeElement("JEUX", _selectedCategory == 6, () {
            changeSelectedCategory(6);
          }),
          SizedBox(
            width: 31,
          ),
        ],
      ),
    );
  }

  Widget _searchMessage(String text) {
    return Container(
      height: 150,
      child: Center(
        child: Text(
          text,
          style: CustomStyle.noResultText,
        ),
      ),
    );
  }

  //endregion

  //region Logic
  void _search(String text) {
    if (text.length < 2) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text("Il faut au moins 2 caractères pour effectuer une recherche")));
      return;
    }

    if (!_isSearching) {
      setState(() {
        _isSearching = true;
      });
      _initCategoryAreLoadedBoolean();
    }

    text = text.toLowerCase();

    if (!_categoryIsAlreadyLoaded[_selectedCategory]) {
      switch (_selectedCategory) {
        case 0:
          _musicBloc.add(SearchMusic(text));
          break;
        case 1:
          _transcriberBloc.add(SearchTranscriber(text));
          break;
        case 2:
          _artistBloc.add(SearchArtist(text));
          break;
        case 3:
          break;
        case 4:
          break;
        case 5:
          break;
        case 6:
          break;
      }
      _categoryIsAlreadyLoaded[_selectedCategory] = true;
    }

    // I unfocus the textfield
    unfocusTextField();
  }

  void _initCategoryAreLoadedBoolean() {
    if (_categoryIsAlreadyLoaded == null) {
      _categoryIsAlreadyLoaded = [];
      for (int i = 0; i < 7; i++) {
        _categoryIsAlreadyLoaded.add(false);
      }
    }

    for (int i = 0; i < 7; i++) {
      _categoryIsAlreadyLoaded[i] = false;
    }
  }

  void changeSelectedCategory(int category) {
    setState(() {
      _selectedCategory = category;
    });
    _search(_searchtext);
  }

  void onMusicSelect(Music music) async {
    List<String> musicsIds = await Utils.readListOfStringFromSharedPreferences(Strings.RECENT_SEARCH_SHARED_PREFS, defaultValue: List<String>());
    if (!musicsIds.contains(music.id)) musicsIds.add(music.id);
    if (musicsIds.length > 5) musicsIds.removeAt(0);
    await Utils.saveListOfStringToSharedPreferences(Strings.RECENT_SEARCH_SHARED_PREFS, musicsIds);
  }

  void _loadRecentSearchs() async {
    List<String> musicsIds = await Utils.readListOfStringFromSharedPreferences(Strings.RECENT_SEARCH_SHARED_PREFS, defaultValue: List<String>());
    if (musicsIds.length > 0) _recentMusicBloc.add(GetMusics(musicsIds));
  }

  /// Hide the keyboard by unfocusing the textfield
  void unfocusTextField() {
    FocusScope.of(context).requestFocus(new FocusNode());
  }
//endregion
}
