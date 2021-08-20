import 'package:flutter/material.dart';
// Providers
import 'package:peliculas/providers/movies_provider.dart';
// Screens
import 'package:peliculas/screens/screens.dart';
import 'package:provider/provider.dart';

void main() => runApp(AppState());

// Class for init Providers/Services
class AppState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => MoviesProvider(),
            lazy: false,
          ),
        ],
        // Init App after load Providers
        child: MyApp());
  }
}

// My Main Appp
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Peliculas',
      initialRoute: 'home',
      routes: {
        'home': (_) => const HomeScreen(),
        'details': (_) => const DetailsScreen(),
      },
      // Temas de la aplicacion solo hay:
      //  1. ThemeData.light()
      //  2. ThemeData.dark()
      theme: ThemeData.light()
          .copyWith(appBarTheme: AppBarTheme(color: Colors.indigo)),
    );
  }
}
