import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:autocare_pro/core/utils/helpers.dart';
import 'package:autocare_pro/data/models/service.dart';
import 'package:autocare_pro/data/models/vehicle.dart';
import 'package:autocare_pro/data/services/camera_service.dart';
import 'package:autocare_pro/presentation/providers/service_provider.dart';
import 'package:autocare_pro/presentation/providers/vehicle_provider.dart';

// Route constants
class Routes {
  static const String dashboard = '/';
  static const String vehicleList = '/vehicles';
  static const String vehicleDetails = '/vehicle-details';
  static const String addVehicle = '/add-vehicle';
  static const String addService = '/add-service';
  static const String serviceList = '/service-list';
  static const String serviceDetails = '/service-details';
  static const String analytics = '/analytics';
  static const String settings = '/settings';
}

class ServiceDetailsScreen extends StatefulWidget {
  final String serviceId;

  const ServiceDetailsScreen({super.key, required this.serviceId});

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  Service? _service;
  Vehicle? _vehicle;
  bool _isLoading = true;
  bool _isEditing = false;

  // Form controllers
  final _costController = TextEditingController();
  final _mileageController = TextEditingController();
  final _notesController = TextEditingController();
  final _mechanicController = TextEditingController();

  ServiceType _selectedServiceType = ServiceType.oilChange;
  DateTime _serviceDate = DateTime.now();
  String? _receiptPath;

  @override
  void initState() {
    super.initState();
    _loadService();
  }

  @override
  void dispose() {
    _costController.dispose();
    _mileageController.dispose();
    _notesController.dispose();
    _mechanicController.dispose();
    super.dispose();
  }

  Future<void> _loadService() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final serviceProvider = context.read<ServiceProvider>();
      final vehicleProvider = context.read<VehicleProvider>();

      final service = serviceProvider.allServices.firstWhere(
        (s) => s.id == widget.serviceId,
        orElse: () => throw Exception('Service not found'),
      );

      final vehicle = vehicleProvider.getVehicleById(service.vehicleId);

      if (mounted) {
        setState(() {
          _service = service;
          _vehicle = vehicle;
          _populateFormFields(service);
        });
      }
    } catch (e) {
      if (mounted) {
        Helpers.showErrorSnackBar(context, 'Failed to load service details');
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

  void _populateFormFields(Service service) {
    _selectedServiceType = service.serviceType;
    _serviceDate = service.serviceDate;
    _costController.text = service.cost.toStringAsFixed(2);
    _mileageController.text = service.mileageAtService.toString();
    _notesController.text = service.notes ?? '';
    _mechanicController.text = service.mechanicInfo ?? '';
    _receiptPath = service.receiptPath;
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing && _service != null) {
        _populateFormFields(_service!);
      }
    });
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

  Future<void> _saveChanges() async {
    if (_service == null) return;

    final cost = double.tryParse(_costController.text);
    final mileage = int.tryParse(_mileageController.text);

    if (cost == null || mileage == null) {
      Helpers.showErrorSnackBar(context, 'Please enter valid cost and mileage');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedService = _service!.copyWith(
        serviceType: _selectedServiceType,
        serviceDate: _serviceDate,
        mileageAtService: mileage,
        cost: cost,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        mechanicInfo: _mechanicController.text.trim().isEmpty ? null : _mechanicController.text.trim(),
        receiptPath: _receiptPath,
        updatedAt: DateTime.now(),
      );

      final success = await context.read<ServiceProvider>().updateService(updatedService);

      if (success && mounted) {
        setState(() {
          _service = updatedService;
          _isEditing = false;
        });
        Helpers.showSuccessSnackBar(context, 'Service updated successfully');
      }
    } catch (e) {
      if (mounted) {
        Helpers.showErrorSnackBar(context, 'Failed to update service: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteService() async {
    if (_service == null) return;

    final confirmed = await Helpers.showConfirmationDialog(
      context,
      title: 'Delete Service',
      message: 'Are you sure you want to delete this service record? This action cannot be undone.',
      confirmText: 'Delete Service',
      confirmColor: Theme.of(context).colorScheme.error,
      icon: Icons.delete_forever,
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        final success = await context.read<ServiceProvider>().deleteService(_service!.id);

        if (success && mounted) {
          Helpers.showSuccessSnackBar(context, 'Service deleted successfully');
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          Helpers.showErrorSnackBar(context, 'Failed to delete service');
        }
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickReceipt() async {
    try {
      final cameraService = context.read<CameraService>();
      final String? photoPath = await showModalBottomSheet<String>(
        context: context,
        builder: (context) => _buildReceiptPickerSheet(cameraService),
      );

      if (photoPath != null) {
        setState(() {
          _receiptPath = photoPath;
        });
      }
    } catch (e) {
      if (mounted) {
        Helpers.showErrorSnackBar(context, 'Failed to pick receipt: ${e.toString()}');
      }
    }
  }

  Widget _buildReceiptPickerSheet(CameraService cameraService) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Take Photo'),
            onTap: () async {
              Navigator.of(context).pop();
              try {
                final photoPath = await cameraService.takePhoto();
                if (mounted && photoPath != null) {
                  setState(() {
                    _receiptPath = photoPath;
                  });
                }
              } catch (e) {
                if (mounted) {
                  Helpers.showErrorSnackBar(context, 'Failed to take photo: ${e.toString()}');
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from Gallery'),
            onTap: () async {
              Navigator.of(context).pop();
              try {
                final photoPath = await cameraService.pickFromGallery();
                if (mounted && photoPath != null) {
                  setState(() {
                    _receiptPath = photoPath;
                  });
                }
              } catch (e) {
                if (mounted) {
                  Helpers.showErrorSnackBar(context, 'Failed to pick photo: ${e.toString()}');
                }
              }
            },
          ),
          if (_receiptPath != null) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Remove Receipt'),
              onTap: () {
                Navigator.of(context).pop();
                setState(() {
                  _receiptPath = null;
                });
              },
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _service == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_service == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text('Service not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_service!.serviceType.displayName),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: _isLoading ? null : _toggleEditMode,
            tooltip: _isEditing ? 'Cancel editing' : 'Edit service',
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
                    _deleteService();
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
                      Text('Delete Service'),
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
          // Vehicle Information
          _buildSectionCard(
            'Vehicle Information',
            [
              _buildInfoRow('Vehicle', _vehicle != null
                  ? '${_vehicle!.year} ${_vehicle!.make} ${_vehicle!.model}'
                  : 'Unknown Vehicle'),
              _buildInfoRow('License Plate', _vehicle?.licensePlate ?? 'N/A'),
            ],
          ),
          const SizedBox(height: 16),

          // Service Information
          _buildSectionCard(
            'Service Details',
            [
              _buildInfoRow('Service Type', _service!.serviceType.displayName),
              _buildInfoRow('Date', Helpers.formatDate(_service!.serviceDate)),
              _buildInfoRow('Mileage', _service!.formattedMileage),
              _buildInfoRow('Cost', _service!.formattedCost),
            ],
          ),
          const SizedBox(height: 16),

          // Additional Information
          if (_service!.mechanicInfo != null || _service!.notes != null)
            _buildSectionCard(
              'Additional Information',
              [
                if (_service!.mechanicInfo != null)
                  _buildInfoRow('Mechanic/Shop', _service!.mechanicInfo!),
                if (_service!.notes != null)
                  _buildInfoRow('Notes', _service!.notes!),
              ],
            ),

          // Receipt Photo
          if (_service!.receiptPath != null) ...[
            const SizedBox(height: 16),
            _buildReceiptSection(),
          ],

          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_vehicle != null) {
                      Navigator.pushNamed(
                        context,
                        Routes.vehicleDetails,
                        arguments: _vehicle!.id,
                      );
                    }
                  },
                  icon: const Icon(Icons.directions_car),
                  label: const Text('View Vehicle'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    if (_vehicle != null) {
                      Navigator.pushNamed(
                        context,
                        Routes.serviceList,
                        arguments: _vehicle!.id,
                      );
                    }
                  },
                  icon: const Icon(Icons.list),
                  label: const Text('All Services'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vehicle Information (Read-only)
          _buildSectionCard(
            'Vehicle Information',
            [
              _buildInfoRow('Vehicle', _vehicle != null
                  ? '${_vehicle!.year} ${_vehicle!.make} ${_vehicle!.model}'
                  : 'Unknown Vehicle'),
              _buildInfoRow('License Plate', _vehicle?.licensePlate ?? 'N/A'),
            ],
          ),
          const SizedBox(height: 24),

          // Service Details Form
          Text(
            'Service Details',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildServiceDetailsForm(),
          const SizedBox(height: 24),

          // Receipt Section
          Text(
            'Receipt Photo',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildReceiptEditSection(),
        ],
      ),
    );
  }

  Widget _buildServiceDetailsForm() {
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

          // Service Date
          InkWell(
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
          const SizedBox(height: 16),

          // Mileage and Cost
          Row(
            children: [
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
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
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
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

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
        ],
      ),
    );
  }

  Widget _buildReceiptEditSection() {
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
        children: [
          if (_receiptPath != null)
            Container(
              height: 200,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: FileImage(File(_receiptPath!)),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: Text(
                  _receiptPath != null ? 'Receipt photo attached' : 'No receipt photo',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _receiptPath != null
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _pickReceipt,
                icon: Icon(
                  _receiptPath != null ? Icons.edit : Icons.camera_alt,
                ),
                label: Text(_receiptPath != null ? 'Change' : 'Add'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptSection() {
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
            'Receipt Photo',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: FileImage(File(_service!.receiptPath!)),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
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
}
