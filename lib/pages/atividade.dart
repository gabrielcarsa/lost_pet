import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lost_pet/pages/encontrados_screen.dart';
import 'package:lost_pet/pages/home.dart';
import 'package:lost_pet/widgets/progress.dart';
import 'package:timeago/timeago.dart' as timeago;

class Atividade extends StatefulWidget {
  const Atividade({Key? key}) : super(key: key);

  @override
  State<Atividade> createState() => _AtividadeState();
}

class _AtividadeState extends State<Atividade> {
  getAtividade() async {
    QuerySnapshot snapshot = await atividadeRef
        .doc(currentUser?.id)
        .collection("feedItems")
        .orderBy('timestamp', descending: true)
        .limit(50)
        .get();

    List<AtividadeFeedItem> feedItems = [];

    snapshot.docs.forEach((element) {
      feedItems.add(AtividadeFeedItem.fromDocument(element));
    });
    return feedItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 240, 240, 240),
        foregroundColor: Colors.black,
        title: const Text(
          "Atividade",
          style: TextStyle(
            color: Colors.black,
            fontFamily: "Inter",
            fontWeight: FontWeight.w700,
            fontSize: 20.0,
          ),
        ),
      ),
      body: Container(
        child: FutureBuilder<dynamic>(
          future: getAtividade(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return circularProgress();
            }
            timeago.setLocaleMessages('pt_BR', timeago.PtBrMessages());
            return ListView(
              children: snapshot.data!,
            );
          },
        ),
      ),
    );
  }
}

class AtividadeFeedItem extends StatelessWidget {
  final String username;
  final String userImg;
  final String userId;
  final String type;
  final Timestamp timestamp;
  final String postId;
  final String numero;
  final String mediaUrl;

  AtividadeFeedItem({
    required this.username,
    required this.userImg,
    required this.userId,
    required this.type,
    required this.timestamp,
    required this.postId,
    required this.numero,
    required this.mediaUrl,
  });

  factory AtividadeFeedItem.fromDocument(DocumentSnapshot docs) {
    return AtividadeFeedItem(
      username: docs['username'],
      userImg: docs['userImg'],
      userId: docs['userId'],
      type: docs['type'],
      timestamp: docs['timestamp'],
      postId: docs['postId'],
      numero: docs['numero'],
      mediaUrl: docs['mediaUrl'],
    );
  }

  showEncontrado(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EncontradosScreen(
          postId: postId,
          userId: userId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: ListTile(
          title: RichText(
            text: TextSpan(
              style: const TextStyle(
                  fontSize: 14.0, fontFamily: "Inter", color: Colors.black),
              children: [
                TextSpan(
                  text: username,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                    text:
                        " sinalizou para esta publicação, entre em contato pelo número: $numero"),
              ],
            ),
          ),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(userImg),
          ),
          subtitle: Text(
            timeago.format(timestamp.toDate(), locale: 'pt_BR'),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: GestureDetector(
            onTap: () => showEncontrado(context),
            child: Container(
              width: 50.0,
              height: 50.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: CachedNetworkImageProvider(mediaUrl)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
