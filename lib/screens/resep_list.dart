import 'package:flutter/material.dart';

import '../models/resep.dart';
import '../services/api_service.dart';
import '../services/local_storage.dart';
import 'favorite.dart';
import 'login.dart';
import 'resep_detail.dart';

class ResepListScreen extends StatefulWidget {
  const ResepListScreen({super.key});

  @override
  State<ResepListScreen> createState() => _ResepListScreenState();
}

class _ResepListScreenState extends State<ResepListScreen> {
  List<Resep> reseps = [];
  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    fetchResep();
  }

  Future<void> fetchResep() async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    try {
      final data = await ApiService.getResep();

      if (!mounted) return;

      setState(() {
        reseps = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  void _logout() async {
    await LocalStorage.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  // Satu kartu resep pada grid
  Widget _resepCard(Resep resep) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResepDetailScreen(resep: resep),
          ),
        );
      },
      child: Card(
        color: Color(0xFFFFFDF5),
        clipBehavior: Clip.antiAlias,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar sebagai thumbnail
            Expanded(
              child: Image.network(
                resep.image,
                width: double.infinity,
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
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul
                  Text(
                    resep.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A1C24),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Asal makanan • rating
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          resep.cuisine,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      const Text(
                        ' • ',
                        style: TextStyle(fontSize: 10, color: Colors.black54),
                      ),
                      const Icon(Icons.star, size: 12, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text(
                        resep.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Color(0xFF722F37)),
          const SizedBox(height: 10),
          const Text('Gagal mengambil data resep'),
          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFFC72C),
              foregroundColor: Color(0xFF722F37),
            ),
            onPressed: fetchResep,
            child: const Text('Coba Lagi'),
          ),
        ],
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
        title: const Text('Resep Masakan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Favorite',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoriteScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF722F37)),
            )
          : isError
          ? _errorView()
          : GridView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: reseps.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.62,
              ),
              itemBuilder: (context, index) {
                return _resepCard(reseps[index]);
              },
            ),
    );
  }
}
