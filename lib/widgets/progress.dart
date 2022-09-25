import 'package:flutter/material.dart';

Container circularProgress(){
  return Container(
    color: const Color.fromARGB(255, 240, 240, 240),
    alignment: Alignment.center,
    padding: const EdgeInsets.only(top: 10.0),
    child: const CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Color.fromARGB(255, 208, 54, 106)),
    ),
  );
}

Container linearProgress(){
  return Container(
    padding: const EdgeInsets.only(bottom: 10.0),
    child: const LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.purple),
    ),
  );
}