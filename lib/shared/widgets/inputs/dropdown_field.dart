import 'package:flutter/material.dart';
import '../../../core/constants/app_text_styles.dart';

class DropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?>? onChanged;
  final bool enabled;

  const DropdownField({
    super.key,
    required this.label,
    this.value,
    required this.items,
    required this.itemLabel,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodyLarge),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          dropdownColor: Theme.of(context).scaffoldBackgroundColor,
          initialValue: value,
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(
                    itemLabel(item),
                    style: AppTextStyles.bodyRegular,
                  ),
                ),
              )
              .toList(),
          onChanged: enabled ? onChanged : null,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}

/// Reusable filter/sort popup with optional search
Future<void> showFilterPopup<T>({
  required BuildContext context,
  required List<T> items,
  required T? selectedValue,
  required ValueChanged<T> onItemSelected,
  bool enableSearch = false,
  String searchHint = 'Search...', // optional customizable hint
}) {
  TextEditingController searchController = TextEditingController();
  List<T> filteredItems = List.from(items);

  return showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.3),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          // Filter items by search query
          if (enableSearch) {
            filteredItems = items
                .where(
                  (item) => item.toString().toLowerCase().contains(
                    searchController.text.toLowerCase(),
                  ),
                )
                .toList();
          }

          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Optional search field
                  if (enableSearch)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: TextField(
                        controller: searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: searchHint,
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),

                  // Item list
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: filteredItems.map((item) {
                          final isSelected = item == selectedValue;
                          return InkWell(
                            onTap: () {
                              onItemSelected(item);
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 2),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.grey.shade100
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: isSelected
                                    ? const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 2,
                                          offset: Offset(0, 1),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Text(
                                item.toString(),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

/// Reusable bottom sheet for selecting an item from a list
Future<void> showItemSelectionSheet<T>({
  required BuildContext context,
  required String title,
  required List<T> items,
  T? selectedItem,
  required ValueChanged<T> onItemSelected,
  bool enableSearch = true,
  String Function(T)? itemLabel, // optional custom label
}) {
  TextEditingController searchController = TextEditingController();
  List<T> filteredItems = List.from(items);

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          // Filter items if search enabled
          if (enableSearch) {
            filteredItems = items
                .where(
                  (item) =>
                      (itemLabel != null ? itemLabel(item) : item.toString())
                          .toLowerCase()
                          .contains(searchController.text.toLowerCase()),
                )
                .toList();
          }

          return DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.3,
            maxChildSize: 0.8,
            expand: false,
            builder: (_, controller) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  children: [
                    // Drag indicator
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // Title
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Search field
                    // if (enableSearch)
                    //   TextField(
                    //     controller: searchController,
                    //     onChanged: (_) => setState(() {}),
                    //     decoration: InputDecoration(
                    //       hintText: 'Search...',
                    //       prefixIcon: const Icon(Icons.search),
                    //       border: OutlineInputBorder(
                    //         borderRadius: BorderRadius.circular(12),
                    //       ),
                    //       contentPadding: const EdgeInsets.symmetric(
                    //         horizontal: 16,
                    //         vertical: 12,
                    //       ),
                    //     ),
                    //   ),
                    const SizedBox(height: 12),

                    // Items list
                    Expanded(
                      child: filteredItems.isEmpty
                          ? const Center(child: Text('No items found'))
                          : ListView.builder(
                              controller: controller,
                              itemCount: filteredItems.length,
                              itemBuilder: (context, index) {
                                final item = filteredItems[index];
                                final label = itemLabel != null
                                    ? itemLabel(item)
                                    : item.toString();
                                final isSelected = item == selectedItem;

                                return InkWell(
                                  onTap: () {
                                    onItemSelected(item);
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.grey.shade100
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: isSelected
                                          ? [
                                              const BoxShadow(
                                                color: Colors.black12,
                                                blurRadius: 2,
                                                offset: Offset(0, 1),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Text(
                                      label,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
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
            },
          );
        },
      );
    },
  );
}
