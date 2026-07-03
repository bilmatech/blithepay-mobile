import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SearchModal<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final String Function(T) itemBuilder;
  final Function(T) onItemSelected;
  final String placeholder;

  const SearchModal({
    super.key,
    required this.title,
    required this.items,
    required this.itemBuilder,
    required this.onItemSelected,
    this.placeholder = 'Search...',
  });

  @override
  State<SearchModal<T>> createState() => _SearchModalState<T>();
}

class _SearchModalState<T> extends State<SearchModal<T>> {
  late TextEditingController _searchController;
  late List<T> _filteredItems;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredItems = widget.items;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems(String query) {
    if (query.isEmpty) {
      setState(() => _filteredItems = widget.items);
    } else {
      setState(() {
        _filteredItems = widget.items
            .where((item) => widget
                .itemBuilder(item)
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _filterItems,
              decoration: InputDecoration(
                hintText: widget.placeholder,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: const Icon(Icons.tune),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:  const BorderSide(color: AppColors.borderColor),
                ),
              ),
            ),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                final item = _filteredItems[index];
                return ListTile(
                  title: Text(widget.itemBuilder(item)),
                  onTap: () {
                    widget.onItemSelected(item);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
