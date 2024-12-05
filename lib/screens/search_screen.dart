import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisata_candi/data/candi_data.dart';

import '../models/candi.dart';
import 'detail_screen.dart';

class SearchScreen extends StatefulWidget {

  @override
  State<SearchScreen> createState() => _SearchScreen();
}

class _SearchScreen extends State<SearchScreen> {
  // TODO: 1: Deklarasi variable
  late List<Candi> _favorites;
  List<Candi> _filteredItems = [];
  String _searchQuery = '';
  final TextEditingController _controller = TextEditingController();
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
  void onChangeSearch(String value) {
    _filteredItems.clear();
    setState(() {
      for(Candi _cand in candiList) {
        if(_cand.name.toLowerCase().contains(value.toLowerCase())) {
          _filteredItems.add(_cand);
        }
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // TODO: 2: Buat AppBar dengan judul pencarian candi.
      appBar: AppBar(
        title: const Text("Pencarian Candi"),
      ),
      // TODO: 3: Buat body berupa column.
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TODO: 4: Buat TextField pencarian sebagai anak dari column.
            TextFormField(
              controller: _controller,
              onChanged: (value) {
                onChangeSearch(value);
              },
              decoration: const InputDecoration(
                labelText: "Cari candi...",
                prefixIcon: Icon(Icons.search),
                focusedBorder: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12)
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            // TODO: 5: Buat ListView hasil pencarian sebagai anak dari column.
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: _filteredItems.length,
                itemBuilder: (context, index) {
                  final candi = _filteredItems[index];

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
                      margin: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            width: 100,
                            height: 100,
                            child: Hero(
                              tag:  candi.imageAsset,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: CachedNetworkImage(
                                  imageUrl: candi.imageUrls[0],
                                  width: 120,
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
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(candi.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                                  const SizedBox(height: 4,),
                                  Text(
                                    candi.location,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
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
          ],
        ),
      ),
    );
  }
}
