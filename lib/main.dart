import 'package:flutter/material.dart';
import 'package:lost_pet/pages/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Colors.black,
        ),
        dividerColor: Colors.transparent,
      ),
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}
