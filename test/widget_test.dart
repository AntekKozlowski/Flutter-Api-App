import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Upewnij się, że ta nazwa pakietu zgadza się z nazwą w Twoim pubspec.yaml
// Zazwyczaj jest to: pakiet_twojego_projektu/main.dart
import 'package:rick_and_morty_api_project/main.dart';

void main() {
  testWidgets('Sprawdzenie czy aplikacja uruchamia się z tytułem i wyszukiwarką', (WidgetTester tester) async {
    // 1. Uruchom aplikację.
    // Używamy const MyApp(), jeśli konstruktor jest const, w przeciwnym razie usuń const.
    await tester.pumpWidget(MyApp());

    // 2. Sprawdź, czy wyświetla się tytuł z AppBar (zdefiniowany w home_screen.dart).
    expect(find.text('Rick and Morty Wiki'), findsOneWidget);

    // 3. Sprawdź, czy wyświetla się pole tekstowe wyszukiwarki.
    expect(find.byType(TextField), findsOneWidget);

    // 4. Sprawdź, czy wyświetla się tekst pomocniczy w wyszukiwarce.
    expect(find.text('Szukaj postaci...'), findsOneWidget);

    // Uwaga: Nie testujemy tutaj kliknięć w listę, ponieważ wymagałoby to 
    // zamockowania (symulacji) zapytania sieciowego HTTP, co jest bardziej zaawansowane.
  });
}