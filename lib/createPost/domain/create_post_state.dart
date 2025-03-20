import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

enum CommonNetworkStatus{initial, loading, error}


class CreatePostState extends Equatable{

  CommonNetworkStatus networkStatus = CommonNetworkStatus.initial;
  String message  = "";
  List<AssetEntity> mainEntities = [];
  List <dynamic> localImagesData = [];
  List<AssetEntity> selectedImagesList = [];

  ColorFilter? selectedFilter;
  int currentScreenIndex = 0;

  CreatePostState({required this.networkStatus,
    required this.selectedFilter,
    required this.selectedImagesList,
    required this.localImagesData,
    required this.message, required this.mainEntities, required this.currentScreenIndex});

  CreatePostState copyWith({
    CommonNetworkStatus? networkStatus,
    String? message,
    int? currentScreenIndex,
    List<AssetEntity>? mainEntities,
    List<dynamic>? localImagesData,
    ColorFilter? selectedFilter,
    List<AssetEntity>? selectedImagesList,
  }) {
    return CreatePostState(
      networkStatus: networkStatus ?? this.networkStatus,
      message: message ?? this.message,
      currentScreenIndex: currentScreenIndex ?? this.currentScreenIndex,
      mainEntities: mainEntities ?? this.mainEntities,
      localImagesData: localImagesData ?? this.localImagesData,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      selectedImagesList: selectedImagesList ?? this.selectedImagesList,
    );
  }

  factory CreatePostState.init(){
    return CreatePostState(
      networkStatus: CommonNetworkStatus.initial,
      currentScreenIndex: 0,
      selectedImagesList: [],
      selectedFilter: null,
      message: '',
      mainEntities: [],
      localImagesData: [],
    );
  }

  @override
  // TODO: implement props
  List<Object?> get props => [networkStatus,selectedImagesList, message, mainEntities,currentScreenIndex,selectedFilter,localImagesData];
}
