import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/shared/widgets/buttons/app_outlined_icon_button.dart';
import 'package:blithepay/shared/widgets/inputs/dropdown_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/notifications_bloc.dart';
import '../bloc/notifications_event.dart';
import '../bloc/notifications_state.dart';
import '../../../../shared/widgets/loaders/shimmer_notification_loader.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  final String _selectedNotification = '';
  String _searchQuery = '';
  String? currentFilter;
  String? currentSort;

  @override
  void initState() {
    super.initState();
    context.read<NotificationsBloc>().add(const GetNotificationsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        title: const Text('Notifications'),
        centerTitle: true,
      ),
      body: BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (context, state) {
          if (state is NotificationsLoading) {
            return const ShimmerNotificationLoader();
          } else if (state is NotificationsLoaded) {
            final notifications = state.notifications;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TextField(
                    //   onChanged: (value) =>
                    //       setState(() => _searchQuery = value),
                    //   decoration: InputDecoration(
                    //     hintText: 'Search Notifications',
                    //     prefixIcon: const Icon(Icons.search),
                    //     border: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(12),
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(height: 20),

                    // Filter and sort
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Today:',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            // Filter button with search
                            AppOutlinedIconButton(
                              onPressed: () => showFilterPopup<String>(
                                context: context,
                                items: ['Deposit'],
                                selectedValue: currentFilter,
                                onItemSelected: (value) =>
                                    setState(() => currentFilter = value),
                                enableSearch: false,
                              ),
                              label: 'Filter',
                              icon: Icons.tune,
                            ),
                            const SizedBox(width: 8),

                            // Sort button without search
                            AppOutlinedIconButton(
                              onPressed: () => showFilterPopup<String>(
                                context: context,
                                items: ['Most Recent', 'Oldest'],
                                selectedValue: currentSort,
                                onItemSelected: (value) =>
                                    setState(() => currentSort = value),
                                enableSearch: false, // no search for sort
                              ),
                              label: 'Sort by',
                              icon: Icons.sort,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Notification list
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: notifications
                          .where(
                            (notif) =>
                                notif.sender.toLowerCase().contains(
                                  _searchQuery.toLowerCase(),
                                ) ||
                                notif.body.toLowerCase().contains(
                                  _searchQuery.toLowerCase(),
                                ),
                          )
                          .length,
                      itemBuilder: (context, index) {
                        final filteredNotifications = notifications
                            .where(
                              (notif) =>
                                  notif.sender.toLowerCase().contains(
                                    _searchQuery.toLowerCase(),
                                  ) ||
                                  notif.body.toLowerCase().contains(
                                    _searchQuery.toLowerCase(),
                                  ),
                            )
                            .toList();
                        final notif = filteredNotifications[index];
                        final isSelected = _selectedNotification == notif.id;

                        return GestureDetector(
                          // onTap: () =>
                          //     setState(() => _selectedNotification = notif.id),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.border,
                                width: isSelected ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(
                                      0.1,
                                    ), // light background
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    notif.sender.isNotEmpty
                                        ? notif.sender[0].toUpperCase()
                                        : '',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            notif.sender,
                                            style: AppTextStyles.headingSmall,
                                          ),
                                          Text(
                                            '${notif.date.month}/${notif.date.day}/${notif.date.year}',
                                            style: AppTextStyles.bodySmall,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        notif.body,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.bodyRegular,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          } else if (state is NotificationsError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
