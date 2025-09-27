import 'package:flutter/foundation.dart';

import 'models/models.dart';

class AppState extends ChangeNotifier {
  AppState() {
    _seedData();
  }

  final List<RideOffer> rides = <RideOffer>[];
  final List<MarketplaceListing> listings = <MarketplaceListing>[];
  final List<StudentPost> posts = <StudentPost>[];
  final Map<String, ChatThread> _chats = <String, ChatThread>{};

  void _seedData() {
    final RideOffer welcomeRide = RideOffer(
      id: generateId(),
      driverName: 'Alex Johnson',
      origin: 'Campus North Lot',
      destination: 'Downtown Library',
      departureTime: DateTime.now().add(const Duration(hours: 6)),
      availableSeats: 3,
      notes: 'Leaving after my 2 PM class.',
    );
    final MarketplaceListing welcomeListing = MarketplaceListing(
      id: generateId(),
      title: 'Used Calculus Textbook',
      description: 'Lightly highlighted. Perfect for MAT201 exam prep.',
      price: 25.0,
      sellerName: 'Priya Singh',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    );
    final StudentPost welcomePost = StudentPost(
      id: generateId(),
      author: 'Campus Green Club',
      body:
          'Reminder: Sustainability fair this Friday! Bring a mug for free coffee.',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      reactions: 12,
    );

    rides.add(welcomeRide);
    listings.add(welcomeListing);
    posts.add(welcomePost);
  }

  List<ChatThread> get chats => _chats.values.toList();

  ChatThread? chatById(String id) => _chats[id];

  void addRide(RideOffer ride) {
    rides.add(ride);
    notifyListeners();
  }

  void requestRide({
    required String rideId,
    required String studentName,
  }) {
    final RideOffer? ride = rides.firstWhere((RideOffer r) => r.id == rideId);
    if (ride.request != null) {
      return;
    }
    ride.request = RideRequest(studentName: studentName);
    notifyListeners();
  }

  void acceptRideRequest(String rideId) {
    final RideOffer ride = rides.firstWhere((RideOffer r) => r.id == rideId);
    if (ride.request == null) {
      return;
    }
    ride.request!.status = RideRequestStatus.accepted;
    final ChatThread thread = ChatThread(
      id: generateId(),
      title: 'Ride with ${ride.driverName}',
      expiresAt: ride.departureTime,
      participants: <String>[ride.driverName, ride.request!.studentName],
    );
    ride.chatThreadId = thread.id;
    _chats[thread.id] = thread;
    notifyListeners();
  }

  void declineRideRequest(String rideId) {
    final RideOffer ride = rides.firstWhere((RideOffer r) => r.id == rideId);
    if (ride.request == null) {
      return;
    }
    ride.request!.status = RideRequestStatus.declined;
    notifyListeners();
  }

  void addRideMessage(String rideId, ChatMessage message) {
    final RideOffer ride = rides.firstWhere((RideOffer r) => r.id == rideId);
    if (ride.chatThreadId == null) {
      return;
    }
    final ChatThread? thread = _chats[ride.chatThreadId];
    if (thread == null || thread.isExpired) {
      return;
    }
    thread.messages.add(message);
    notifyListeners();
  }

  void addListing(MarketplaceListing listing) {
    listings.add(listing);
    notifyListeners();
  }

  void markListingPending(String listingId, String buyerName) {
    final MarketplaceListing listing =
        listings.firstWhere((MarketplaceListing l) => l.id == listingId);
    if (listing.status != ListingStatus.available) {
      return;
    }
    listing.status = ListingStatus.pending;
    final ChatThread thread = ChatThread(
      id: generateId(),
      title: 'Marketplace: ${listing.title}',
      expiresAt: DateTime.now().add(const Duration(days: 14)),
      participants: <String>[listing.sellerName, buyerName],
    );
    listing.chatThreadId = thread.id;
    _chats[thread.id] = thread;
    notifyListeners();
  }

  void completeListing(String listingId) {
    final MarketplaceListing listing =
        listings.firstWhere((MarketplaceListing l) => l.id == listingId);
    listing.status = ListingStatus.sold;
    if (listing.chatThreadId != null) {
      final ChatThread? thread = _chats[listing.chatThreadId];
      thread?.expire();
    }
    notifyListeners();
  }

  void addListingMessage(String listingId, ChatMessage message) {
    final MarketplaceListing listing =
        listings.firstWhere((MarketplaceListing l) => l.id == listingId);
    if (listing.chatThreadId == null) {
      return;
    }
    final ChatThread? thread = _chats[listing.chatThreadId];
    if (thread == null || thread.isExpired) {
      return;
    }
    thread.messages.add(message);
    notifyListeners();
  }

  void addPost(StudentPost post) {
    posts.insert(0, post);
    notifyListeners();
  }

  void reactToPost(String postId) {
    final StudentPost post =
        posts.firstWhere((StudentPost element) => element.id == postId);
    post.reactions++;
    notifyListeners();
  }

  void commentOnPost(String postId, String comment) {
    final StudentPost post =
        posts.firstWhere((StudentPost element) => element.id == postId);
    post.comments.add(comment);
    notifyListeners();
  }

  void addMessageToThread(String threadId, ChatMessage message) {
    final ChatThread? thread = _chats[threadId];
    if (thread == null || thread.isExpired) {
      return;
    }
    thread.messages.add(message);
    notifyListeners();
  }
}
