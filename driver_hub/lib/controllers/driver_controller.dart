import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../models/driver_id_model.dart';
import '../models/driver_model.dart';
import '../services/driver_service.dart';

class DriverController {
  DriverService driverService = DriverService();

  Future<DriverModel> createDriver(DriverModel driverModel) async {
    DriverModel createdDriver = await driverService.createDriver(driverModel);

    return createdDriver;
  }

  Future<List<DriverModel>> getAllDrivers() async {
    List<DriverModel> driverList = await driverService.getAllDrivers();

    return driverList;
  }

  Future<List<DriverModel>> getAvailableDrivers() async {
    List<DriverModel> driverList = await driverService.getAvailableDrivers();

    return driverList;
  }

  Future<DriverModel> getDriver(DriverIdModel driverIdModel) async {
    DriverModel driver = await driverService.getDriver(driverIdModel);

    return driver;
  }

  Future<DriverModel> updateDriver(DriverModel driverModel) async {
    DriverModel updatedDriver = await driverService.updateDriver(driverModel);

    return updatedDriver;
  }

  Future<DriverModel> deleteDriver(DriverIdModel driverIdModel) async {
    DriverModel deletedDriver = await driverService.deleteDriver(driverIdModel);

    return deletedDriver;
  }

  Future<Uint8List?> generateQrImage(String driverId) async {
    QrPainter qrPainter = QrPainter(
      data: driverId,
      version: QrVersions.auto,
      gapless: true,
      emptyColor: Colors.white,
    );

    ByteData? imageData = await qrPainter.toImageData(1000, format: ui.ImageByteFormat.png);

    return imageData?.buffer.asUint8List();
  }

  Future<void> shareDriverQr(String driverId) async {
    Uint8List? qrBytes = await generateQrImage(driverId);

    if (qrBytes == null) {
      return;
    }

    Directory directory = await getTemporaryDirectory();

    File qrFile = File('${directory.path}/$driverId.png');

    await qrFile.writeAsBytes(qrBytes);

    await Share.shareXFiles(
      [XFile(qrFile.path, mimeType: 'image/png')],
      text: 'Driver QR Code - $driverId',
    );
  }

  Future<void> saveDriverQr(String driverId) async {
    Uint8List? qrBytes = await generateQrImage(driverId);

    if (qrBytes == null) {
      return;
    }

    Directory directory = await getApplicationDocumentsDirectory();

    File qrFile = File('${directory.path}/$driverId.png');

    await qrFile.writeAsBytes(qrBytes);
  }
}