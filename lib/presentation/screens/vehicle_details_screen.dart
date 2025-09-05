import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:autocare_pro/core/utils/helpers.dart';
import 'package:autocare_pro/data/models/vehicle.dart';
import 'package:autocare_pro/presentation/providers/vehicle_provider.dart';

class VehicleDetailsScreen extends StatefulWidget {
  final String vehicleId;

  const VehicleDetailsScreen({super.key, required this.vehicleId});

  @override
  State<VehicleDetailsScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen> {
  Vehicle? _vehicle;
  bool _isLoading = true;
  bool _isEditing = false;

  // Form controllers
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

  @override
  void initState() {
    super.initState();
    _loadVehicle();
  }

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

  Future<void> _loadVehicle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final vehicle = context.read<VehicleProvider>().getVehicleById(widget.vehicleId);
      if (vehicle != null) {
        setState(() {
          _vehicle = vehicle;
          _populateFormFields(vehicle);
        });
      }
    } catch (e) {
      if (mounted) {
        Helpers.showErrorSnackBar(context, 'Failed to load vehicle');
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _populateFormFields(Vehicle vehicle) {
    _makeController.text = vehicle.make;
    _modelController.text = vehicle.model;
    _yearController.text = vehicle.year.toString();
    _vinController.text = vehicle.vin ?? '';
    _licensePlateController.text = vehicle.licensePlate ?? '';
    _mileageController.text = vehicle.currentMileage.toString();
    _notesController.text = vehicle.notes ?? '';
    _purchaseDate = vehicle.purchaseDate;
    _status = vehicle.status;
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing && _vehicle != null) {
        _populateFormFields(_vehicle!);
      }
    });
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

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedVehicle = _vehicle!.copyWith(
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
        updatedAt: DateTime.now(),
      );

      final success = await context.read<VehicleProvider>().updateVehicle(updatedVehicle);

      if (success && mounted) {
        setState(() {
          _vehicle = updatedVehicle;
          _isEditing = false;
        });
        Helpers.showSuccessSnackBar(context, 'Vehicle updated successfully');
      }
    } catch (e) {
      if (mounted) {
        Helpers.showErrorSnackBar(context, 'Failed to update vehicle: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteVehicle() async {
    final confirmed = await Helpers.showConfirmationDialog(
      context,
      title: 'Delete Vehicle',
      message: 'Are you sure you want to delete this vehicle? This action cannot be undone.',
      confirmText: 'Delete',
      confirmColor: Theme.of(context).colorScheme.error,
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        final success = await context.read<VehicleProvider>().deleteVehicle(widget.vehicleId);

        if (success && mounted) {
          Helpers.showSuccessSnackBar(context, 'Vehicle deleted successfully');
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          Helpers.showErrorSnackBar(context, 'Failed to delete vehicle');
        }
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _vehicle == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_vehicle == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text('Vehicle not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_vehicle!.displayName),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: _isLoading ? null : _toggleEditMode,
            tooltip: _isEditing ? 'Cancel editing' : 'Edit vehicle',
          ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _isLoading ? null : _saveChanges,
              tooltip: 'Save changes',
            ),
          if (!_isEditing)
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'delete':
                    _deleteVehicle();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete Vehicle'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _isEditing ? _buildEditView() : _buildViewMode(),
    );
  }

  Widget _buildViewMode() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vehicle Photo
          _buildPhotoSection(),
          const SizedBox(height: 24),

          // Basic Information
          _buildInfoSection(
            'Basic Information',
            [
              _buildInfoRow('Make', _vehicle!.make),
              _buildInfoRow('Model', _vehicle!.model),
              _buildInfoRow('Year', _vehicle!.year.toString()),
              _buildInfoRow('Mileage', _vehicle!.formattedMileage),
              _buildInfoRow('Status', _vehicle!.status.displayName),
            ],
          ),

          const SizedBox(height: 24),

          // Additional Details
          _buildInfoSection(
            'Additional Details',
            [
              if (_vehicle!.vin != null) _buildInfoRow('VIN', _vehicle!.vin!),
              if (_vehicle!.licensePlate != null) _buildInfoRow('License Plate', _vehicle!.licensePlate!),
              if (_vehicle!.purchaseDate != null)
                _buildInfoRow('Purchase Date', Helpers.formatDate(_vehicle!.purchaseDate!)),
              if (_vehicle!.notes != null) _buildInfoRow('Notes', _vehicle!.notes!),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildEditView() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vehicle Photo
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
            _buildEditBasicInfoSection(),

            const SizedBox(height: 24),

            // Additional Details
            Text(
              'Additional Details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildEditAdditionalDetailsSection(),

            const SizedBox(height: 32),
          ],
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
          if (_isEditing) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () {
                // TODO: Implement photo picker
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('Change Photo'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditBasicInfoSection() {
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
      ],
    );
  }

  Widget _buildEditAdditionalDetailsSection() {
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

        // Notes
        TextFormField(
          controller: _notesController,
          decoration: const InputDecoration(
            labelText: 'Notes',
          ),
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
        ),
      ],
    );
  }
}
