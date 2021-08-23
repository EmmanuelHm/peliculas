import 'package:flutter/material.dart';
import 'package:peliculas/models/models.dart';
import 'package:peliculas/providers/movies_provider.dart';
import 'package:provider/provider.dart';

class MovieSearchDelegate extends SearchDelegate {
  // Cambiar a español (placeholder buscador)
  @override
  String? get searchFieldLabel => 'Buscar pelicula';

  // BOTONES DE ACCION
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      )
    ];
  }

  // BOTÓN LEADING
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  // RESULTADOS DE BÚSQUEDA
  @override
  Widget buildResults(BuildContext context) {
    return Text('buildResults');
  }

  // SUGERENCIAS DE BÚSQUEDA
  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return _emptyContainer();
    }

    final moviesProvider = Provider.of<MoviesProvider>(context, listen: false);
    moviesProvider.getSuggestionsByQuery(query);

    return StreamBuilder(
      stream: moviesProvider.suggestionsStream,
      builder: (_, AsyncSnapshot<List<Movie>> snapshot) {
        if (!snapshot.hasData) return _emptyContainer();

        final movies = snapshot.data!;

        return ListView.builder(
            itemCount: movies.length,
            itemBuilder: (_, int index) => _MovieItem(movie: movies[index]));
      },
    );

    // return FutureBuilder(
    //   future: moviesProvider.searchMovie(query),
    //   builder: (_, AsyncSnapshot<List<Movie>> snapshot) {
    //     if (!snapshot.hasData) return _emptyContainer();

    //     final movies = snapshot.data!;

    //     return ListView.builder(
    //         itemCount: movies.length,
    //         itemBuilder: (_, int index) => _MovieItem(movie: movies[index]));
    //   },
    // );
  }

  Widget _emptyContainer() {
    return Container(
      child: const Center(
        child: Icon(Icons.movie_creation_outlined,
            color: Colors.black38, size: 130),
      ),
    );
  }
}

class _MovieItem extends StatelessWidget {
  final Movie movie;
  const _MovieItem({Key? key, required this.movie}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    movie.heroId = 'search-${movie.id}';
    return ListTile(
        contentPadding: EdgeInsets.only(bottom: 10),
        leading: Hero(
          tag: movie.heroId!,
          child: FadeInImage(
            placeholder: AssetImage('assets/no-image.jpg'),
            image: NetworkImage(movie.fullPosterImg),
            width: 50,
            fit: BoxFit.contain,
          ),
        ),
        title: Text(movie.title),
        subtitle: Text(movie.originalTitle),
        onTap: () => Navigator.pushNamed(context, 'details', arguments: movie));
  }
}
