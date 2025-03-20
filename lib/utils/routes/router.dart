import 'package:create_post/createPost/presentation/create_post.dart';
import 'package:create_post/createPost/presentation/view_posts.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
/// The route configuration.
final GoRouter router = GoRouter(
  navigatorKey: navigatorKey,
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return  HomeScreen();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'createPost',
          builder: (BuildContext context, GoRouterState state) {
            return  CreatePost();
          },
        ),
      ],
    ),
  ],
);