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
