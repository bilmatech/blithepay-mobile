import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class SearchSchoolView extends StatefulWidget {
  const SearchSchoolView({super.key});

  @override
  State<SearchSchoolView> createState() => _SearchSchoolViewState();
}

class _SearchSchoolViewState extends State<SearchSchoolView> {
  final _searchController = TextEditingController();
  
  final mockSchools = [
    'Seaman International Nursery & Primary School',
    'Lagos State Model School',
    'British International School',
    'Greenfield International School',
    'Ikoyi Cantonment Primary School',
  ];

  late List<String> filteredSchools;

  @override
  void initState() {
    super.initState();
    filteredSchools = mockSchools;
  }

  void _filterSchools(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredSchools = mockSchools;
      } else {
        filteredSchools = mockSchools
            .where((school) =>
                school.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                onChanged: _filterSchools,
                decoration: InputDecoration(
                  hintText: 'Search school...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: const Icon(Icons.tune),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredSchools.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.school,
                            color: AppColors.white,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          filteredSchools[index],
                          style: AppTextStyles.bodyMedium,
                        ),
                        onTap: () => Navigator.pop(context, filteredSchools[index]),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
