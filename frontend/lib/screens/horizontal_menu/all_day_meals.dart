import 'package:flutter/material.dart';

class AllDayMealsMenu extends StatelessWidget {
  AllDayMealsMenu({super.key});

  final List<_MealCategory> meals = [
    const _MealCategory(
      title: "Breakfast",
      emoji: "🍳",
      description: "Quick & energizing morning meals",
    ),
    const _MealCategory(
      title: "Lunch",
      emoji: "🥪",
      description: "Balanced midday refuels & hearty bowls",
    ),
    const _MealCategory(
      title: "Dinner",
      emoji: "🍝",
      description: "Comforting evening plates & family meals",
    ),
    const _MealCategory(
      title: "Snack",
      emoji: "🍪",
      description: "Light bites between meals",
    ),
    const _MealCategory(
      title: "Dessert",
      emoji: "🧁",
      description: "Sweet treats & indulgent finishes",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 12),

          ...meals.map((meal) => _MealItem(meal: meal)).toList(),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _MealItem extends StatelessWidget {
  final _MealCategory meal;

  const _MealItem({required this.meal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: colors.surface,
        elevation: 3,
        borderRadius: BorderRadius.circular(20),
        shadowColor: Colors.black.withOpacity(0.08),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          splashColor: colors.primary.withOpacity(0.1),
          highlightColor: colors.primary.withOpacity(0.05),
          onTap: () {
            // TODO: Navigate to category screen
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
            child: Row(
              children: [
                /// Emoji bubble
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.primary.withOpacity(0.08),
                  ),
                  child: Text(
                    meal.emoji,
                    style: const TextStyle(fontSize: 30),
                  ),
                ),

                const SizedBox(width: 16),

                /// Text column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meal.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        meal.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color
                              ?.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                /// Arrow icon
                Icon(
                  Icons.chevron_right_rounded,
                  color: colors.primary,
                  size: 26,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MealCategory {
  final String title;
  final String emoji;
  final String description;

  const _MealCategory({
    required this.title,
    required this.emoji,
    required this.description,
  });
}