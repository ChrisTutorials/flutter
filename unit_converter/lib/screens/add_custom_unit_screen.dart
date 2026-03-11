import 'package:flutter/material.dart';

import '../models/conversion.dart';
import '../services/custom_units_service.dart';
import '../utils/button_styles.dart';
import '../utils/navigation_utils.dart';
import '../utils/snackbar_utils.dart';

class AddCustomUnitScreen extends StatefulWidget {
  const AddCustomUnitScreen({super.key});

  @override
  State<AddCustomUnitScreen> createState() => _AddCustomUnitScreenState();
}

class _AddCustomUnitScreenState extends State<AddCustomUnitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _symbolController = TextEditingController();
  final _conversionFactorController = TextEditingController();
  final CustomUnitsService _customUnitsService = CustomUnitsService();

  String? _selectedCategory;
  final List<String> _categories = [
    'Length',
    'Weight',
    'Temperature',
    'Volume',
    'Area',
    'Speed',
    'Time',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _symbolController.dispose();
    _conversionFactorController.dispose();
    super.dispose();
  }

  Future<void> _saveCustomUnit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check if symbol already exists in category
    final exists = await _customUnitsService.customUnitExists(
      _symbolController.text.trim(),
      _selectedCategory!,
    );

    if (exists) {
      if (!mounted) return;
      SnackbarUtils.showError(
        context,
        'A unit with this symbol already exists in this category',
      );
      return;
    }

    final customUnit = CustomUnit(
      id: _customUnitsService.generateId(),
      name: _nameController.text.trim(),
      symbol: _symbolController.text.trim(),
      conversionFactor: double.parse(_conversionFactorController.text),
      categoryName: _selectedCategory!,
      createdAt: DateTime.now(),
    );

    await _customUnitsService.saveCustomUnit(customUnit);

    if (!mounted) return;
    SnackbarUtils.showSuccess(context, 'Custom unit added successfully');
    NavigationUtils.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Custom Unit')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildUnitDetailsCard(theme),
            const SizedBox(height: 16),
            _buildConversionFactorInfoCard(theme),
            const SizedBox(height: 24),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitDetailsCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Unit Details',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Unit Name',
                hintText: 'e.g., Furlong',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a unit name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _symbolController,
              decoration: const InputDecoration(
                labelText: 'Symbol',
                hintText: 'e.g., fur',
              ),
              textCapitalization: TextCapitalization.characters,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a symbol';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Category'),
              items: _categories
                  .map(
                    (category) => DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a category';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _conversionFactorController,
              decoration: const InputDecoration(
                labelText: 'Conversion Factor',
                hintText: 'e.g., 201.168',
                helperText: 'Value in base unit (e.g., meters for Length)',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a conversion factor';
                }
                final factor = double.tryParse(value);
                if (factor == null || factor <= 0) {
                  return 'Please enter a positive number';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversionFactorInfoCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How Conversion Factor Works',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'The conversion factor represents how many base units equal one of your custom units.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Examples:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '• 1 inch = 0.0254 meters → Factor: 0.0254',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              '• 1 foot = 0.3048 meters → Factor: 0.3048',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              '• 1 kilometer = 1000 meters → Factor: 1000',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return FilledButton.icon(
      onPressed: _saveCustomUnit,
      icon: const Icon(Icons.add),
      label: const Text('Add Custom Unit'),
      style: ButtonStyles.fullWidthButton,
    );
  }
}
