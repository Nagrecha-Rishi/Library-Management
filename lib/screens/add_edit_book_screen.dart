import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/book_model.dart';
import '../providers/book_provider.dart';

class AddEditBookScreen extends StatefulWidget {
  final Book? book;

  const AddEditBookScreen({super.key, this.book});

  @override
  State<AddEditBookScreen> createState() => _AddEditBookScreenState();
}

class _AddEditBookScreenState extends State<AddEditBookScreen> {
  final title = TextEditingController();
  final author = TextEditingController();
  final isbn = TextEditingController();
  final quantity = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    if (widget.book != null) {
      title.text = widget.book!.title;
      author.text = widget.book!.author;
      isbn.text = widget.book!.isbn;
      quantity.text = widget.book!.quantity.toString();
    }
  }

  @override
  void dispose() {
    title.dispose();
    author.dispose();
    isbn.dispose();
    quantity.dispose();
    super.dispose();
  }

  String generateBookId() {
    return '${DateTime.now().millisecondsSinceEpoch}${Random().nextInt(999)}';
  }

  Future<void> _saveBook() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final provider = context.read<BookProvider>();

    final book = Book(
      id: widget.book?.id ?? generateBookId(),
      title: title.text.trim(),
      author: author.text.trim(),
      isbn: isbn.text.trim(),
      quantity: int.parse(quantity.text.trim()),
      isIssued: widget.book?.isIssued ?? false,
    );

    if (widget.book == null) {
      await provider.addBook(book);
    } else {
      await provider.updateBook(widget.book!.id, book);
    }

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xff8B5CF6);
    const secondary = Color(0xff6366F1);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xffEEF2FF),
              Color(0xffF8FAFF),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  children: [

                    /// 🔙 BACK + HEADER
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back),
                        ),
                        const Spacer(),
                      ],
                    ),

                    /// 🔥 TOP ICON CARD (LIKE LOGIN)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [primary, secondary],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withOpacity(0.4),
                            blurRadius: 25,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.menu_book,
                              color: Colors.white, size: 36),
                          SizedBox(height: 10),
                          Text(
                            "Manage Book",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// 🧊 FORM CARD
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 30,
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Text(
                              widget.book == null
                                  ? "Add Book"
                                  : "Edit Book",
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 20),

                            _input(
                              controller: title,
                              label: "Title",
                              icon: Icons.book,
                            ),
                            const SizedBox(height: 16),

                            _input(
                              controller: author,
                              label: "Author",
                              icon: Icons.person,
                            ),
                            const SizedBox(height: 16),

                            _input(
                              controller: isbn,
                              label: "ISBN",
                              icon: Icons.qr_code,
                              keyboard: TextInputType.number,
                              formatter: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                            ),
                            const SizedBox(height: 16),

                            _input(
                              controller: quantity,
                              label: "Quantity",
                              icon: Icons.numbers,
                              keyboard: TextInputType.number,
                              formatter: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                            ),

                            const SizedBox(height: 24),

                            /// 🔥 BUTTON (LIKE LOGIN)
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed:
                                    _isLoading ? null : _saveBook,
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(16),
                                  ),
                                ),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [primary, secondary],
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(16),
                                  ),
                                  child: Center(
                                    child: _isLoading
                                        ? const CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                        : Text(
                                            widget.book == null
                                                ? "Save Book"
                                                : "Update Book",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight:
                                                  FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(context),
                              child: const Text("Cancel"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    List<TextInputFormatter>? formatter,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      inputFormatters: formatter,
      validator: (value) =>
          value == null || value.isEmpty ? "$label required" : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}