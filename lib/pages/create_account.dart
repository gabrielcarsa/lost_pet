import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({Key? key}) : super(key: key);

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String? phoneNumber;
  final _formKey = GlobalKey<FormState>();

  var maskFormatter = MaskTextInputFormatter(
      mask: '+55 (##) #####-####',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);

  submit() {
    print("1a");
    final form = _formKey.currentState;
    if (form!.validate()) {
      form.save();
      // SnackBar snackbar = const SnackBar(content: Text("Conta criada com sucesso!"));
      //_scaffoldKey.currentState!.showSnackBar(snackbar);
      //Timer(const Duration(seconds: 2), () {
      Navigator.pop(context, phoneNumber);
      print("1");
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Container(
                      height: 150.0,
                      width: 150.0,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          image: const DecorationImage(
                            image: AssetImage("assets/images/logo.png"),
                            fit: BoxFit.cover,
                          ),
                          border: Border.all(color: Colors.black, width: 2.0),
                          borderRadius:
                              BorderRadiusDirectional.circular(100.0)),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 25.0, bottom: 15.0),
                    child: Center(
                      child: Text(
                        "Insira o número do\nseu celular",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 25.0,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                    child: Container(
                      child: Form(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.always,
                        child: Column(
                          children: [
                            TextFormField(
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
                              onSaved: (val) => phoneNumber = val,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Número de celular",
                                labelStyle: TextStyle(fontSize: 15.0),
                                hintText: "Insira seu número",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 10.0, bottom: 40.0),
                    child: Text(
                      "Ninguém poderá visualizar seu "
                      "número ao menos que na você sinalize em alguma publicação.",
                      style: TextStyle(
                        fontFamily: "Inter",
                        color: Color.fromARGB(210, 129, 133, 138),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: submit,
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 40,vertical: 15)),
                    ),
                    child: Text("Enviar", style: TextStyle(fontSize: 16),),
                  )
                  /*GestureDetector(
                    onTap: submit,
                    child: Container(
                      height: 50.0,
                      width: 350.0,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(
                            255, 208, 54, 106),
                        borderRadius: BorderRadius.circular(7.0),
                      ),
                      child: const Center(
                        child: Text(
                          "Enviar",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),*/
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
