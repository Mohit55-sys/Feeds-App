import 'dart:typed_data';

import 'package:create_post/main.dart';
import 'package:create_post/utils/common.dart';
import 'package:create_post/utils/database.dart';
import 'package:create_post/utils/postsController.dart';
import 'package:create_post/views/createPost/createPost.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final postsController = Get.put(PostsController());
  @override
  void initState() {
    super.initState();
  }




  @override
  Widget build(BuildContext context) {



    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Post"),
        actions: [GestureDetector(
          onTap: () async{

            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) =>
                        const CreatePost()));
          },
          child: Container(
              margin: EdgeInsets.only(right: size.width *0.05),
              child: const Text("Start",style: TextStyle(color: AppColors.buttonColor,fontWeight: FontWeight.w800),)),
        )],


      ),
      body: Obx(() =>
      postsController.localImagesData.isNotEmpty ?
          ListView.builder(

          itemCount: postsController.localImagesData.length,
          itemBuilder: (context,index){
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: size.width,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                      itemCount: postsController.localImagesData[index]['images'].length,
                      itemBuilder: (context,idx){
                    return AspectRatio(aspectRatio: 1,
                    child: Image.memory(postsController.localImagesData[index]['images'][idx],fit: BoxFit.contain,));
                  }),
                ),
                SizedBox(height: size.width * 0.05,),
                Text(postsController.localImagesData[index]['text']),
              ],
            );
          }) : Center(child: CommonWidgets.textWidget("No Posts Found")),
    ));
  }
}


