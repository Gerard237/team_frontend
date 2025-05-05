import 'dart:ffi';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RecipeListPage extends StatefulWidget {
  final String user;
  RecipeListPage(this.user);

  @override
  _RecipeListPageState createState() => _RecipeListPageState();
}

class _RecipeListPageState extends State<RecipeListPage> {
  final ScrollController _scrollController = ScrollController();

  List<dynamic> _recipes = [];
  int _page = 1;
  final int _pageSize = 10;
  bool _isLoading = false;
  bool _hasMore = true;

  List<String> _countries = [];
  Map<String, List<String>> _countryFoodMap = {};
  String? _selectedCountry;
  String? _selectedFood;
  List<String> _foodNames = [];
  final List<int> _userFavori = [];

  var hostIp = dotenv.env['BACKEND_HOST_ADRESSE'];
  var port = dotenv.env['BACKEND_HOST_PORT'];

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !_isLoading &&
          _hasMore) {
        _fetchRecipes();
      }
    });
  }

  Future<void> _fetchRecipes({bool isSearch = false}) async {
    setState(() => _isLoading = true);

    final country = _selectedCountry; //_countryController.text.trim();
    final name = _selectedFood; //_cityController.text.trim();

    String url = isSearch
      ? 'http://$hostIp:$port/api/recipes/filter_by_location/?page=$_page&page_size=$_pageSize&country=$country&name=$name'
      : 'http://$hostIp:$port/api/recipes?page=$_page&page_size=$_pageSize';
    String tmp = widget.user;

    String urlFavori = 'http://$hostIp:$port/api/favoris?$tmp';

    try {
      
      final response = await http.get(
        Uri.parse(urlFavori),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        for(var favori in data){
          _userFavori.add(favori['id_recipe']);
        }

      } else {
        throw Exception('Failed to load recipes');
      }

    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Populate countries and map country to food names
        final Map<String, List<String>> tempCountryFoodMap = {};
        final Set<String> countriesSet = {};
        final List<dynamic> recipes = data['results'];
        

        for (var recipe in recipes) {
          final country = recipe['country'] as String;
          final foodName = recipe['name'] as String;

          countriesSet.add(country);
          if (!tempCountryFoodMap.containsKey(country)) {
            tempCountryFoodMap[country] = [];
          }
          tempCountryFoodMap[country]!.add(foodName);

          recipe['isFavorited'] = _userFavori.contains(recipe['id_recipe']);
        }

          _countries = countriesSet.toList();
          _countryFoodMap = tempCountryFoodMap;

        setState(() {
          if (isSearch) {
            _recipes = recipes;
          } else {
            _recipes.addAll(recipes); // Append for scrolling
          }
          _hasMore = data['next'] != null;
          if (!isSearch) _page++;
        });
      } else {
        throw Exception('Failed to load recipes');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onSearch() {
    setState(() {
      _page = 1;
      _hasMore = true;
    });
    _fetchRecipes(isSearch: true);
  }

  void _showSearchModal() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          
        builder : (context, setModalState) {
        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                  setModalState(() {
                    _selectedCountry = value;
                    _foodNames = _countryFoodMap[value] ?? [];
                    //_selectedFood = null; // Reset food selection
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
                  // setState(() {
                  //   _selectedFood = value;
                  // });

                  setModalState(() {
                    _selectedFood = value;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _onSearch,
                child: Text('Rechercher'),
              ),
              ],
          ),
        );
        }
        );
      },
    );
  }

  Future<void> _toggleFavorite(int recipeId, int index) async {
    
    var url = 'http://$hostIp:$port/api/favoris/'; //put correct url
    try {
        if (_recipes[index]['isFavorited'] == false){
        final response = await http.post(
          Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            'user':widget.user,
            'id_recipe': recipeId,
          }),
        );

        if (response.statusCode == 201) {
          // Successfully updated favorite status
          setState(() {
            _recipes[index]['isFavorited'] = !_recipes[index]['isFavorited'];
          });
        } else {
          throw Exception('Failed to update favorite status');
        }
      }else{
        final response = await http.delete(
          Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            'user':widget.user,
            'id_recipe': recipeId,
          })
        );

        if (response.statusCode == 204) {
          // Successfully updated favorite status
          setState(() {
            _recipes[index]['isFavorited'] = !_recipes[index]['isFavorited'];
          });
        } else {
          throw Exception('Failed to update favorite status');
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recettes'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              _showSearchModal();
            },
          ),
        ],
      ),
      body: 
      _recipes.isNotEmpty ?
      Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _recipes.length + 1,
              itemBuilder: (context, index) {
                if (index == _recipes.length) {
                  return _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : SizedBox.shrink();
                }

                final recipe = _recipes[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: user and more options
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.grey[300],
                                child: Icon(Icons.person),
                              ),
                              SizedBox(width: 10),
                              Text(
                                recipe['user'] ?? 'Utilisateur inconnu',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          
                        ],
                      ),
                      SizedBox(height: 10),
                      // Recipe image
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: NetworkImage(recipe['file']),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),

                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              recipe['isFavorited']
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: recipe['isFavorited'] ? Colors.red : Colors.grey,
                            ),
                            onPressed: () {
                              _toggleFavorite(recipe['id_recipe'], index);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.share),
                            onPressed: () {
                              // Share the recipe's name and description
                              final recipeName = recipe['name'] ?? 'Recipe';
                              final recipeCountry = recipe['country'] ?? 'Unkown';
                              final recipeDescription =
                                  recipe['description'] ??
                                      'No description available.';
                              Share.share(
                                'Check out this recipe: $recipeName\n\n from $recipeCountry\n\n with Description :\n\n $recipeDescription',
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      // Recipe name and description
                      Text(
                        recipe['name'] ?? 'Recette inconnue',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        recipe['description'] ?? 'Aucune description disponible.',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      Divider(),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ):
      Container(
        child: const Center(
          child: Text("No Recipe found."),
        ),
      )
    );
  }
}
