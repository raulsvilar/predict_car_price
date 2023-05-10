import 'dart:async';

import 'package:car_price/js_controller.dart';
import 'package:flutter/material.dart';
import 'package:js/js_util.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Comparauto',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(
          title: 'A análise de dados  que auxilia na precificação de veículos'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<void> loadingPython;
  int tipoCarro = -1;
  int transmissao = -1;
  int cilindros = -1;

  final TextEditingController _potenciaController = TextEditingController();
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _alturaController = TextEditingController();
  final TextEditingController _lugaresController = TextEditingController();
  final TextEditingController _portasController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Future<void> initPython() async {
    await promiseToFuture(loadPython());
    var result = await promiseToFuture(getMappedCodes());
    return result;
  }

  FutureOr<double> calcularPreco(List<dynamic> valores) async {
    return await promiseToFuture(predictPrice(valores));
  }

  @override
  void initState() {
    loadingPython = initPython();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder(
          future: loadingPython,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading Python'));
            }
            if (snapshot.hasData) {
              final Map<String, dynamic> data =
                  const JsonDecoder().convert(snapshot.data as String);
              final tipoCarroItems = (data["Body type"] as Map<String, dynamic>)
                  .entries
                  .map((item) => DropdownMenuItem<int>(
                      value: item.value,
                      child: Text(
                        item.value == -1
                            ? "Selecione o tipo do carro"
                            : item.key,
                        overflow: TextOverflow.ellipsis,
                      )))
                  .toList();
              final transmissaoItems =
                  (data["Transmission"] as Map<String, dynamic>)
                      .entries
                      .map((item) => DropdownMenuItem<int>(
                          value: item.value,
                          child: Text(
                            item.value == -1
                                ? "Selecione o tipo da transmissão"
                                : item.key,
                            overflow: TextOverflow.ellipsis,
                          )))
                      .toList();
              final cilindrosItems = (data["Cylinders"] as Map<String, dynamic>)
                  .entries
                  .map((item) => DropdownMenuItem<int>(
                      value: item.value,
                      child: Text(
                        item.value == -1
                            ? "Selecione a quantidade e o tipo de cilindro"
                            : item.key,
                        overflow: TextOverflow.ellipsis,
                      )))
                  .toList();
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        InputDecorator(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.all(4),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: ButtonTheme(
                              alignedDropdown: true,
                              child: DropdownButtonFormField<int>(
                                validator: (value) {
                                  if (value == null || value == -1) {
                                    return 'Selecione um valor';
                                  }
                                  return null;
                                },
                                isExpanded: true,
                                items: tipoCarroItems,
                                value: tipoCarro,
                                onChanged: (int? value) {
                                  setState(() {
                                    tipoCarro = value!;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        InputDecorator(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.all(4),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: ButtonTheme(
                              alignedDropdown: true,
                              child: DropdownButtonFormField<int>(
                                validator: (value) {
                                  if (value == null || value == -1) {
                                    return 'Selecione um valor';
                                  }
                                  return null;
                                },
                                isExpanded: true,
                                items: transmissaoItems,
                                value: transmissao,
                                onChanged: (int? value) {
                                  setState(() {
                                    transmissao = value!;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        InputDecorator(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.all(4),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: ButtonTheme(
                              alignedDropdown: true,
                              child: DropdownButtonFormField<int>(
                                validator: (value) {
                                  if (value == null || value == -1) {
                                    return 'Selecione um valor';
                                  }
                                  return null;
                                },
                                isExpanded: true,
                                items: cilindrosItems,
                                value: cilindros,
                                onChanged: (int? value) {
                                  setState(() {
                                    cilindros = value!;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _potenciaController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Preencha o campo';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Digite a potencia do motor (cv)',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _portasController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Preencha o campo';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Digite a quantidade de portas',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _lugaresController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Preencha o campo';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Digite quantos a quantidade de lugares',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _pesoController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Preencha o campo';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Digite o peso em ordem de marcha (kg)',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _alturaController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Preencha o campo';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Digite altura do solo (cm)',
                          ),
                        ),
                        const SizedBox(height: 16),
                        IntrinsicWidth(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                final List<dynamic> inputs = [
                                  transmissao,
                                  _portasController.text,
                                  tipoCarro,
                                  _lugaresController.text,
                                  cilindros,
                                  _alturaController.text,
                                  _pesoController.text,
                                  _potenciaController.text,
                                ];
                                final valor = await calcularPreco(inputs);
                                final snackBar = SnackBar(
                                  content: Text(
                                      'O valor do carro é de US\$ ${valor.toStringAsFixed(2)}'),
                                  action: SnackBarAction(
                                    label: 'Fechar',
                                    onPressed: () {
                                      ScaffoldMessenger.of(context)
                                          .hideCurrentSnackBar();
                                    },
                                  ),
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              }
                            },
                            child: const Text(
                              'Calcular',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          }),
    );
  }
}
