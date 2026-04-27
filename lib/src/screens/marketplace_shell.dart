import 'package:flutter/material.dart';

import '../models/listing.dart';
import '../widgets/listing_card.dart';
import 'create_listing_screen.dart';
import 'listing_detail_screen.dart';

class MarketplaceShell extends StatefulWidget {
  const MarketplaceShell({
    super.key,
    required this.store,
    required this.userName,
    required this.userCampus,
    required this.onSignOut,
  });

  final MarketplaceStore store;
  final String userName;
  final String userCampus;
  final VoidCallback onSignOut;

  @override
  State<MarketplaceShell> createState() => _MarketplaceShellState();
}

class _MarketplaceShellState extends State<MarketplaceShell> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      BrowsePage(
        store: widget.store,
        userCampus: widget.userCampus,
        onOpenListing: openListing,
      ),
      MyListingsPage(store: widget.store, onOpenListing: openListing),
      ProfilePage(
        userName: widget.userName,
        userCampus: widget.userCampus,
        onSignOut: widget.onSignOut,
      ),
    ];

    return Scaffold(
      body: SafeArea(child: pages[selectedIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => setState(() => selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.search),
            selectedIcon: Icon(Icons.search),
            label: 'Browse',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'My Listings',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: selectedIndex == 0 || selectedIndex == 1
          ? FloatingActionButton.extended(
              onPressed: createListing,
              icon: const Icon(Icons.add),
              label: const Text('New Listing'),
            )
          : null,
    );
  }

  void openListing(Listing listing) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ListingDetailScreen(
          store: widget.store,
          listing: listing,
          isOwner: listing.sellerId == MarketplaceStore.demoUserId,
        ),
      ),
    );
  }

  void createListing() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateListingScreen(
          store: widget.store,
          sellerName: widget.userName,
          campus: widget.userCampus,
        ),
      ),
    );
  }
}

class BrowsePage extends StatefulWidget {
  const BrowsePage({
    super.key,
    required this.store,
    required this.userCampus,
    required this.onOpenListing,
  });

  final MarketplaceStore store;
  final String userCampus;
  final void Function(Listing listing) onOpenListing;

  @override
  State<BrowsePage> createState() => _BrowsePageState();
}

class _BrowsePageState extends State<BrowsePage> {
  final searchController = TextEditingController();
  String? category;

  @override
  void initState() {
    super.initState();
    widget.store.addListener(refresh);
    searchController.addListener(refresh);
  }

  @override
  void dispose() {
    widget.store.removeListener(refresh);
    searchController.dispose();
    super.dispose();
  }

  void refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final listings = widget.store.activeListings(
      campus: widget.userCampus,
      category: category,
      query: searchController.text,
    );

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Browse',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 4),
                Text(widget.userCampus),
                const SizedBox(height: 16),
                TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search listings',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  initialValue: category,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text(
                        'All categories',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    ...categories.map(
                      (item) => DropdownMenuItem<String?>(
                        value: item,
                        child: Text(item, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                  onChanged: (value) => setState(() => category = value),
                ),
              ],
            ),
          ),
        ),
        if (listings.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              icon: Icons.search_off,
              title: 'No listings found',
              message: 'Try another search or create the first listing.',
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
            sliver: SliverList.separated(
              itemCount: listings.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return ListingCard(
                  listing: listings[index],
                  onTap: () => widget.onOpenListing(listings[index]),
                );
              },
            ),
          ),
      ],
    );
  }
}

class MyListingsPage extends StatefulWidget {
  const MyListingsPage({
    super.key,
    required this.store,
    required this.onOpenListing,
  });

  final MarketplaceStore store;
  final void Function(Listing listing) onOpenListing;

  @override
  State<MyListingsPage> createState() => _MyListingsPageState();
}

class _MyListingsPageState extends State<MyListingsPage> {
  @override
  void initState() {
    super.initState();
    widget.store.addListener(refresh);
  }

  @override
  void dispose() {
    widget.store.removeListener(refresh);
    super.dispose();
  }

  void refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final listings = widget.store.myListings();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Listings',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: listings.isEmpty
                ? const EmptyState(
                    icon: Icons.inventory_2_outlined,
                    title: 'Nothing listed yet',
                    message: 'Create a listing when you are ready to sell.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: 96),
                    itemCount: listings.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return ListingCard(
                        listing: listings[index],
                        onTap: () => widget.onOpenListing(listings[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
    required this.userName,
    required this.userCampus,
    required this.onSignOut,
  });

  final String userName;
  final String userCampus;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 4),
          Text('Profile', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    child: Text(userName.characters.first.toUpperCase()),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(userCampus),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: onSignOut,
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
