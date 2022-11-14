import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lost_pet/pages/create_account.dart';
import 'package:lost_pet/pages/encontrados.dart';
import 'package:lost_pet/pages/perdidos.dart';
import 'package:lost_pet/pages/perfil.dart';
import 'package:lost_pet/pages/publicar_encontrado.dart';
import 'package:lost_pet/pages/publicar_perdido.dart';
import 'package:lost_pet/pages/timeline.dart';

import '../models/User/user.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final Reference storageRef = FirebaseStorage.instance.ref();
final usersRef = FirebaseFirestore.instance.collection('users');
final encontradosRef = FirebaseFirestore.instance.collection('encontrados');
final perdidosRef = FirebaseFirestore.instance.collection('perdidos');
final atividadeRef = FirebaseFirestore.instance.collection('feed');
final timelineEncontradosRef =
    FirebaseFirestore.instance.collection('timelineEncontrados');
final timelinePerdidosRef =
    FirebaseFirestore.instance.collection('timelinePerdidos');
final DateTime timestamp = DateTime.now();
User? currentUser;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth = false;
  PageController pageController = PageController();
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
    pageController = PageController();
    //Detecta quando um usuário entra
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (err) {
      print('Erro: $err');
    });
    //Reautenticar
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account);
    }).catchError((err) {
      print('Erro: $err');
    });
  }

  handleSignIn(GoogleSignInAccount? account) {
    if (account != null) {
      setState(() {
        isAuth = true;
      });
      createUserInFirestore();
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  createUserInFirestore() async {
    //checar se o usuário existe
    final GoogleSignInAccount? user = googleSignIn.currentUser;
    DocumentSnapshot dado = await usersRef.doc(user?.id).get();

    //Se o usuário não existir, criar conta
    if (!dado.exists) {
      print("Rota");
      final phoneNumber = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => CreateAccount()));

      //Pegar nome de usuario para criar conta
      usersRef.doc(user?.id).set({
        "id": user?.id,
        "phoneNumber": phoneNumber,
        "photoUrl": user?.photoUrl,
        "email": user?.email,
        "displayName": user?.displayName,
        "timestamp": timestamp
      });
      dado = await usersRef.doc(user?.id).get();
    }
    currentUser = User.fromDocument(dado);
    print(currentUser?.phoneNumber);
  }

  login() {
    googleSignIn.signIn();
  }

  logout() {
    googleSignIn.signOut();
  }

  //Controllar onde página esta
  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  //Pular para página
  ChangePage(int pageIndex) {
    pageController.jumpToPage(pageIndex);
  }

  Scaffold buildAuthScreen() {
    return Scaffold(
      body: PageView(
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
        children: <Widget>[
          /*RaisedButton(
            child: Text('Sair'),
            onPressed: logout,
          )*/
          TimelineNavegar(userId: currentUser?.id),
          PublicarEncontrado(currentUser: currentUser),
          PublicarPerdido(
            currentUser: currentUser,
          ),
          Perfil(profileId: currentUser?.id),
        ],
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: ChangePage,
        inactiveColor: const Color.fromARGB(255, 216, 78, 132),
        activeColor: Colors.black,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(
            Icons.explore,
          )),
          BottomNavigationBarItem(
              icon: Icon(
            Icons.add_a_photo,
          )),
          BottomNavigationBarItem(
              icon: Icon(
            Icons.add_box,
          )),
          BottomNavigationBarItem(
              icon: Icon(
            Icons.person_rounded,
          )),
        ],
      ),
    );
  }

  //Tela de não logado
  Scaffold buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height * 1,
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.9,
              padding: const EdgeInsets.only(left: 20.0, top: 80.0),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/fundo.png"),
                  fit: BoxFit.fill,
                ),
              ),
              alignment: Alignment.center,
              child: Column(
                children: <Widget>[
                  Row(
                    children: [
                      Container(
                        width: 220.0,
                        child: const Text(
                          "Seu PET se \nperdeu?",
                          style: TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 36.0,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 208, 54, 106)),
                        ),
                      ),
                      Container(
                        height: 120.0,
                        width: 120.0,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/images/logo.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: const [
                      Text(
                        "Faça parte dessa\ncomunidade para\ntentar encontra-lo",
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.white,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 10),
                    child: Column(
                      children: [
                        Row(
                          children: const [
                            Padding(
                              padding: EdgeInsets.only(right: 15),
                              child: Icon(
                                Icons.add_location_alt_outlined,
                                size: 50,
                                color: Color.fromARGB(255, 208, 54, 106),
                              ),
                            ),
                            Flexible(
                              child: Text(
                                "Publique a localização de um cachorrinho que você encontrou na rua.",
                                style: TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.white,
                                  fontFamily: "Poppins",
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15.0,
                        ),
                        Row(
                          children: const [
                            Padding(
                              padding: EdgeInsets.only(right: 15),
                              child: Icon(
                                Icons.image_search,
                                size: 50,
                                color: Color.fromARGB(255, 208, 54, 106),
                              ),
                            ),
                            Flexible(
                              child: Text(
                                "Perdeu o seu? Outras pessoas podem encontrá-lo e postar aqui.",
                                style: TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.white,
                                  fontFamily: "Poppins",
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15.0,
                        ),
                        Row(
                          children: const [
                            Padding(
                              padding: EdgeInsets.only(right: 15),
                              child: Icon(
                                Icons.explore,
                                size: 50.0,
                                color: Color.fromARGB(255, 208, 54, 106),
                              ),
                            ),
                            Flexible(
                              child: Text(
                                "Publique a localização de um cachorrinho que você encontrou na rua.",
                                style: TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.white,
                                  fontFamily: "Poppins",
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.1,
              alignment: Alignment.center,
              color: const Color.fromARGB(240, 240, 240, 240),
              child: Center(
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                      shadowColor: Colors.black,
                      backgroundColor: Colors.white,
                      elevation: 1.0,
                      fixedSize: Size.fromWidth(300)),
                  icon: const Icon(
                    Icons.login,
                    size: 25.0,
                    color: Colors.black,
                  ),
                  label: const Text(
                    'Entrar com Google',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 17.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: login,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}
