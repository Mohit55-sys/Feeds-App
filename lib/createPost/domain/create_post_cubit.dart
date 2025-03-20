
import 'dart:typed_data';

import 'package:create_post/createPost/domain/create_post_state.dart';
import 'package:create_post/main.dart';
import 'package:create_post/utils/common.dart';
import 'package:create_post/utils/database.dart';
import 'package:create_post/utils/routes/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';

class CreatePostCubit extends Cubit<CreatePostState> {
  CreatePostCubit() : super(CreatePostState.init()){
    fetchImagesWithText();
    requestAssets();
  }

  final ScrollController controller = ScrollController();
  final int sizePerPage = 50;
  final _dbHelper = ImageTextDatabase();

  AssetPathEntity? path;
  // List<AssetEntity> entities = [];
  TextEditingController postDescription = TextEditingController();
  int totalEntitiesCount = 0;
  final GlobalKey widgetKey =  GlobalKey();

  List<ColorFilter> filtersList = [
    AppColors.SEPIA_MATRIX,
    AppColors.GREYSCALE_MATRIX,
    AppColors.VINTAGE_MATRIX,
    AppColors.FILTER_5,

  ];
  int page = 0;
  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasMoreToLoad = true;




  updateSelectedFilter(ColorFilter newFilter){

    emit(state.copyWith(selectedFilter: newFilter));

  }



  fetchImagesWithText() async{
    await _dbHelper.getImagesWithText().then((e){
      if(e.isNotEmpty){
        emit(state.copyWith(localImagesData : [...e]));
      }
    });
    debugPrint("here----->${state.localImagesData.length}");
  }


  Future<void> requestAssets() async {
    isLoading = true;
    // Request permissions.
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    // Further requests can be only proceed with authorized or limited.
    if (!ps.hasAccess) {
      isLoading = false;
      //showToast('Permission is not accessible.');
      return;
    }
    // Customize your own filter options.
    final PMFilter filter = FilterOptionGroup(
      imageOption: const FilterOption(
        sizeConstraint: SizeConstraint(ignoreSize: true),
      ),
    );
    // Obtain assets using the path entity.
    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
      onlyAll: true,
      filterOption: filter,
    );

    // Return if not paths found.
    if (paths.isEmpty) {
      isLoading = false;
      return;
    }
    path = paths.first;
    totalEntitiesCount = await path!.assetCountAsync;
    final List<AssetEntity> entitied = await path!.getAssetListPaged(
      page: 0,
      size: sizePerPage,
    );

    state.mainEntities = entitied;

    isLoading = false;
    hasMoreToLoad = state.mainEntities.length < totalEntitiesCount;
    //showModelBottomSheet();
    emit(state.copyWith(mainEntities : state.mainEntities));
  }

  Future<void> loadMoreAsset() async {
    final List<AssetEntity> entitied = await path!.getAssetListPaged(
      page: page + 1,
      size: sizePerPage,
    );

    emit(state.copyWith(mainEntities : [...state.mainEntities,...entitied]));
    page++;
    hasMoreToLoad = state.mainEntities.length < totalEntitiesCount;
    isLoadingMore = false;

  }


  createPostInDatabase() async{
    CommonWidgets.showLoaderDialog(navigatorKey.currentContext!);
    List <Uint8List> imageBytesList = [];
    for (var item in state.selectedImagesList) {
      final Uint8List? uintData = await item.thumbnailData;
      imageBytesList.add(uintData!);
    }
    await _dbHelper.insertImagesWithText(postDescription.text,imageBytesList).then((e){
      fetchImagesWithText();
      switchScreenVal(0);
      emit(state.copyWith(selectedImagesList: []));
      Navigator.pop(navigatorKey.currentContext!);
      Navigator.pop(navigatorKey.currentContext!);
    });

  }


  switchScreenVal(int newVal){
    emit(state.copyWith(currentScreenIndex : newVal));
    debugPrint("val$newVal");
  }


  void scrollUp(CreatePostCubit cubit, int idx) {
    final updatedList = List<AssetEntity>.from(state.selectedImagesList)..add(state.mainEntities[idx]);
   emit(state.copyWith(selectedImagesList: updatedList));
    cubit.controller.animateTo(
      cubit.controller.position.minScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );

  }

  refreshFilter(){
    debugPrint("filter to be refresh0000>");
    state.selectedFilter = null;
   emit(state.copyWith(selectedFilter: state.selectedFilter));
    debugPrint("filter to be refresh0000>${state.selectedFilter}");
  }
}
