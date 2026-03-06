import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../constants/colors.dart';

class CookbookScreen extends StatefulWidget {
  const CookbookScreen({super.key});

  @override
  State<CookbookScreen> createState() => _CookbookScreenState();
}

class _CookbookScreenState extends State<CookbookScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;

  List<Collection> _collections = [];

  final Set<int> _selectedIndices = {};
  bool _isSelecting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool get _showFab => _tabController.index != 0;

  void _createCollection() async {

    final nameCtrl = TextEditingController();

    final String? newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Collection"),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "e.g. Weekend BBQs",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              if (name.isNotEmpty) Navigator.pop(context, name);
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty) {

      setState(() {
        _collections.add(
          Collection(
            name: newName,
            createdAt: DateTime.now(),
          ),
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Created "$newName"')),
      );
    }
  }

  void _deleteSelected() {

    final count = _selectedIndices.length;

    setState(() {

      final indices = _selectedIndices.toList()
        ..sort((a, b) => b.compareTo(a));

      for (final i in indices) {
        _collections.removeAt(i);
      }

      _selectedIndices.clear();
      _isSelecting = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Deleted $count collections")),
    );
  }

  void _toggleSelection(int index) {

    setState(() {

      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }

      _isSelecting = _selectedIndices.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(

      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,

      appBar: AppBar(

        title: const Text("My Cookbook"),

        centerTitle: true,

        backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,

        foregroundColor: isDark ? AppColors.lightText : AppColors.darkText,

        elevation: 0,

        actions: _isSelecting
            ? [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteSelected,
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() {
                _selectedIndices.clear();
                _isSelecting = false;
              });
            },
          )
        ]
            : null,
      ),

      body: Column(

        children: [

          TabBar(

            controller: _tabController,

            isScrollable: true,

            labelColor: AppColors.vibrantOrange,

            unselectedLabelColor:
            isDark ? Colors.white70 : Colors.black54,

            indicatorColor: AppColors.vibrantOrange,

            tabs: const [

              Tab(text: "Favorites"),

              Tab(text: "My Recipes"),

              Tab(text: "Collections"),

            ],
          ),

          Expanded(

            child: TabBarView(

              controller: _tabController,

              children: [

                _buildFavoritesTab(isDark),

                _buildEmptyState(

                  icon: Icons.book_outlined,

                  title: "No custom recipes yet",

                  subtitle: "Create your first recipe",

                ),

                _buildCollectionsTab(isDark),

              ],
            ),
          ),
        ],
      ),

      floatingActionButton: _showFab
          ? FloatingActionButton(

        onPressed: _createCollection,

        backgroundColor: AppColors.vibrantOrange,

        child: const Icon(Icons.add),

      )
          : null,
    );
  }

  Widget _buildFavoritesTab(bool isDark) {

    final categories = [

      _CategoryTile(
        title: "Food Favorites",
        subtitle: "Hearted food recipes",
        icon: Icons.restaurant_rounded,
      ),

      _CategoryTile(
        title: "Drink Favorites",
        subtitle: "Hearted drink recipes",
        icon: Icons.local_drink_rounded,
      ),

      _CategoryTile(
        title: "Food & Drink Favorites",
        subtitle: "All your favorites",
        icon: Icons.favorite,
      ),

    ];

    return ListView.separated(

      padding: const EdgeInsets.all(16),

      itemCount: categories.length + 1,

      separatorBuilder: (_, __) => const SizedBox(height: 10),

      itemBuilder: (context, index) {

        if (index == 0) {
          return Text(
            "Favorites",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
            ),
          );
        }

        return categories[index - 1];
      },
    );
  }

  Widget _buildCollectionsTab(bool isDark) {

    if (_collections.isEmpty) {
      return _buildEmptyState(
        icon: Icons.collections_bookmark_outlined,
        title: "No collections yet",
        subtitle: "Tap + to create one",
      );
    }

    return ListView.builder(

      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),

      itemCount: _collections.length,

      itemBuilder: (context, index) {

        final collection = _collections[index];

        final dateStr =
        DateFormat("d MMM yyyy • HH:mm").format(collection.createdAt);

        return Card(

          margin: const EdgeInsets.only(bottom: 12),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),

          child: ListTile(

            title: Text(collection.name),

            subtitle: Text(dateStr),

            onTap: () {

              Navigator.push(

                context,

                MaterialPageRoute(
                  builder: (_) =>
                      CollectionDetailScreen(collection: collection),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(

      child: Column(

        mainAxisSize: MainAxisSize.min,

        children: [

          Icon(icon,
              size: 100,
              color: isDark ? Colors.white24 : Colors.black26)
              .animate()
              .fadeIn(duration: 800.ms),

          const SizedBox(height: 24),

          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            subtitle,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class Collection {

  final String name;

  final DateTime createdAt;

  Collection({
    required this.name,
    required this.createdAt,
  });
}

class CollectionDetailScreen extends StatelessWidget {

  final Collection collection;

  const CollectionDetailScreen({super.key, required this.collection});

  @override
  Widget build(BuildContext context) {

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(

      appBar: AppBar(
        title: Text(collection.name),
      ),

      body: Center(

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            Icon(
              Icons.collections_bookmark_outlined,
              size: 80,
              color: isDark ? Colors.white24 : Colors.black26,
            ),

            const SizedBox(height: 20),

            Text(
              "This collection is empty",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {

  final String title;

  final String subtitle;

  final IconData icon;

  const _CategoryTile({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(

      elevation: 0,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),

      child: InkWell(

        borderRadius: BorderRadius.circular(14),

        child: Padding(

          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),

          child: Row(

            children: [

              Container(

                height: 40,
                width: 40,

                decoration: BoxDecoration(
                  color: AppColors.vibrantOrange.withOpacity(.12),
                  borderRadius: BorderRadius.circular(10),
                ),

                child: Icon(
                  icon,
                  size: 22,
                  color: AppColors.vibrantOrange,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? Colors.white60
                            : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.chevron_right),

            ],
          ),
        ),
      ),
    );
  }
}