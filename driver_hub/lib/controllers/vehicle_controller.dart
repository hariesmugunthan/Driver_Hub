import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../models/vehicle_id_model.dart';
import '../models/vehicle_model.dart';
import '../services/vehicle_service.dart';

class VehicleController {
  VehicleService vehicleService = VehicleService();

  Future<VehicleModel> createVehicle(VehicleModel vehicleModel) async {
    VehicleModel createdVehicle = await vehicleService.createVehicle(vehicleModel);

    return createdVehicle;
  }

  Future<List<VehicleModel>> getAllVehicles() async {
    List<VehicleModel> vehicleList = await vehicleService.getAllVehicles();

    return vehicleList;
  }

  Future<List<VehicleModel>> getAvailableVehicles() async {
    List<VehicleModel> vehicleList = await vehicleService.getAvailableVehicles();

    return vehicleList;
  }

  Future<VehicleModel> getVehicle(VehicleIdModel vehicleIdModel) async {
    VehicleModel vehicle = await vehicleService.getVehicle(vehicleIdModel);

    return vehicle;
  }

  Future<VehicleModel> updateVehicle(VehicleModel vehicleModel) async {
    VehicleModel updatedVehicle = await vehicleService.updateVehicle(vehicleModel);

    return updatedVehicle;
  }

  Future<VehicleModel> deleteVehicle(VehicleIdModel vehicleIdModel) async {
    VehicleModel deletedVehicle = await vehicleService.deleteVehicle(vehicleIdModel);

    return deletedVehicle;
  }

  Future<Uint8List?> generateQrImage(String vehicleId) async {
    QrPainter qrPainter = QrPainter(
      data: vehicleId,
      version: QrVersions.auto,
      gapless: true,
      emptyColor: Colors.white,
    );

    ByteData? imageData = await qrPainter.toImageData(1000, format: ui.ImageByteFormat.png);

    return imageData?.buffer.asUint8List();
  }

  Future<void> shareVehicleQr(String vehicleId) async {
    Uint8List? qrBytes = await generateQrImage(vehicleId);

    if (qrBytes == null) {
      return;
    }

    Directory directory = await getTemporaryDirectory();

    File qrFile = File('${directory.path}/$vehicleId.png');

    await qrFile.writeAsBytes(qrBytes);

    await Share.shareXFiles(
      [XFile(qrFile.path, mimeType: 'image/png')],
      text: 'Vehicle QR Code - $vehicleId',
    );
  }

  Future<void> saveVehicleQr(String vehicleId) async {
    Uint8List? qrBytes = await generateQrImage(vehicleId);

    if (qrBytes == null) {
      return;
    }

    Directory directory = await getApplicationDocumentsDirectory();

    File qrFile = File('${directory.path}/$vehicleId.png');

    await qrFile.writeAsBytes(qrBytes);
  }
}