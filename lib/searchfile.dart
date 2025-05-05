import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
class DropdownExample extends StatefulWidget {
  @override
  _DropdownExampleState createState() => _DropdownExampleState();
}

class _DropdownExampleState extends State<DropdownExample> {
  List<String> _countries = [];
  Map<String, List<String>> _countryFoodMap = {};
  String? _selectedCountry;
  String? _selectedFood;
  List<String> _foodNames = [];
  var hostIp = dotenv.env['BACKEND_HOST_ADRESSE'];

  @override
  void initState() {
    super.initState();
    _fetchCountriesAndFoods();
  }

  Future<void> _fetchCountriesAndFoods() async {
    var url = 'http://$hostIp/api/recipes';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List<dynamic>;

        // Populate countries and map country to food names
        final Map<String, List<String>> tempCountryFoodMap = {};
        final Set<String> countriesSet = {};

        for (var recipe in results) {
          final country = recipe['country'] as String;
          final foodName = recipe['name'] as String;

          countriesSet.add(country);
          if (!tempCountryFoodMap.containsKey(country)) {
            tempCountryFoodMap[country] = [];
          }
          tempCountryFoodMap[country]!.add(foodName);
        }

        setState(() {
          _countries = countriesSet.toList();
          _countryFoodMap = tempCountryFoodMap;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dropdown Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Country Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCountry,
              hint: Text('Select a country'),
              items: _countries.map((country) {
                return DropdownMenuItem<String>(
                  value: country,
                  child: Text(country),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCountry = value;
                  _foodNames = _countryFoodMap[_selectedCountry] ?? [];
                  _selectedFood = null; // Reset food selection
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 10),
            // Food Name Dropdown
            DropdownButtonFormField<String>(
              value: _selectedFood,
              hint: Text('Select a food'),
              items: _foodNames.map((food) {
                return DropdownMenuItem<String>(
                  value: food,
                  child: Text(food),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedFood = value;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Display selected values
            ElevatedButton(
              onPressed: () {
                if (_selectedCountry != null && _selectedFood != null) {
                  print(
                      'Selected Country: $_selectedCountry, Selected Food: $_selectedFood');
                } else {
                  print('Please select both country and food');
                }
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
