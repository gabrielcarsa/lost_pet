
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lost_pet/pages/encontrados.dart';
import 'package:lost_pet/pages/home.dart';
import 'package:lost_pet/pages/perdidos.dart';
import 'package:lost_pet/widgets/progress.dart';

class TimelineNavegar extends StatefulWidget {
  final userId;

  const TimelineNavegar({Key? key, this.userId}) : super(key: key);

  @override
  State<TimelineNavegar> createState() => _TimelineState();
}

class _TimelineState extends State<TimelineNavegar> {
  List<Encontrados> encontrados = [];
  List<Perdidos> perdidos = [];
  bool isLoading = false;
  bool qualTimeline = true;
  TextEditingController racaController = TextEditingController();
  TextEditingController cidadeController = TextEditingController();
  TextEditingController estadoController = TextEditingController();
  TextEditingController corController = TextEditingController();
  String cidade = "";
  String estado = "";
  String raca = "";
  String cor = "";

  @override
  initState() {
    getEncontradosPost();
    getPerdidosPost();
    super.initState();
  }

  getPerdidosPost() async {
    setState(() {
      isLoading = true;
    });
    if (cidade != "" && estado != "" && raca != "" && cor != "") {
      QuerySnapshot snapshot = await timelinePerdidosRef
          .orderBy('timestamp', descending: true)
          .where('cidade', isEqualTo: cidade)
          .where('estado', isEqualTo: estado)
          .where('raca', isEqualTo: raca)
          .where('cor', isEqualTo: cor)
          .get();
      setState(() {
        isLoading = false;
        perdidos =
            snapshot.docs.map((doc) => Perdidos.fromDocument(doc)).toList();
      });
    } else if (cidade != "" && estado != "" && raca != "") {
      QuerySnapshot snapshot = await timelinePerdidosRef
          .orderBy('timestamp', descending: true)
          .where('cidade', isEqualTo: cidade)
          .where('estado', isEqualTo: estado)
          .where('raca', isEqualTo: raca)
          .get();
      setState(() {
        isLoading = false;
        perdidos =
            snapshot.docs.map((doc) => Perdidos.fromDocument(doc)).toList();
      });
    } else if (cidade != "" && estado != "") {
      QuerySnapshot snapshot = await timelinePerdidosRef
          .orderBy('timestamp', descending: true)
          .where('cidade', isEqualTo: cidade)
          .where('estado', isEqualTo: estado)
          .get();
      setState(() {
        isLoading = false;
        perdidos =
            snapshot.docs.map((doc) => Perdidos.fromDocument(doc)).toList();
      });
    } else if (cidade != "") {
      QuerySnapshot snapshot = await timelinePerdidosRef
          .orderBy('timestamp', descending: true)
          .where('cidade', isEqualTo: cidade)
          .get();
      setState(() {
        isLoading = false;
        perdidos =
            snapshot.docs.map((doc) => Perdidos.fromDocument(doc)).toList();
      });
    }else if (raca != "") {
      QuerySnapshot snapshot = await timelinePerdidosRef
          .orderBy('timestamp', descending: true)
          .where('raca', isEqualTo: raca)
          .get();
      setState(() {
        isLoading = false;
        perdidos =
            snapshot.docs.map((doc) => Perdidos.fromDocument(doc)).toList();
      });
    }else{
      QuerySnapshot snapshot =
      await timelinePerdidosRef.orderBy('timestamp', descending: true).get();
      setState(() {
        isLoading = false;
        perdidos =
            snapshot.docs.map((doc) => Perdidos.fromDocument(doc)).toList();
      });
    }

  }

  getEncontradosPost() async {
    setState(() {
      isLoading = true;
    });
    if (cidade != "" && estado != "" && raca != "" && cor != "") {
      QuerySnapshot snapshot = await timelineEncontradosRef
          .orderBy('timestamp', descending: true)
          .where('cidade', isEqualTo: cidade)
          .where('estado', isEqualTo: estado)
          .where('raca', isEqualTo: raca)
          .where('cor', isEqualTo: cor)
          .get();
      setState(() {
        isLoading = false;
        encontrados =
            snapshot.docs.map((doc) => Encontrados.fromDocument(doc)).toList();
      });
    } else if (cidade != "" && estado != "" && raca != "") {
      QuerySnapshot snapshot = await timelineEncontradosRef
          .orderBy('timestamp', descending: true)
          .where('cidade', isEqualTo: cidade)
          .where('estado', isEqualTo: estado)
          .where('raca', isEqualTo: raca)
          .get();
      setState(() {
        isLoading = false;
        encontrados =
            snapshot.docs.map((doc) => Encontrados.fromDocument(doc)).toList();
      });
    } else if (cidade != "" && estado != "") {
      QuerySnapshot snapshot = await timelineEncontradosRef
          .orderBy('timestamp', descending: true)
          .where('cidade', isEqualTo: cidade)
          .where('estado', isEqualTo: estado)
          .get();
      setState(() {
        isLoading = false;
        encontrados =
            snapshot.docs.map((doc) => Encontrados.fromDocument(doc)).toList();
      });
    } else if (cidade != "") {
      QuerySnapshot snapshot = await timelineEncontradosRef
          .orderBy('timestamp', descending: true)
          .where('cidade', isEqualTo: cidade)
          .get();
      setState(() {
        isLoading = false;
        encontrados =
            snapshot.docs.map((doc) => Encontrados.fromDocument(doc)).toList();
      });
    }else if (raca != "") {
      QuerySnapshot snapshot = await timelineEncontradosRef
          .orderBy('timestamp', descending: true)
          .where('raca', isEqualTo: raca)
          .get();
      setState(() {
        isLoading = false;
        encontrados =
            snapshot.docs.map((doc) => Encontrados.fromDocument(doc)).toList();
      });
    } else {
      QuerySnapshot snapshot = await timelineEncontradosRef
          .orderBy('timestamp', descending: true)
          .get();
      setState(() {
        isLoading = false;
        encontrados =
            snapshot.docs.map((doc) => Encontrados.fromDocument(doc)).toList();
      });
    }
  }

  buildTimelinePerdidos() {
    if (isLoading) {
      return circularProgress();
    } else if (perdidos.isEmpty) {
      return Container(
        color: const Color.fromARGB(255, 240, 240, 240),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Padding(
              padding: EdgeInsets.only(top: 100, bottom: 20),
              child: Icon(
                Icons.info_outline,
                size: 100,
                color: Color.fromARGB(255, 145, 139, 139),
              ),
            ),
            Text(
              "Sem resultados!",
              style: TextStyle(
                color: Colors.black,
                fontFamily: "Inter",
                fontWeight: FontWeight.w700,
                fontSize: 24.0,
              ),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 50),
              child: Text(
                "Não foram encontrados resultados :(",
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: "Inter",
                  fontSize: 16.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    } else {
      return Column(
        children: perdidos,
      );
    }
  }

  buildTimelineEncontrados() {
    if (isLoading) {
      return circularProgress();
    } else if (encontrados.isEmpty) {
      return Container(
        color: const Color.fromARGB(255, 240, 240, 240),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Padding(
              padding: EdgeInsets.only(top: 100, bottom: 20),
              child: Icon(
                Icons.info_outline,
                size: 100,
                color: Color.fromARGB(255, 145, 139, 139),
              ),
            ),
            Text(
              "Sem resultados!",
              style: TextStyle(
                color: Colors.black,
                fontFamily: "Inter",
                fontWeight: FontWeight.w700,
                fontSize: 24.0,
              ),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 50),
              child: Text(
                "Não foram encontrados resultados :(",
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: "Inter",
                  fontSize: 16.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    } else {
      return Column(
        children: encontrados,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 240, 240, 240),
        body: SafeArea(
          child: ListView(
            children: [
              Container(
                color: const Color.fromARGB(255, 227, 227, 227),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 100.0,
                          width: 100.0,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage("assets/images/logo.png"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Flexible(
                          child: Column(
                            children: const [
                              Padding(
                                padding: EdgeInsets.only(top: 10.0, left: 10.0),
                                child: Text(
                                  "Página Inicial",
                                  style: TextStyle(
                                    fontFamily: "Poppins",
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.0,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 10.0, left: 10.0),
                                child: Text(
                                  "Comunidade para ajudar a encontrar cachorros desaparecidos.",
                                  style: TextStyle(
                                    fontFamily: "Inter",
                                    fontSize: 12.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.50,
                          child: Container(
                            decoration: BoxDecoration(
                              border: qualTimeline
                                  ? const Border(
                                      bottom: BorderSide(
                                          color: Colors.black, width: 1))
                                  : const Border(),
                            ),
                            child: TextButton(
                              child: Text(
                                "Cachorros\nEncontrados",
                                style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontWeight: qualTimeline == true
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 16.0,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              onPressed: () {
                                setState(() {
                                  qualTimeline = true;
                                });
                              },
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.50,
                          child: Container(
                            decoration: BoxDecoration(
                              border: qualTimeline == false
                                  ? const Border(
                                      bottom: BorderSide(
                                          color: Colors.black, width: 1))
                                  : const Border(),
                            ),
                            child: TextButton(
                              child: Text(
                                "Cachorros\nPerdidos",
                                style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontSize: 16.0,
                                  fontWeight: qualTimeline == false
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              onPressed: () {
                                setState(() {
                                  qualTimeline = false;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              buildQualTimeline(),
            ],
          ),
        ),
      ),
    );
  }

  filtrar() {
    setState(() {
      cidade = cidadeController.text;
      estado = estadoController.text;
      raca = racaController.text;
      cor = corController.text;
    });
    if(qualTimeline){
      getEncontradosPost();
    }else{
      getPerdidosPost();
    }

  }

  buildQualTimeline() {
    if (qualTimeline == true) {
      //Encontrados
      return Column(
        children: [
          ExpansionTile(
            title: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.filter_alt),
                ),
                const Text(
                  "Filtrando por ",
                  style: TextStyle(
                    fontFamily: "Inter",
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
            children: [
              Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: TextFormField(
                      controller: cidadeController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        focusColor: Colors.black,
                        hintStyle: TextStyle(
                          fontSize: 12.0,
                          fontFamily: "Inter",
                          color: Color.fromARGB(100, 100, 100, 100),
                        ),
                        hintText: "Cidade",
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: TextFormField(
                      controller: estadoController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        focusColor: Colors.black,
                        hintStyle: TextStyle(
                          fontSize: 12.0,
                          fontFamily: "Inter",
                          color: Color.fromARGB(100, 100, 100, 100),
                        ),
                        hintText: "Estado",
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    height: 50,
                    child: TextFormField(
                      controller: racaController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        focusColor: Colors.black,
                        hintStyle: TextStyle(
                          fontSize: 12.0,
                          fontFamily: "Inter",
                          color: Color.fromARGB(100, 100, 100, 100),
                        ),
                        hintText: "Raça",
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: TextFormField(
                      controller: corController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        focusColor: Colors.black,
                        hintStyle: TextStyle(
                          fontSize: 12.0,
                          fontFamily: "Inter",
                          color: Color.fromARGB(100, 100, 100, 100),
                        ),
                        hintText: "Cor predominante",
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                width: MediaQuery.of(context).size.width * 1,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                child: TextButton(
                  onPressed: filtrar,
                  style: ButtonStyle(
                    backgroundColor: MaterialStateColor.resolveWith(
                        (states) => Colors.blueAccent),
                  ),
                  child: const Text(
                    "Filtrar",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 40,
            child: GridView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 15.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                childAspectRatio: 0.4,
              ),
              children: [
                Chip(
                  label: const Text('Cidade'),
                  backgroundColor: cidade != ""
                      ? const Color.fromARGB(95, 216, 78, 132)
                      : null,
                  onDeleted: cidade != ""
                      ? () {
                          setState(() {
                            cidade = "";
                          });
                          getEncontradosPost();
                        }
                      : null,
                ),
                Chip(
                  label: const Text('Raça'),
                  backgroundColor: raca != ""
                      ? const Color.fromARGB(95, 216, 78, 132)
                      : null,
                  onDeleted: raca != ""
                      ? () {
                          setState(() {
                            raca = "";
                          });
                          getEncontradosPost();
                        }
                      : null,
                ),
                Chip(
                  label: const Text('Estado'),
                  backgroundColor: estado != ""
                      ? const Color.fromARGB(95, 216, 78, 132)
                      : null,
                  onDeleted: estado != ""
                      ? () {
                          setState(() {
                            estado = "";
                          });
                          getEncontradosPost();
                        }
                      : null,
                ),
                Chip(
                  label: const Text('Cor predominante'),
                  backgroundColor:
                      cor != "" ? const Color.fromARGB(95, 216, 78, 132) : null,
                  onDeleted: cor != ""
                      ? () {
                          setState(() {
                            cor = "";
                          });
                          getEncontradosPost();
                        }
                      : null,
                ),
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 1,
            padding: const EdgeInsets.only(top: 10.0, left: 15.0),
            child: const Text(
              "Veja os cachorros que foram \nencontrados",
              style: TextStyle(
                fontFamily: "Inter",
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          ),
          buildTimelineEncontrados(),
        ],
      );
    } else if (qualTimeline == false) {
      return Column(
        children: [
          ExpansionTile(
            title: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.filter_alt),
                ),
                const Text(
                  "Filtrando por ",
                  style: TextStyle(
                    fontFamily: "Inter",
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
            children: [
              Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: TextFormField(
                      controller: cidadeController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        focusColor: Colors.black,
                        hintStyle: TextStyle(
                          fontSize: 12.0,
                          fontFamily: "Inter",
                          color: Color.fromARGB(100, 100, 100, 100),
                        ),
                        hintText: "Cidade",
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: TextFormField(
                      controller: estadoController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        focusColor: Colors.black,
                        hintStyle: TextStyle(
                          fontSize: 12.0,
                          fontFamily: "Inter",
                          color: Color.fromARGB(100, 100, 100, 100),
                        ),
                        hintText: "Estado",
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    height: 50,
                    child: TextFormField(
                      controller: racaController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        focusColor: Colors.black,
                        hintStyle: TextStyle(
                          fontSize: 12.0,
                          fontFamily: "Inter",
                          color: Color.fromARGB(100, 100, 100, 100),
                        ),
                        hintText: "Raça",
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: TextFormField(
                      controller: corController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        focusColor: Colors.black,
                        hintStyle: TextStyle(
                          fontSize: 12.0,
                          fontFamily: "Inter",
                          color: Color.fromARGB(100, 100, 100, 100),
                        ),
                        hintText: "Cor predominante",
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                width: MediaQuery.of(context).size.width * 1,
                padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                child: TextButton(
                  onPressed: filtrar,
                  style: ButtonStyle(
                    backgroundColor: MaterialStateColor.resolveWith(
                            (states) => Colors.blueAccent),
                  ),
                  child: const Text(
                    "Filtrar",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 40,
            child: GridView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 15.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                childAspectRatio: 0.4,
              ),
              children: [
                Chip(
                  label: const Text('Cidade'),
                  backgroundColor: cidade != ""
                      ? const Color.fromARGB(95, 216, 78, 132)
                      : null,
                  onDeleted: cidade != ""
                      ? () {
                    setState(() {
                      cidade = "";
                    });
                    getEncontradosPost();
                  }
                      : null,
                ),
                Chip(
                  label: const Text('Raça'),
                  backgroundColor: raca != ""
                      ? const Color.fromARGB(95, 216, 78, 132)
                      : null,
                  onDeleted: raca != ""
                      ? () {
                    setState(() {
                      raca = "";
                    });
                    getEncontradosPost();
                  }
                      : null,
                ),
                Chip(
                  label: const Text('Estado'),
                  backgroundColor: estado != ""
                      ? const Color.fromARGB(95, 216, 78, 132)
                      : null,
                  onDeleted: estado != ""
                      ? () {
                    setState(() {
                      estado = "";
                    });
                    getEncontradosPost();
                  }
                      : null,
                ),
                Chip(
                  label: const Text('Cor predominante'),
                  backgroundColor:
                  cor != "" ? const Color.fromARGB(95, 216, 78, 132) : null,
                  onDeleted: cor != ""
                      ? () {
                    setState(() {
                      cor = "";
                    });
                    getEncontradosPost();
                  }
                      : null,
                ),
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 1,
            padding: const EdgeInsets.only(top: 10.0, left: 15.0),
            child: const Text(
              "Veja os cachorros perdidos e\najude a acha-los ",
              style: TextStyle(
                fontFamily: "Inter",
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          ),
          buildTimelinePerdidos(),
        ],
      );
    }
  }
}
