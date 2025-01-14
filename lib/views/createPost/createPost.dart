

import 'package:create_post/main.dart';
import 'package:create_post/utils/common.dart';
import 'package:create_post/utils/database.dart';
import 'package:create_post/utils/postsController.dart';


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import 'package:get/get.dart';

import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({super.key});

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {

  final _dbHelper = ImageTextDatabase();
  PostsController postsController = Get.find();

  @override
  void initState() {
    super.initState();

    _requestAssets();
  }
  final ScrollController _controller = ScrollController();
  final int _sizePerPage = 50;

  List<AssetEntity> selectedImagesList = [];
  AssetPathEntity? _path;
  List<AssetEntity> _entities = [];
  int _totalEntitiesCount = 0;

  int _page = 0;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreToLoad = true;


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return
      WillPopScope(
          onWillPop: () {

            if(postsController.currentScreenIndex.value == 1){
              postsController.switchScreenVal(0);
              postsController.refreshFilter();
              return Future.value(false);
            }else if(postsController.currentScreenIndex.value == 2){
              postsController.switchScreenVal(1);
              postsController.refreshFilter();
              return Future.value(false);
            }else{
              postsController.refreshFilter();
              return Future.value(true);

            }

          },
          child:  Scaffold(resizeToAvoidBottomInset: false,
              appBar: AppBar(
                title: const Text("New Post"),
                actions: [InkWell(
                  onTap: (){
                    if(postsController.currentScreenIndex.value == 0){
                      if(selectedImagesList.isNotEmpty){
                        postsController.switchScreenVal(1);
                      }else{

                        ScaffoldMessenger.of(context).showSnackBar( const SnackBar(
                          content: Text('Please select media'),
                        ));
                      }

                    }else if(postsController.currentScreenIndex.value == 1){
                      postsController.switchScreenVal(2);
                    }else{

                      createPostInDatabase();

                    }


                  },
                  child: Container(
                      margin: EdgeInsets.only(right: size.width *0.05),
                      child: const Text("Next",style: TextStyle(color: AppColors.buttonColor,fontWeight: FontWeight.w800),)),
                )],


              ),
              body:

              Obx(()=>  postsController.currentScreenIndex.value == 0 ?
              CustomScrollView(
                controller: _controller,
                slivers: <Widget>[
                  ///First sliver is the App Bar
                  SliverAppBar(
                    automaticallyImplyLeading: false,
                    ///Properties of app bar
                    backgroundColor: Colors.white,
                    floating: false,

                    expandedHeight: size.width,

                    ///Properties of the App Bar when it is expanded
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,

                      background: ListView.builder(

                          scrollDirection: Axis.horizontal,
                          itemCount: selectedImagesList.length,
                          itemBuilder: (context,index){
                            return AspectRatio(
                              aspectRatio: 1,
                              child: selectedImagesList[index].type == AssetType.video ?
                              Stack(
                                alignment: Alignment.center,
                                children: [

                                  AssetEntityImage(
                                    selectedImagesList[index],
                                    isOriginal: true, // Defaults to `true`.

                                    thumbnailFormat: ThumbnailFormat.jpeg, // Defaults to `jpeg`.
                                  ),
                                  Icon(Icons.play_circle_outline,
                                    size: 50,
                                    color: AppColors.buttonColor.withOpacity(0.9),)
                                ],
                              ):
                              AssetEntityImage(
                                selectedImagesList[index],
                                isOriginal: true, // Defaults to `true`.

                                thumbnailFormat: ThumbnailFormat.jpeg, // Defaults to `jpeg`.
                              ),
                            );
                          }),
                    ),
                  ),
                  SliverGrid.builder(
                      itemCount: _entities.length,

                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        ///no.of items in the horizontal axis
                        crossAxisCount: 4,
                      ),

                      ///Lazy building of list
                      itemBuilder: (BuildContext context, int index) {
                        if (index == _entities.length - 8 &&
                            !_isLoadingMore &&
                            _hasMoreToLoad) {
                          _loadMoreAsset();
                        }
                        return GestureDetector(
                          onTap: (){
                            setState(() {
                              selectedImagesList.add(_entities[index]);
                              _scrollUp();
                            });
                          },
                          child:
                          _entities[index].type == AssetType.video ?
                          Stack(

                            alignment: Alignment.center,
                            children: [
                              AssetEntityImage(
                                _entities[index],
                                isOriginal: false, // Defaults to `true`.
                                thumbnailSize: const ThumbnailSize.square(200),
                                thumbnailFormat: ThumbnailFormat.jpeg, // Defaults to `jpeg`.
                              ),
                              Icon(Icons.play_circle_outline,color: AppColors.buttonColor.withOpacity(0.9),)
                            ],
                          ):
                          AssetEntityImage(
                            _entities[index],
                            isOriginal: false, // Defaults to `true`.
                            thumbnailSize: const ThumbnailSize.square(200),
                            thumbnailFormat: ThumbnailFormat.jpeg, // Defaults to `jpeg`.
                          ),
                        );

                      }

                  )
                ],
              ) :
              postsController.currentScreenIndex.value == 1 ?
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  secondWidget(context),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: size.width * 0.4,
                      padding: EdgeInsets.only(bottom: size.width * 0.05,right: size.width * 0.05),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonColor,
                          textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontStyle: FontStyle.normal),
                        ),
                        onPressed: () {
                          if(postsController.currentScreenIndex.value == 0){
                            if(selectedImagesList.isNotEmpty){
                              postsController.switchScreenVal(1);
                            }else{

                              ScaffoldMessenger.of(context).showSnackBar( const SnackBar(
                                content: Text('Please select media'),
                              ));
                            }

                          }else if(postsController.currentScreenIndex.value == 1){
                            postsController.switchScreenVal(2);
                          }else{

                            createPostInDatabase();

                          }
                        },
                        child: const Text('Next',style: TextStyle(color: Colors.white),),
                      ),
                    ),
                  ],
                ),

                ],
              ) :
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  thirdWidget(context),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: size.width * 0.4,
                        padding: EdgeInsets.only(bottom: size.width * 0.05,right: size.width * 0.05),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonColor,
                            textStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontStyle: FontStyle.normal),
                          ),
                          onPressed: () {
                            if(postsController.currentScreenIndex.value == 0){
                              if(selectedImagesList.isNotEmpty){
                                postsController.switchScreenVal(1);
                              }else{

                                ScaffoldMessenger.of(context).showSnackBar( const SnackBar(
                                  content: Text('Please select media'),
                                ));
                              }

                            }else if(postsController.currentScreenIndex.value == 1){
                              postsController.switchScreenVal(2);
                            }else{

                              createPostInDatabase();

                            }

                          },
                          child: const Text('Next',style: TextStyle(color: Colors.white),),
                        ),
                      ),
                    ],
                  ),
                ],
              )
              )
          )
      );
  }


  createPostInDatabase() async{
    CommonWidgets.showLoaderDialog(context);
    List <Uint8List> imageBytesList = [];
    for (var item in selectedImagesList) {
      final Uint8List? uintData = await item.thumbnailData;
      imageBytesList.add(uintData!);
    }

    print("data---->${imageBytesList.length}");

    await _dbHelper.insertImagesWithText(postsController.postDescription.text,imageBytesList).then((e){
      postsController.fetchImagesWithText();
      postsController.switchScreenVal(0);
      Navigator.pop(navigatorKey.currentContext!);
      Navigator.pop(navigatorKey.currentContext!);
    });

  }

  Widget secondWidget(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return   Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          height: size.width,
          child: GetBuilder <PostsController>(builder: (postsController) {return
            ListView.builder(

                itemCount: selectedImagesList.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context,index){
                  return
                    AspectRatio(
                      aspectRatio: 1,
                      child: postsController.selectedFilter != null ?
                      selectedImagesList[index].type == AssetType.video ?
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          RepaintBoundary(
                            key: postsController.widgetKey,
                            child: ColorFiltered(
                                colorFilter:

                                postsController.selectedFilter!,
                                child:

                                AssetEntityImage(
                                  selectedImagesList[index],
                                  isOriginal: true, // Defaults to `true`.
                                  thumbnailFormat: ThumbnailFormat.jpeg, // Defaults to `jpeg`.
                                )
                            ),
                          ),
                          Icon(Icons.play_circle_outline,
                            size: 50,
                            color: AppColors.buttonColor.withOpacity(0.9),)
                        ],
                      ):

                      RepaintBoundary(
                        key: postsController.widgetKey,
                        child: ColorFiltered(
                            colorFilter:
                            postsController.selectedFilter!,
                            child:

                            AssetEntityImage(
                              selectedImagesList[index],
                              isOriginal: true, // Defaults to `true`.
                              thumbnailFormat: ThumbnailFormat.jpeg, // Defaults to `jpeg`.
                            )
                        ),
                      )   :

                      selectedImagesList[index].type == AssetType.video ?
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          AssetEntityImage(
                            selectedImagesList[index],
                            isOriginal: true, // Defaults to `true`.
                            thumbnailFormat: ThumbnailFormat.jpeg, // Defaults to `jpeg`.
                          ),

                          Icon(Icons.play_circle_outline,
                            size: 50,
                            color: AppColors.buttonColor.withOpacity(0.9),)
                        ],):
                      AssetEntityImage(
                        selectedImagesList[index],
                        isOriginal: true, // Defaults to `true`.
                        thumbnailFormat: ThumbnailFormat.jpeg, // Defaults to `jpeg`.
                      ),
                    );
                });
          }),
        ),

        selectedImagesList.length > 1 ? Container():
        SizedBox(height: size.width * 0.3,
          width: double.infinity,
          child: ListView.builder(
              itemCount: postsController.filtersList.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context,index){
                return
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ColorFiltered(
                      colorFilter: postsController.filtersList[index],
                      child:
                      GestureDetector(
                          onTap: (){
                            postsController.updateSelectedFilter(postsController.filtersList[index]);

                            /*   setState(() {
                                  selectedFilter = filtersList[index];
                                });*/
                          },
                          child:  Column(
                            children: [
                              const CircleAvatar(
                                radius: 40,
                              ),
                              CommonWidgets.textWidget("Filter ${index+1}")
                            ],
                          )
                      ),),
                  );
              }),
        )
      ],
    );
  }

  void _scrollUp() {
    _controller.animateTo(
      _controller.position.minScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  Widget thirdWidget(BuildContext context){
    Size size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [


        SizedBox(
          height: size.width,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: selectedImagesList.length,
              itemBuilder: (context,index){
                return  AspectRatio(
                  aspectRatio: 1,


                  child:
                  selectedImagesList[index].type == AssetType.video ?
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      AssetEntityImage(
                        selectedImagesList[index],
                        isOriginal: true, // Defaults to `true`.
                        thumbnailFormat: ThumbnailFormat.jpeg, // Defaults to `jpeg`.
                      ),

                      Icon(Icons.play_circle_outline,
                        size: 50,
                        color: AppColors.buttonColor.withOpacity(0.9),)
                    ],
                  ):
                  AssetEntityImage(
                    selectedImagesList[index],
                    isOriginal: true, // Defaults to `true`.
                    thumbnailFormat: ThumbnailFormat.jpeg, // Defaults to `jpeg`.
                  ),

                );
              }),

        ),

        SizedBox(height:  size.width *0.05,),
        TextFormField(
          maxLines: 3,
          controller: postsController.postDescription,
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintStyle: TextStyle(color:AppColors.hintColor ),
            hintText: 'Add a caption...',

            filled: true,
            fillColor: Colors.white,
          ),


        ),


      ],);
  }

  Future<void> _requestAssets() async {
    setState(() {
      _isLoading = true;
    });
    // Request permissions.
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (!mounted) {
      return;
    }
    // Further requests can be only proceed with authorized or limited.
    if (!ps.hasAccess) {
      setState(() {
        _isLoading = false;
      });
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
    if (!mounted) {
      return;
    }
    // Return if not paths found.
    if (paths.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      //  showToast('No paths found.');
      return;
    }
    setState(() {
      _path = paths.first;

    });
    _totalEntitiesCount = await _path!.assetCountAsync;
    final List<AssetEntity> entities = await _path!.getAssetListPaged(
      page: 0,
      size: _sizePerPage,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _entities = entities;
      _isLoading = false;
      _hasMoreToLoad = _entities.length < _totalEntitiesCount;
    });
    //showModelBottomSheet();
  }

  Future<void> _loadMoreAsset() async {
    final List<AssetEntity> entities = await _path!.getAssetListPaged(
      page: _page + 1,
      size: _sizePerPage,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _entities.addAll(entities);
      _page++;
      _hasMoreToLoad = _entities.length < _totalEntitiesCount;
      _isLoadingMore = false;
    });
  }
}
