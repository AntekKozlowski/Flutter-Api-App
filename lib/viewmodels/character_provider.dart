import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/character_model.dart';

class CharacterProvider with ChangeNotifier {
  // --- ZMIENNE STANU (Prywatne) ---
  List<Character> _characters = []; // Główna lista postaci
  bool _isLoading = false;          // Flaga ładowania całej listy (pierwsze wejście/szukanie)
  bool _isLoadingMore = false;      // Flaga ładowania kolejnej strony (paginacja)
  String _errorMessage = '';        // Przechowywanie komunikatów błędów

  // --- ZMIENNE POMOCNICZE DO PAGINACJI ---
  int _currentPage = 1;      // Aktualny numer strony w API
  bool _hasMore = true;      // Czy API posiada kolejne strony?
  String _currentQuery = ''; // Zapamiętana fraza wyszukiwania (żeby wiedzieć co stronicować)

  // --- ZMIENNE DLA EKRANU SZCZEGÓŁÓW ---
  Character? _selectedCharacter;
  bool _isDetailLoading = false;

  // --- GETTERY (Publiczny dostęp dla UI) ---
  List<Character> get characters => _characters;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String get errorMessage => _errorMessage;
  Character? get selectedCharacter => _selectedCharacter;
  bool get isDetailLoading => _isDetailLoading;

  // ==================================================================
  // FUNKCJA 1: GŁÓWNE POBIERANIE / WYSZUKIWANIE
  // Uruchamiana przy starcie aplikacji lub wpisaniu nowej frazy
  // ==================================================================
  Future<void> fetchCharacters({String query = ''}) async {
    _isLoading = true;
    _errorMessage = '';

    // Resetujemy stan paginacji, bo to nowe zapytanie
    _currentPage = 1;
    _hasMore = true;
    _currentQuery = query;

    notifyListeners(); // Informujemy UI -> Pokaż duży loader

    try {
      // Próbujemy pobrać 1. stronę z internetu (clearList: true czyści starą listę)
      await _fetchPage(page: 1, query: query, clearList: true);
    } catch (e) {
      // OBSŁUGA TRYBU OFFLINE
      // Jeśli wystąpi błąd (np. brak sieci), próbujemy wczytać dane z pamięci telefonu
      print('Błąd sieci: $e. Próba wczytania offline...');
      await _loadFromLocalStorage();

      if (_characters.isEmpty) {
        _errorMessage = 'Brak internetu i brak zapisanych danych.';
      } else {
        // Jeśli udało się wczytać dane z cache, logujemy to (UI wyświetli listę)
        print('Załadowano dane offline.');
      }
    }

    _isLoading = false;
    notifyListeners(); // Informujemy UI -> Ukryj loader, pokaż listę/błąd
  }

  // ==================================================================
  // FUNKCJA 2: PAGINACJA (Dociąganie kolejnych stron)
  // Uruchamiana przez ScrollController w home_screen.dart
  // ==================================================================
  Future<void> fetchNextPage() async {
    // Zabezpieczenia (Guard Clauses):
    // Nie pobieraj, jeśli: nie ma więcej stron LUB trwa już ładowanie
    if (!_hasMore || _isLoading || _isLoadingMore) return;

    _isLoadingMore = true;
    notifyListeners(); // UI -> Pokaż mały loader na dole

    try {
      // Pobieramy stronę nr (obecna + 1), clearList: false (DOPISUJEMY do listy)
      await _fetchPage(page: _currentPage + 1, query: _currentQuery, clearList: false);
    } catch (e) {
      // Przy paginacji zazwyczaj ignorujemy błędy sieci (nie czyścimy listy),
      // użytkownik po prostu nie zobaczy nowych elementów na dole.
      print('Błąd pobierania kolejnej strony: $e');
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  // ==================================================================
  // FUNKCJA POMOCNICZA (Wspólna logika zapytań API)
  // ==================================================================
  Future<void> _fetchPage({required int page, required String query, required bool clearList}) async {
    // Budowanie adresu URL w zależności czy jest wyszukiwanie czy nie
    final url = query.isEmpty
        ? 'https://rickandmortyapi.com/api/character/?page=$page'
        : 'https://rickandmortyapi.com/api/character/?page=$page&name=$query';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];

      // Konwersja JSON -> Obiekty Dart
      final newCharacters = results.map((json) => Character.fromJson(json)).toList();

      // Sprawdzamy w metadanych 'info', czy pole 'next' jest nullem (koniec danych)
      if (data['info']['next'] == null) {
        _hasMore = false;
      }

      if (clearList) {
        _characters = newCharacters; // Nadpisz listę (nowe szukanie)
      } else {
        _characters.addAll(newCharacters); // Dopisz do listy (paginacja)
      }

      _currentPage = page; // Zaktualizuj licznik stron po sukcesie

      // Zapisujemy stan listy do pamięci telefonu (cache) na wypadek braku sieci później
      _saveToLocalStorage();

    } else if (response.statusCode == 404) {
      // API zwraca 404, gdy nie znajdzie wyników dla danej nazwy
      _hasMore = false;
      if (clearList) _characters = [];
    } else {
      throw Exception('Błąd serwera: ${response.statusCode}');
    }
  }

  // ==================================================================
  // PERSYSTENCJA (OFFLINE - Shared Preferences)
  // ==================================================================

  // Zapisywanie listy do pamięci urządzenia
  Future<void> _saveToLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // SharedPreferences obsługuje tylko proste typy, więc zamieniamy List<Obiekt> na String (JSON)
      final String encodedData = json.encode(
        _characters.map((c) => c.toJson()).toList(),
      );
      await prefs.setString('cached_characters', encodedData);
    } catch (e) {
      print('Błąd zapisu cache: $e');
    }
  }

  // Odczytywanie listy z pamięci urządzenia
  Future<void> _loadFromLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('cached_characters')) {
        final String encodedData = prefs.getString('cached_characters')!;
        final List<dynamic> decodedList = json.decode(encodedData);

        // Odtwarzamy obiekty Character z JSON-a
        _characters = decodedList.map((json) => Character.fromJson(json)).toList();
        notifyListeners(); // Odśwież widok danymi z pamięci
      }
    } catch (e) {
      print('Błąd odczytu cache: $e');
    }
  }

  // ==================================================================
  // POBIERANIE SZCZEGÓŁÓW (Dla drugiego ekranu)
  // ==================================================================
  Future<void> fetchCharacterDetails(int id) async {
    _isDetailLoading = true;
    _selectedCharacter = null; // Czyścimy poprzedni wybór, żeby nie migały stare dane
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