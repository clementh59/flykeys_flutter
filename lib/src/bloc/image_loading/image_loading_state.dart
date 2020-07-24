import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

@immutable
abstract class ImageLoadingState {}

class LoadingImageState extends ImageLoadingState {}

class ImageLoadedState extends ImageLoadingState {
	final Widget image;

	ImageLoadedState(this.image);
}


class NoImageState extends ImageLoadingState{}
