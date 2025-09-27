import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../models/models.dart';
import 'chat_screen.dart';

class MarketplaceTab extends StatelessWidget {
  const MarketplaceTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AppState>(
        builder: (BuildContext context, AppState state, _) {
          if (state.listings.isEmpty) {
            return const Center(
              child: Text('No listings yet. Sell something to your peers!'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.listings.length,
            itemBuilder: (BuildContext context, int index) {
              final MarketplaceListing listing = state.listings[index];
              return _ListingCard(listing: listing);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddListingDialog(context),
        icon: const Icon(Icons.post_add),
        label: const Text('List item'),
      ),
    );
  }

  Future<void> _showAddListingDialog(BuildContext context) async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController sellerController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('List an item'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Item name'),
                    validator: (String? value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: descriptionController,
                    decoration:
                        const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                  ),
                  TextFormField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      final double? price = double.tryParse(value);
                      if (price == null || price <= 0) {
                        return 'Enter a valid amount';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: sellerController,
                    decoration: const InputDecoration(labelText: 'Your name'),
                    validator: (String? value) =>
                        value == null || value.isEmpty ? 'Required' : null,
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
                if (formKey.currentState?.validate() != true) {
                  return;
                }
                context.read<AppState>().addListing(
                      MarketplaceListing(
                        id: generateId(),
                        title: titleController.text.trim(),
                        description: descriptionController.text.trim(),
                        price: double.parse(priceController.text.trim()),
                        sellerName: sellerController.text.trim(),
                        createdAt: DateTime.now(),
                      ),
                    );
                Navigator.pop(context);
              },
              child: const Text('Post listing'),
            ),
          ],
        );
      },
    );
  }
}

class _ListingCard extends StatelessWidget {
  const _ListingCard({required this.listing});

  final MarketplaceListing listing;

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final ChatThread? thread = listing.chatThreadId == null
        ? null
        : state.chatById(listing.chatThreadId!);
    final bool canChat = thread != null && !thread.isExpired;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              listing.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text('Seller: ${listing.sellerName}'),
            const SizedBox(height: 8),
            Text(listing.description),
            const SizedBox(height: 8),
            Text('Price: ${listing.price.toStringAsFixed(2)} USD'),
            Text('Posted ${formatDateTime(listing.createdAt)}'),
            const Divider(height: 24),
            if (listing.status == ListingStatus.available)
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.tonalIcon(
                  icon: const Icon(Icons.message),
                  onPressed: () => _promptBuyerName(context, state),
                  label: const Text('Contact seller'),
                ),
              )
            else if (listing.status == ListingStatus.pending)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Pending sale to ${thread?.participants.last ?? 'buyer'}'),
                  FilledButton.icon(
                    icon: const Icon(Icons.check_circle),
                    onPressed: () => state.completeListing(listing.id),
                    label: const Text('Mark sold'),
                  ),
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text('Item sold'),
                  FilledButton.icon(
                    icon: const Icon(Icons.chat_bubble_outline),
                    onPressed: canChat
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
                    label: Text(canChat ? 'View chat' : 'Chat closed'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _promptBuyerName(BuildContext context, AppState state) async {
    final TextEditingController controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Introduce yourself'),
          content: TextField(
            controller: controller,
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
                if (controller.text.trim().isEmpty) {
                  return;
                }
                state.markListingPending(listing.id, controller.text.trim());
                Navigator.pop(context);
              },
              child: const Text('Start chat'),
            ),
          ],
        );
      },
    );
  }
}
