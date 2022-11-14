import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lost_pet/pages/publicar_perdido.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/User/user.dart';
import '../widgets/custom_image.dart';
import '../widgets/progress.dart';
import 'home.dart';

final DateTime agora = DateTime.now();

class Perdidos extends StatefulWidget {
  final String cor;
  final String detalhes;
  final String identificacao;
  final String mediaUrl;
  final String porte;
  final String postId;
  final String raca;
  final String userId;
  final String username;
  final String estado;
  final String cidade;
  final String bairro;
  final String recompensa;
  final Timestamp timestamp;
  final String desaparecimento;
  final dynamic sinalizar;

  const Perdidos({
    Key? key,
    required this.cor,
    required this.detalhes,
    required this.identificacao,
    required this.mediaUrl,
    required this.porte,
    required this.postId,
    required this.raca,
    required this.userId,
    required this.username,
    required this.cidade,
    required this.estado,
    required this.desaparecimento,
    required this.timestamp,
    required this.sinalizar,
    required this.recompensa,
    required this.bairro,
  }) : super(key: key);

  factory Perdidos.fromDocument(DocumentSnapshot doc) {
    return Perdidos(
        cor: doc['cor'],
        detalhes: doc['detalhes'],
        identificacao: doc['identificacao'],
        mediaUrl: doc['mediaUrl'],
        porte: doc['porte'],
        postId: doc['postId'],
        raca: doc['raca'],
        userId: doc['userId'],
        username: doc['username'],
        timestamp: doc['timestamp'],
        estado: doc['estado'],
        cidade: doc['cidade'],
        bairro: doc['bairro'],
        desaparecimento: doc['desaparecimento'],
        recompensa: doc['recompensa'],
        sinalizar: doc['sinalizar']);
  }

  @override
  State<Perdidos> createState() => _PerdidosState(
      cor: this.cor,
      detalhes: this.detalhes,
      identificacao: this.identificacao,
      mediaUrl: this.mediaUrl,
      porte: this.porte,
      postId: this.postId,
      raca: this.raca,
      userId: this.userId,
      username: this.username,
      sinalizar: this.sinalizar,
      estado: this.estado,
      recompensa: this.recompensa,
      bairro: this.bairro,
      desaparecimento: this.desaparecimento,
      cidade: this.cidade,
      timestamp: this.timestamp);
}

class _PerdidosState extends State<Perdidos> {
  final String? currentUserId = currentUser?.id;
  final String cor;
  final String detalhes;
  final String identificacao;
  final String mediaUrl;
  final String porte;
  final String postId;
  final String raca;
  final String userId;
  final String username;
  final String estado;
  final String recompensa;
  final String desaparecimento;
  final String bairro;
  final String cidade;
  final Timestamp timestamp;
  Map sinalizar;

  _PerdidosState(
      {required this.cor,
      required this.recompensa,
      required this.desaparecimento,
      required this.bairro,
      required this.detalhes,
      required this.identificacao,
      required this.mediaUrl,
      required this.porte,
      required this.postId,
      required this.raca,
      required this.userId,
      required this.username,
      required this.cidade,
      required this.estado,
      required this.timestamp,
      required this.sinalizar});

  @override
  initState() {
    if (sinalizar[currentUserId] == null) {
      sinalizar[currentUserId] = false;
    }
  }

  sinalizarPerdidos() {
    if (sinalizar[currentUserId] == true) {
      perdidosRef
          .doc(userId)
          .collection('userPerdidos')
          .doc(postId)
          .update({'sinalizar.$currentUserId': false});
      removeSinalizarAtividade();
      setState(() {
        sinalizar[currentUserId] = false;
      });
    } else if (sinalizar[currentUserId] == false) {
      perdidosRef
          .doc(userId)
          .collection('userPerdidos')
          .doc(postId)
          .update({'sinalizar.$currentUserId': true});
      addSinalizarAtividade();
      setState(() {
        sinalizar[currentUserId] = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Quando você sinaliza o usuário poderá ver seu número de celular para entrar em contato!'),
        duration: Duration(milliseconds: 5000),
      ));
    }
  }

  addSinalizarAtividade() {
    //if(currentUserId != userId){
    atividadeRef.doc(userId).collection("feedItems").doc(postId).set({
      "type": "sinalizarPerdidos",
      "username": currentUser?.displayName,
      "numero": currentUser?.phoneNumber,
      "userId": currentUser?.id,
      "userImg": currentUser?.photoUrl,
      "postId": postId,
      "mediaUrl": mediaUrl,
      "timestamp": agora,
    });
    // }
  }

  removeSinalizarAtividade() {
    //if(currentUserId != userId) {
    atividadeRef
        .doc(userId)
        .collection("feedItems")
        .doc(postId)
        .get()
        .then((docs) {
      if (docs.exists) {
        docs.reference.delete();
      }
    });
    // }
  }

  Icon exibirSinalizar() {
    if (sinalizar[currentUserId] == true && sinalizar[currentUserId] != null) {
      return const Icon(
        Icons.flag,
        color: Colors.yellow,
        size: 35,
      );
    } else {
      return const Icon(
        Icons.outlined_flag,
        color: Colors.yellow,
        size: 35,
      );
    }
  }

  handleDeletePerdidos(BuildContext parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: const Text("Excluir publicação?"),
            children: [
              SimpleDialogOption(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            Home()),
                  );
                  deletePost();
                },
                child: const Text(
                  "Deletar",
                  style: TextStyle(color: Colors.red),
                ),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancelar"),
              ),
            ],
          );
        });
  }

  deletePost() async {
    //Deletar post Encontrados
    perdidosRef
        .doc(userId)
        .collection("userPerdidos")
        .doc(postId)
        .get()
        .then((value) {
      if (value.exists) {
        value.reference.delete();
      }
    });
    //Deletar Imagem
    storageRef.child("post_$postId.jpg").delete();

    //Deletar Notificações daquele post
    QuerySnapshot atividadeSnapshot = await atividadeRef
        .doc(userId)
        .collection("feedItems")
        .where('postId', isEqualTo: postId)
        .get();
    atividadeSnapshot.docs.forEach((value) {
      if (value.exists) {
        value.reference.delete();
      }
    });

    //Deletar da timeline
    timelinePerdidosRef.doc(postId).get().then((value) {
      if (value.exists) {
        value.reference.delete();
      }
    });
  }

  buildPostPerdidos() {
    return FutureBuilder<DocumentSnapshot>(
      future: usersRef.doc(userId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        timeago.setLocaleMessages('pt_BR', timeago.PtBrMessages());
        User user = User.fromDocument(snapshot.data!);
        bool postOwner = currentUserId == userId;
        return Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 15.0),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                  backgroundColor: Colors.black,
                ),
                title: Text(
                  username,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontFamily: "Inter",
                  ),
                ),
                trailing: postOwner
                    ? IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () => handleDeletePerdidos(context),
                      )
                    : const Text(''),
              ),
            ),
            Row(
              children: [
                Container(
                  margin: const EdgeInsets.all(0),
                  padding:
                      const EdgeInsets.only(top: 0, left: 15.0, bottom: 10),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black,
                        fontFamily: "Inter",
                      ),
                      children: [
                        const TextSpan(
                          text: "Desaparecido desde ",
                        ),
                        TextSpan(
                          text: desaparecimento,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            fontFamily: "Inter",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Stack(
              children: [
                cachedNetworkImage(mediaUrl),
              ],
            ),
            ListTile(
              title: Text(
                raca,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontFamily: "Inter",
                ),
              ),
              trailing: IconButton(
                onPressed: sinalizarPerdidos,
                icon: Icon(
                  sinalizar[currentUserId] ? Icons.flag : Icons.outlined_flag,
                  color: const Color.fromARGB(255, 212, 218, 16),
                  size: 30,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 15.0, right: 15),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: Color.fromARGB(255, 208, 54, 106),
                  ),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        "$estado, $cidade, $bairro",
                        overflow: TextOverflow.visible,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontFamily: "Inter",
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 15.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.attach_money,
                    color: Color.fromARGB(255, 208, 54, 106),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontFamily: "Inter",
                        ),
                        children: [
                          const TextSpan(
                            text: "Paga recompensa de ",
                          ),
                          TextSpan(
                            text: recompensa == ""
                                ? "0,00 reais"
                                : "$recompensa reais",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.green,
                              fontWeight: FontWeight.w700,
                              fontFamily: "Inter",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
              child: ExpansionTile(
                childrenPadding: const EdgeInsets.only(
                    bottom: 15.0, left: 15.0, right: 15.0),
                title: const Text(
                  "Ver mais",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontFamily: "Inter",
                  ),
                ),
                backgroundColor: const Color.fromARGB(255, 234, 234, 234),
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.badge,
                        color: Color.fromARGB(255, 208, 54, 106),
                      ),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            identificacao == "sim"
                                ? "Possui identificação"
                                : "Não possui identificação",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontFamily: "Inter",
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.height,
                        color: Color.fromARGB(255, 208, 54, 106),
                      ),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            "Porte $porte",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontFamily: "Inter",
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.short_text,
                        color: Color.fromARGB(255, 208, 54, 106),
                      ),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            "Observações: $detalhes",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontFamily: "Inter",
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 240, 240, 240),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildPostPerdidos(),
        ],
      ),
    );
  }
}
