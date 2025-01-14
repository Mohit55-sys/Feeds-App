import 'package:create_post/main.dart';
import 'package:create_post/utils/common.dart';
import 'package:create_post/utils/database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class PostsController extends GetxController {
  final _dbHelper = ImageTextDatabase();
  RxList <dynamic> localImagesData = [].obs;
  ColorFilter? selectedFilter;
  final GlobalKey widgetKey =  GlobalKey();
  List<ColorFilter> filtersList = [
    AppColors.SEPIA_MATRIX,
    AppColors.GREYSCALE_MATRIX,
    AppColors.VINTAGE_MATRIX,
    AppColors.FILTER_5,

  ];

  TextEditingController postDescription = TextEditingController();
  RxInt currentScreenIndex = 0.obs;

  @override
  void onInit() {

    fetchImagesWithText();
    super.onInit();
  }



  switchScreenVal(int newVal){
    currentScreenIndex.value = newVal;

  }

  refreshFilter(){
    selectedFilter = null;
    update();
  }

  updateSelectedFilter(ColorFilter newFilter){
    selectedFilter = newFilter;
    update();
  }


  fetchImagesWithText() async{
    await _dbHelper.getImagesWithText().then((e){
      if(e.isNotEmpty){
        localImagesData.assignAll(e as List);
        print("eeeee$e");
      }

      print("here----->"+localImagesData.length.toString());
    });
  }



}