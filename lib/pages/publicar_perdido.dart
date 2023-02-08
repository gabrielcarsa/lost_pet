import 'dart:io';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as Im;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../models/User/user.dart';
import '../widgets/progress.dart';
import 'home.dart';

class PublicarPerdido extends StatefulWidget {
  final User? currentUser;

  const PublicarPerdido({Key? key, required this.currentUser})
      : super(key: key);

  @override
  State<PublicarPerdido> createState() => _PublicarPerdidoState();
}

class _PublicarPerdidoState extends State<PublicarPerdido> {
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
  TextEditingController bairroController = TextEditingController();
  TextEditingController recompensaController = TextEditingController();
  TextEditingController desaparecimentoController = TextEditingController();
  int passo = 2;

  var maskFormatterDate = MaskTextInputFormatter(
      mask: '##/##/####',
      filter: {"#": RegExp(r'[0-8]')},
      type: MaskAutoCompletionType.lazy);

  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();

  Map<int, String> sinalizar = Map();

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
              "Publicar cachorro perdido",
              style:
                  TextStyle(fontFamily: "Inter", fontWeight: FontWeight.w800),
            ),
            children: [
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
                    "Perdeu seu dog?",
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
                  "Vamos te ajudar! Publique a imagem do seu cachorro que se perdeu com algumas informações para que a comunidade possa te ajudar.",
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
      passo = 2;
      file = null;
    });
  }

  //Upload Image
  Future<String> uploadImage(imageFile) async {
    UploadTask uploadTask =
        storageRef.child("perdido_$postId.jpg").putFile(File(imageFile.path));
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
      required String bairro,
      required String recompensa,
      required String desaparecimento,
      required String estado,
      required Map sinalizar}) {
    perdidosRef
        .doc(widget.currentUser?.id)
        .collection("userPerdidos")
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
      "sinalizar": sinalizar,
      "recompensa": recompensa,
      "bairro": bairro,
      "desaparecimento": desaparecimento,
    });

    timelinePerdidosRef.doc(postId).set({
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
      "sinalizar": sinalizar,
      "recompensa": recompensa,
      "bairro": bairro,
      "desaparecimento": desaparecimento,
    });
  }

  //Submeter
  submit() async {
    final form1 = _formKey1.currentState;
    final form2 = _formKey2.currentState;
    final form3 = _formKey3.currentState;

    if (passo == 2) {
      if (form1!.validate()) {
        setState(() {
          passo++;
        });
      }
    } else if (passo == 3) {
      if (form2!.validate()) {
        setState(() {
          passo++;
        });
      }
    } else {
      if (form3!.validate()) {
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
            sinalizar: sinalizar,
            recompensa: recompensaController.text,
            bairro: bairroController.text,
            desaparecimento: desaparecimentoController.text);
        setState(() {
          file = null;
          isUploading = false;
          postId = Uuid().v4();
        });
      }
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

  corEtapa(int etapa) {
    if (passo == etapa) {
      return Color.fromARGB(255, 215, 97, 142);
    } else if (passo < etapa) {
      return Colors.black12;
    } else {
      return Color.fromARGB(255, 224, 171, 190);
    }
  }

  Scaffold buildUploadFormCachorro() {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 1,
              color: const Color.fromARGB(255, 240, 240, 240),
              padding: const EdgeInsets.only(
                  left: 15.0, top: 20.0, bottom: 30.0, right: 15.0),
              child: Form(
                key: _formKey1,
                autovalidateMode: AutovalidateMode.always,
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.topLeft,
                      child: const Text(
                        "Próximo Passo.",
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
                        "Preencha algumas informações para te ajudarmos.",
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.normal,
                          fontFamily: "Inter",
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Passo $passo de 4",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Color.fromARGB(255, 208, 54, 106),
                          fontFamily: "Inter",
                          fontWeight: FontWeight.w800,
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                    Container(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            margin: const EdgeInsets.only(right: 5),
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              color: corEtapa(1),
                            ),
                            child: Center(
                              child: Text(
                                "Foto \nselecionada",
                                style: TextStyle(
                                  fontFamily: "Inter",
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            margin: const EdgeInsets.only(right: 5),
                            height: 50,
                            decoration: BoxDecoration(
                              boxShadow: passo == 2
                                  ? [
                                      BoxShadow(
                                        color: Color.fromARGB(255, 84, 84, 84),
                                        offset: const Offset(
                                          1.0,
                                          2.0,
                                        ),
                                        blurRadius: 2.0,
                                        spreadRadius: 1.0,
                                      )
                                    ]
                                  : [],
                              borderRadius: BorderRadius.circular(3),
                              color: corEtapa(2),
                            ),
                            child: Center(
                              child: Text(
                                "Sobre o \ncachorro",
                                style: TextStyle(
                                  fontFamily: "Inter",
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            margin: const EdgeInsets.only(right: 5),
                            height: 50,
                            decoration: BoxDecoration(
                              boxShadow: passo == 3
                                  ? [
                                      BoxShadow(
                                        color: Color.fromARGB(255, 84, 84, 84),
                                        offset: const Offset(
                                          1.0,
                                          2.0,
                                        ),
                                        blurRadius: 2.0,
                                        spreadRadius: 1.0,
                                      )
                                    ]
                                  : [],
                              borderRadius: BorderRadius.circular(3),
                              color: corEtapa(3),
                            ),
                            child: Center(
                              child: Text(
                                "Localidade \nAproximada",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: "Inter",
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            margin: const EdgeInsets.only(right: 5),
                            height: 50,
                            decoration: BoxDecoration(
                              boxShadow: passo == 4
                                  ? [
                                      BoxShadow(
                                        color: Color.fromARGB(255, 84, 84, 84),
                                        offset: const Offset(
                                          1.0,
                                          2.0,
                                        ),
                                        blurRadius: 2.0,
                                        spreadRadius: 1.0,
                                      )
                                    ]
                                  : [],
                              borderRadius: BorderRadius.circular(3),
                              color: corEtapa(4),
                            ),
                            child: Center(
                              child: Text(
                                "Outros",
                                style: TextStyle(
                                  fontFamily: "Inter",
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
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
                              onPressed: () => submit(),
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
                                "Próximo",
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

  Scaffold buildUploadFormLocalidade() {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 1,
              color: const Color.fromARGB(255, 240, 240, 240),
              padding: const EdgeInsets.only(
                  left: 15.0, top: 20.0, bottom: 30.0, right: 15.0),
              child: Form(
                key: _formKey2,
                autovalidateMode: AutovalidateMode.always,
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.topLeft,
                      child: const Text(
                        "Próximo Passo.",
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
                        "Preencha algumas informações para te ajudarmos.",
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.normal,
                          fontFamily: "Inter",
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Passo $passo de 4",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Color.fromARGB(255, 208, 54, 106),
                          fontFamily: "Inter",
                          fontWeight: FontWeight.w800,
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                    Container(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            margin: const EdgeInsets.only(right: 5),
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              color: corEtapa(1),
                            ),
                            child: Center(
                              child: Text(
                                "Foto \nselecionada",
                                style: TextStyle(
                                  fontFamily: "Inter",
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            margin: const EdgeInsets.only(right: 5),
                            height: 50,
                            decoration: BoxDecoration(
                              boxShadow: passo == 2
                                  ? [
                                      BoxShadow(
                                        color: Color.fromARGB(255, 84, 84, 84),
                                        offset: const Offset(
                                          1.0,
                                          2.0,
                                        ),
                                        blurRadius: 2.0,
                                        spreadRadius: 1.0,
                                      )
                                    ]
                                  : [],
                              borderRadius: BorderRadius.circular(3),
                              color: corEtapa(2),
                            ),
                            child: Center(
                              child: Text(
                                "Sobre o \ncachorro",
                                style: TextStyle(
                                  fontFamily: "Inter",
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            margin: const EdgeInsets.only(right: 5),
                            height: 50,
                            decoration: BoxDecoration(
                              boxShadow: passo == 3
                                  ? [
                                      BoxShadow(
                                        color: Color.fromARGB(255, 84, 84, 84),
                                        offset: const Offset(
                                          1.0,
                                          2.0,
                                        ),
                                        blurRadius: 2.0,
                                        spreadRadius: 1.0,
                                      )
                                    ]
                                  : [],
                              borderRadius: BorderRadius.circular(3),
                              color: corEtapa(3),
                            ),
                            child: Center(
                              child: Text(
                                "Localidade \nAproximada",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: "Inter",
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            margin: const EdgeInsets.only(right: 5),
                            height: 50,
                            decoration: BoxDecoration(
                              boxShadow: passo == 4
                                  ? [
                                      BoxShadow(
                                        color: Color.fromARGB(255, 84, 84, 84),
                                        offset: const Offset(
                                          1.0,
                                          2.0,
                                        ),
                                        blurRadius: 2.0,
                                        spreadRadius: 1.0,
                                      )
                                    ]
                                  : [],
                              borderRadius: BorderRadius.circular(3),
                              color: corEtapa(4),
                            ),
                            child: Center(
                              child: Text(
                                "Outros",
                                style: TextStyle(
                                  fontFamily: "Inter",
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
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
                    Container(
                      alignment: Alignment.topLeft,
                      width: MediaQuery.of(context).size.width * 0.80,
                      padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                      child: const Text(
                        "Bairro:",
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
                        controller: bairroController,
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
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                      child: Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.45,
                            alignment: Alignment.center,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  passo--;
                                });
                              },
                              style: ButtonStyle(
                                elevation: MaterialStateProperty.all(1),
                                padding: MaterialStateProperty.all(
                                    const EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 30.0)),
                                backgroundColor: MaterialStateProperty.all(
                                    const Color.fromARGB(255, 240, 240, 240)),
                              ),
                              child: const Text(
                                "Voltar",
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
                              onPressed: () => submit(),
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
                                "Próximo",
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

  Scaffold buildUploadFormOutros() {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 1,
              color: const Color.fromARGB(255, 240, 240, 240),
              padding: const EdgeInsets.only(
                  left: 15.0, top: 20.0, bottom: 30.0, right: 15.0),
              child: Form(
                key: _formKey3,
                autovalidateMode: AutovalidateMode.always,
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.topLeft,
                      child: const Text(
                        "Próximo Passo.",
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
                        "Preencha algumas informações para te ajudarmos.",
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.normal,
                          fontFamily: "Inter",
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Passo $passo de 4",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Color.fromARGB(255, 208, 54, 106),
                          fontFamily: "Inter",
                          fontWeight: FontWeight.w800,
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                    Container(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            margin: const EdgeInsets.only(right: 5),
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              color: corEtapa(1),
                            ),
                            child: Center(
                              child: Text(
                                "Foto \nselecionada",
                                style: TextStyle(
                                  fontFamily: "Inter",
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            margin: const EdgeInsets.only(right: 5),
                            height: 50,
                            decoration: BoxDecoration(
                              boxShadow: passo == 2
                                  ? [
                                      BoxShadow(
                                        color: Color.fromARGB(255, 84, 84, 84),
                                        offset: const Offset(
                                          1.0,
                                          2.0,
                                        ),
                                        blurRadius: 2.0,
                                        spreadRadius: 1.0,
                                      )
                                    ]
                                  : [],
                              borderRadius: BorderRadius.circular(3),
                              color: corEtapa(2),
                            ),
                            child: Center(
                              child: Text(
                                "Sobre o \ncachorro",
                                style: TextStyle(
                                  fontFamily: "Inter",
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            margin: const EdgeInsets.only(right: 5),
                            height: 50,
                            decoration: BoxDecoration(
                              boxShadow: passo == 3
                                  ? [
                                      BoxShadow(
                                        color: Color.fromARGB(255, 84, 84, 84),
                                        offset: const Offset(
                                          1.0,
                                          2.0,
                                        ),
                                        blurRadius: 2.0,
                                        spreadRadius: 1.0,
                                      )
                                    ]
                                  : [],
                              borderRadius: BorderRadius.circular(3),
                              color: corEtapa(3),
                            ),
                            child: Center(
                              child: Text(
                                "Localidade \nAproximada",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: "Inter",
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            margin: const EdgeInsets.only(right: 5),
                            height: 50,
                            decoration: BoxDecoration(
                              boxShadow: passo == 4
                                  ? [
                                      BoxShadow(
                                        color: Color.fromARGB(255, 84, 84, 84),
                                        offset: const Offset(
                                          1.0,
                                          2.0,
                                        ),
                                        blurRadius: 2.0,
                                        spreadRadius: 1.0,
                                      )
                                    ]
                                  : [],
                              borderRadius: BorderRadius.circular(3),
                              color: corEtapa(4),
                            ),
                            child: Center(
                              child: Text(
                                "Outros",
                                style: TextStyle(
                                  fontFamily: "Inter",
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      alignment: Alignment.topLeft,
                      width: MediaQuery.of(context).size.width * 0.80,
                      padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                      child: const Text(
                        "Recompensa (R\$):",
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
                        keyboardType: TextInputType.number,
                        controller: recompensaController,
                        inputFormatters: [
                          CurrencyTextInputFormatter(
                            locale: 'br',
                            decimalDigits: 2,
                            symbol: 'R\$',
                          ),
                        ],
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          focusColor: Colors.black,
                          hintStyle: TextStyle(
                            fontSize: 12.0,
                            fontFamily: "Inter",
                            color: Color.fromARGB(100, 100, 100, 100),
                          ),
                          hintText: "Ex.: 100,00",
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.topLeft,
                      width: MediaQuery.of(context).size.width * 0.80,
                      padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                      child: const Text(
                        "Data do desaparecimento:",
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
                        keyboardType: TextInputType.datetime,
                        controller: desaparecimentoController,
                        inputFormatters: [maskFormatterDate],
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          focusColor: Colors.black,
                          hintStyle: TextStyle(
                            fontSize: 12.0,
                            fontFamily: "Inter",
                            color: Color.fromARGB(100, 100, 100, 100),
                          ),
                          hintText: "Ex.: 20/11/2022",
                        ),
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
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                      child: Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.45,
                            alignment: Alignment.center,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  passo--;
                                });
                              },
                              style: ButtonStyle(
                                elevation: MaterialStateProperty.all(1),
                                padding: MaterialStateProperty.all(
                                    const EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 30.0)),
                                backgroundColor: MaterialStateProperty.all(
                                    const Color.fromARGB(255, 240, 240, 240)),
                              ),
                              child: const Text(
                                "Voltar",
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

  buildFormEtapa() {
    if (passo == 2) {
      return buildUploadFormCachorro();
    } else if (passo == 3) {
      return buildUploadFormLocalidade();
    } else {
      return buildUploadFormOutros();
    }
  }

  @override
  Widget build(BuildContext context) {
    return file == null ? escolherFoto() : buildFormEtapa();
  }
}
