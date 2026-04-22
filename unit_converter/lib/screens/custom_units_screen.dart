import 'package:flutter/material.dart';

import '../models/conversion.dart';
import '../services/custom_units_service.dart';
import '../utils/navigation_utils.dart';
import '../utils/snackbar_utils.dart';
import 'add_custom_unit_screen.dart';

class CustomUnitsScreen extends StatefulWidget {
  const CustomUnitsScreen({super.key});

  @override
  State<CustomUnitsScreen> createState() => _CustomUnitsScreenState();
}

class _CustomUnitsScreenState extends State<CustomUnitsScreen> {
  final CustomUnitsService _customUnitsService = CustomUnitsService.instance;
  List<CustomUnit> _customUnits = [];

  @override
  void initState() {
    super.initState();
    _loadCustomUnits();
  }

  Future<void> _loadCustomUnits() async {
    final units = await _customUnitsService.getCustomUnits();
    if (!mounted) return;
    setState(() {
      _customUnits = units;
    });
  }

  Future<void> _deleteUnit(String id) async {
    await _customUnitsService.deleteCustomUnit(id);
    await _loadCustomUnits();
    if (!mounted) return;
    SnackbarUtils.show(context, 'Custom unit deleted');
  }

  void _navigateToAddCustomUnit() {
    NavigationUtils.pushWithCallback(
      context,
      const AddCustomUnitScreen(),
      _loadCustomUnits,
    );
  }

  void _navigateToEditCustomUnit(CustomUnit unit) {
    NavigationUtils.pushWithCallback(
      context,
      AddCustomUnitScreen(existingUnit: unit),
      _loadCustomUnits,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Units'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToAddCustomUnit,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: _buildDifferentiatorCard(theme),
          ),
          Expanded(
            child: _customUnits.isEmpty
                ? _buildEmptyState(theme)
                : _buildCustomUnitsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDifferentiatorCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Make the converter yours',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Custom units are the clearest differentiator: add niche measurements, engineering shortcuts, or business-specific units and keep them available on desktop, web, and mobile layouts.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.extension_outlined,
            size: 64,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'No custom units yet',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add your first custom unit and create a converter competitors usually do not cover.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCustomUnitsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _customUnits.length,
      itemBuilder: (context, index) {
        final unit = _customUnits[index];
        return _buildCustomUnitCard(unit);
      },
    );
  }

  Widget _buildCustomUnitCard(CustomUnit unit) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 10,
        ),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            unit.symbol,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        title: Text(
          unit.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${unit.categoryName} • Factor: ${unit.conversionFactor}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _navigateToEditCustomUnit(unit),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _showDeleteDialog(unit),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(CustomUnit unit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Custom Unit'),
        content: Text(
          'Are you sure you want to delete ${unit.name} (${unit.symbol})?',
        ),
        actions: [
          TextButton(
            onPressed: () => NavigationUtils.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              NavigationUtils.pop(context);
              _deleteUnit(unit.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
