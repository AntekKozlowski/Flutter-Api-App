import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/character_model.dart';

class CharacterProvider with ChangeNotifier {
  // Stan listy
  List<Character> _characters = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // Stan szczegółów
  Character? _selectedCharacter;
  bool _isDetailLoading = false;

  // Gettery dla UI
  List<Character> get characters => _characters;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  Character? get selectedCharacter => _selectedCharacter;
  bool get isDetailLoading => _isDetailLoading;

  // ZAPYTANIE 1: Pobieranie listy i wyszukiwarka
  Future<void> fetchCharacters({String query = ''}) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners(); // Informujemy UI, że zaczynamy ładować

    try {
      final url = query.isEmpty
          ? 'https://rickandmortyapi.com/api/character'
          : 'https://rickandmortyapi.com/api/character/?name=$query';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'];
        _characters = results.map((json) => Character.fromJson(json)).toList();
      } else {
        _characters = [];
        _errorMessage = 'Nie znaleziono postaci lub błąd serwera.';
      }
    } catch (e) {
      _errorMessage = 'Błąd połączenia: $e';
    }

    _isLoading = false;
    notifyListeners(); // Aktualizujemy UI po zakończeniu
  }

  // ZAPYTANIE 2: Pobieranie szczegółów (na potrzeby drugiego ekranu)
  Future<void> fetchCharacterDetails(int id) async {
    _isDetailLoading = true;
    _selectedCharacter = null; // Czyścimy poprzedni wybór
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('https://rickandmortyapi.com/api/character/$id'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _selectedCharacter = Character.fromJson(data);
      } else {
        _errorMessage = 'Błąd pobierania szczegółów.';
      }
    } catch (e) {
      _errorMessage = 'Błąd połączenia: $e';
    }

    _isDetailLoading = false;
    notifyListeners();
  }
}