import 'dart:ui';

import 'package:flutter/cupertino.dart';

const mainScreenBackGroundPath = "assets/back1.jpg";
const LoginIconPath = "assets/LoginIcon.png";

const helpOthersImagePath = "assets/help_others.png";
const requestHelpImagePath = "assets/request_help.png";
//bottom sheet
const bottomSheetColor = Color(0xFFFAEEE7);
const bottomSheetButtonColor = Color(0xFFFF8BA7);
const bottomSheetButtonTextColor = Color(0xFF18275b);

const roundedCornerRadius = Radius.circular(40);

//!    Register Screen
const registerLoginButtonColor = Color(0xFFFF8BA7);
const registerFadedTextColor = Color(0xFF807F7F);

//!Help Screen
const messageBackgroundColor = Color(0xFFFAEEE7);
const messageForegroundColor = Color(0xFFffc6c7);
const messageButtonColor = Color(0xFFFF8BA7);

//!Random
const textHeaderColor = Color(0xFF33272a);
const aiTextForegroundColor = Color(0xFFfaeee7);
const aiTextMinimalColor = Color(0xFF594a4e);

const dashboardButtonColor = Color(0xFFff6e6c);

//!backgroundGradient
const backgroundGradient = LinearGradient(
  begin: Alignment.topRight,
  end: Alignment.bottomLeft,
  colors: [
    bottomSheetColor,
    messageForegroundColor,
  ],
);
