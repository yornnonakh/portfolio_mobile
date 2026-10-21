import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final analyticsServiceProvider = Provider<AnalyticsService>((ref) => AnalyticsService());

final analyticsNavigatorObserverProvider = Provider<NavigatorObserver>((ref) {
  final service = ref.watch(analyticsServiceProvider);
  return AnalyticsNavigatorObserver(service);
});

class AnalyticsService {
  final List<AnalyticsEvent> _events = [];

  List<AnalyticsEvent> get events => List.unmodifiable(_events);

  void trackScreen(String screenName, {Map<String, dynamic>? parameters}) {
    final event = AnalyticsEvent(
      type: AnalyticsEventType.screenView,
      name: screenName,
      parameters: parameters ?? {},
      timestamp: DateTime.now(),
    );
    _events.insert(0, event);
    debugPrint('[Analytics] Screen View: $screenName (${event.parameters})');
  }

  void trackEvent(String eventName, {Map<String, dynamic>? parameters}) {
    final event = AnalyticsEvent(
      type: AnalyticsEventType.customEvent,
      name: eventName,
      parameters: parameters ?? {},
      timestamp: DateTime.now(),
    );
    _events.insert(0, event);
    debugPrint('[Analytics] Event: $eventName (${event.parameters})');
  }

  void clear() {
    _events.clear();
  }
}

enum AnalyticsEventType { screenView, customEvent }

class AnalyticsEvent {
  const AnalyticsEvent({
    required this.type,
    required this.name,
    required this.parameters,
    required this.timestamp,
  });

  final AnalyticsEventType type;
  final String name;
  final Map<String, dynamic> parameters;
  final DateTime timestamp;
}

class AnalyticsNavigatorObserver extends NavigatorObserver {
  AnalyticsNavigatorObserver(this._analyticsService);
  final AnalyticsService _analyticsService;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _trackRoute(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _trackRoute(newRoute);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _trackRoute(previousRoute);
    }
  }

  void _trackRoute(Route<dynamic> route) {
    final name = route.settings.name ?? route.toString();
    if (name.isNotEmpty && name != '/') {
      _analyticsService.trackScreen(name);
    }
  }
}
