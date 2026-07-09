import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Leitor de Medidor',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MedidorScreen(),
    );
  }
}

class MedidorScreen extends StatefulWidget {
  const MedidorScreen({super.key});

  @override
  State<MedidorScreen> createState() => _MedidorScreenState();
}

class _MedidorScreenState extends State<MedidorScreen> {
  final _picker = ImagePicker();
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  final _controller = TextEditingController();

  File? _imagem;
  bool _carregando = false;

  Future<void> _tirarFoto() async {
    final XFile? foto = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
    );

    if (foto == null) return;

    setState(() {
      _imagem = File(foto.path);
      _carregando = true;
    });

    final numero = await _lerNumero(foto.path);

    setState(() {
      _controller.text = numero ?? '';
      _carregando = false;
    });
  }

  Future<String?> _lerNumero(String caminho) async {
    final inputImage = InputImage.fromFilePath(caminho);
    final resultado = await _textRecognizer.processImage(inputImage);

    // DEBUG: veja no console o que o OCR está enxergando
    print('===== TEXTO BRUTO RECONHECIDO =====');
    print(resultado.text);
    print('====================================');

    final candidatos = <String>[];

    for (final block in resultado.blocks) {
      for (final line in block.lines) {
        final apenasDigitos = line.text.replaceAll(RegExp(r'[^0-9]'), '');
        print('Linha: "${line.text}" -> dígitos: "$apenasDigitos"'); // DEBUG
        if (apenasDigitos.length >= 4 && apenasDigitos.length <= 9) {
          candidatos.add(apenasDigitos);
        }
      }
    }

    if (candidatos.isEmpty) return null;

    candidatos.sort((a, b) => b.length.compareTo(a.length));
    return candidatos.first;
  }

  @override
  void dispose() {
    _textRecognizer.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leitor de Medidor')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_imagem != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(_imagem!, height: 250, fit: BoxFit.cover),
              )
            else
              Container(
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(Icons.camera_alt, size: 64, color: Colors.grey),
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _carregando ? null : _tirarFoto,
              icon: const Icon(Icons.camera_alt),
              label: Text(_carregando ? 'Lendo...' : 'Fotografar medidor'),
            ),
            const SizedBox(height: 24),
            if (_carregando) const CircularProgressIndicator(),
            if (!_carregando && _imagem != null) ...[
              const Text(
                'Confirme ou corrija o número lido:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28, letterSpacing: 2),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Número do medidor',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Salvo: ${_controller.text}')),
                  );
                  // aqui você chamaria sua API/banco de dados
                },
                child: const Text('Confirmar leitura'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
