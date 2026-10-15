import 'package:flutter/widgets.dart';

import 'data/dummy_data.dart';
import 'models.dart';

/// 앱 전체 상태. 메모리에만 있고 앱을 끄면 사라진다.
class AppState extends ChangeNotifier {
  int tab = 0;
  bool loggedIn = false;
  String? loginProvider;
  final Set<String> likedEvents = {};
  final Set<String> likedVenues = {};
  final List<Ticket> tickets = [];
  final List<AppNotification> notifications = initialNotifications();

  // 베뉴 탭 화면 상태 (다른 화면에서 "지도에서 보기"로 이동할 때 사용)
  bool venueMapView = true;
  String? selectedVenueId;

  void setTab(int index) {
    tab = index;
    notifyListeners();
  }

  void login(String provider) {
    loggedIn = true;
    loginProvider = provider;
    notifyListeners();
  }

  void logout() {
    loggedIn = false;
    loginProvider = null;
    notifyListeners();
  }

  void toggleEventLike(String id) {
    if (!likedEvents.remove(id)) likedEvents.add(id);
    notifyListeners();
  }

  void toggleVenueLike(String id) {
    if (!likedVenues.remove(id)) likedVenues.add(id);
    notifyListeners();
  }

  void setVenueView({bool? map, String? selected, bool clearSelected = false}) {
    if (map != null) venueMapView = map;
    if (selected != null || clearSelected) selectedVenueId = selected;
    notifyListeners();
  }

  void markAllRead() {
    for (final n in notifications) {
      n.read = true;
    }
    notifyListeners();
  }

  /// 모의 결제: 실제 결제 없이 더미 티켓을 발급한다.
  Ticket issueTicket({
    required Event event,
    required DateTime session,
    required int quantity,
    required String payMethod,
    required int total,
  }) {
    final ticket = Ticket(
      id: (2550001 + tickets.length).toString(),
      event: event,
      session: session,
      quantity: quantity,
      payMethod: payMethod,
      total: total,
    );
    tickets.insert(0, ticket);
    notifications.insert(
      0,
      AppNotification(title: '예매 완료', body: '${event.title} 티켓 $quantity매가 발급되었어요.', time: DateTime.now()),
    );
    notifyListeners();
    return ticket;
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child}) : super(notifier: state);

  /// 상태 변화 시 다시 그려야 하는 build 안에서 사용.
  static AppState of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;

  /// 콜백 안에서 사용 (구독하지 않음).
  static AppState read(BuildContext context) => context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
