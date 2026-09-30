import 'package:lottie/lottie.dart';
import 'package:lekhan_ai/core/enums/notification_status_enum.dart';
import 'package:lekhan_ai/core/theme/app_color.dart';
import 'package:lekhan_ai/core/utils/snack_bars.dart';
import 'package:lekhan_ai/features/notifications/presentation/widgets/filter_option.dart';
import 'package:lekhan_ai/features/notifications/presentation/widgets/notification_list.dart';
import 'package:lekhan_ai/features/notifications/presentation/widgets/notification_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/notification_bloc.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ScrollController _scrollController = ScrollController();
  String _currentFilter = 'all';
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialNotifications();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialNotifications() {
    context.read<NotificationBloc>().add(
          const NotificationEvent.getNotifications(
            filter: 'all',
            page: 1,
            isRefresh: true,
          ),
        );
  }

  void _onScroll() {
    if (_isLoadingMore) return;

    if (_isBottom) {
      final state = context.read<NotificationBloc>().state;

      state.maybeWhen(
        loaded: (notifications, currentFilter, isLoading, totalCount,
            currentPage, hasReachedEnd) {
          if (!isLoading && !hasReachedEnd && notifications.isNotEmpty) {
            setState(() {
              _isLoadingMore = true;
            });

            context.read<NotificationBloc>().add(
                  NotificationEvent.loadMoreNotifications(
                    filter: currentFilter,
                    page: currentPage + 1,
                  ),
                );

            // Reset flag after delay to prevent rapid calls
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (mounted) {
                setState(() {
                  _isLoadingMore = false;
                });
              }
            });
          }
        },
        orElse: () {},
      );
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return maxScroll > 0 && currentScroll >= (maxScroll * 0.95);
  }

  void _refreshNotifications() {
    context.read<NotificationBloc>().add(
          NotificationEvent.getNotifications(
            filter: _currentFilter,
            page: 1,
            isRefresh: true,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationBloc, NotificationState>(
      listener: (context, state) {
        state.maybeWhen(
          error: (message) => SnackBars.error(context, message),
          orElse: () {},
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
          actions: [
            BlocBuilder<NotificationBloc, NotificationState>(
              builder: (context, state) {
                int unreadCount = 0;
                String currentFilter = 'all';

                state.maybeWhen(
                  loaded: (notifications, filter, isLoading, totalCount,
                      currentPage, hasReachedEnd) {
                    unreadCount = notifications.where((n) => !n.isSeen).length;
                    currentFilter = filter;

                    // Update current filter without setState in build
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_currentFilter != currentFilter) {
                        setState(() {
                          _currentFilter = currentFilter;
                        });
                      }
                    });
                  },
                  orElse: () {},
                );

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      onPressed: () =>
                          _showFilterBottomSheet(context, currentFilter),
                      icon: const Icon(Icons.more_vert_sharp),
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: unreadCount > 9
                                ? BoxShape.rectangle
                                : BoxShape.circle,
                            borderRadius: unreadCount > 9
                                ? BorderRadius.circular(8)
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              unreadCount > 99 ? '99+' : '$unreadCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            )
          ],
        ),
        body: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            return state.maybeWhen(
              initial: () => const NotificationShimmerList(),
              loading: () => const NotificationShimmerList(),
              loaded: (notifications, currentFilter, isLoading, totalCount,
                  currentPage, hasReachedEnd) {
                return RefreshIndicator(
                  onRefresh: () async {
                    _refreshNotifications();
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  child: NotificationsList(
                    notifications: notifications,
                    isLoading: isLoading,
                    hasReachedEnd: hasReachedEnd,
                    scrollController: _scrollController,
                  ),
                );
              },
              error: (message) => RefreshIndicator.adaptive(
                color: AppColors.primary,
                onRefresh: () async {
                  _refreshNotifications();
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Lottie.asset(
                              'assets/lottie/404.json',
                              width: 200,
                              height: 200,
                              fit: BoxFit.contain,
                              repeat: true,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Something went wrong',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                message,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppColors.textSecondary,
                                      height: 1.4,
                                    ),
                                maxLines: 3,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: _refreshNotifications,
                              icon: const Icon(Icons.refresh, size: 18),
                              label: const Text('Try Again'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
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
              orElse: () => const SizedBox.shrink(),
            );
          },
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context, String currentFilter) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bottomSheetContext) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios,
                        color: Color(0xFF333333)),
                    onPressed: () => Navigator.pop(bottomSheetContext),
                  ),
                  Text(
                    'Filter',
                    style: Theme.of(bottomSheetContext)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF333333),
                        ),
                  ),
                ],
              ),
              const Divider(
                height: 20,
                thickness: 1,
                color: Color(0xFFEEEEEE),
              ),
              FilterOption(
                filterName: 'All',
                selectedFilter: currentFilter,
                onChanged: (value) =>
                    _onFilterChanged('all', bottomSheetContext),
              ),
              FilterOption(
                filterName: NotificationStatus.unread.displayName,
                selectedFilter: currentFilter,
                onChanged: (value) => _onFilterChanged(
                    NotificationStatus.unread.toApiString().toLowerCase(),
                    bottomSheetContext),
              ),
              FilterOption(
                filterName: NotificationStatus.read.displayName,
                selectedFilter: currentFilter,
                onChanged: (value) => _onFilterChanged(
                    NotificationStatus.read.toApiString().toLowerCase(),
                    bottomSheetContext),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _onFilterChanged(String filter, BuildContext bottomSheetContext) {
    // Update current filter
    setState(() {
      _currentFilter = filter;
      _isLoadingMore = false;
    });

    // Load notifications with new filter from page 1
    context.read<NotificationBloc>().add(
          NotificationEvent.getNotifications(
            filter: filter,
            page: 1,
            isRefresh: true,
          ),
        );

    Navigator.pop(bottomSheetContext);
  }
}
