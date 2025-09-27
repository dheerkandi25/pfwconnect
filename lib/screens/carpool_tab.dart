import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../models/models.dart';
import 'chat_screen.dart';

class CarpoolTab extends StatelessWidget {
  const CarpoolTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AppState>(
        builder: (BuildContext context, AppState state, _) {
          if (state.rides.isEmpty) {
            return const Center(
              child: Text('No rides yet. Be the first to offer one!'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.rides.length,
            itemBuilder: (BuildContext context, int index) {
              final RideOffer ride = state.rides[index];
              return _RideCard(ride: ride);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddRideDialog(context),
        icon: const Icon(Icons.add_road),
        label: const Text('Offer ride'),
      ),
    );
  }

  Future<void> _showAddRideDialog(BuildContext context) async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController driverController = TextEditingController();
    final TextEditingController originController = TextEditingController();
    final TextEditingController destinationController = TextEditingController();
    final TextEditingController seatsController = TextEditingController();
    final TextEditingController notesController = TextEditingController();
    DateTime? departure;

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Offer a ride'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    controller: driverController,
                    decoration: const InputDecoration(labelText: 'Your name'),
                    validator: (String? value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: originController,
                    decoration: const InputDecoration(labelText: 'From'),
                    validator: (String? value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: destinationController,
                    decoration: const InputDecoration(labelText: 'To'),
                    validator: (String? value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: seatsController,
                    decoration:
                        const InputDecoration(labelText: 'Available seats'),
                    keyboardType: TextInputType.number,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      final int? seats = int.tryParse(value);
                      if (seats == null || seats <= 0) {
                        return 'Enter a valid number';
                      }
                      return null;
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      departure == null
                          ? 'Select departure time'
                          : formatDateTime(departure!),
                    ),
                    trailing: const Icon(Icons.calendar_month),
                    onTap: () async {
                      final DateTime now = DateTime.now();
                      final DateTime? date = await showDatePicker(
                        context: context,
                        initialDate: now.add(const Duration(days: 1)),
                        firstDate: now,
                        lastDate: now.add(const Duration(days: 30)),
                      );
                      if (date == null) {
                        return;
                      }
                      if (!context.mounted) {
                        return;
                      }
                      final TimeOfDay? time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time == null) {
                        return;
                      }
                      departure = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                      (context as Element).markNeedsBuild();
                    },
                  ),
                  TextFormField(
                    controller: notesController,
                    decoration: const InputDecoration(labelText: 'Notes'),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState?.validate() != true ||
                    departure == null) {
                  return;
                }
                final AppState state = context.read<AppState>();
                state.addRide(
                  RideOffer(
                    id: generateId(),
                    driverName: driverController.text.trim(),
                    origin: originController.text.trim(),
                    destination: destinationController.text.trim(),
                    departureTime: departure!,
                    availableSeats: int.parse(seatsController.text.trim()),
                    notes: notesController.text.trim(),
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('Post ride'),
            ),
          ],
        );
      },
    );
  }
}

class _RideCard extends StatelessWidget {
  const _RideCard({required this.ride});

  final RideOffer ride;

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final RideRequest? request = ride.request;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${ride.origin} → ${ride.destination}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      'Driver: ${ride.driverName}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                Chip(
                  label: Text(
                    ride.isExpired ? 'Completed' : '${ride.availableSeats} seats',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Departure: ${formatDateTime(ride.departureTime)}'),
            if (ride.notes.isNotEmpty) ...<Widget>[
              const SizedBox(height: 8),
              Text('Notes: ${ride.notes}'),
            ],
            const Divider(height: 24),
            if (request == null)
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.tonalIcon(
                  icon: const Icon(Icons.handshake),
                  onPressed: ride.isExpired
                      ? null
                      : () => _promptRideRequest(context, ride.id),
                  label: const Text('Request ride'),
                ),
              )
            else
              _RideRequestActions(ride: ride, request: request, state: state),
          ],
        ),
      ),
    );
  }

  Future<void> _promptRideRequest(BuildContext context, String rideId) async {
    final TextEditingController nameController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Request ride'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Your name',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  return;
                }
                context.read<AppState>().requestRide(
                      rideId: rideId,
                      studentName: nameController.text.trim(),
                    );
                Navigator.pop(context);
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}

class _RideRequestActions extends StatelessWidget {
  const _RideRequestActions({
    required this.ride,
    required this.request,
    required this.state,
  });

  final RideOffer ride;
  final RideRequest request;
  final AppState state;

  @override
  Widget build(BuildContext context) {
    if (request.status == RideRequestStatus.pending) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Request from ${request.studentName}'),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              OutlinedButton.icon(
                icon: const Icon(Icons.clear),
                onPressed: () => state.declineRideRequest(ride.id),
                label: const Text('Decline'),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                icon: const Icon(Icons.check),
                onPressed: () => state.acceptRideRequest(ride.id),
                label: const Text('Accept'),
              ),
            ],
          ),
        ],
      );
    }

    if (request.status == RideRequestStatus.declined) {
      return const Text('You declined this request.');
    }

    final ChatThread? thread =
        ride.chatThreadId == null ? null : state.chatById(ride.chatThreadId!);
    final bool canMessage = thread != null && !thread.isExpired;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Passenger: ${request.studentName}'),
        const SizedBox(height: 8),
        FilledButton.icon(
          icon: const Icon(Icons.chat_bubble_outline),
          onPressed: canMessage
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => ChatScreen(
                        threadId: thread!.id,
                      ),
                    ),
                  );
                }
              : null,
          label: Text(canMessage ? 'Contact rider' : 'Chat expired'),
        ),
      ],
    );
  }
}
