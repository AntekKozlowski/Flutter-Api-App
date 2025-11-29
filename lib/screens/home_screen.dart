import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/character_provider.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pobierz dane startowe po załadowaniu widoku
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CharacterProvider>(context, listen: false).fetchCharacters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Rick and Morty Wiki')),
      body: Column(
        children: [
          // WYSZUKIWARKA
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
                    // Wywołanie logiki z Providera
                    Provider.of<CharacterProvider>(context, listen: false)
                        .fetchCharacters(query: _searchController.text);
                  },
                ),
              ),
              onSubmitted: (value) {
                Provider.of<CharacterProvider>(context, listen: false)
                    .fetchCharacters(query: value);
              },
            ),
          ),

          // LISTA WYNIKÓW
          Expanded(
            child: Consumer<CharacterProvider>(
              builder: (context, provider, child) {
                // Obsługa ładowania
                if (provider.isLoading) {
                  return Center(child: CircularProgressIndicator());
                }

                // Obsługa błędów
                if (provider.errorMessage.isNotEmpty) {
                  return Center(child: Text(provider.errorMessage));
                }

                // Lista
                return ListView.builder(
                  itemCount: provider.characters.length,
                  itemBuilder: (context, index) {
                    final character = provider.characters[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: Image.network(character.image, width: 50),
                        title: Text(character.name),
                        subtitle: Text('${character.species} - ${character.status}'),
                        onTap: () {
                          // Przejście do szczegółów
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