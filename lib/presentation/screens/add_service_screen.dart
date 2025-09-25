import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:autocare_pro/core/utils/helpers.dart';
import 'package:autocare_pro/data/models/service.dart';
import 'package:autocare_pro/presentation/providers/service_provider.dart';
import 'package:autocare_pro/presentation/providers/vehicle_provider.dart';

class AddServiceScreen extends StatefulWidget {
  final String? vehicleId;

  const AddServiceScreen({super.key, this.vehicleId});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _costController = TextEditingController();
  final _mileageController = TextEditingController();
  final _notesController = TextEditingController();
  final _mechanicController = TextEditingController();

  ServiceType _selectedServiceType = ServiceType.oilChange;
  String? _selectedVehicleId;
  DateTime _serviceDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.vehicleId != null) {
      _selectedVehicleId = widget.vehicleId;
      _loadVehicleMileage();
    }
  }

  @override
  void dispose() {
    _costController.dispose();
    _mileageController.dispose();
    _notesController.dispose();
    _mechanicController.dispose();
    super.dispose();
  }

  Future<void> _loadVehicleMileage() async {
    if (_selectedVehicleId != null) {
      final vehicleProvider = context.read<VehicleProvider>();
      final vehicle = vehicleProvider.getVehicleById(_selectedVehicleId!);
      if (vehicle != null && mounted) {
        setState(() {
          _mileageController.text = vehicle.currentMileage.toString();
        });
      }
    }
  }

  Future<void> _selectServiceDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _serviceDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _serviceDate) {
      setState(() {
        _serviceDate = picked;
      });
    }
  }

  Future<void> _saveService() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedVehicleId == null) {
      Helpers.showErrorSnackBar(context, 'Please select a vehicle');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final service = Service(
        vehicleId: _selectedVehicleId!,
        serviceType: _selectedServiceType,
        serviceDate: _serviceDate,
        mileageAtService: int.parse(_mileageController.text),
        cost: double.parse(_costController.text),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        mechanicInfo: _mechanicController.text.trim().isEmpty ? null : _mechanicController.text.trim(),
      );

      final success = await context.read<ServiceProvider>().addService(service);

      if (success && mounted) {
        // Update vehicle mileage if it's higher than current
        final vehicleProvider = context.read<VehicleProvider>();
        final vehicle = vehicleProvider.getVehicleById(_selectedVehicleId!);
        if (vehicle != null && service.mileageAtService > vehicle.currentMileage) {
          await vehicleProvider.updateVehicleMileage(_selectedVehicleId!, service.mileageAtService);
        }

        Helpers.showSuccessSnackBar(context, 'Service added successfully');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        Helpers.showErrorSnackBar(context, 'Failed to add service: ${e.toString()}');
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
        title: const Text('Add Service'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveService,
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
              // Vehicle Selection (only if not pre-selected)
              if (widget.vehicleId == null) ...[
                Text(
                  'Vehicle',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildVehicleSelection(),
                const SizedBox(height: 24),
              ],

              // Service Details
              Text(
                'Service Details',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildServiceDetailsSection(),

              const SizedBox(height: 24),

              // Additional Information
              Text(
                'Additional Information',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildAdditionalInfoSection(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleSelection() {
    return Consumer<VehicleProvider>(
      builder: (context, vehicleProvider, child) {
        final vehicles = vehicleProvider.vehicles;

        if (vehicles.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.error.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.warning,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 8),
                Text(
                  'No vehicles available',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add a vehicle first before logging services',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return DropdownButtonFormField<String>(
          value: _selectedVehicleId,
          decoration: const InputDecoration(
            labelText: 'Select Vehicle *',
            prefixIcon: Icon(Icons.directions_car),
          ),
          items: vehicles.map((vehicle) {
            return DropdownMenuItem(
              value: vehicle.id,
              child: Text('${vehicle.year} ${vehicle.make} ${vehicle.model}'),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedVehicleId = value;
            });
            if (value != null) {
              _loadVehicleMileage();
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a vehicle';
            }
            return null;
          },
        );
      },
    );
  }

  Widget _buildServiceDetailsSection() {
    return Column(
      children: [
        // Service Type
        DropdownButtonFormField<ServiceType>(
          value: _selectedServiceType,
          decoration: const InputDecoration(
            labelText: 'Service Type *',
            prefixIcon: Icon(Icons.build),
          ),
          items: ServiceType.values.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(type.displayName),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedServiceType = value;
              });
            }
          },
        ),
        const SizedBox(height: 16),

        // Service Date and Mileage
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: _selectServiceDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Service Date *',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    Helpers.formatDate(_serviceDate),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _mileageController,
                decoration: const InputDecoration(
                  labelText: 'Mileage *',
                  prefixIcon: Icon(Icons.speed),
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

        // Cost
        TextFormField(
          controller: _costController,
          decoration: const InputDecoration(
            labelText: 'Cost *',
            prefixIcon: Icon(Icons.attach_money),
            hintText: '0.00',
          ),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Cost is required';
            }
            final cost = double.tryParse(value);
            if (cost == null || cost < 0) {
              return 'Enter a valid cost';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Column(
      children: [
        // Mechanic Information
        TextFormField(
          controller: _mechanicController,
          decoration: const InputDecoration(
            labelText: 'Mechanic/Shop',
            prefixIcon: Icon(Icons.person),
            hintText: 'Name of mechanic or service shop',
          ),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 16),

        // Notes
        TextFormField(
          controller: _notesController,
          decoration: const InputDecoration(
            labelText: 'Notes',
            prefixIcon: Icon(Icons.note),
            hintText: 'Additional details about the service',
          ),
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: 16),

        // Receipt Upload (placeholder for now)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.receipt,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Receipt Photo',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Attach a photo of your receipt',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  // TODO: Implement camera integration
                  Helpers.showInfoSnackBar(context, 'Camera integration coming soon!');
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('Add'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
