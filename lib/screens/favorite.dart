import 'package:flutter/material.dart';

import '../services/local_storage.dart';
import 'resep_detail.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF8E1),
      appBar: AppBar(
        backgroundColor: Color(0xFF722F37),
        foregroundColor: Colors.white,
        title: const Text('Favorite'),
      ),

      body: ValueListenableBuilder(
        valueListenable: LocalStorage.favoritesListenable,
        builder: (context, box, child) {
          final favorites = LocalStorage.getFavorites();

          if (favorites.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada resep favorite.',
                style: TextStyle(color: Color(0xFF722F37), fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final resep = favorites[index];

              return Card(
                color: Color(0xFFFFFDF5),
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResepDetailScreen(resep: resep),
                      ),
                    );
                  },
                  leading: Container(
                    width: 60,
                    height: 60,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Image.network(
                      resep.image,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFFFFE9A6),
                          child: const Icon(
                            Icons.broken_image,
                            size: 24,
                            color: Color(0xFF722F37),
                          ),
                        );
                      },
                    ),
                  ),
                  title: Text(
                    resep.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A1C24),
                    ),
                  ),
                  subtitle: Text('${resep.cuisine} • ${resep.difficulty}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Color(0xFF722F37)),
                    tooltip: 'Hapus dari favorite',
                    onPressed: () {
                      LocalStorage.removeFavorite(resep.id);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
