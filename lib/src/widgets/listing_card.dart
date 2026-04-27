import 'package:flutter/material.dart';

import '../models/listing.dart';

class ListingCard extends StatelessWidget {
  const ListingCard({super.key, required this.listing, required this.onTap});

  final Listing listing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: categoryColor(listing.category, colorScheme),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  categoryIcon(listing.category),
                  color: Colors.white,
                  size: 34,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            listing.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        Text(
                          '\$${listing.price.toStringAsFixed(0)}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      listing.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.62),
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _Tag(label: listing.category),
                        if (listing.distanceMiles != null)
                          _Tag(
                            icon: Icons.place_outlined,
                            label:
                                '${listing.distanceMiles!.toStringAsFixed(1)} mi',
                          ),
                        if (listing.isSold) const _Tag(label: 'Sold'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData categoryIcon(String category) {
    return switch (category) {
      'Books' => Icons.menu_book_outlined,
      'Electronics' => Icons.devices_outlined,
      'Furniture' => Icons.chair_outlined,
      'Housing' => Icons.home_work_outlined,
      'Services' => Icons.handyman_outlined,
      _ => Icons.sell_outlined,
    };
  }

  Color categoryColor(String category, ColorScheme colorScheme) {
    return switch (category) {
      'Books' => const Color(0xFF6B5B95),
      'Electronics' => const Color(0xFF3178A6),
      'Furniture' => const Color(0xFF9B6A3B),
      'Housing' => const Color(0xFF2F6F5E),
      'Services' => const Color(0xFFC2683A),
      _ => colorScheme.primary,
    };
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EFE6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: Colors.black.withValues(alpha: 0.58)),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black.withValues(alpha: 0.68),
            ),
          ),
        ],
      ),
    );
  }
}
