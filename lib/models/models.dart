import 'package:flutter/material.dart';

enum RideRequestStatus { none, pending, accepted, declined }

enum ListingStatus { available, pending, sold }

class RideRequest {
  RideRequest({
    required this.studentName,
    this.status = RideRequestStatus.pending,
  });

  final String studentName;
  RideRequestStatus status;
}

class RideOffer {
  RideOffer({
    required this.id,
    required this.driverName,
    required this.origin,
    required this.destination,
    required this.departureTime,
    required this.availableSeats,
    this.notes = '',
    this.request,
    this.chatThreadId,
  });

  final String id;
  final String driverName;
  final String origin;
  final String destination;
  final DateTime departureTime;
  final int availableSeats;
  final String notes;
  RideRequest? request;
  String? chatThreadId;

  bool get isExpired => DateTime.now().isAfter(departureTime);
}

class MarketplaceListing {
  MarketplaceListing({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.sellerName,
    required this.createdAt,
    this.status = ListingStatus.available,
    this.chatThreadId,
  });

  final String id;
  final String title;
  final String description;
  final double price;
  final String sellerName;
  final DateTime createdAt;
  ListingStatus status;
  String? chatThreadId;

  bool get isSold => status == ListingStatus.sold;
}

class StudentPost {
  StudentPost({
    required this.id,
    required this.author,
    required this.body,
    required this.createdAt,
    this.reactions = 0,
    List<String>? comments,
  }) : comments = comments ?? <String>[];

  final String id;
  final String author;
  final String body;
  final DateTime createdAt;
  int reactions;
  final List<String> comments;
}

class ChatThread {
  ChatThread({
    required this.id,
    required this.title,
    required this.expiresAt,
    required this.participants,
    List<ChatMessage>? messages,
  }) : messages = messages ?? <ChatMessage>[];

  final String id;
  final String title;
  final DateTime? expiresAt;
  final List<String> participants;
  final List<ChatMessage> messages;
  bool _manuallyExpired = false;

  bool get isExpired {
    if (_manuallyExpired) {
      return true;
    }
    if (expiresAt == null) {
      return false;
    }
    return DateTime.now().isAfter(expiresAt!);
  }

  void expire() {
    _manuallyExpired = true;
  }
}

class ChatMessage {
  ChatMessage({
    required this.sender,
    required this.message,
    required this.sentAt,
  });

  final String sender;
  final String message;
  final DateTime sentAt;
}

String generateId() => DateTime.now().microsecondsSinceEpoch.toString();

String formatDateTime(DateTime time) {
  return '${time.month.toString().padLeft(2, '0')}/'
      '${time.day.toString().padLeft(2, '0')} '
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}
