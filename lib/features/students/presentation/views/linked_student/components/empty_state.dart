import 'package:blithepay/core/navigation/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Widget buildEmptyState(BuildContext context) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.school_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 24),
          const Text(
            'No Linked Students',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          const Text(
            'You have not linked any students yet.\nAdd a child to get started.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.push(AppRoutes.linkchildSchool),
            child: const Text('Add Child'),
          ),
        ],
      ),
    ),
  );
}
