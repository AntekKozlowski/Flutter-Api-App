import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/character_provider.dart';

class DetailScreen extends StatefulWidget {
  final int characterId;

  DetailScreen({required this.characterId});

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  void initState() {
    super.initState();
    // Wywołanie drugiego endpointu API (szczegóły)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CharacterProvider>(context, listen: false)
          .fetchCharacterDetails(widget.characterId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Szczegóły postaci')),
      body: Consumer<CharacterProvider>(
        builder: (context, provider, child) {
          if (provider.isDetailLoading) {
            return Center(child: CircularProgressIndicator());
          }

          final character = provider.selectedCharacter;

          if (character == null) {
            return Center(child: Text('Nie udało się pobrać danych.'));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                CircleAvatar(
                  radius: 80,
                  backgroundImage: NetworkImage(character.image),
                ),
                SizedBox(height: 20),
                Text(
                  character.name,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                _buildInfoRow('Status', character.status),
                _buildInfoRow('Gatunek', character.species),
                _buildInfoRow('Płeć', character.gender),
                _buildInfoRow('Pochodzenie', character.origin),
                _buildInfoRow('ID', character.id.toString()),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(value, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}