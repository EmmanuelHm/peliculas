import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:peliculas/helpers/debouncer.dart';
import 'package:peliculas/models/models.dart';
import 'package:peliculas/models/popular_response.dart';
import 'package:peliculas/models/search_response.dart';

class MoviesProvider extends ChangeNotifier {
  String _apiKey = "54a33308b8ae93d789684e6bfa325c6c";
  String _baseUrl = "api.themoviedb.org";
  String _language = "es-MX";

  List<Movie> onDisplayMovies = [];
  List<Movie> popularMovies = [];
  Map<int, List<Cast>> moviesCast = {};
  int _popularpage = 0;

  final debouncer = Debouncer(
    duration: Duration(milliseconds: 500),
  );

  // Stream
  final StreamController<List<Movie>> _suggestionsStreamController =
      new StreamController.broadcast();

  Stream<List<Movie>> get suggestionsStream =>
      this._suggestionsStreamController.stream;

  MoviesProvider() {
    print('MoviesProvider inicializado');
    this.getOnDisplayMovies();
    this.getPopularMovies();
  }

  Future<String> _getJsonData(String endpoint, [int page = 1]) async {
    final url = Uri.https(_baseUrl, endpoint,
        {'api_key': _apiKey, 'language': _language, 'page': '$page'});
    final response = await http.get(url);
    return response.body;
  }

  // Get Now_Playing
  getOnDisplayMovies() async {
    final jsonData = await this._getJsonData('3/movie/now_playing');
    // Convert JSON to Map
    final nowPlayingResponse = NowPlayingResponse.fromJson(jsonData);
    this.onDisplayMovies = nowPlayingResponse.results;
    // Listen For all widgets
    notifyListeners();
  }

  // Get Popular Movies
  getPopularMovies() async {
    _popularpage++;
    final jsonData = await this._getJsonData('3/movie/popular', _popularpage);
    final popularResponse = PopularResponse.fromJson(jsonData);
    this.popularMovies = [...popularMovies, ...popularResponse.results];
    notifyListeners();
  }

  // Get Cast Movie
  Future<List<Cast>> getMovieCast(int movieId) async {
    // TODO revisar el Mapa

    if (moviesCast.containsKey(movieId)) return moviesCast[movieId]!;

    // print('Pidiendo info al Servidor');
    final jsonData = await this._getJsonData('3/movie/${movieId}/credits');
    final creditsResponse = CredistResponse.fromJson(jsonData);

    moviesCast[movieId] = creditsResponse.cast;
    return creditsResponse.cast;
  }

  //Search(Buscador)
  Future<List<Movie>> searchMovie(String query) async {
    final url = Uri.https(_baseUrl, '3/search/movie',
        {'api_key': _apiKey, 'language': _language, 'query': query});
    //Send request
    final response = await http.get(url);
    final searchResponse = SearchResponse.fromJson(response.body);

    return searchResponse.results;
  }

  void getSuggestionsByQuery(String searchTerm) {
    debouncer.value = '';
    debouncer.onValue = (value) async {
      // print('Tenemos valor a buscar $value');
      final results = await this.searchMovie(value);
      this._suggestionsStreamController.add(results);
    };

    final timer = Timer.periodic(Duration(milliseconds: 300), (_) {
      debouncer.value = searchTerm;
    });

    Future.delayed(Duration(milliseconds: 301)).then((_) => timer.cancel());
  }
}
