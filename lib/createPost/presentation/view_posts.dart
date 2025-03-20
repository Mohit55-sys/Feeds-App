import 'package:create_post/createPost/domain/create_post_cubit.dart';
import 'package:create_post/createPost/domain/create_post_state.dart';
import 'package:create_post/utils/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});


  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: const Text("New Post"),
          actions: [GestureDetector(
            onTap: () async{
              context.go('/createPost');
            },
            child: Container(
                margin: EdgeInsets.only(right: size.width *0.05),
                child: const Text("Start",style: TextStyle(color: AppColors.buttonColor,fontWeight: FontWeight.w800),)),
          )],


        ),
        body: BlocBuilder<CreatePostCubit, CreatePostState>(
          builder: (context, state) {
            var cubit = context.read<CreatePostCubit>();
            return
              state.localImagesData.isNotEmpty ?
              ListView.separated(

                itemCount: state.localImagesData.length,
                itemBuilder: (context,index){
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(width
                              : size.width * 0.02,),
                          CircleAvatar(
                            backgroundColor: Colors.blue,
                            radius: size.width * 0.052,
                            child: const CircleAvatar(
                                child:  Icon(Icons.person)),
                          ),
                          SizedBox(width
                              : size.width * 0.02,),
                          const Text("John Karter",style: TextStyle(fontWeight: FontWeight.w500),),
                        ],
                      ),
                      SizedBox(height
                          : size.width * 0.03,),
                      SizedBox(
                        height: size.width,
                        child:
                        ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: state.localImagesData[index]['images'].length,
                          itemBuilder: (context,idx){
                            return AspectRatio(aspectRatio: 1,
                                child: Image.memory(state.localImagesData[index]['images'][idx],fit: BoxFit.contain,));
                          }, ),
                      ),
                      SizedBox(height: size.width * 0.05,),
                      Row(
                        children: [
                          SizedBox(width
                              : size.width * 0.02,),
                          Text(state.localImagesData[index]['text']),
                        ],
                      ),
                    ],
                  );
                }, separatorBuilder: (BuildContext context, int index) { return SizedBox(height: size.width * 0.05,); },) : Center(child: CommonWidgets.textWidget("No Posts Found"));

          },
        ));
  }
}


