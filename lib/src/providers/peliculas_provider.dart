import 'package:app_peliculas/src/models/actores_model.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';
import 'dart:async';

import 'package:app_peliculas/src/models/pelicula_model.dart';

class PeliculasProvider {
  String _apiKey = 'e3bcfd8aaeafb048bc425ec65761413e';
  String _url = 'api.themoviedb.org';
  String _language = 'es-ES';

  int _populares_page = 0;
  bool _cargadoDatos = false;

  List<Pelicula> _populares = new List();

  final _popularesStreamController =
      StreamController<List<Pelicula>>.broadcast();

  Function(List<Pelicula>) get popularesSink =>
      _popularesStreamController.sink.add;

  Stream<List<Pelicula>> get poupularesStream =>
      _popularesStreamController.stream;

  void disposeStreams() {
    _popularesStreamController
        ?.close(); // ? si el stream no contiene información, no lo cierra
  }

  Future<List<Pelicula>> _procesarRespuesta(Uri url) async {
    final resp = await http.get(url); //obtener la data desde la API
    //print('aqui estoy');
    final decodeData =
        json.decode(resp.body); //convirtiendo a json la respuesta

    final peliculas = new Peliculas.fromJsonList(decodeData[
        'results']); //Instancia a nuestro modelo Pelicula ubicado en el provider

    //print(decodeData['results']);

    return peliculas.items;
  }

  Future<List<Pelicula>> getEnCines() async {
    final url = Uri.https(_url, '3/movie/now_playing',
        {'api_key': _apiKey, 'language': _language});
    return await _procesarRespuesta(url);
  }

  Future<List<Pelicula>> getPopulares() async {
    if (_cargadoDatos) return [];

    _cargadoDatos = true;

    _populares_page++;

    print(_populares_page);
    print('Cargando siguientes....y Realizando nuevamente petición');

    final url = Uri.https(_url, '3/movie/popular', {
      'api_key': _apiKey,
      'language': _language,
      'page': _populares_page.toString()
    });

    final resp = await _procesarRespuesta(url);

    _populares.addAll(resp);
    popularesSink(_populares);
    _cargadoDatos = false;
    return resp;
  }

  Future<List<Actor>> getCast(String peliId) async {
    final url = Uri.https(_url, '3/movie/$peliId/credits',
        {'api_key': _apiKey, 'language': _language});

    final resp = await http.get(url);
    final decodeData = json.decode(resp.body);

    final cast = new Cast.fromJsonList(decodeData['cast']);

    return cast.actores;
  }

  Future<List<Pelicula>> buscarPelicula(String query) async {
    final url = Uri.https(_url, '3/search/movie',
        {'api_key': _apiKey, 'language': _language, 'query': query});
    return await _procesarRespuesta(url);
  }
}
