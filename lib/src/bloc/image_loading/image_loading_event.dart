import 'package:flykeys/src/model/music.dart';
import 'package:flykeys/src/model/transcriber.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

@immutable
abstract class ImageLoadingEvent extends Equatable {
	ImageLoadingEvent();
}

class LoadImage extends ImageLoadingEvent {

	final String image;
	final String path;

	LoadImage(this.image,this.path);

	@override
	List<Object> get props => [image,path];

}

