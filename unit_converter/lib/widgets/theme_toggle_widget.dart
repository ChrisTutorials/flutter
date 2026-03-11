import 'package:flutter/material.dart';
import '../services/theme_service.dart';

/// Widget that provides a theme toggle button
class ThemeToggleWidget extends StatelessWidget {
  const ThemeToggleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = ThemeController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopupMenuButton<AppThemeMode>(
      icon: Icon(
        isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      tooltip: 'Change theme',
      onSelected: (mode) async {
        await themeController.updateThemeMode(mode);
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: AppThemeMode.light,
          child: _buildMenuItem(
            context,
            icon: Icons.light_mode,
            label: 'Light',
            mode: AppThemeMode.light,
            controller: themeController,
          ),
        ),
        PopupMenuItem(
          value: AppThemeMode.dark,
          child: _buildMenuItem(
            context,
            icon: Icons.dark_mode,
            label: 'Dark',
            mode: AppThemeMode.dark,
            controller: themeController,
          ),
        ),
        PopupMenuItem(
          value: AppThemeMode.system,
          child: _buildMenuItem(
            context,
            icon: Icons.brightness_auto,
            label: 'System',
            mode: AppThemeMode.system,
            controller: themeController,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required AppThemeMode mode,
    required ThemeController controller,
  }) {
    final isSelected = controller.themeModeSetting == mode;

    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        const Spacer(),
        if (isSelected)
          Icon(
            Icons.check,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
      ],
    );
  }
}

/// Simple theme toggle button that switches between light and dark
class SimpleThemeToggle extends StatelessWidget {
  const SimpleThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = ThemeController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return IconButton(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Icon(
          isDark ? Icons.light_mode : Icons.dark_mode,
          key: ValueKey(isDark),
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
      onPressed: () async {
        final newMode = isDark ? AppThemeMode.light : AppThemeMode.dark;
        await themeController.updateThemeMode(newMode);
      },
    );
  }
}
