import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisata_candi/models/candi.dart'; // Pastikan sudah ada model Candi
import 'package:wisata_candi/screens/detail_screen.dart';
import 'package:wisata_candi/data/candi_data.dart';
class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  late List<Candi> _favorites;

  @override
  void initState() {
    super.initState();
    _favorites = [];
    _loadFavorites();
  }

  // Fungsi untuk memuat candi favorit dari SharedPreferences
  void _loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Candi> favoriteCandis = [];

    // Periksa semua objek Candi apakah masuk dalam daftar favorit
    for (var candi in candiList) { // allCandis adalah daftar semua Candi
      bool isFavorite = prefs.getBool('favorite_${candi.name.replaceAll(' ', '_')}') ?? false;
      if (isFavorite) {
        favoriteCandis.add(candi);
      }
    }

    setState(() {
      _favorites = favoriteCandis; // _favoriteCandis adalah daftar favorit di FavoriteScreen
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Favorite Candi'),
        ),
        body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: _favorites.isEmpty
                ? const Center(child: Text('No favorites added yet'))
                : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: _favorites.length,
              itemBuilder: (context, index) {
                final candi = _favorites[index];
                return GestureDetector(
                  onTap: () async {
                    // Navigasi ke DetailScreen dan tunggu hasilnya
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(candi: candi),
                      ),
                    );

                    // Jika status favorit berubah, perbarui daftar
                    if (result != null) {
                      _loadFavorites();
                    }
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    margin: const EdgeInsets.all(4),
                    elevation: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Hero(
                            tag: candi.imageAsset,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: CachedNetworkImage(
                                imageUrl: candi.imageUrls[0],
                                width: double.infinity,
                                height: 120,
                                fit : BoxFit.cover,
                                placeholder: (context,
                                    url) => Container(
                                  width: 120,
                                  height: 120,
                                  color: Colors.deepPurple[50],
                                ),
                                errorWidget: (context, url, error) =>
                                const Icon(
                                  Icons.error,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            top: 8,
                          ),
                          child: Text(
                            candi.name, // Menampilkan nama candi
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16, bottom: 8),
                          child: Text(
                            candi.type, // Menampilkan jenis candi
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ),
    );
  }
}