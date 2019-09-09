import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const API_KEY = "18abeb74";

const request =
    "https://api.hgbrasil.com/finance/quotations?format=json&key=$API_KEY";

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(hintColor: Colors.amber, primaryColor: Colors.white),
    debugShowCheckedModeBanner: false,
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double real;
  double dolar;
  double euro;
  double libra;
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();
  final libraController = TextEditingController();

  void _realChanged(String txt) {
    if (realController.text.isEmpty) {
      dolarController.text = "";
      euroController.text = "";
      libraController.text = "";
    } else {
    double real = double.parse(txt);
    dolarController.text = (real / this.dolar).toStringAsFixed(2);
    euroController.text = (real / this.euro).toStringAsFixed(2);
    libraController.text = (real / this.libra).toStringAsFixed(2);
    }
  }

  void _dolarChanged(String txt) {
    if (dolarController.text.isEmpty) {
      realController.text = "";
      euroController.text = "";
      libraController.text = "";
    } else {
    double dolar = double.parse(txt);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = ((dolar * this.dolar) / this.euro).toStringAsFixed(2);
    libraController.text =
        ((dolar * this.dolar) / this.libra).toStringAsFixed(2);
    }
  }

  void _euroChanged(String txt) {
    if (euroController.text.isEmpty) {
      realController.text = "";
      dolarController.text = "";
      libraController.text = "";
    } else {
    double euro = double.parse(txt);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = ((euro * this.euro) / this.dolar).toStringAsFixed(2);
    libraController.text = ((euro * this.euro) / this.libra).toStringAsFixed(2);
    }
  }

  void _libraChanged(String txt) {
    if (libraController.text.isEmpty) {
      realController.text = "";
      dolarController.text = "";
      euroController.text = "";
    } else {
    double libra = double.parse(txt);
    realController.text = (libra * this.libra).toStringAsFixed(2);
    dolarController.text = ((libra * this.libra) / this.dolar).toStringAsFixed(2);
    euroController.text = ((libra * this.libra) / this.euro).toStringAsFixed(2);
    }
  }

  void _resetFields() {
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
    libraController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("\$ Converter \$"),
        centerTitle: true,
        backgroundColor: Colors.amber,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _resetFields,
          )
        ],
      ),
      body: FutureBuilder<Map>(
          future: getCurrencies(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                    child: Text(
                  "Carregando dados...",
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 25.0,
                  ),
                  textAlign: TextAlign.center,
                ));
              default:
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Erro ao carregar dados :(",
                      style: TextStyle(color: Colors.amber, fontSize: 25.0),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else {
                  dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                  libra = snapshot.data["results"]["currencies"]["GBP"]["buy"];

                  return SingleChildScrollView(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Icon(
                            Icons.monetization_on,
                            size: 150,
                            color: Colors.amber,
                          ),
                          Divider(),
                          buildTextField(
                              "Reais", "R\$ ", realController, _realChanged),
                          Divider(),
                          buildTextField("Dólares", "US\$ ", dolarController,
                              _dolarChanged),
                          Divider(),
                          buildTextField(
                              "Euros", "€ ", euroController, _euroChanged),
                          Divider(),
                          buildTextField(
                              "Libras", "£ ", libraController, _libraChanged)
                        ],
                      ));
                }
            }
          }),
    );
  }
}

Widget buildTextField(
    String label, String prefix, TextEditingController controller, Function f) {
  return TextField(
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber),
        border: OutlineInputBorder(),
        prefixText: prefix),
    style: TextStyle(color: Colors.amber, fontSize: 25),
    keyboardType: TextInputType.number,
    controller: controller,
    onChanged: f,
  );
}

Future<Map> getCurrencies() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}
