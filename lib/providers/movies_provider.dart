import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:peliculas/models/models.dart';

class MoviesProvider extends ChangeNotifier {
  String _apiKey = "54a33308b8ae93d789684e6bfa325c6c";
  String _baseUrl = "api.themoviedb.org";
  String _language = "es-MX";

  List<Movie> onDisplayMovies = [];

  MoviesProvider() {
    print('MoviesProvider inicializado');
    this.getOnDisplayMovies();
  }

  getOnDisplayMovies() async {
    var url = Uri.https(_baseUrl, '3/movie/now_playing',
        {'api_key': _apiKey, 'language': _language, 'page': '1'});

    //Await the http get response, then decode the json-formatted response
    final response = await http.get(url);
    // print(response.body); //Verify response

    // Convert JSON to Map
    final nowPlayingResponse = NowPlayingResponse.fromJson(response.body);
    // print(nowPlayingResponse);
    this.onDisplayMovies = nowPlayingResponse.results;

    // Listen For all widgets
    notifyListeners();
  }
}
