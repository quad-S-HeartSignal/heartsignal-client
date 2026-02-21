import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatHistoryDrawer extends StatefulWidget {
  const ChatHistoryDrawer({super.key});

  @override
  State<ChatHistoryDrawer> createState() => _ChatHistoryDrawerState();
}

class _ChatHistoryDrawerState extends State<ChatHistoryDrawer> {
  bool _isSelectionMode = false;
  final List<bool> _selectedItems = List.generate(5, (_) => false);

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedItems.fillRange(0, _selectedItems.length, false);
      }
    });
  }

  void _toggleItemSelection(int index) {
    setState(() {
      _selectedItems[index] = !_selectedItems[index];
    });
  }

  void _deleteSelected() {
    setState(() {
      _isSelectionMode = false;
      _selectedItems.fillRange(0, _selectedItems.length, false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool hasSelection = _selectedItems.contains(true);

    return Drawer(
      backgroundColor: const Color(0xFFFDE8E8), // Light pink background
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFA7B7B), // Search bar pink
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  style: GoogleFonts.notoSans(color: Colors.black),
                  decoration: InputDecoration(
                    icon: const Icon(Icons.search, color: Colors.black),
                    border: InputBorder.none,
                    hintText: '검색',
                    hintStyle: GoogleFonts.notoSans(color: Colors.black54),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '챗 내역',
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  if (!_isSelectionMode)
                    GestureDetector(
                      onTap: _toggleSelectionMode,
                      child: Text(
                        '선택',
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: hasSelection ? _deleteSelected : null,
                      child: Icon(
                        Icons.delete_outline,
                        color: hasSelection ? Colors.black : Colors.black26,
                        size: 24,
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: _isSelectionMode
                        ? () => _toggleItemSelection(index)
                        : null,
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          if (_isSelectionMode)
                            Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: Checkbox(
                                  value: _selectedItems[index],
                                  onChanged: (val) {
                                    if (val != null) {
                                      _toggleItemSelection(index);
                                    }
                                  },
                                  fillColor: MaterialStateProperty.resolveWith(
                                    (states) => Colors.transparent,
                                  ),
                                  checkColor: Colors.black,
                                  side: const BorderSide(
                                    color: Colors.black,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          Expanded(
                            child: Text(
                              'Chat ${index + 1}',
                              style: GoogleFonts.notoSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.black,
                            size: 20,
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
