import 'package:flutter/material.dart';

import '../models/resep.dart';
import '../services/api_service.dart';
import '../services/local_storage.dart';

class ResepDetailScreen extends StatefulWidget {
  final Resep resep;

  const ResepDetailScreen({super.key, required this.resep});

  @override
  State<ResepDetailScreen> createState() => _ResepDetailScreenState();
}

class _ResepDetailScreenState extends State<ResepDetailScreen> {
  late Resep resep;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    resep = widget.resep;
    fetchDetail();
  }

  Future<void> fetchDetail() async {
    try {
      final data = await ApiService.getSingleResep(resep.id);

      if (!mounted) return;

      setState(() {
        resep = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  void _toggleFavorite() async {
    final sudahFavorite = LocalStorage.isFavorite(resep.id);

    if (sudahFavorite) {
      await LocalStorage.removeFavorite(resep.id);
    } else {
      await LocalStorage.addFavorite(resep);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          sudahFavorite ? 'Dihapus dari favorite' : 'Ditambahkan ke favorite',
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: Color(0xFF4A1C24),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Color(0xFFFFE9A6),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Color(0xFFFFC72C)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Color(0xFF722F37)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4A1C24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.bold,
        color: Color(0xFF722F37),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF8E1),
      appBar: AppBar(
        backgroundColor: Color(0xFF722F37),
        foregroundColor: Colors.white,
        title: const Text('Detail Resep'),
        actions: [
          ValueListenableBuilder(
            valueListenable: LocalStorage.favoritesListenable,
            builder: (context, box, child) {
              final isFavorite = LocalStorage.isFavorite(resep.id);

              return IconButton(
                tooltip: 'Favorite',
                onPressed: _toggleFavorite,
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Color(0xFFFFC72C) : Colors.white,
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF722F37)),
            )
          : ListView(
              children: [
                // Gambar
                Image.network(
                  resep.image,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFFFFE9A6),
                      child: const Icon(
                        Icons.broken_image,
                        size: 40,
                        color: Color(0xFF722F37),
                      ),
                    );
                  },
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resep.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A1C24),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${resep.cuisine} • ${resep.mealType.join(', ')}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 14),

                      Row(
                        children: [
                          _infoChip(
                            Icons.star,
                            '${resep.rating.toStringAsFixed(1)} (${resep.reviewCount})',
                          ),
                          const SizedBox(width: 8),
                          _infoChip(Icons.speed, resep.difficulty),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _infoChip(
                            Icons.timer,
                            'Persiapan ${resep.prepTimeMinutes} mnt',
                          ),
                          const SizedBox(width: 8),
                          _infoChip(
                            Icons.soup_kitchen,
                            'Masak ${resep.cookTimeMinutes} mnt',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _infoChip(Icons.people, '${resep.servings} porsi'),
                          const SizedBox(width: 8),
                          _infoChip(
                            Icons.bolt,
                            '${resep.caloriesPerServing} kal/porsi',
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      _sectionTitle('Bahan-bahan'),
                      const SizedBox(height: 10),
                      ...resep.ingredients.map((bahan) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 6),
                                child: Icon(
                                  Icons.circle,
                                  size: 8,
                                  color: Color(0xFF722F37),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  bahan,
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 16),

                      _sectionTitle('Langkah Memasak'),
                      const SizedBox(height: 10),
                      ...resep.instructions.asMap().entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 13,
                                backgroundColor: Color(0xFF722F37),
                                child: Text(
                                  '${entry.key + 1}',
                                  style: const TextStyle(
                                    color: Color(0xFFFFC72C),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  entry.value,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
