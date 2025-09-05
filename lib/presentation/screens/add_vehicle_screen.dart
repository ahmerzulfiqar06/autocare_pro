import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:autocare_pro/core/utils/helpers.dart';
import 'package:autocare_pro/data/models/vehicle.dart';
import 'package:autocare_pro/presentation/providers/vehicle_provider.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _vinController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _mileageController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _purchaseDate;
  VehicleStatus _status = VehicleStatus.active;
  bool _isLoading = false;

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _vinController.dispose();
    _licensePlateController.dispose();
    _mileageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectPurchaseDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _purchaseDate) {
      setState(() {
        _purchaseDate = picked;
      });
    }
  }

  Future<void> _saveVehicle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final vehicle = Vehicle(
        make: _makeController.text.trim(),
        model: _modelController.text.trim(),
        year: int.parse(_yearController.text),
        vin: _vinController.text.trim().isEmpty ? null : _vinController.text.trim(),
        licensePlate: _licensePlateController.text.trim().isEmpty
            ? null
            : _licensePlateController.text.trim(),
        currentMileage: int.parse(_mileageController.text),
        purchaseDate: _purchaseDate,
        status: _status,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      final success = await context.read<VehicleProvider>().addVehicle(vehicle);

      if (success && mounted) {
        Helpers.showSuccessSnackBar(context, 'Vehicle added successfully');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        Helpers.showErrorSnackBar(context, 'Failed to add vehicle: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Vehicle'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveVehicle,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vehicle Photo Section
              _buildPhotoSection(),
              const SizedBox(height: 24),

              // Basic Information
              Text(
                'Basic Information',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildBasicInfoSection(),

              const SizedBox(height: 24),

              // Additional Details
              Text(
                'Additional Details',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildAdditionalDetailsSection(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.directions_car,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () {
              // TODO: Implement photo picker
            },
            icon: const Icon(Icons.camera_alt),
            label: const Text('Add Photo'),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      children: [
        // Make and Model
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _makeController,
                decoration: const InputDecoration(
                  labelText: 'Make *',
                  hintText: 'e.g., Toyota',
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Make is required';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(
                  labelText: 'Model *',
                  hintText: 'e.g., Camry',
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Model is required';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Year and Mileage
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(
                  labelText: 'Year *',
                  hintText: 'e.g., 2020',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Year is required';
                  }
                  final year = int.tryParse(value);
                  if (year == null || year < 1900 || year > DateTime.now().year + 1) {
                    return 'Enter a valid year';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _mileageController,
                decoration: const InputDecoration(
                  labelText: 'Current Mileage *',
                  hintText: 'e.g., 50000',
                  suffixText: 'miles',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Mileage is required';
                  }
                  final mileage = int.tryParse(value);
                  if (mileage == null || mileage < 0) {
                    return 'Enter a valid mileage';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdditionalDetailsSection() {
    return Column(
      children: [
        // VIN and License Plate
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _vinController,
                decoration: const InputDecoration(
                  labelText: 'VIN',
                  hintText: 'Vehicle Identification Number',
                ),
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(17),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _licensePlateController,
                decoration: const InputDecoration(
                  labelText: 'License Plate',
                  hintText: 'License plate number',
                ),
                textCapitalization: TextCapitalization.characters,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Purchase Date
        InkWell(
          onTap: _selectPurchaseDate,
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Purchase Date',
              suffixIcon: Icon(Icons.calendar_today),
            ),
            child: Text(
              _purchaseDate != null
                  ? Helpers.formatDate(_purchaseDate!)
                  : 'Select purchase date',
              style: TextStyle(
                color: _purchaseDate != null
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Status
        DropdownButtonFormField<VehicleStatus>(
          value: _status,
          decoration: const InputDecoration(
            labelText: 'Status',
          ),
          items: VehicleStatus.values.map((status) {
            return DropdownMenuItem(
              value: status,
              child: Text(status.displayName),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _status = value;
              });
            }
          },
        ),
        const SizedBox(height: 16),

        // Notes
        TextFormField(
          controller: _notesController,
          decoration: const InputDecoration(
            labelText: 'Notes',
            hintText: 'Additional notes about the vehicle',
          ),
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
        ),
      ],
    );
  }
}
