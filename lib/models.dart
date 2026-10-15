import 'package:flutter/material.dart';

class Event {
  const Event({
    required this.id,
    required this.title,
    required this.category,
    required this.venueId,
    required this.sessions,
    required this.price,
    required this.lineup,
    required this.about,
    required this.entryInfo,
    required this.attendees,
    required this.tags,
    required this.color,
    this.entryType = '자율입장',
    this.pick = false,
    this.onSale = true,
  });

  final String id;
  final String title;
  final String category;
  final String venueId;
  final List<DateTime> sessions;
  final int price;
  final List<String> lineup;
  final String about;
  final String entryInfo;
  final List<String> attendees;
  final List<String> tags;
  final Color color;
  final String entryType;
  final bool pick;
  final bool onSale;
}

class Venue {
  const Venue({
    required this.id,
    required this.name,
    required this.region,
    required this.area,
    required this.type,
    required this.genre,
    required this.address,
    required this.mapX,
    required this.mapY,
  });

  final String id;
  final String name;
  final String region;
  final String area;
  final String type;
  final String genre;
  final String address;

  /// 간이 지도 위 위치 (0~1 비율).
  final double mapX;
  final double mapY;
}

class Ticket {
  const Ticket({
    required this.id,
    required this.event,
    required this.session,
    required this.quantity,
    required this.payMethod,
    required this.total,
  });

  final String id;
  final Event event;
  final DateTime session;
  final int quantity;
  final String payMethod;
  final int total;
}

class AppNotification {
  AppNotification({required this.title, required this.body, required this.time});

  final String title;
  final String body;
  final DateTime time;
  bool read = false;
}
