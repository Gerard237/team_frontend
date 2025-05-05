import 'dart:ffi';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class FavoriListPage extends StatefulWidget {
  final String user;
  FavoriListPage(this.user);

  @override
  _FavoriListPageState createState() => _FavoriListPageState();
}

class _FavoriListPageState extends State<FavoriListPage> {
  final ScrollController _scrollController = ScrollController();
  List<dynamic> _recipes = [];
  int _page = 1;
  final int _pageSize = 10;
  bool _isLoading = false;
  bool _hasMore = true;
  var hostIp = dotenv.env['BACKEND_HOST_ADRESSE'];
  //var port = dotenv.env['BACKEND_HOST_PORT'];

  final List<int> _userFavori = [];

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

  Future<void> _fetchRecipes() async {
    setState(() => _isLoading = true);

    

    String tmp = widget.user;
    String url = 'http://$hostIp/api/favoris?user=$tmp';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        for (var recipe in data) {
          _userFavori.add(recipe["id_recipe"]);
        }

      String urlRecipe = 'http://$hostIp/api/recipes/filter_by_location/?id_recipes=$_userFavori&page=$_page&page_size=$_pageSize';        

      final responseR = await http.get(
        Uri.parse(urlRecipe),
        headers: {'Content-Type': 'application/json'},
      );

      if (responseR.statusCode == 200) {
        final data = json.decode(responseR.body);

        final List<dynamic> recipes = data['results'];

        for (var recipe in recipes) {
          recipe['isFavorited'] = true;
        }
        setState(() {
          _recipes.addAll(recipes);
          _hasMore = data['next'] != null;
          _page++;
        });
      } else {
        throw Exception('Failed to load recipes');
      }

      } else {
        throw Exception('Failed to load recipes');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }


  Future<void> _toggleFavorite(int recipeId, int index) async {
    
    var url = 'http://$hostIp/api/favoris/'; //put correct url
    try {
        
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
            _recipes.removeAt(index);
          });
        } else {
          throw Exception('Failed to update favorite status');
        
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favori Recettes'),
      ),
      body:_recipes.isNotEmpty? 
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
          child: Text("No recipe in Favori."),
        ),
      )
    );
  }
}
