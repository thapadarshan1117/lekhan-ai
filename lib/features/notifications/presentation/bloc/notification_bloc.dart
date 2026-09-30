import 'package:flutter/foundation.dart';
import 'package:lekhan_ai/core/enums/notification_status_enum.dart';
import 'package:lekhan_ai/features/notifications/domain/usecases/mark_as_read_usecase.dart';
import 'package:lekhan_ai/shared/domain/models/paginated_response_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:rxdart/rxdart.dart';
import '../../domain/models/notification_model.dart';
import '../../domain/usecases/get_notifications_usecase.dart';

part 'notification_event.dart';
part 'notification_state.dart';
part 'notification_bloc.freezed.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  static const int _pageSize = 12;
  static const _throttleDuration = Duration(milliseconds: 1000);

  // Cache for different filters
  final Map<String, List<NotificationModel>> _filterCache = {};
  final Map<String, Set<String>> _loadedIds = {};
  final Map<String, int> _currentPage = {};
  final Map<String, bool> _hasReachedEnd = {};
  final Map<String, int> _totalItems = {};

  final GetNotificationsUsecase getNotificationsUsecase;
  final MarkAsReadUsecase markAsReadUsecase;

  NotificationBloc({
    required this.getNotificationsUsecase,
    required this.markAsReadUsecase,
  }) : super(const NotificationState.initial()) {
    on<_GetNotifications>(_onGetNotifications);
    on<_LoadMoreNotifications>(
      _onLoadMoreNotifications,
      transformer: _throttleDroppable(_throttleDuration),
    );
    on<_MarkAsRead>(_onMarkAsRead);
  }

  EventTransformer<E> _throttleDroppable<E>(Duration duration) {
    return (events, mapper) {
      return droppable<E>().call(events.throttleTime(duration), mapper);
    };
  }

  Future<void> _onGetNotifications(
    _GetNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    final filter = event.filter?.toLowerCase() ?? 'all';

    // Show loading for initial load or refresh
    if (event.page == 1 || event.isRefresh) {
      emit(const NotificationState.loading());
    }

    // Reset cache for refresh or initial load
    if (event.isRefresh || event.page == 1) {
      _resetFilterCache(filter);
    }

    try {
      final result = await getNotificationsUsecase(
        GetNotificationsParams(
          page: event.page,
          pageSize: _pageSize,
          filter: filter,
        ),
      );

      result.fold(
        (failure) {
          // Use toString() to avoid assuming a 'message' getter exists on the failure object.
          emit(NotificationState.error(failure.toString()));
        },
        (paginationResponse) {
          _updateCache(filter, paginationResponse, event.page);

          emit(NotificationState.loaded(
            notifications: List.from(_filterCache[filter]!),
            currentFilter: filter,
            isLoading: false,
            totalCount: _totalItems[filter]!,
            currentPage: _currentPage[filter]!,
            hasReachedEnd: _hasReachedEnd[filter]!,
          ));
        },
      );
    } catch (e) {
      emit(NotificationState.error(
          'An unexpected error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onLoadMoreNotifications(
    _LoadMoreNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    final currentState = state;

    await currentState.maybeWhen(
      loaded: (notifications, currentFilter, isLoading, totalCount, currentPage,
          hasReachedEnd) async {
        // Prevent multiple simultaneous requests
        if (isLoading || hasReachedEnd) {
          return;
        }

        final filter = event.filter.toLowerCase();
        final nextPage = (_currentPage[filter] ?? 0) + 1;

        if (event.page <= (_currentPage[filter] ?? 0)) {
          return;
        }

        emit(NotificationState.loaded(
          notifications: notifications,
          currentFilter: currentFilter,
          isLoading: true,
          totalCount: totalCount,
          currentPage: currentPage,
          hasReachedEnd: hasReachedEnd,
        ));

        try {
          final result = await getNotificationsUsecase(
            GetNotificationsParams(
              page: nextPage,
              pageSize: _pageSize,
              filter: filter,
            ),
          );

          result.fold(
            (failure) {
              // Revert loading state on error
              emit(NotificationState.loaded(
                notifications: notifications,
                currentFilter: currentFilter,
                isLoading: false,
                totalCount: totalCount,
                currentPage: currentPage,
                hasReachedEnd: hasReachedEnd,
              ));
            },
            (paginationResponse) {
              _updateCache(filter, paginationResponse, nextPage,
                  isLoadMore: true);

              emit(NotificationState.loaded(
                notifications: List.from(_filterCache[filter]!),
                currentFilter: currentFilter,
                isLoading: false,
                totalCount: _totalItems[filter]!,
                currentPage: _currentPage[filter]!,
                hasReachedEnd: _hasReachedEnd[filter]!,
              ));
            },
          );
        } catch (e) {
          // Revert loading state on error
          emit(NotificationState.loaded(
            notifications: notifications,
            currentFilter: currentFilter,
            isLoading: false,
            totalCount: totalCount,
            currentPage: currentPage,
            hasReachedEnd: hasReachedEnd,
          ));
        }
      },
      orElse: () {},
    );
  }

  Future<void> _onMarkAsRead(
    _MarkAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    final currentState = state;

    await currentState.maybeWhen(
      loaded: (notifications, currentFilter, isLoading, totalCount, currentPage,
          hasReachedEnd) async {
        // Optimistically update UI
        final updatedNotifications = notifications.map((notification) {
          if (notification.id == event.notificationId) {
            return notification.copyWith(
              isSeen: true,
              status: NotificationStatus.read,
            );
          }
          return notification;
        }).toList();

        emit(NotificationState.loaded(
          notifications: updatedNotifications,
          currentFilter: currentFilter,
          isLoading: false,
          totalCount: totalCount,
          currentPage: currentPage,
          hasReachedEnd: hasReachedEnd,
        ));

        // Update cache as well
        final filter = currentFilter.toLowerCase();
        _filterCache[filter] = updatedNotifications;

        try {
          final params = MarkAsReadParams(notificationId: event.notificationId);
          final result = await markAsReadUsecase(params);

          result.fold(
            (failure) {
              // Revert on failure
              emit(NotificationState.loaded(
                notifications: notifications,
                currentFilter: currentFilter,
                isLoading: false,
                totalCount: totalCount,
                currentPage: currentPage,
                hasReachedEnd: hasReachedEnd,
              ));
            },
            (success) {
              debugPrint('Notification marked as read successfully');
            },
          );
        } catch (e) {
          // Revert on error
          emit(NotificationState.loaded(
            notifications: notifications,
            currentFilter: currentFilter,
            isLoading: false,
            totalCount: totalCount,
            currentPage: currentPage,
            hasReachedEnd: hasReachedEnd,
          ));
        }
      },
      orElse: () {},
    );
  }

  void _resetFilterCache(String filter) {
    _filterCache[filter] = [];
    _loadedIds[filter] = <String>{};
    _currentPage[filter] = 0;
    _hasReachedEnd[filter] = false;
    _totalItems[filter] = 0;
  }

  void _updateCache(
    String filter,
    PaginationResponseModel<NotificationModel> paginationResponse,
    int page, {
    bool isLoadMore = false,
  }) {
    // Initialize cache if not exists
    _filterCache[filter] ??= [];
    _loadedIds[filter] ??= <String>{};

    if (isLoadMore) {
      // For load more, append unique notifications
      final uniqueNotifications = paginationResponse.results
          .where(
              (notification) => !_loadedIds[filter]!.contains(notification.id))
          .toList();

      _filterCache[filter]!.addAll(uniqueNotifications);
      _loadedIds[filter]!.addAll(uniqueNotifications.map((n) => n.id));
    } else {
      // For initial load, replace cache
      _filterCache[filter] = List.from(paginationResponse.results);
      _loadedIds[filter] = paginationResponse.results.map((n) => n.id).toSet();
    }

    // Update tracking variables
    _currentPage[filter] = paginationResponse.currentPage;
    _totalItems[filter] = paginationResponse.totalItems;
    _hasReachedEnd[filter] = paginationResponse.next == null;
  }
}
