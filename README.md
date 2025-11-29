# Rick and Morty Api Project

Aplikacja mobilna stworzona we Flutterze, umożliwiająca przeglądanie bazy postaci z uniwersum "Rick and Morty". Projekt demonstruje zastosowanie architektury MVVM, obsługę REST API, paginację danych oraz pracę w trybie offline.

## Funkcjonalności

* **Lista Postaci:** Pobieranie i wyświetlanie listy postaci z zewnętrznego API.
* **Wyszukiwarka:** Filtrowanie wyników po nazwie postaci w czasie rzeczywistym.
* **Paginacja (Infinite Scroll):** Automatyczne dociąganie kolejnych stron danych podczas przewijania listy.
* **Tryb Offline:** Persystencja danych przy użyciu `shared_preferences`. Ostatnio pobrana lista jest dostępna nawet bez połączenia z internetem.
* **Szczegóły:** Dedykowany ekran z pełnymi informacjami o postaci (Status, Gatunek, Płeć, Pochodzenie).
* **Architektura:** Czysty podział na warstwy (Model - View - ViewModel) z wykorzystaniem `Provider`.

## Wykorzystane API

Aplikacja korzysta z publicznego, darmowego API:
[The Rick and Morty API](https://rickandmortyapi.com/)

Endpointy użyte w projekcie:
* Pobieranie listy i szukanie: `https://rickandmortyapi.com/api/character/?page={page}&name={query}`
* Szczegóły postaci: `https://rickandmortyapi.com/api/character/{id}`

## Wspierane platformy

* **Android** (min SDK 21)

## Struktura Projektu (MVVM)

Pliki zostały podzielone zgodnie z warstwową strukturą MVVM:

```text
lib/
rick_and_morty_api_project/
├── demo/                       
│   ├── screen_main.png
│   ├── screen_details.png
│   ├── video_demo.mp4
│   └── architecture_info.txt  
├── lib/
│    ├── models/          # Warstwa Danych (Character Model)
│    ├── view_models/     # Warstwa Logiki (CharacterProvider - State Management)
│    ├── screens/         # Warstwa Prezentacji (UI Widgety)
│    └── main.dart        # Konfiguracja aplikacji i Providerów
├── pubspec.yaml
├── README.md
└── ...
```
## Instrukcja uruchomienia

Wymagane zainstalowane Flutter SDK.

1.  Sklonuj repozytorium:
    ```bash
    git clone [https://github.com/TWOJA_NAZWA_UZYTKOWNIKA/NAZWA_REPOZYTORIUM.git](https://github.com/TWOJA_NAZWA_UZYTKOWNIKA/NAZWA_REPOZYTORIUM.git)
    cd NAZWA_REPOZYTORIUM
    ```

2.  Pobierz zależności:
    ```bash
    flutter pub get
    ```

3.  Uruchom aplikację:
    ```bash
    flutter run
    ```

---
*Uwaga: Zrzut z Firebase nie jest dołączony, ponieważ projekt opiera się na architekturze REST API.*