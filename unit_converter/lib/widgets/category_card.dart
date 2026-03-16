import 'package:flutter/material.dart';
import '../models/conversion.dart';
import '../utils/icon_utils.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
    this.isLocked = false,
    this.lockedSubtitle,
  });

  final ConversionCategory category;
  final VoidCallback onTap;
  final bool isLocked;
  final String? lockedSubtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact =
            constraints.maxHeight < 160 || constraints.maxWidth < 180;
        final iconSize = compact ? 20.0 : 28.0;
        final containerPadding = compact ? 6.0 : 12.0;
        final contentPadding = compact ? 8.0 : 14.0;
        final titleStyle = compact
            ? theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              )
            : theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              );

        return Card(
          child: Opacity(
            opacity: isLocked ? 0.65 : 1.0,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: onTap,
              child: Padding(
                padding: EdgeInsets.all(contentPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(containerPadding),
                      decoration: BoxDecoration(
                        color: isLocked
                            ? theme.colorScheme.surfaceContainerHighest
                            : theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        IconUtils.getIconForCategory(category.icon),
                        size: iconSize,
                        color: isLocked
                            ? theme.colorScheme.onSurfaceVariant
                            : theme.colorScheme.primary,
                      ),
                    ),
                    SizedBox(height: compact ? 6 : 8),
                    Text(
                      category.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: titleStyle?.copyWith(
                        color: isLocked
                            ? theme.colorScheme.onSurfaceVariant
                            : null,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: compact ? 1 : 2),
                    Text(
                      isLocked
                          ? (lockedSubtitle ?? '${category.units.length} units')
                          : '${category.units.length} units',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: compact ? 11 : 11,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (isLocked) ...[
                      SizedBox(height: compact ? 3 : 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.workspace_premium,
                            size: compact ? 16 : 18,
                            color: theme.colorScheme.secondary,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
