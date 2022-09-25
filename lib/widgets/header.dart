import 'package:flutter/material.dart';

AppBar header(context, {bool isAppTitle = false, String titleText = "", removeBackButton = false}){
  return AppBar(
    automaticallyImplyLeading: removeBackButton ? false : true,
    title: Text(
      isAppTitle ? "LostPet" : titleText,
      style: TextStyle(
        color: Colors.black,
        fontFamily: isAppTitle ? "Inter" : "",
        fontSize: isAppTitle ? 50.0 : 22.0,
      ),
      overflow: TextOverflow.ellipsis,
    ),
    centerTitle: true,
    backgroundColor: const Color.fromARGB(255, 240, 240, 240),
    foregroundColor: Colors.black,
  );
}