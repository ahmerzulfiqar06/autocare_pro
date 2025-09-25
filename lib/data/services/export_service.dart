import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:autocare_pro/data/models/vehicle.dart';
import 'package:autocare_pro/data/models/service.dart';
import 'package:autocare_pro/data/models/service_schedule.dart';
import 'package:autocare_pro/core/utils/helpers.dart';

class ExportService {
  static const String appName = 'AutoCare Pro';
  static const String appVersion = '1.0.0';

  // Export data to CSV format
  Future<File> exportToCSV({
    required List<Vehicle> vehicles,
    required List<Service> services,
    required List<ServiceSchedule> schedules,
    String fileName = 'autocare_export',
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName.csv');

    final csvContent = StringBuffer();

    // Add CSV headers and data for vehicles
    csvContent.writeln('=== VEHICLES ===');
    csvContent.writeln('ID,Make,Model,Year,Mileage,VIN,License Plate,Status,Purchase Date,Notes');

    for (final vehicle in vehicles) {
      csvContent.writeln(
        '${vehicle.id},'
        '${vehicle.make},'
        '${vehicle.model},'
        '${vehicle.year},'
        '${vehicle.currentMileage},'
        '${vehicle.vin ?? ''},'
        '${vehicle.licensePlate ?? ''},'
        '${vehicle.status.displayName},'
        '${vehicle.purchaseDate?.toIso8601String() ?? ''},'
        '"${vehicle.notes ?? ''}"'
      );
    }

    csvContent.writeln('\n=== SERVICES ===');
    csvContent.writeln('ID,Vehicle ID,Service Type,Date,Mileage,Cost,Notes,Mechanic');

    for (final service in services) {
      csvContent.writeln(
        '${service.id},'
        '${service.vehicleId},'
        '${service.serviceType.displayName},'
        '${service.serviceDate.toIso8601String()},'
        '${service.mileageAtService},'
        '${service.cost},'
        '"${service.notes ?? ''}",'
        '"${service.mechanicInfo ?? ''}"'
      );
    }

    csvContent.writeln('\n=== SERVICE SCHEDULES ===');
    csvContent.writeln('ID,Vehicle ID,Service Name,Type,Frequency,Next Service,Status');

    for (final schedule in schedules) {
      csvContent.writeln(
        '${schedule.id},'
        '${schedule.vehicleId},'
        '${schedule.serviceName},'
        '${schedule.serviceType.displayName},'
        '${schedule.frequency.displayName},'
        '${schedule.nextServiceDate.toIso8601String()},'
        '${schedule.isActive ? 'Active' : 'Inactive'}'
      );
    }

    await file.writeAsString(csvContent.toString());
    return file;
  }

  // Export comprehensive PDF report
  Future<File> exportToPDF({
    required List<Vehicle> vehicles,
    required List<Service> services,
    required List<ServiceSchedule> schedules,
    String fileName = 'autocare_report',
  }) async {
    final pdf = pw.Document();
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName.pdf');

    // Create PDF content
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (context) => _buildPDFHeader(),
        footer: (context) => _buildPDFFooter(context),
        build: (context) => [
          _buildVehicleSection(vehicles),
          pw.SizedBox(height: 20),
          _buildServiceSection(services, vehicles),
          pw.SizedBox(height: 20),
          _buildScheduleSection(schedules, vehicles),
          pw.SizedBox(height: 20),
          _buildSummarySection(vehicles, services),
        ],
      ),
    );

    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // Build PDF header
  pw.Widget _buildPDFHeader() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 2),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                appName,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'Generated: ${DateTime.now().toString().split('.')[0]}',
                style: const pw.TextStyle(fontSize: 12),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Vehicle Maintenance Report',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Build PDF footer
  pw.Widget _buildPDFFooter(pw.Context context) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.top(width: 1),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Page ${context.pageNumber}'),
          pw.Text(appVersion),
        ],
      ),
    );
  }

  // Build vehicle section
  pw.Widget _buildVehicleSection(List<Vehicle> vehicles) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'VEHICLES',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            decoration: pw.TextDecoration.underline,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table.fromTextArray(
          headers: ['Make', 'Model', 'Year', 'Mileage', 'Status'],
          data: vehicles.map((vehicle) => [
            vehicle.make,
            vehicle.model,
            vehicle.year.toString(),
            '${vehicle.currentMileage.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} miles',
            vehicle.status.displayName,
          ]).toList(),
          border: pw.TableBorder.all(),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          cellAlignment: pw.Alignment.centerLeft,
          cellHeight: 30,
        ),
      ],
    );
  }

  // Build service section
  pw.Widget _buildServiceSection(List<Service> services, List<Vehicle> vehicles) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'RECENT SERVICES',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            decoration: pw.TextDecoration.underline,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table.fromTextArray(
          headers: ['Vehicle', 'Service', 'Date', 'Cost'],
          data: services.take(10).map((service) {
            final vehicle = vehicles.firstWhere(
              (v) => v.id == service.vehicleId,
              orElse: () => Vehicle(
                make: 'Unknown',
                model: 'Vehicle',
                year: 0,
                currentMileage: 0,
              ),
            );
            return [
              '${vehicle.year} ${vehicle.make} ${vehicle.model}',
              service.serviceType.displayName,
              Helpers.formatDate(service.serviceDate),
              Helpers.formatCurrency(service.cost),
            ];
          }).toList(),
          border: pw.TableBorder.all(),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          cellAlignment: pw.Alignment.centerLeft,
          cellHeight: 30,
        ),
      ],
    );
  }

  // Build schedule section
  pw.Widget _buildScheduleSection(List<ServiceSchedule> schedules, List<Vehicle> vehicles) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'SERVICE SCHEDULES',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            decoration: pw.TextDecoration.underline,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table.fromTextArray(
          headers: ['Vehicle', 'Service', 'Next Due', 'Status', 'Days Until'],
          data: schedules.map((schedule) {
            final vehicle = vehicles.firstWhere(
              (v) => v.id == schedule.vehicleId,
              orElse: () => Vehicle(
                make: 'Unknown',
                model: 'Vehicle',
                year: 0,
                currentMileage: 0,
              ),
            );
            final daysUntil = schedule.daysUntilDue;
            final status = daysUntil < 0
                ? 'OVERDUE'
                : daysUntil <= 7
                    ? 'DUE SOON'
                    : 'ACTIVE';
            return [
              '${vehicle.year} ${vehicle.make} ${vehicle.model}',
              schedule.serviceName,
              Helpers.formatDate(schedule.nextServiceDate),
              status,
              daysUntil < 0 ? '${-daysUntil} days overdue' : '$daysUntil days',
            ];
          }).toList(),
          border: pw.TableBorder.all(),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          cellAlignment: pw.Alignment.centerLeft,
          cellHeight: 30,
        ),
      ],
    );
  }

  // Build summary section
  pw.Widget _buildSummarySection(List<Vehicle> vehicles, List<Service> services) {
    final totalSpent = services.fold<double>(0.0, (sum, service) => sum + service.cost);
    final activeVehicles = vehicles.where((v) => v.status == VehicleStatus.active).length;
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey200,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'SUMMARY',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('Total Vehicles', vehicles.length.toString()),
              _buildSummaryItem('Active Vehicles', activeVehicles.toString()),
              _buildSummaryItem('Total Spent', Helpers.formatCurrency(totalSpent)),
              _buildSummaryItem('Services', services.length.toString()),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSummaryItem(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 10),
        ),
      ],
    );
  }

  // Share export file
  Future<void> shareFile(File file, String fileName) async {
    try {
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'AutoCare Pro - $fileName',
        subject: 'Vehicle Maintenance Report',
      );
    } catch (e) {
      throw Exception('Failed to share file: $e');
    }
  }

  // Generate quick summary text for sharing
  String generateSummaryText({
    required List<Vehicle> vehicles,
    required List<Service> services,
    required List<ServiceSchedule> schedules,
  }) {
    final totalSpent = services.fold<double>(0.0, (sum, service) => sum + service.cost);
    final activeVehicles = vehicles.where((v) => v.status == VehicleStatus.active).length;
    final overdueServices = schedules.where((s) => s.isDue).length;

    return '''
AutoCare Pro - Maintenance Summary

📊 Overview:
• Total Vehicles: ${vehicles.length}
• Active Vehicles: $activeVehicles
• Total Services: ${services.length}
• Amount Spent: ${Helpers.formatCurrency(totalSpent)}

⚠️ Alerts:
• Overdue Services: $overdueServices
• Upcoming Services: ${schedules.where((s) => s.daysUntilDue <= 7 && s.daysUntilDue > 0).length}

Generated by AutoCare Pro v$appVersion
    '''.trim();
  }
}
