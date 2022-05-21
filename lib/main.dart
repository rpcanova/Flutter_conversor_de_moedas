import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

var request = Uri.https('api.hgbrasil.com', '/finance');

void main() async {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
      theme: ThemeData(
        hintColor: Colors.green,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green),
          ),
          hintStyle: TextStyle(color: Colors.green),
        ),
      ),
    ),
  );
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double? dolar;
  double? euro;

  String _realChanged(String texto) {
    double real = double.parse(texto);
    dolarController.text = (real / dolar!).toStringAsFixed(2);
    euroController.text = (real / euro!).toStringAsFixed(2);
    return '';
  }

  String _dolarChanged(String texto) {
    double _dolar = double.parse(texto);
    realController.text = (_dolar * dolar!).toStringAsFixed(2);
    euroController.text = (_dolar * dolar! / euro!).toStringAsFixed(2);
    return '';
  }

  String _euroChanged(String texto) {
    double _euro = double.parse(texto);
    realController.text = (_euro * euro!).toStringAsFixed(2);
    dolarController.text = (_euro * euro! / dolar!).toStringAsFixed(2);
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Conversor de Moedas"),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
          future: pegarDados(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: Text(
                    "Carregando dados...",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 25,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              default:
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Erro ao Carregar os Dados",
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 25,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else {
                  dolar = snapshot.data!["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data!["results"]["currencies"]["EUR"]["buy"];
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 40),
                        Icon(
                          Icons.monetization_on,
                          size: 150,
                          color: Colors.green,
                        ),
                        const SizedBox(height: 60),
                        construirTextField(
                            "Reais", "R\$", realController, _realChanged),
                        const SizedBox(height: 40),
                        construirTextField(
                            "Dólares", "US\$", dolarController, _dolarChanged),
                        const SizedBox(height: 40),
                        construirTextField(
                            "Euros", "€", euroController, _euroChanged),
                      ],
                    ),
                  );
                }
            }
          }),
    );
  }
}

Future<Map> pegarDados() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

Widget construirTextField(
    String texto, String prefixo, TextEditingController c, Function(String) f) {
  return TextField(
    controller: c,
    decoration: InputDecoration(
      labelText: texto,
      labelStyle: TextStyle(color: Colors.green),
      border: OutlineInputBorder(),
      prefixText: prefixo,
    ),
    style: TextStyle(
      color: Colors.green,
      fontSize: 25,
    ),
    onChanged: f,
    keyboardType: TextInputType.number,
  );
}
