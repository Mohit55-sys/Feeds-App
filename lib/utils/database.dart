import 'dart:convert';
import 'dart:typed_data';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:path_provider/path_provider.dart';

class ImageTextDatabase {
  static Database? _database;


  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    } else {
      _database = await _initializeDatabase();
      return _database!;
    }
  }


  Future<Database> _initializeDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'image_text.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

    Future<void> _onCreate(Database db, int version) async {

    await db.execute('''
      CREATE TABLE image_text (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        text TEXT,
        images VARCHAR(5000)
      )
    ''');
  }

    Future<void> insertImagesWithText(String text, List<Uint8List> images) async {
    final db = await database;


    List<String> base64Images = images.map((img) => base64Encode(img)).toList();


    String base64ImagesJson = jsonEncode(base64Images);


        var response = await db.insert('image_text', {
      'text': text,
      'images': base64ImagesJson,
    });

  }

  // Retrieve images and text from the database
  Future<List<Map<String, dynamic>>> getImagesWithText() async {
    final db = await database;

    // Query the table for the stored images and text
    final List<Map<String, dynamic>> result = await db.query('image_text');

    // Decode base64 strings back into images

    return result.map((row) {
      print("reslt---->$row");
      // Decode base64 images (which were stored as JSON)
      List<dynamic> base64Images = jsonDecode(row['images']);
      List<Uint8List> images = base64Images.map((img) => base64Decode(img)).toList();

      print("here-----Ssss>$images");
      return {
        'text': row['text'],
        'images': images,
      };
    }).toList();
  }
}
