import 'package:flutter/material.dart';
import '../viewmodels/character_provider.dart';
import 'package:provider/provider.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Kontroler pola tekstowego do wyszukiwania
  final TextEditingController _searchController = TextEditingController();

  // Kontroler przewijania listy - kluczowy dla funkcji "Infinite Scroll"
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // 1. Pobranie danych startowych po załadowaniu drzewa widgetów
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // listen: false, ponieważ w initState nie chcemy przebudowywać widoku, tylko wywołać metodę
      Provider.of<CharacterProvider>(context, listen: false).fetchCharacters();
    });

    // 2. Dodanie nasłuchiwania na zdarzenia przewijania (dla paginacji)
    _scrollController.addListener(() {
      // Sprawdzamy, czy użytkownik jest blisko końca listy (200 pikseli od dołu)
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        // Jeśli tak, zlecamy Providerowi pobranie kolejnej strony
        Provider.of<CharacterProvider>(context, listen: false).fetchNextPage();
      }
    });
  }

  @override
  void dispose() {
    // Pamiętamy o zwolnieniu zasobów kontrolerów przy zamykaniu ekranu
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Rick and Morty Wiki')),
      body: Column(
        children: [
          // --- SEKCJA WYSZUKIWARKI ---
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Szukaj postaci...',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    // Wywołanie wyszukiwania po kliknięciu ikony lupki
                    Provider.of<CharacterProvider>(context, listen: false)
                        .fetchCharacters(query: _searchController.text);
                  },
                ),
              ),
              onSubmitted: (value) {
                // Wywołanie wyszukiwania po kliknięciu Enter na klawiaturze
                Provider.of<CharacterProvider>(context, listen: false)
                    .fetchCharacters(query: value);
              },
            ),
          ),

          // --- SEKCJA LISTY WYNIKÓW ---
          Expanded(
            // Consumer nasłuchuje zmian w CharacterProvider i przebudowuje ten fragment UI
            child: Consumer<CharacterProvider>(
              builder: (context, provider, child) {

                // 1. Wyświetl duży loader na środku tylko przy PIERWSZYM ładowaniu pustej listy
                if (provider.isLoading && provider.characters.isEmpty) {
                  return Center(child: CircularProgressIndicator());
                }

                // 2. Obsługa błędów (tylko jeśli lista jest pusta, np. brak neta na starcie)
                if (provider.errorMessage.isNotEmpty && provider.characters.isEmpty) {
                  return Center(child: Text(provider.errorMessage));
                }

                // 3. Budowanie listy danych
                return ListView.builder(
                  controller: _scrollController, // Podpięcie kontrolera scrolla (Wymagane!)

                  // Triki paginacji: Jeśli ładujemy więcej danych (isLoadingMore),
                  // dodajemy +1 do długości listy, żeby zrobić miejsce na dolny loader.
                  itemCount: provider.characters.length + (provider.isLoadingMore ? 1 : 0),

                  itemBuilder: (context, index) {

                    // Jeśli jesteśmy na ostatnim elemencie (który jest tym "dodatkowym")
                    // to wyświetlamy mały loader na dole listy
                    if (index == provider.characters.length) {
                      return Center(child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ));
                    }

                    // W przeciwnym razie wyświetlamy kartę postaci
                    final character = provider.characters[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: Image.network(
                          character.image,
                          width: 50,
                          // Obsługa błędu obrazka (np. w trybie Offline), wyświetlamy ikonę
                          errorBuilder: (context, error, stackTrace) => Icon(Icons.person),
                        ),
                        title: Text(character.name),
                        subtitle: Text('${character.species} - ${character.status}'),
                        onTap: () {
                          // Nawigacja do ekranu szczegółów
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailScreen(characterId: character.id),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}