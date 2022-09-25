import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lost_pet/pages/home.dart';
import 'package:lost_pet/widgets/progress.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../models/User/user.dart';

class Configuracoes extends StatefulWidget {
  final String currentUserId;

  const Configuracoes({Key? key, required this.currentUserId})
      : super(key: key);

  @override
  State<Configuracoes> createState() => _ConfiguracoesState();
}

class _ConfiguracoesState extends State<Configuracoes> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  User? user;
  TextEditingController phoneNumberController = TextEditingController();
  var maskFormatter = MaskTextInputFormatter(
      mask: '+55 (##) #####-####',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await usersRef.doc(widget.currentUserId).get();
    user = User.fromDocument(doc);
    phoneNumberController.text = user!.phoneNumber;
    setState(() {
      isLoading = false;
    });
  }

  updateProfile(){
    final form = _formKey.currentState;
    if (form!.validate()) {
      usersRef.doc(widget.currentUserId).update({
        "phoneNumber": phoneNumberController.text
      });
      SnackBar snackbar = SnackBar(content: Text("Número atualizado!"));
      _scaffoldKey.currentState?.showSnackBar(snackbar);
    }
  }

  logout() async{
    await googleSignIn.signOut();
    Navigator.push(context, MaterialPageRoute(builder: (context) => const Home()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 240, 240, 240),
        foregroundColor: Colors.black,
        title: const Text(
          "Configurações",
          style: TextStyle(
            color: Colors.black,
            fontFamily: "Inter",
            fontWeight: FontWeight.w700,
            fontSize: 20.0,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.check,
              size: 30.0,
              color: Colors.green,
            ),
          ),
        ],
      ),
      body: isLoading
          ? circularProgress()
          : Container(
              color: const Color.fromARGB(255, 240, 240, 240),
              child: ListView(
                children: [
                  Container(
                    child: Column(
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 15.0, bottom: 10.0),
                          child: CircleAvatar(
                            radius: 50.0,
                            backgroundImage:
                                CachedNetworkImageProvider(user!.photoUrl),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(15.0),
                          child: Container(
                            child: Form(
                              key: _formKey,
                              autovalidateMode: AutovalidateMode.always,
                              child: TextFormField(
                                controller: phoneNumberController,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [maskFormatter],
                                validator: (val) {
                                  if (val!.trim().length < 19 || val.isEmpty) {
                                    return 'Número de telefone muito curto';
                                  } else if (val.trim().length > 20) {
                                    return 'Número de telefone muito longo';
                                  } else {
                                    return null;
                                  }
                                },
                                //onSaved: (val) => phoneNumber = val,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: "Número de celular",
                                  labelStyle: TextStyle(fontSize: 15.0),
                                  hintText: "Insira seu número",
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.92,
                          height: 50.0,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.refresh),
                            onPressed: updateProfile,
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  const Color.fromARGB(255, 208, 54, 106)),
                            ),
                            label: const Text(
                              "Atualizar dados",
                              style: TextStyle(
                                fontFamily: "Inter",
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          child: TextButton(
                            onPressed: logout,
                            child: const Text(
                              "Sair da conta",
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: "Inter",
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
