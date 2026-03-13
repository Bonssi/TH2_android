import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note_model.dart';

class NoteService {
  static const String storageKey = "smart_note_storage";

  static Future<List<Note>> getNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(storageKey);

      if (data == null || data.isEmpty) return [];

      final decoded = jsonDecode(data);

      if (decoded is! List) return [];

      return decoded.map<Note>((e) {
        return Note.fromMap(e as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print("Lỗi đọc dữ liệu: $e");
      return [];
    }
  }

  static Future<void> saveNotes(List<Note> notes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded =
          jsonEncode(notes.map((e) => e.toMap()).toList());
      await prefs.setString(storageKey, encoded);
    } catch (e) {
      print("Lỗi lưu dữ liệu: $e");
    }
  }
}