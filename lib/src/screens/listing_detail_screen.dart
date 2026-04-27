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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Listing')),
      body: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                height: 240,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      bottom: -26,
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        size: 150,
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    Center(
                      child: Icon(
                        Icons.photo_camera_outlined,
                        size: 68,
                        color: Colors.white.withValues(alpha: 0.92),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      bottom: 16,
                      child: _DetailPill(label: listing.category),
                    ),
                  ],
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
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    avatar: const Icon(Icons.school_outlined, size: 16),
                    label: Text(listing.campus),
                  ),
                  if (listing.distanceMiles != null)
                    Chip(
                      avatar: const Icon(Icons.place_outlined, size: 16),
                      label: Text(
                        '${listing.distanceMiles!.toStringAsFixed(1)} miles away',
                      ),
                    ),
                  if (listing.isSold) const Chip(label: Text('Sold')),
                ],
              ),
              const SizedBox(height: 20),
              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      Text(listing.description),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                color: Colors.white,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.secondaryContainer,
                    child: Text(listing.sellerName.characters.first),
                  ),
                  title: Text(listing.sellerName),
                  subtitle: Text(
                    listing.distanceMiles == null
                        ? 'Campus seller'
                        : '${listing.distanceMiles!.toStringAsFixed(1)} miles away',
                  ),
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

class _DetailPill extends StatelessWidget {
  const _DetailPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }
}
