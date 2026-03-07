import 'package:flutter/material.dart';
import '../../constants/colors.dart';

import 'shop/shopping_model.dart';
import 'shop/list_detail_screen.dart';
import 'shop/shopping_data.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ShoppingData data = ShoppingData.instance;

  final Set<int> selectedManualIndexes = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // refresh FAB visibility
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  void _deleteSelectedManualLists() {
    final indexes = selectedManualIndexes.toList()..sort((a, b) => b.compareTo(a));
    for (var index in indexes) {
      data.manualLists.removeAt(index);
    }
    selectedManualIndexes.clear();
    _refresh();
  }

  void _addNewManualList() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Manual List"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "List Name"),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
              onPressed: () {
                var name = controller.text.trim();
                if (name.isEmpty) {
                  name = "My List ${data.manualLists.length + 1}";
                }
                data.manualLists.add(
                  ManualList(
                    name: name,
                    items: [],
                    createdAt: DateTime.now(),
                  ),
                );
                _refresh();
                Navigator.pop(context);
              },
              child: const Text("Add")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                "Shopping Lists",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.lightText : AppColors.darkText,
                ),
              ),
            ),
            TabBar(
              controller: _tabController,
              labelColor: AppColors.vibrantOrange,
              unselectedLabelColor: isDark ? Colors.white70 : Colors.black54,
              indicatorColor: AppColors.vibrantOrange,
              tabs: const [
                Tab(text: "Smart Lists"),
                Tab(text: "Manual Lists"),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSmartListsView(),
                  _buildManualListsView(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton(
        onPressed: _addNewManualList,
        backgroundColor: AppColors.vibrantOrange,
        child: const Icon(Icons.add),
      )
          : null,
    );
  }

  // ---------------- SMART LISTS ----------------
  Widget _buildSmartListsView() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _smartListTile(data.drinkList, Icons.local_drink, Colors.blueAccent),
        _smartListTile(data.foodList, Icons.fastfood, Colors.green),
        _smartListTile(data.foodDrinkList, Icons.restaurant_menu, Colors.purple),
        _smartListTile(data.mealPlanner, Icons.calendar_today, Colors.orange),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _smartListTile(SmartList list, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      color: Theme.of(context).cardColor,
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(list.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(list.subtitle,
            style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ListDetailScreen(
                title: list.name,
                items: list.items,
                isSmartList: true,
                onItemsChanged: _refresh,
              ),
            ),
          );
          _refresh();
        },
      ),
    );
  }

  // ---------------- MANUAL LISTS ----------------
  Widget _buildManualListsView() {
    if (data.manualLists.isEmpty) {
      return Center(
        child: Text(
          "No manual lists yet",
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white70
                : Colors.black54,
          ),
        ),
      );
    }

    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: data.manualLists.length,
          itemBuilder: (context, index) {
            final list = data.manualLists[index];
            final selected = selectedManualIndexes.contains(index);

            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: selected ? 6 : 3,
              shadowColor: selected ? Colors.redAccent.withOpacity(0.3) : Colors.black12,
              color: selected
                  ? AppColors.vibrantOrange.withOpacity(0.2)
                  : Theme.of(context).cardColor,
              child: ListTile(
                title: Text(list.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(list.subtitle,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                trailing: selected
                    ? IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    data.manualLists.removeAt(index);
                    selectedManualIndexes.remove(index);
                    _refresh();
                  },
                )
                    : const Icon(Icons.chevron_right),
                onTap: selected
                    ? () {
                  setState(() {
                    selectedManualIndexes.remove(index);
                  });
                }
                    : () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ListDetailScreen(
                        title: list.name,
                        items: list.items,
                        onItemsChanged: _refresh,
                      ),
                    ),
                  );
                  _refresh();
                },
                onLongPress: () {
                  setState(() {
                    if (selectedManualIndexes.contains(index)) {
                      selectedManualIndexes.remove(index);
                    } else {
                      selectedManualIndexes.add(index);
                    }
                  });
                },
              ),
            );
          },
        ),
        // Floating delete button for multi-select
        if (selectedManualIndexes.isNotEmpty)
          Positioned(
            top: 16,
            right: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.red,
              onPressed: _deleteSelectedManualLists,
              child: const Icon(Icons.delete),
            ),
          ),
      ],
    );
  }
}