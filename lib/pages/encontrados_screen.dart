import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lost_pet/pages/encontrados.dart';
import 'package:lost_pet/pages/home.dart';
import 'package:lost_pet/widgets/header.dart';
import 'package:lost_pet/widgets/progress.dart';

class EncontradosScreen extends StatelessWidget {
  final postId;
  final userId;
  
  const EncontradosScreen({Key? key, this.userId, this.postId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: encontradosRef.doc(userId).collection("userEncontrados").doc(postId).get(),
      builder: (context, snapshot) {
        if(!snapshot.hasData){
          return circularProgress();
        }
        Encontrados encontrados = Encontrados.fromDocument(snapshot.data!);
        return Center(
          child: Scaffold(
            appBar: header(context, titleText: "Encontrado"),
            body: ListView(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 1,
                  child: encontrados,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

