import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import '../models/note_model.dart';
import '../services/note_service.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Note> notes = [];
  String keyword = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  Future<void> loadNotes() async {
    notes = await NoteService.getNotes();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotes = notes.where((note) {
      return note.title
          .toLowerCase()
          .contains(keyword.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],

      /// APPBAR
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Smart Note - Nghiêm Xuân Trường - 2351160561",
        ),
      ),

      /// FAB
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const DetailScreen(),
            ),
          );
          loadNotes();
        },
        child: const Icon(Icons.add),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [

                /// SEARCH BAR
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Tìm kiếm...",
                      prefixIcon:
                          const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        keyword = value;
                      });
                    },
                  ),
                ),

                /// EMPTY STATE
                if (filteredNotes.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Icon(Icons.note_alt_outlined,
                              size: 100,
                              color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            "Bạn chưa có ghi chú nào, hãy tạo mới nhé!",
                          ),
                        ],
                      ),
                    ),
                  )
                else

                  /// GRID 2 CỘT
                  Expanded(
                    child: MasonryGridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      padding:
                          const EdgeInsets.all(12),
                      itemCount:
                          filteredNotes.length,
                      itemBuilder:
                          (context, index) {
                        final note =
                            filteredNotes[index];

                        return Dismissible(
                          key: Key(note.id),

                          /// NỀN ĐỎ KHI VUỐT
                          background: Container(
                            decoration:
                                BoxDecoration(
                              color: Colors.red,
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          16),
                            ),
                            alignment:
                                Alignment
                                    .centerRight,
                            padding:
                                const EdgeInsets
                                    .only(
                                        right:
                                            20),
                            child:
                                const Icon(
                              Icons.delete,
                              color:
                                  Colors.white,
                            ),
                          ),

                          /// CONFIRM DELETE
                          confirmDismiss:
                              (_) async {
                            return await showDialog(
                              context:
                                  context,
                              builder:
                                  (_) =>
                                      AlertDialog(
                                title:
                                    const Text(
                                        "Xác nhận"),
                                content:
                                    const Text(
                                        "Bạn có chắc chắn muốn xóa ghi chú này không?"),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(
                                            context,
                                            false),
                                    child:
                                        const Text(
                                            "Hủy"),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(
                                            context,
                                            true),
                                    child:
                                        const Text(
                                            "OK"),
                                  ),
                                ],
                              ),
                            );
                          },

                          onDismissed:
                              (_) async {
                            notes.removeWhere(
                                (n) =>
                                    n.id ==
                                    note.id);
                            await NoteService
                                .saveNotes(
                                    notes);
                            loadNotes();
                          },

                          /// TAP TO EDIT
                          child:
                              GestureDetector(
                            onTap:
                                () async {
                              await Navigator
                                  .push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      DetailScreen(
                                          note:
                                              note),
                                ),
                              );
                              loadNotes();
                            },

                            /// CARD
                            child: Card(
                              color: Color(
                                  note.color), // 🔥 MÀU NOTE
                              elevation: 4,
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                            16),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets
                                        .all(14),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [

                                    /// TITLE
                                    Text(
                                      note.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),

                                    const SizedBox(
                                        height:
                                            8),

                                    /// CONTENT
                                    Text(
                                      note.content,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 14,
                                      ),
                                    ),

                                    const SizedBox(
                                        height:
                                            12),

                                    /// TIME (bottom-right)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          DateFormat("dd/MM/yyyy HH:mm")
                                              .format(note.updatedAt),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
    );
  }
}