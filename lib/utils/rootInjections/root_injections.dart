import 'package:create_post/createPost/domain/create_post_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RoutesInjection extends StatelessWidget {
  Widget myWidget;
  RoutesInjection({super.key, required this.myWidget});

  @override
  Widget build(BuildContext context) {
    return
      MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => CreatePostCubit(),
          ),

        ],
        child: myWidget,
      );
  }
}