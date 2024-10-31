import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'location_service.dart';

DateTime agora = DateTime.now();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF111827), // Cor principal do tema
        scaffoldBackgroundColor: const Color(0xFF111827), // Cor de fundo do Scaffold
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: Colors.white, // Cor do corpo do texto
          displayColor: Colors.white, // Cor do texto de exibição
        ),
      ),
      home: const HomeMaterial(),
    );
  }
}

class HomeMaterial extends StatefulWidget {
  const HomeMaterial({super.key});

  @override
  State<HomeMaterial> createState() => _HomeMaterialState();
}

class _HomeMaterialState extends State<HomeMaterial> {
  final String apiKey ='Substitua pela sua API Key';
  late Future<Map<String, dynamic>?> weatherData; // Variável para armazenar os dados do clima

  @override
  void initState() {
    super.initState();
    // Chama a função para obter os dados do clima
    weatherData = dadosLocalizacao(); 
  }

  Future<Map<String, dynamic>?> dadosLocalizacao() async {
    try {
      LocationService locationService = LocationService();
      Position? position = await locationService.getCurrentLocation();

      if (position != null) {
        // Obtém os dados do clima usando a localização
        return await getDadosWeather(position.latitude, position.longitude);
      } else {
        return null; // Retorna null se não conseguir obter a localização
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>?> getDadosWeather(double latitude, double longitude) async {
    final url = 'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric';
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode != HttpStatus.ok) {
        throw 'Erro de conexão';
      }
      final data = json.decode(res.body); // Retorna o corpo da resposta como um mapa
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: weatherData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (snapshot.hasData) {
            String city = snapshot.data!["name"]; // Nome da cidade
            double temperature = snapshot.data!["main"]["temp"]; // Temperatura atual
            double feelsLike = snapshot.data!["main"]["feels_like"]; // Sensação térmica
            double tempMin = snapshot.data!["main"]["temp_min"]; // Temperatura mínima
            double tempMax = snapshot.data!["main"]["temp_max"]; // Temperatura máxima

            return Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: Text(
                      '${agora.day}/${agora.month},  ${agora.year}',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: Row(
                      children: [
                        Text(
                          city,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width:8), 
                        Image.asset(
                          'lib/assets/outra_img.jpg', // Especifique o caminho da sua imagem
                          width: 24, // Defina a largura da imagem
                          height: 24, // Defina a altura da imagem
                        ),

                      ],
                    ),
                  ),
                  const SizedBox(height: 70),
                  Center(
                    child: Column(
                      children: [
                        Image.asset('lib/assets/icon.png'),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  Center(
                    child: Text(
                      '  ${temperature.toInt()}°',
                      style: const TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Max: ${tempMax.toInt()}° Min: ${tempMin.toInt()}°',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      'Sensação Termica ${feelsLike.toInt()}°',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold, 
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return Text("Algum erro aconteceu");
        },
      ),
    );
  }
}
