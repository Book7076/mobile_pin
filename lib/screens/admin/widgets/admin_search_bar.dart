import 'package:flutter/material.dart';
import '../admin_theme.dart';

class AdminSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const AdminSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: AdminTheme.searchBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AdminTheme.searchBorder, width: 1.2),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: const InputDecoration(
                hintText: 'ค้นหาร้านค้า',
                hintStyle: TextStyle(
                  color: Color(0xFF9E9E9E),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(
                fontSize: 14,
                color: AdminTheme.textPrimary,
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 18, color: Colors.grey),
              onPressed: onClear,
              splashRadius: 18,
            ),
          const Padding(
            padding: EdgeInsets.only(right: 14.0),
            child: Icon(
              Icons.search_rounded,
              color: AdminTheme.searchIcon,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}
