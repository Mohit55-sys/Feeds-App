

import 'package:create_post/createPost/domain/create_post_cubit.dart';
import 'package:create_post/createPost/domain/create_post_state.dart';

import 'package:create_post/utils/common.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

class CreatePost extends StatelessWidget {
  const CreatePost({super.key});



  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return
      BlocBuilder<CreatePostCubit, CreatePostState>(
        builder: (context, state) {
          var cubit = context.read<CreatePostCubit>();
          return WillPopScope(
              onWillPop: () {

                if(state.currentScreenIndex == 1){
                  cubit.switchScreenVal(0);
                  cubit.refreshFilter();
                  return Future.value(false);
                }else if(state.currentScreenIndex == 2){
                  cubit.switchScreenVal(1);
                  cubit.refreshFilter();
                  return Future.value(false);
                }else{
                  cubit.refreshFilter();
                  return Future.value(true);

                }

              },
              child:  Scaffold(
                // Rectangular Floating Button
                floatingActionButton: state.currentScreenIndex != 0 ?  SizedBox(
                  width: size.width * 0.4, // Adjust width as needed
                  height:  size.width * 0.1, // Optional: Adjust height too
                  child:
                  FloatingActionButton.extended(
                    onPressed: () {
                      if(state.currentScreenIndex == 0){
                        if(state.selectedImagesList.isNotEmpty){
                          cubit.switchScreenVal(1);
                        }else{

                          ScaffoldMessenger.of(context).showSnackBar( const SnackBar(
                            content: Text('Please select media'),
                          ));
                        }

                      }
                      else if(state.currentScreenIndex == 1){
                        cubit.switchScreenVal(2);
                      }
                      else{

                        cubit.createPostInDatabase();

                      }
                    },
                    label: const Text('Next',style: TextStyle(color: Colors.white),),

                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // Adjust for rectangle look
                    ),
                  ),) : const SizedBox.shrink(),
                floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
                resizeToAvoidBottomInset: false,
                appBar: AppBar(
                  title: const Text("New Post"),
                  actions: [
                    state.currentScreenIndex == 0 ?
                    InkWell(
                      onTap: (){
                        if(state.currentScreenIndex == 0){
                          if(state.selectedImagesList.isNotEmpty){
                            cubit.refreshFilter();
                            cubit.switchScreenVal(1);
                          }else{

                            ScaffoldMessenger.of(context).showSnackBar( const SnackBar(
                              content: Text('Please select media'),
                            ));
                          }

                        }
                        else if(state.currentScreenIndex == 1){
                          cubit.switchScreenVal(2);
                        }
                        else{
                          cubit.createPostInDatabase();
                        }


                      },
                      child: Container(
                          margin: EdgeInsets.only(right: size.width *0.05),
                          child: const Text("Next",style: TextStyle(color: AppColors.buttonColor,fontWeight: FontWeight.w800),)),
                    ) : Container()
                  ],
                ),
                body:
                state.currentScreenIndex == 0 ?

                CustomScrollView(
                  controller: cubit.controller,
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
                            itemCount: state.selectedImagesList.length,
                            itemBuilder: (context,index){
                              return AspectRatio(
                                aspectRatio: 1,
                                child: state.selectedImagesList[index].type == AssetType.video ?
                                Stack(
                                  alignment: Alignment.center,
                                  children: [

                                    AssetEntityImage(
                                      state.selectedImagesList[index],
                                      isOriginal: true, // Defaults to `true`.

                                      thumbnailFormat: ThumbnailFormat.jpeg, // Defaults to `jpeg`.
                                    ),
                                    Icon(Icons.play_circle_outline,
                                      size: 50,
                                      color: AppColors.buttonColor.withOpacity(0.9),)
                                  ],
                                ):
                                AssetEntityImage(
                                  state.selectedImagesList[index],
                                  isOriginal: true, // Defaults to `true`.

                                  thumbnailFormat: ThumbnailFormat.jpeg, // Defaults to `jpeg`.
                                ),
                              );
                            }),
                      ),
                    ),
                    SliverGrid.builder(
                        itemCount: state.mainEntities.length,

                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          ///no.of items in the horizontal axis
                          crossAxisCount: 4,
                        ),

                        ///Lazy building of list
                        itemBuilder: (BuildContext context, int index) {
                          if (index == state.mainEntities.length - 8 &&
                              !cubit.isLoadingMore &&
                              cubit.hasMoreToLoad) {
                            cubit.loadMoreAsset();
                          }
                          return GestureDetector(
                            onTap: (){
                              cubit.scrollUp(cubit,index);

                            },
                            child:
                            state.mainEntities[index].type == AssetType.video ?
                            Stack(

                              alignment: Alignment.center,
                              children: [
                                AssetEntityImage(
                                  state.mainEntities[index],
                                  isOriginal: false, // Defaults to `true`.
                                  thumbnailSize: const ThumbnailSize.square(200),
                                  thumbnailFormat: ThumbnailFormat.jpeg, // Defaults to `jpeg`.
                                ),
                                Icon(Icons.play_circle_outline,color: AppColors.buttonColor.withOpacity(0.9),)
                              ],
                            ):
                            AssetEntityImage(
                              state.mainEntities[index],
                              isOriginal: false, // Defaults to `true`.
                              thumbnailSize: const ThumbnailSize.square(200),
                              thumbnailFormat: ThumbnailFormat.jpeg, // Defaults to `jpeg`.
                            ),
                          );

                        }

                    )
                  ],
                )
                    :
                state.currentScreenIndex == 1 ?
                secondWidget(context,cubit)  :
                thirdWidget(context,cubit),
              )

          );
        },
      );
  }



  Widget secondWidget(BuildContext context,CreatePostCubit cubeVal) {
    Size size = MediaQuery.of(context).size;
    return
      BlocProvider.value(
          value: cubeVal,
          child:
          BlocBuilder<CreatePostCubit, CreatePostState>(
            builder: (context, state) {
              var cubit = context.read<CreatePostCubit>();
              return Column(

                children: [
                  SizedBox(
                      height: size.width,
                      child:  ListView.builder(

                          itemCount: state.selectedImagesList.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context,index){
                            return
                              AspectRatio(
                                aspectRatio: 1,
                                child: state.selectedFilter != null ?
                                state.selectedImagesList[index].type == AssetType.video ?
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    RepaintBoundary(
                                      key: cubit.widgetKey,
                                      child: ColorFiltered(
                                          colorFilter:
                                          state.selectedFilter!,
                                          child:
                                          AssetEntityImage(
                                            state.selectedImagesList[index],
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
                                  key: cubit.widgetKey,
                                  child: ColorFiltered(
                                      colorFilter:
                                      state.selectedFilter!,
                                      child:

                                      AssetEntityImage(
                                        state.selectedImagesList[index],
                                        isOriginal: true, // Defaults to `true`.
                                        thumbnailFormat: ThumbnailFormat.jpeg, // Defaults to `jpeg`.
                                      )
                                  ),
                                )   :

                                state.selectedImagesList[index].type == AssetType.video ?
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    AssetEntityImage(
                                      state.selectedImagesList[index],
                                      isOriginal: true, // Defaults to `true`.
                                      thumbnailFormat: ThumbnailFormat.jpeg, // Defaults to `jpeg`.
                                    ),

                                    Icon(Icons.play_circle_outline,
                                      size: 50,
                                      color: AppColors.buttonColor.withOpacity(0.9),)
                                  ],):
                                AssetEntityImage(
                                  state.selectedImagesList[index],
                                  isOriginal: true, // Defaults to `true`.
                                  thumbnailFormat: ThumbnailFormat.jpeg, // Defaults to `jpeg`.
                                ),
                              );
                          })
                  ),

                  state.selectedImagesList.length > 1 ? Container():
                  Container(
                    padding: EdgeInsets.only(top:  size.width * 0.05),
                    child: SizedBox(height: size.width * 0.3,
                      width: double.infinity,
                      child: ListView.builder(
                          itemCount: cubit.filtersList.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context,index){
                            return
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ColorFiltered(
                                  colorFilter: cubit.filtersList[index],
                                  child:
                                  GestureDetector(
                                      onTap: (){
                                        cubit.updateSelectedFilter(cubit.filtersList[index]);
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
                    ),
                  )
                ],
              );
            },
          ));
  }

  void _scrollUp(CreatePostCubit cubit) {
    cubit.controller.animateTo(
      cubit.controller.position.minScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  Widget thirdWidget(BuildContext context,CreatePostCubit cubeVal){
    Size size = MediaQuery.of(context).size;
    return
      BlocProvider.value(
          value: cubeVal,
          child: BlocBuilder<CreatePostCubit, CreatePostState>(
            builder: (context, state) {
              var cubit = context.read<CreatePostCubit>();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [


                  SizedBox(
                    height: size.width,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.selectedImagesList.length,
                        itemBuilder: (context,index){
                          return  AspectRatio(
                            aspectRatio: 1,


                            child:
                            state.selectedImagesList[index].type == AssetType.video ?
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                AssetEntityImage(
                                  state.selectedImagesList[index],
                                  isOriginal: true, // Defaults to `true`.
                                  thumbnailFormat: ThumbnailFormat.jpeg, // Defaults to `jpeg`.
                                ),

                                Icon(Icons.play_circle_outline,
                                  size: 50,
                                  color: AppColors.buttonColor.withOpacity(0.9),)
                              ],
                            ):
                            AssetEntityImage(
                              state.selectedImagesList[index],
                              isOriginal: true, // Defaults to `true`.
                              thumbnailFormat: ThumbnailFormat.jpeg, // Defaults to `jpeg`.
                            ),

                          );
                        }),

                  ),

                  SizedBox(height:  size.width *0.05,),
                  TextFormField(
                    maxLines: 3,
                    controller: cubit.postDescription,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintStyle: TextStyle(color:AppColors.hintColor ),
                      hintText: 'Add a caption...',

                      filled: true,
                      fillColor: Colors.white,
                    ),


                  ),


                ],);
            },
          )
      );


  }
}

