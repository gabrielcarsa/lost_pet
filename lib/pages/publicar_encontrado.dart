import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lost_pet/models/User/user.dart';
import 'package:lost_pet/pages/home.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../widgets/progress.dart';

class PublicarEncontrado extends StatefulWidget {
  final User? currentUser;

  const PublicarEncontrado({Key? key, required this.currentUser})
      : super(key: key);

  @override
  State<PublicarEncontrado> createState() => _PublicarEncontradoState();
}

class _PublicarEncontradoState extends State<PublicarEncontrado> {
  XFile? file;
  final ImagePicker _picker = ImagePicker();
  bool isUploading = false;
  String postId = const Uuid().v4();
  String racaDropdown = '- Selecione -';
  String identificacaoDropdown = '- Selecione -';
  String porteDropdown = '- Selecione -';
  String corDropdown = '- Selecione -';
  String levarDropdown = '- Selecione -';
  TextEditingController detalhesController = TextEditingController();
  TextEditingController cidadeController = TextEditingController();
  TextEditingController estadoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Map<int, String> sinalizar = Map();

  //Função para tirar foto
  tirarFoto() async {
    Navigator.pop(context);
    XFile? file = await _picker.pickImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    );
    setState(() {
      this.file = file;
    });
  }

  //Função para escolher imagem na galeria
  escolherGaleria() async {
    Navigator.pop(context);
    XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      this.file = file;
    });
  }

  selectImage(parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: const Text(
              "Publicar cachorro encontrado na rua",
              style:
                  TextStyle(fontFamily: "Inter", fontWeight: FontWeight.w800),
            ),
            children: [
              SimpleDialogOption(
                onPressed: tirarFoto,
                child: const Text("Tirar foto com câmera"),
              ),
              SimpleDialogOption(
                onPressed: escolherGaleria,
                child: const Text("Escolher foto na galeria"),
              ),
              SimpleDialogOption(
                child: const Text("Cancelar"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  Scaffold escolherFoto() {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
              left: 15.0, top: 30.0, bottom: 30.0, right: 15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Text(
                    "Tire foto dos cachorros\nandando na rua",
                    style: TextStyle(
                      fontFamily: "Inter",
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0,
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Text(
                  "Você pode ajudar alguém a achar um cachorro que está perdido.",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.normal,
                    fontFamily: "Inter",
                  ),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.61,
                width: MediaQuery.of(context).size.width,
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(2.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          const Color.fromARGB(255, 216, 78, 132)),
                      padding: MaterialStateProperty.all(
                          const EdgeInsets.symmetric(
                              vertical: 15.0, horizontal: 60.0)),
                    ),
                    onPressed: () => selectImage(context),
                    child: const Text(
                      "Selecionar foto",
                      style: TextStyle(
                        fontFamily: "Inter",
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  //Botão cancelar
  cancelar() {
    setState(() {
      file = null;
    });
  }

  //Upload Image
  Future<String> uploadImage(imageFile) async {
    UploadTask uploadTask = storageRef
        .child("encontrado_$postId.jpg")
        .putFile(File(imageFile.path));
    TaskSnapshot storageSnap = await uploadTask;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  //Criar post no BD
  createPostInFirestore(
      {required String mediaUrl,
      required String raca,
      required String identificacao,
      required String porte,
      required String cor,
      required String detalhes,
      required String cidade,
      required String estado,
      required Map sinalizar}) {
    encontradosRef
        .doc(widget.currentUser?.id)
        .collection("userEncontrados")
        .doc(postId)
        .set({
      "postId": postId,
      "userId": widget.currentUser?.id,
      "username": widget.currentUser?.displayName,
      "mediaUrl": mediaUrl,
      "raca": raca,
      "identificacao": identificacao,
      "porte": porte,
      "cor": cor,
      "detalhes": detalhes,
      "timestamp": timestamp,
      "cidade": cidade,
      "estado": estado,
      "sinalizar": sinalizar


    });

    timelineEncontradosRef
        .doc(postId)
        .set({
      "postId": postId,
      "userId": widget.currentUser?.id,
      "username": widget.currentUser?.displayName,
      "mediaUrl": mediaUrl,
      "raca": raca,
      "identificacao": identificacao,
      "porte": porte,
      "cor": cor,
      "detalhes": detalhes,
      "timestamp": timestamp,
      "cidade": cidade,
      "estado": estado,
      "sinalizar": sinalizar
    });
  }

  //Submeter
  submit() async {
    final form = _formKey.currentState;
    if (form!.validate()) {
      setState(() {
        isUploading = true;
      });
      await compressImage();
      String mediaUrl = await uploadImage(file);
      createPostInFirestore(
          mediaUrl: mediaUrl,
          raca: racaDropdown,
          identificacao: identificacaoDropdown,
          porte: porteDropdown,
          cor: corDropdown,
          detalhes: detalhesController.text,
          cidade: cidadeController.text,
          estado: estadoController.text,
          sinalizar: sinalizar);
      setState(() {
        file = null;
        isUploading = false;
        postId = Uuid().v4();
      });
    }
  }

  //Comprimir imagem
  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image? imageFile = Im.decodeImage(await file!.readAsBytes());
    final compressedImageFile = File('$path/image_$postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile!, quality: 85));
    setState(() {
      file = XFile(compressedImageFile.path);
    });
  }

  Scaffold buildUploadForm() {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            Container(
              color: const Color.fromARGB(255, 240, 240, 240),
              padding: const EdgeInsets.only(
                  left: 15.0, top: 20.0, bottom: 30.0, right: 15.0),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.always,
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.topLeft,
                      child: const Text(
                        "Foto Capturada!",
                        style: TextStyle(
                          fontFamily: "Inter",
                          fontWeight: FontWeight.bold,
                          fontSize: 24.0,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
                      child: const Text(
                        "Antes de publicar, ajude-nos a coletar mais algumas informações.",
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.normal,
                          fontFamily: "Inter",
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.10,
                            child: const Icon(
                              Icons.verified,
                              color: Color.fromARGB(255, 208, 54, 106),
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width * 0.50,
                            child: const Text(
                              "Foto escolhida",
                              style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  fontFamily: "Inter",
                                  fontSize: 20.0),
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            height: 60.0,
                            width: 60,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: FileImage(File(file!.path)),
                                )),
                          )
                        ],
                      ),
                    ),
                    Container(
                      alignment: Alignment.topLeft,
                      width: MediaQuery.of(context).size.width * 0.80,
                      padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                      child: const Text(
                        "Selecione a raça:",
                        style: TextStyle(
                          fontFamily: "Inter",
                          fontWeight: FontWeight.w800,
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.80,
                      child: DropdownButtonFormField<String>(
                        validator: (val) {
                          if (val == '- Selecione -') {
                            return 'Selecione uma opção!';
                          } else {
                            return null;
                          }
                        },
                        value: racaDropdown,
                        icon: const Icon(Icons.expand_more),
                        elevation: 16,
                        style: const TextStyle(
                            fontFamily: "Inter", color: Colors.black),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        focusColor: Colors.black,
                        onChanged: (String? newValue) {
                          setState(() {
                            racaDropdown = newValue!;
                          });
                        },
                        items: <String>[
                          '- Selecione -',
                          'Não Sei',
                          'Afegão Hound',
                          'Affenpinscher',
                          'Airedale Terrier',
                          'Akita',
                          'American Staffordshire Terrier',
                          'Basenji',
                          'Basset Hound',
                          'Beagle',
                          'Beagle Harrier',
                          'Bearded Collie',
                          'Bedlington Terrier',
                          'Bichon Frisé',
                          'Bloodhound',
                          'Bobtail',
                          'Boiadeiro Australiano',
                          'Boiadeiro Bernês',
                          'Border Collie',
                          'Border Terrier',
                          'Borzoi',
                          'Boston Terrier',
                          'Boxer',
                          'Buldogue Francês',
                          'Buldogue Inglês',
                          'Bull Terrier',
                          'Bulmastife',
                          'Cairn Terrier',
                          'Cane Corso',
                          'Cão de Água Português',
                          'Cão de Crista Chinês',
                          'Cavalier King Charles Spaniel',
                          'Chesapeake Bay Retriever',
                          'Chihuahua',
                          'Chow Chow',
                          'Cocker Spaniel Americano',
                          'Cocker Spaniel Inglês',
                          'Collie',
                          'Coton de Tuléar',
                          'Dachshund',
                          'Dálmata',
                          'Dandie Dinmont Terrier',
                          'Dobermann',
                          'Dogo Argentino',
                          'Dogue Alemão',
                          'Fila Brasileiro',
                          'Fox Terrier (Pelo Duro e Pelo Liso)',
                          'Foxhound Inglês',
                          'Galgo Escocês',
                          'Galgo Irlandês',
                          'Golden Retriever',
                          'Grande Boiadeiro Suiço',
                          'Greyhound',
                          'Grifo da Bélgica',
                          'Husky Siberiano',
                          'Jack Russell Terrier',
                          'King Charles',
                          'Komondor',
                          'Labradoodle',
                          'Labrador Retriever',
                          'Lakeland Terrier',
                          'Leonberger',
                          'Lhasa Apso',
                          'Lulu da Pomerânia',
                          'Malamute do Alasca',
                          'Maltês',
                          'Mastife',
                          'Mastim Napolitano',
                          'Mastim Tibetano',
                          'Norfolk Terrier',
                          'Norwich Terrier',
                          'Papillon',
                          'Pastor Alemão',
                          'Pastor Australiano',
                          'Pinscher Miniatura',
                          'Poodle',
                          'Pug',
                          'Rottweiler',
                          'Sem Raça Definida (SRD)',
                          'ShihTzu',
                          'Silky Terrier',
                          'Skye Terrier',
                          'Staffordshire Bull Terrier',
                          'Terra Nova',
                          'Terrier Escocês',
                          'Tosa',
                          'Weimaraner',
                          'Welsh Corgi (Cardigan)',
                          'Welsh Corgi (Pembroke)',
                          'West Highland White Terrier',
                          'Whippet',
                          'Xoloitzcuintli',
                          'Yorkshire Terrier'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                    Container(
                      alignment: Alignment.topLeft,
                      width: MediaQuery.of(context).size.width * 0.80,
                      padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                      child: const Text(
                        "Possui identificação:",
                        style: TextStyle(
                          fontFamily: "Inter",
                          fontWeight: FontWeight.w800,
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.80,
                      child: DropdownButtonFormField<String>(
                        validator: (val) {
                          if (val == '- Selecione -') {
                            return 'Selecione uma opção!';
                          } else {
                            return null;
                          }
                        },
                        value: identificacaoDropdown,
                        icon: const Icon(Icons.expand_more),
                        elevation: 16,
                        style: const TextStyle(
                            fontFamily: "Inter", color: Colors.black),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        focusColor: Colors.black,
                        onChanged: (String? newValue) {
                          setState(() {
                            identificacaoDropdown = newValue!;
                          });
                        },
                        items: <String>['- Selecione -', 'Não', 'Sim']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                    Container(
                      alignment: Alignment.topLeft,
                      width: MediaQuery.of(context).size.width * 0.80,
                      padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                      child: const Text(
                        "Porte do cachorro:",
                        style: TextStyle(
                          fontFamily: "Inter",
                          fontWeight: FontWeight.w800,
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.80,
                      child: DropdownButtonFormField<String>(
                        validator: (val) {
                          if (val == '- Selecione -') {
                            return 'Selecione uma opção!';
                          } else {
                            return null;
                          }
                        },
                        value: porteDropdown,
                        icon: const Icon(Icons.expand_more),
                        elevation: 16,
                        style: const TextStyle(
                            fontFamily: "Inter", color: Colors.black),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        focusColor: Colors.black,
                        onChanged: (String? newValue) {
                          setState(() {
                            porteDropdown = newValue!;
                          });
                        },
                        items: <String>[
                          '- Selecione -',
                          'Mini: até 6kg, até 33cm',
                          'Pequeno: de 6 a 15kg, até 43cm',
                          'Médio: de 15 a 25kg, até 60cm',
                          'Grande: de 25 a 45kg, até 70cm',
                          'Gigante: de 45 a 90kg, sem limite',
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                    Container(
                      alignment: Alignment.topLeft,
                      width: MediaQuery.of(context).size.width * 0.80,
                      padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                      child: const Text(
                        "Cor predominante:",
                        style: TextStyle(
                          fontFamily: "Inter",
                          fontWeight: FontWeight.w800,
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.80,
                      child: DropdownButtonFormField<String>(
                        validator: (val) {
                          if (val == '- Selecione -') {
                            return 'Selecione uma opção!';
                          } else {
                            return null;
                          }
                        },
                        value: corDropdown,
                        icon: const Icon(Icons.expand_more),
                        elevation: 16,
                        style: const TextStyle(
                            fontFamily: "Inter", color: Colors.black),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        focusColor: Colors.black,
                        onChanged: (String? newValue) {
                          setState(() {
                            corDropdown = newValue!;
                          });
                        },
                        items: <String>[
                          '- Selecione -',
                          'Branca',
                          'Preta',
                          'Dourada',
                          'Cinza',
                          'Marron',
                          'Vermelha',
                          'Creme'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                    Container(
                      alignment: Alignment.topLeft,
                      width: MediaQuery.of(context).size.width * 0.80,
                      padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                      child: const Text(
                        "Detalhes adicionais:",
                        style: TextStyle(
                          fontFamily: "Inter",
                          fontWeight: FontWeight.w800,
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.80,
                      child: TextField(
                        controller: detalhesController,
                        maxLines: 6,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          focusColor: Colors.black,
                          hintStyle: TextStyle(
                            fontSize: 12.0,
                            fontFamily: "Inter",
                            color: Color.fromARGB(100, 100, 100, 100),
                          ),
                          hintText:
                              "Fique a vontade para colocar informações adicionais, se o animal está aos seus cuidados...",
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.topLeft,
                      width: MediaQuery.of(context).size.width * 0.80,
                      padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                      child: const Text(
                        "Cidade:",
                        style: TextStyle(
                          fontFamily: "Inter",
                          fontWeight: FontWeight.w800,
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.80,
                      child: TextFormField(
                        validator: (val) {
                          if (val!.trim().length < 2 || val.isEmpty) {
                            return 'Nome de cidade muito curto!';
                          } else {
                            return null;
                          }
                        },
                        controller: cidadeController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          focusColor: Colors.black,
                          hintStyle: TextStyle(
                            fontSize: 12.0,
                            fontFamily: "Inter",
                            color: Color.fromARGB(100, 100, 100, 100),
                          ),
                          hintText: "Ex.: Campo Grande",
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.topLeft,
                      width: MediaQuery.of(context).size.width * 0.80,
                      padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                      child: const Text(
                        "Estado:",
                        style: TextStyle(
                          fontFamily: "Inter",
                          fontWeight: FontWeight.w800,
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.80,
                      child: TextFormField(
                        validator: (val) {
                          if (val!.trim().length < 2 || val.isEmpty) {
                            return 'Nome do estado muito curto!';
                          } else {
                            return null;
                          }
                        },
                        controller: estadoController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          focusColor: Colors.black,
                          hintStyle: TextStyle(
                            fontSize: 12.0,
                            fontFamily: "Inter",
                            color: Color.fromARGB(100, 100, 100, 100),
                          ),
                          hintText: "Ex.: Mato Grosso do Sul",
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                      child: Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.45,
                            alignment: Alignment.center,
                            child: ElevatedButton(
                              onPressed: cancelar,
                              style: ButtonStyle(
                                elevation: MaterialStateProperty.all(1),
                                padding: MaterialStateProperty.all(
                                    const EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 30.0)),
                                backgroundColor: MaterialStateProperty.all(
                                    const Color.fromARGB(255, 240, 240, 240)),
                              ),
                              child: const Text(
                                "Cancelar",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.normal,
                                  fontFamily: "Inter",
                                ),
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width * 0.45,
                            child: ElevatedButton(
                              onPressed: isUploading ? null : () => submit(),
                              style: ButtonStyle(
                                padding: MaterialStateProperty.all(
                                    const EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 50.0)),
                                backgroundColor: isUploading
                                    ? MaterialStateProperty.all(
                                        const Color.fromARGB(
                                            255, 225, 185, 201))
                                    : MaterialStateProperty.all(
                                        const Color.fromARGB(
                                            255, 208, 54, 106)),
                              ),
                              child: const Text(
                                "Postar",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: "Inter",
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            isUploading
                ? linearProgress()
                : const Text(
                    "",
                    style: TextStyle(fontSize: 0),
                  ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return file == null ? escolherFoto() : buildUploadForm();
  }
}
