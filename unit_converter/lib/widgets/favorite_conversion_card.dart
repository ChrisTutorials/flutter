import 'package:flutter/material.dart';

import '../models/favorite_conversion.dart';

class FavoriteConversionCard extends StatelessWidget {
  const FavoriteConversionCard({
    super.key,
    required this.favorite,
    required this.onTap,
    required this.onRemove,
  });

  final FavoriteConversion favorite;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 220,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: onRemove,
                      tooltip: 'Remove favorite',
                      icon: const Icon(Icons.close_rounded),
                      iconSize: 18,
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints.tightFor(
                        width: 28,
                        height: 28,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  favorite.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${favorite.fromSymbol} to ${favorite.toSymbol}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
