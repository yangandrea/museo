  import 'dart:convert';

  import 'package:camera/camera.dart';
  import 'package:flutter/material.dart';
  import 'package:http/http.dart' as http;
  import 'package:permission_handler/permission_handler.dart';
  import 'package:qr_code_scanner/qr_code_scanner.dart';
  import 'package:qr_flutter/qr_flutter.dart';
  import 'package:fluttertoast/fluttertoast.dart';

    void main() {
    runApp(const MuseoApp());
  }

  class PrenotazionePage extends StatelessWidget {


    const PrenotazionePage({super.key,
      required this.nome,
      required this.cognome,
      required this.email,
      required this.orario,
      required this.museo,
    });
    final String nome;
    final String cognome;
    final String email;
    final String orario;
    final String museo;


    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
        ),
        body: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nome: $nome',
                style: const TextStyle(fontSize: 18.0),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Cognome: $cognome',
                style: const TextStyle(fontSize: 18.0),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Email: $email',
                style: const TextStyle(fontSize: 18.0),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Orario: $orario',
                style: const TextStyle(fontSize: 18.0),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Museo: $museo',
                style: const TextStyle(fontSize: 18.0),
              ),
            ],
          ),
        ),
      );
    }
  }
  class MuseoApp extends StatelessWidget {
    const MuseoApp({super.key});

    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        title: 'Museo Prenotazione',
        theme: ThemeData(
          primarySwatch: Colors.purple,
        ),
        home: const MuseoHomePage(),
      );
    }
  }


  class MuseoHomePage extends StatefulWidget {
    const MuseoHomePage({super.key});

    @override
    _MuseoHomePageState createState() => _MuseoHomePageState();
  }


  class _MuseoHomePageState extends State<MuseoHomePage> {
    bool _isPurchaseComplete = false;
    String _qrData = '';
    String nome = ' ';
    String cognome = ' ';
    String email = ' ';
    String orario = ' ';
    String museo = ' ';
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final TextEditingController _nomeController = TextEditingController();
    final TextEditingController _cognomeController = TextEditingController();
    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _orarioController = TextEditingController();
    final TextEditingController _museoController = TextEditingController();



    @override
    void dispose() {
      _nomeController.dispose();
      _cognomeController.dispose();
      _emailController.dispose();
      _orarioController.dispose();
      _museoController.dispose();
      super.dispose();
    }
    Future<void> _requestCameraPermission() async {
      final PermissionStatus status = await Permission.camera.request();
      if (status.isGranted) {
        // Il permesso è stato concesso, puoi aprire la fotocamera
      } else {
        // Il permesso non è stato concesso, mostra un messaggio all'utente o gestisci la situazione di conseguenza
      }
    }
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Museo Prenotazione',
            textAlign: TextAlign.center,
          ),
          centerTitle: true,
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/R.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 16.0),
                  if (!_isPurchaseComplete)
                    ElevatedButton(
                      onPressed: _buyTicketButtonPressed,
                      child: const Text('Acquista un biglietto'),
                    ),
                  if (!_isPurchaseComplete) // Added condition to hide buttons
                    ElevatedButton(
                      onPressed: _scanQRCode,
                      child: const Text('Leggi QR'),
                    ),
                  if (!_isPurchaseComplete) // Added condition to hide buttons
                    ElevatedButton(
                      onPressed: () {
                        _requestCameraPermission();
                      },
                      child: const Text('Open Camera'),
                    ),
                  if (_isPurchaseComplete)
                    Column(
                      children: [
                        const SizedBox(height: 16.0),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                if (_isPurchaseComplete) {
                                  setState(() {
                                    _isPurchaseComplete = false;
                                    _qrData = '';
                                  });
                                } else {
                                  _buyTicketButtonPressed();
                                }
                              },
                              icon: const Icon(Icons.more_vert),
                            ),
                          ],
                        ),
                        const Text(
                          'Prenotazione biglietto',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 2.0,
                                offset: Offset(2.0, 2.0),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        _generateBlurEffect(),
                        const SizedBox(height: 16.0),
                        _generateQRWidget(_qrData),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    Future<void> _scanQRCode() async {
      final List<CameraDescription> cameras = await availableCameras();
      final CameraDescription camera = cameras.first;

      final PermissionStatus status = await Permission.camera.request();
      if (status.isGranted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => CameraScreen(camera: camera),
          ),
        );
      } else if (status.isDenied) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Permessi Camera'),
              content: const Text('Per favore, concede i permessi per accedere alla fotocamera.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else if (status.isPermanentlyDenied) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Permessi Camera'),
              content: const Text("Non hai concesso i permessi per accedere alla fotocamera. Abilita i permessi nelle impostazioni dell'app."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }

    Widget _generateBlurEffect() {
      return Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6.0,
                offset: const Offset(0, 2),
              ),
            ],
          )
      );
    }

    Future<void> _buyTicketButtonPressed() async {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Prenotazione Biglietto'),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: _nomeController,
                      decoration: const InputDecoration(
                        labelText: 'Nome',
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty ) {
                          return 'Inserisci il nome';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _cognomeController,
                      decoration: const InputDecoration(
                        labelText: 'Cognome',
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Inserisci il cognome';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty || !value.contains('@')) {
                          return "Inserisci un'email valida";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _orarioController,
                      decoration: const InputDecoration(
                        labelText: 'Orario',
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Inserisci un orario valido';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _museoController,
                      decoration: const InputDecoration(
                        labelText: 'Museo',
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty || isNumeric(value)) {
                          return 'Inserisci un museo valido';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Annulla'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      _isPurchaseComplete = true;
                      _qrData =
                      'Nome: ${_nomeController.text}\nCognome: ${_cognomeController.text}\nEmail: ${_emailController.text}\nOrario: ${_orarioController.text}\nMuseo: ${_museoController.text}';
                    });
                    Navigator.of(context).pop();
                    postRequest();
                  }
                },
                child: const Text('Acquista'),
              ),
            ],
          );
        },
      );
    }

    bool isNumeric(String? value) {
      if (value == null) {
        return false;
      }
      return double.tryParse(value) != null;
    }


    Widget _generateQRWidget(String data) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6.0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: QrImageView(
              data: data,
              size: 200.0,
            ),
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Dettagli Prenotazione'),
                    content: PrenotazionePage(
                      nome: _nomeController.text,
                      cognome: _cognomeController.text,
                      email: _emailController.text,
                      orario: _orarioController.text,
                      museo: _museoController.text,
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Chiudi'),
                      ),
                    ],
                  );
                },
              );
            },
            child: const Text('Visualizza dettagli della prenotazione'),
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isPurchaseComplete = false;
                _qrData = '';
              });
            },
            child: const Text("Fai un'altra prenotazione"),
          ),
        ],
      );
    }

    Future<void> postRequest() async {
      final Uri serverUrl = Uri.parse(
          'http://192.168.1.159:8080/API.php');
      Map<String, String> data = {
        'name': _nomeController.text,
        'cognome': _cognomeController.text,
        'email': _emailController.text,
        'orario': _orarioController.text,
        'museo': _museoController.text,
      };
      final String jsonCorpo = jsonEncode(data);

      try {
        final http.Response response = await http.post(
          serverUrl,
          headers: {'Content-Type': 'application/json'},
          body: jsonCorpo,
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          final String nome = responseData['nome'].toString();
          final String cognome = responseData['cognome'].toString();
          final String email = responseData['email'].toString();
          final String orario = responseData['orario'].toString();
          final String museo = responseData['museo'].toString();

          print('il nome è ' + nome);
          print('il cognome è ' + cognome);
          print("l'email è " + email);
          print("l'orario inserito " + orario);
          print('il museo è ' + museo);

          // Aggiorna lo stato con i dati ricevuti dal server
          setState(() {
            this.nome = nome;
            this.cognome = cognome;
            this.email = email;
            this.orario = orario;
            this.museo = museo;
          });

          // Visualizza una finestra di dialogo con i dettagli della prenotazione
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Dettagli Prenotazione'),
                content: PrenotazionePage(
                  nome: nome,
                  cognome: cognome,
                  email: email,
                  orario: orario,
                  museo: museo,
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Chiudi'),
                  ),
                ],
              );
            },
          );
        }
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  class CameraScreen extends StatefulWidget {
  
    const CameraScreen({Key? key, required this.camera}) : super(key: key);
    final CameraDescription camera;
  
    @override
    _CameraScreenState createState() => _CameraScreenState();
  }
  class _CameraScreenState extends State<CameraScreen> {
    late CameraController _controller;
    late Future<void> _initializeControllerFuture;
  
    @override
    void initState() {
      super.initState();
  
      _controller = CameraController(
        widget.camera,
        ResolutionPreset.medium,
      );
  
      _initializeControllerFuture = _controller.initialize();
    }
  
  
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Lettore QR'),
        ),
        body: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Text('Si è verificato un errore: ${snapshot.error}');
              }
  
              return CameraPreview(_controller);
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      );
    }
  }
