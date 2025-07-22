import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Auth + API Demo',
      home: const AuthExample(),
    );
  }
}

class AuthExample extends StatefulWidget {
  const AuthExample({super.key});

  @override
  AuthExampleState createState() => AuthExampleState();
}

class AuthExampleState extends State<AuthExample> {
  String status = "Not signed in";
  String apiResponse = "No data from backend yet";
  bool isAuthenticated = false;

  // Función para login anónimo (ya la tenías)
  void signInAnonymously() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
      setState(() {
        status = "Signed in anonymously";
        isAuthenticated = true;
      });
    } catch (e) {
      setState(() {
        status = "Error: $e";
        isAuthenticated = false;
      });
    }
  }

  // NUEVA: Función para logout
  void signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      setState(() {
        status = "Not signed in";
        isAuthenticated = false;
        apiResponse = "No data from backend yet";
      });
    } catch (e) {
      setState(() {
        status = "Error al cerrar sesión: $e";
      });
    }
  }

  // NUEVA: Función para llamar tu backend API
  void callBackendAPI() async {
    try {
      // Llamar a tu backend (usa IP del emulador, no localhost)
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/saludo'),
      );

      // Verificar si la respuesta fue exitosa
      if (response.statusCode == 200) {
        // Parsear JSON y mostrar mensaje
        final data = json.decode(response.body);
        setState(() {
          apiResponse = "Backend dice: ${data['mensaje']}";
        });
      } else {
        setState(() {
          apiResponse = "Error del servidor: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        apiResponse = "Error de conexión: Verifica que el backend esté corriendo";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Firebase Auth + Backend API")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Mostrar status de autenticación
              Text(
                status,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Botones que cambian según el estado de autenticación
              if (!isAuthenticated) ...[
                // Mostrar solo botón de login si no está autenticado
                ElevatedButton(
                  onPressed: signInAnonymously,
                  child: const Text("Login anónimo"),
                ),
              ] else ...[
                // Mostrar botones de logout y API si está autenticado
                ElevatedButton(
                  onPressed: signOut,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text("Logout"),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: callBackendAPI,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text("Llamar API Backend"),
                ),
              ],
              const SizedBox(height: 30),

              // Mostrar respuesta del backend solo si está autenticado
              if (isAuthenticated)
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    apiResponse,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}