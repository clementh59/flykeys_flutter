import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flykeys/src/repository/image_provider_repository.dart';
import 'dart:developer' as dev;
import 'bloc.dart';

class ImageLoadingBloc extends Bloc<ImageLoadingEvent, ImageLoadingState> {

  final ImageProviderRepository imageProviderRepository;

  ImageLoadingBloc(this.imageProviderRepository) : super(LoadingImageState());

  @override
  Stream<ImageLoadingState> mapEventToState(
    ImageLoadingEvent event,
  ) async* {

    if (event is LoadImage){
      if (event.image=="")
        yield NoImageState();
      else{
        yield LoadingImageState();
        Widget image = await imageProviderRepository.fetchImage(event.path+'/'+event.image);
        yield ImageLoadedState(image);
      }
    }

  }
}
