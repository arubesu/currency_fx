import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const apiKey = "";
const api = "https://api.hgbrasil.com/finance?format=json&key=$apiKey";
void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
        primaryColor: Colors.white,
        primaryColorDark: Colors.white,
        hintColor: Colors.amber),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(Uri.parse(api));
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var currencies;
  var usdQuotation;
  var eurQuotation;

  var realController = TextEditingController();
  var dollarController = TextEditingController();
  var euroController = TextEditingController();

  void _onRealChanged(String text) {
    var real = double.parse(text);
    dollarController.text = (real / this.usdQuotation).toStringAsFixed(2);
    euroController.text = (real / this.eurQuotation).toStringAsFixed(2);
  }

  void _onDollarChanged(String text) {
    var dollar = double.parse(text);
    realController.text = (dollar * this.usdQuotation).toStringAsFixed(2);
    euroController.text =
        (dollar * this.usdQuotation / this.eurQuotation).toStringAsFixed(2);
  }

  void _onEuroChanged(String text) {
    var euro = double.parse(text);
    realController.text = (euro * this.eurQuotation).toStringAsFixed(2);
    dollarController.text =
        (euro * this.eurQuotation / this.usdQuotation).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black87,
        appBar: AppBar(
            title: Text("Converter"),
            backgroundColor: Colors.amber,
            centerTitle: true),
        body: FutureBuilder<Map>(
            future: getData(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Center(
                    child: Text("Loading prices ...",
                        style: TextStyle(color: Colors.amber, fontSize: 25),
                        textAlign: TextAlign.center),
                  );
                default:
                  if (snapshot.hasError) {
                    return Center(
                      child: Text("Failed to load prices =( ...",
                          style: TextStyle(color: Colors.amber, fontSize: 25),
                          textAlign: TextAlign.center),
                    );
                  } else {
                    currencies = snapshot.data["results"]["currencies"];
                    usdQuotation = currencies["USD"]["buy"];
                    eurQuotation = currencies["EUR"]["buy"];

                    return SingleChildScrollView(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Icon(Icons.monetization_on,
                                size: 150, color: Colors.amber),
                            buildTextField(
                                label: "Reais",
                                prefix: "R\$ ",
                                controller: realController,
                                onChanged: _onRealChanged),
                            Divider(),
                            buildTextField(
                                label: "Dollars",
                                prefix: "US\$ ",
                                controller: dollarController,
                                onChanged: _onDollarChanged),
                            Divider(),
                            buildTextField(
                                label: "Euro",
                                prefix: "€ ",
                                controller: euroController,
                                onChanged: _onEuroChanged),
                          ],
                        ));
                  }
              }
            }));
  }
}

Widget buildTextField(
    {String label,
    String prefix,
    TextEditingController controller,
    Function onChanged}) {
  return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.amber),
          border: OutlineInputBorder(),
          prefixText: prefix),
      style: TextStyle(color: Colors.amber, fontSize: 25),
      onChanged: onChanged);
}
