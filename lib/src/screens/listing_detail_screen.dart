import 'package:flutter/material.dart';

import '../models/listing.dart';

class ListingDetailScreen extends StatelessWidget {
  const ListingDetailScreen({
    super.key,
    required this.store,
    required this.listing,
    required this.isOwner,
  });

  final MarketplaceStore store;
  final Listing listing;
  final bool isOwner;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Listing')),
      body: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                height: 220,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.photo_camera_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      listing.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  Text(
                    '\$${listing.price.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(label: Text(listing.category)),
                  Chip(label: Text(listing.campus)),
                  if (listing.isSold) const Chip(label: Text('Sold')),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Description',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(listing.description),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person_outline),
                title: Text(listing.sellerName),
                subtitle: Text(
                  listing.distanceMiles == null
                      ? 'Campus seller'
                      : '${listing.distanceMiles!.toStringAsFixed(1)} miles away',
                ),
              ),
              const SizedBox(height: 16),
              if (isOwner) ...[
                FilledButton.icon(
                  onPressed: listing.isSold
                      ? null
                      : () {
                          store.markSold(listing.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Marked as sold')),
                          );
                        },
                  icon: const Icon(Icons.done),
                  label: const Text('Mark Sold'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    store.deleteListing(listing.id);
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete Listing'),
                ),
              ] else
                FilledButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Messaging will be added with Firebase.'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Contact Seller'),
                ),
            ],
          );
        },
      ),
    );
  }
}
