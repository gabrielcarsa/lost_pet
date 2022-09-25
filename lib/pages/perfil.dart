import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lost_pet/pages/atividade.dart';
import 'package:lost_pet/pages/configuracoes.dart';
import 'package:lost_pet/pages/encontrados.dart';
import 'package:lost_pet/pages/home.dart';
import 'package:lost_pet/widgets/progress.dart';

import '../models/User/user.dart';

class Perfil extends StatefulWidget {
  final String? profileId;

  const Perfil({Key? key, this.profileId}) : super(key: key);

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  bool isLoading = false;
  List<Encontrados> encontrados = [];
  String qualPost = "Encontrados";
  @override
  initState() {
    super.initState();
    getEncontradosPost();
  }

  getEncontradosPost() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await encontradosRef
        .doc(widget.profileId)
        .collection('userEncontrados')
        .orderBy('timestamp', descending: true)
        .get();
    setState(() {
      isLoading = false;
      encontrados =
          snapshot.docs.map((doc) => Encontrados.fromDocument(doc)).toList();
    });
  }

  buttonConfiguracoes() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                Configuracoes(currentUserId: currentUser!.id)));
  }

  buttonAtividade() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Atividade()));
  }

  buildProfileHeader() {
    return FutureBuilder<DocumentSnapshot>(
        future: usersRef.doc(widget.profileId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          User user = User.fromDocument(snapshot.data!);

          return Container(
            color: const Color.fromARGB(255, 240, 240, 240),
            padding: const EdgeInsets.only(
                left: 15.0, bottom: 30.0, right: 15.0),
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.all(0),
                  leading: const Text(
                    "Seu Perfil",
                    style: TextStyle(
                      fontFamily: "Inter",
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0,
                      color: Color.fromARGB(255, 208, 54, 106),
                    ),
                  ),
                  trailing: IconButton(
                    onPressed: buttonAtividade,
                    icon: const Icon(Icons.notifications_active, color: Colors.yellow,),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.55,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(bottom: 5.0),
                            child: Text(
                              user.displayName,
                              style: const TextStyle(
                                fontFamily: "Inter",
                                fontWeight: FontWeight.w600,
                                fontSize: 24.0,
                              ),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.55,
                            child: Text(
                              user.email,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: "Inter",
                                fontSize: 14.0,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 5.0),
                            width: MediaQuery.of(context).size.width * 0.55,
                            child: OutlinedButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    const Color.fromARGB(255, 240, 240, 240)),
                              ),
                              onPressed: buttonConfiguracoes,
                              child: const Text(
                                "Configurações",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: "Inter",
                                  fontSize: 14.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.35,
                        alignment: Alignment.centerRight,
                        child: CircleAvatar(
                          radius: 40.0,
                          backgroundColor: Colors.grey,
                          backgroundImage:
                              CachedNetworkImageProvider(user.photoUrl),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  setQualPost(String qual) {
    setState(() {
      qualPost = qual;
    });
  }

  buildTogglePost() {
    return Container(
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 240, 240, 240),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () => setQualPost("Encontrados"),
            child: Container(
              decoration: BoxDecoration(
                border: qualPost == "Encontrados"
                    ? Border(bottom: BorderSide(color: Colors.black, width: 1))
                    : Border(),
              ),
              width: MediaQuery.of(context).size.width * 0.40,
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Text(
                "Publicações de\n Encontrados",
                style: TextStyle(
                  color: qualPost == "Encontrados"
                      ? const Color.fromARGB(255, 208, 54, 106)
                      : Colors.black,
                  fontFamily: "Inter",
                  fontSize: 14.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setQualPost("Perdidos"),
            child: Container(
              decoration: BoxDecoration(
                border: qualPost == "Perdidos"
                    ? Border(bottom: BorderSide(color: Colors.black, width: 1))
                    : Border(),
              ),
              width: MediaQuery.of(context).size.width * 0.40,
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Text(
                "Publicações de\n Perdidos",
                style: TextStyle(
                  color: qualPost == "Perdidos"
                      ? const Color.fromARGB(255, 208, 54, 106)
                      : Colors.black,
                  fontFamily: "Inter",
                  fontSize: 14.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  buildPerfilPost() {
    if (isLoading) {
      return circularProgress();
    } else if (encontrados.isEmpty) {
      return Container(
        alignment: Alignment.center,
        child: Row(
          children: const [Icon(Icons.mood_bad), Text("Nada por aqui!")],
        ),
      );
    } else if (qualPost == "Encontrados") {
      return Column(
        children: encontrados,
      );
    } else if (qualPost == "Perdidos") {
      return Center(
        widthFactor: 100,
        child: Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width * 1,
          height: MediaQuery.of(context).size.height * 0.50,
          color: const Color.fromARGB(255, 240, 240, 240),
          child: Row(
            children: const [
              Icon(Icons.mood_bad),
              Text(
                "Nada por aqui!",
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: "Inter",
                  fontSize: 16.0,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
      ;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          buildProfileHeader(),
          buildTogglePost(),
          buildPerfilPost(),
        ],
      ),
    );
  }
}
