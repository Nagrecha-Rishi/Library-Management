import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/book_provider.dart';
import '../routes/app_routes.dart';
import 'add_edit_book_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  int selectedFilter = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<BookProvider>().loadBooks();
    });
  }

  List<dynamic> _getFilteredBooks(BookProvider provider) {
    final query = _searchController.text.trim().toLowerCase();

    return provider.books.where((book) {
      final matchesSearch =
          book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query) ||
          book.isbn.toLowerCase().contains(query);

      final matchesFilter = selectedFilter == 0 ||
          (selectedFilter == 1 && book.isIssued) ||
          (selectedFilter == 2 && !book.isIssued);

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BookProvider>(context);
    final books = _getFilteredBooks(provider);

    const primary = Color(0xff6C63FF);
    const secondary = Color(0xff8B85FF);
    const bgColor = Color(0xffF7F9FC);

    return Scaffold(
      backgroundColor: bgColor,

      /// 🔥 FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addBook);
        },
        backgroundColor: const Color.fromARGB(255, 241, 241, 248),
        icon: const Icon(Icons.add),
        label: const Text("Add Book"),
      ),

      body: SafeArea(
        child: Column(
          children: [
            /// 🔥 HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [primary, secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// TOP ROW
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Lumina Library",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child:
                            const Icon(Icons.person, color: Colors.white),
                      )
                    ],
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    "Dashboard",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "${provider.books.length} books available",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// 🔍 SEARCH
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: "Search books...",
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// 🎯 FILTER CHIPS
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _filterChip("All", 0),
                  _filterChip("Issued", 1),
                  _filterChip("Available", 2),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// 📚 BOOK LIST
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : books.isEmpty
                      ? const Center(child: Text("No Books Found"))
                      : ListView.builder(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: books.length,
                          itemBuilder: (context, index) {
                            final book = books[index];

                            return Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  /// 📘 ICON
                                  Container(
                                    height: 48,
                                    width: 48,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [primary, secondary],
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.menu_book,
                                        color: Colors.white),
                                  ),

                                  const SizedBox(width: 12),

                                  /// 📄 INFO
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          book.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          book.author,
                                          style: TextStyle(
                                              color:
                                                  Colors.grey.shade600),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "ISBN: ${book.isbn}",
                                          style: TextStyle(
                                              fontSize: 11,
                                              color:
                                                  Colors.grey.shade500),
                                        ),
                                      ],
                                    ),
                                  ),

                                  /// STATUS + ACTION
                                  Column(
                                    children: [
                                      Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 4),
                                        decoration: BoxDecoration(
                                          color: book.isIssued
                                              ? Colors.red
                                                  .withOpacity(0.1)
                                              : Colors.purple
                                                  .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          book.isIssued
                                              ? "Issued"
                                              : "Available",
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight:
                                                FontWeight.bold,
                                            color: book.isIssued
                                                ? Colors.red
                                                : Colors.purple,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 8),

                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                                Icons.edit,
                                                size: 18),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      AddEditBookScreen(
                                                          book: book),
                                                ),
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                                Icons.delete,
                                                size: 18),
                                            onPressed: () {
                                              provider
                                                  .deleteBook(book.id);
                                            },
                                          ),
                                        ],
                                      )
                                    ],
                                  )
                                ],
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

  /// 🎯 FILTER CHIP
  Widget _filterChip(String text, int index) {
    final isSelected = selectedFilter == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xff6C63FF) : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}