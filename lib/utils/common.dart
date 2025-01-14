import 'package:flutter/material.dart';

class AppColors {


  // Primary color
  static const Color buttonColor = Color(0xFFD16DF2);
  static const Color hintColor = Color(0xFF949494);
  static const Color divColor = Color(0xFFFDF8FF);



  static const SEPIA_MATRIX = ColorFilter.matrix([0.39, 0.769, 0.189, 0.0,
    0.0, 0.349, 0.686, 0.168,
    0.0, 0.0, 0.272, 0.534, 0.131,
    0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0]);

  static const GREYSCALE_MATRIX =
  ColorFilter.matrix([0.2126, 0.7152, 0.0722, 0.0, 0.0,
    0.2126, 0.7152, 0.0722, 0.0, 0.0,
    0.2126, 0.7152, 0.0722, 0.0, 0.0,
    0.0, 0.0, 0.0, 1.0, 0.0]);

  static const VINTAGE_MATRIX = ColorFilter.matrix([0.9, 0.5, 0.1, 0.0, 0.0,
    0.3, 0.8, 0.1, 0.0, 0.0,
    0.2, 0.3, 0.5, 0.0, 0.0,
    0.0, 0.0, 0.0, 1.0, 0.0]);

  static const FILTER_1 = ColorFilter.matrix([1.0, 0.0, 0.2, 0.0, 0.0,
    0.0, 1.0, 0.0, 0.0, 0.0,
    0.0, 0.0, 1.0, 0.0, 0.0,
    0.0, 0.0, 0.0, 1.0, 0.0]);

  static const FILTER_2 = ColorFilter.matrix([0.4, 0.4, -0.3, 0.0, 0.0,
    0.0, 1.0, 0.0, 0.0, 0.0,
    0.0, 0.0, 1.2, 0.0, 0.0,
    -1.2, 0.6, 0.7, 1.0, 0.0]);

  static const FILTER_3 = ColorFilter.matrix([0.8, 0.5, 0.0, 0.0, 0.0,
    0.0, 1.1,0.0, 0.0, 0.0,
    0.0, 0.2, 1.1 , 0.0, 0.0,
    0.0, 0.0, 0.0, 1.0, 0.0]);

  static const FILTER_4 = ColorFilter.matrix( [1.1, 0.0, 0.0, 0.0, 0.0,
    0.2, 1.0,-0.4, 0.0, 0.0,
    -0.1, 0.0, 1.0 , 0.0, 0.0,
    0.0, 0.0, 0.0, 1.0, 0.0]);

  static const FILTER_5 = ColorFilter.matrix([1.2, 0.1, 0.5, 0.0, 0.0,
    0.1, 1.0,0.05, 0.0, 0.0,
    0.0, 0.1, 1.0 , 0.0, 0.0,
    0.0, 0.0, 0.0, 1.0, 0.0]);




}


class CommonWidgets {

 static Widget textWidget (String text){
    return   Text(text);
  }


 static Future<void> showLoaderDialog(BuildContext context) async {
   var alertDialog = AlertDialog(
     elevation: 0,
     backgroundColor: Colors.white.withOpacity(0),
     content: const Center(
       child: CircularProgressIndicator(
         color: AppColors.buttonColor,
       ),
     ),
   );
   await showDialog(
     barrierDismissible: false,
     barrierColor: Colors.white.withOpacity(0),
     context: context,
     builder: (BuildContext context) {
       return WillPopScope(
           onWillPop: () => Future.value(false), child: alertDialog);
     },
   );
 }

}

