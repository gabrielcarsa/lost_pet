import 'package:flutter/material.dart';

import 'home.dart';

class Perdidos extends StatefulWidget {
  const Perdidos({Key? key}) : super(key: key);

  @override
  State<Perdidos> createState() => _PerdidosState();
}

class _PerdidosState extends State<Perdidos> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        children: [
          Container(
            color: const Color.fromARGB(255, 240, 240, 240),
            child: const Padding(
              padding: EdgeInsets.only(left:15.0, top: 30.0, bottom: 30.0, right:15.0),
              child: Text(
                "Veja os cachorros perdidos e ajude a acha-los ",
                style: TextStyle(
                  fontFamily: "Inter",
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
