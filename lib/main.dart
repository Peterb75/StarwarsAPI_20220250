import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class Character {
  final String name;
  final String height;
  final String mass;
  final String hairColor;
  final String skinColor;
  final String eyeColor;
  final String birthYear;
  final String gender;
  final String imgUrl;

  Character({
    required this.name,
    required this.height,
    required this.mass,
    required this.hairColor,
    required this.skinColor,
    required this.eyeColor,
    required this.birthYear,
    required this.gender,
    required this.imgUrl,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      name: json['name'],
      height: json['height'],
      mass: json['mass'],
      hairColor: json['hair_color'],
      skinColor: json['skin_color'],
      eyeColor: json['eye_color'],
      birthYear: json['birth_year'],
      gender: json['gender'],
      imgUrl: 'https://starwars-visualguide.com/assets/img/characters/${json['url'].split('/')[5]}.jpg',
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Starwars Search',
      home:  SearchScreen(),
    );
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Character? _character;
  bool _load = false;

  Future<void> _fetchCharacter(String name) async {
    setState(() {
      _load = true;
      _character = null;
    });

    final response = await http.get(Uri.parse('https://swapi.dev/api/people/?search=$name'));

    setState(() {
      _load = false;
    });

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      if (data['results'].length > 0) {
        setState(() {
          _character = Character.fromJson(data['results'][0]);
        });
      } else {
        setState(() {
          _character = null;
        });
      }
    } else {
      setState(() {
        _character = null;
      });
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Starwars Search'),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter character name',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    _fetchCharacter(_controller.text.trim());
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            _character != null
                ? Column(
                    children: [
                      Image.network(
                        _character!.imgUrl, height: 190, width: 210,
                      ),
                      const SizedBox(height: 20),
                      Text("Name: ${_character!.name}"),
                      Text("Gender: ${_character!.gender}"),
                      Text("Birth Year: ${_character!.birthYear}"),
                      Text("Height: ${_character!.height}"),
                      Text("Mass: ${_character!.mass}"),
                      Text("Hair Color: ${_character!.hairColor}"),
                      Text("Skin Color: ${_character!.skinColor}"),
                      Text("Eye Color: ${_character!.eyeColor}"),
                    ],
                  )
                : _load
                    ? SizedBox(
                        height: 36,
                        width: 36,
                      )
                    : const Text('Character not found.'),
          ],
        ),
      ),
    ),
  );
}

}
