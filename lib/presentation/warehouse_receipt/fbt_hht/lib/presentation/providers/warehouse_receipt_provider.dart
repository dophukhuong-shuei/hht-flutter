import 'package:flutter/foundation.dart';
import '../../data/models/warehouse_receipt/receipt_order.dart';
import '../../data/models/warehouse_receipt/receipt_line.dart';
import '../../data/models/warehouse_receipt/receipt_staging.dart';
import '../../data/repositories/warehouse_receipt_repository.dart';
import '../../core/storage/local_storage.dart';

class WarehouseReceiptProvider with ChangeNotifier {
  final WarehouseReceiptRepository _repository;
  final LocalStorage _localStorage;

  WarehouseReceiptProvider(this._repository, this._localStorage);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<ReceiptOrder> _receiptOrders = [];
  List<ReceiptOrder> get receiptOrders => _receiptOrders;

  List<ReceiptLine> _receiptLines = [];
  List<ReceiptLine> get receiptLines => _receiptLines;

  List<ReceiptLine> _currentReceiptLines = [];
  List<ReceiptLine> get currentReceiptLines => _currentReceiptLines;

  ReceiptOrder? _selectedReceipt;
  ReceiptOrder? get selectedReceipt => _selectedReceipt;

  List<OfflineReceiptData> _offlineData = [];
  List<OfflineReceiptData> get offlineData => _offlineData;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _hhtInfo;
  String? get hhtInfo => _hhtInfo;

  /// Initialize - load HHT info and offline data
  Future<void> initialize() async {
    _hhtInfo = await _localStorage.getString('hhtInfo');
    _offlineData = await _repository.getOfflineReceiptDataList();
    notifyListeners();
  }

  /// Get offline data by tenant ID
  List<OfflineReceiptData> getOfflineDataByTenant(int tenantId) {
    return _offlineData.where((data) => data.tenantId == tenantId).toList();
  }

  /// Fetch warehouse receipt orders from API
  Future<void> fetchWarehouseReceiptOrders(int tenantId,
      {String? vendorId,
      String? janCode,
      String? productName,
      String? productCode,
      String? arrivalNumber}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Fetch from API
      final orders = await _repository.getWarehouseReceiptOrders();
      final lines = await _repository.getWarehouseReceiptOrderLines();

      // Filter by tenant
      var filteredOrders = orders
          .where((order) =>
              !order.isDeleted && order.status == 1 && order.tenantId == tenantId)
          .toList();

      // Apply additional filters
      if (vendorId != null && vendorId.isNotEmpty) {
        filteredOrders = filteredOrders
            .where((order) => order.supplierId == int.tryParse(vendorId))
            .toList();
      }

      if (arrivalNumber != null && arrivalNumber.isNotEmpty) {
        filteredOrders = filteredOrders
            .where((order) =>
                order.scheduledArrivalNumber
                    ?.toLowerCase()
                    .contains(arrivalNumber.toLowerCase()) ??
                false)
            .toList();
      }

      // Get offline scanned data
      _offlineData = await _repository.getOfflineReceiptDataList();
      final offlineScanned = _offlineData;

      // Get suppliers and products from local storage
      final suppliersJson = await _localStorage.getJson('dataSuppliers');
      final productsJson = await _localStorage.getJson('dataProducts');

      // Enrich orders with supplier names and scan status
      _receiptOrders = filteredOrders.map((order) {
        // Find supplier name
        String? supplierName;
        if (suppliersJson != null && suppliersJson is List) {
          final supplier = suppliersJson.firstWhere(
            (s) => s['id'] == order.supplierId,
            orElse: () => null,
          );
          supplierName = supplier?['supplierName'];
        }

        // Determine scan status
        int scanStatus = -1;
        final scanned = offlineScanned.firstWhere(
          (s) => s.warehouseReceiptNo == order.receiptNo,
          orElse: () => null as OfflineReceiptData,
        );

        if (scanned != null || order.hhtInfo == _hhtInfo) {
          scanStatus = 2; // Scanned
        } else if (order.hhtInfo != null &&
            order.hhtInfo!.isNotEmpty &&
            order.hhtInfo != _hhtInfo) {
          scanStatus = 3; // Handled by other device
        }

        // Get product names for this receipt
        final orderLines =
            lines.where((line) => line.receiptNo == order.receiptNo).toList();
        String productNames = '';
        if (productsJson != null && productsJson is List) {
          for (var line in orderLines) {
            final product = productsJson.firstWhere(
              (p) => p['productCode'] == line.productCode,
              orElse: () => null,
            );
            if (product != null) {
              productNames += '${product['productName']}, ';
            }
          }
        }

        return order.copyWith(
          supplierName: supplierName,
          scanStatus: scanStatus,
          productNames: productNames.isNotEmpty
              ? productNames.substring(0, productNames.length - 2)
              : '',
        );
      }).toList();

      _receiptLines = lines.where((line) => !line.isDeleted).toList();

      // Save to local storage
      await _repository.saveWarehouseReceiptOrders(_receiptOrders);
      await _repository.saveWarehouseReceiptLines(_receiptLines);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'データの取得に失敗しました: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Select a receipt and load its lines
  Future<void> selectReceipt(ReceiptOrder receipt) async {
    _selectedReceipt = receipt;
    _isLoading = true;
    notifyListeners();

    try {
      // Get lines for this receipt
      final lines = _receiptLines
          .where((line) => line.receiptNo == receipt.receiptNo)
          .toList();

      // Enrich with product names
      final productsJson = await _localStorage.getJson('dataProducts');
      if (productsJson != null && productsJson is List) {
        _currentReceiptLines = lines.map((line) {
          final product = productsJson.firstWhere(
            (p) => p['productCode'] == line.productCode,
            orElse: () => null,
          );
          return line.copyWith(
            productName: product?['productName'],
          );
        }).toList();
      } else {
        _currentReceiptLines = lines;
      }

      // Save to local storage
      await _repository.saveWarehouseReceiptLineForReceipt(
        receipt.receiptNo,
        _currentReceiptLines,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'データの取得に失敗しました: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Search receipts by keyword
  Future<void> searchReceipts(String keyword, int tenantId) async {
    if (keyword.isEmpty) {
      await fetchWarehouseReceiptOrders(tenantId);
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Search in receipt numbers and supplier names
      var filtered = _receiptOrders.where((order) {
        return order.receiptNo.toLowerCase().contains(keyword.toLowerCase()) ||
            (order.supplierName
                    ?.toLowerCase()
                    .contains(keyword.toLowerCase()) ??
                false);
      }).toList();

      // If no results, search in product names/codes
      if (filtered.isEmpty) {
        final productsJson = await _localStorage.getJson('dataProducts');
        if (productsJson != null && productsJson is List) {
          // Search by product name
          var productMatches = productsJson.where((p) =>
              p['productName']
                  ?.toLowerCase()
                  .contains(keyword.toLowerCase()) ??
              false);

          // Search by product code
          if (productMatches.isEmpty) {
            productMatches = productsJson.where((p) =>
                p['productCode']
                    ?.toLowerCase()
                    .contains(keyword.toLowerCase()) ??
                false);
          }

          // Search by JAN code
          if (productMatches.isEmpty) {
            productMatches = productsJson.where((p) =>
                p['janCode']?.toLowerCase().contains(keyword.toLowerCase()) ??
                false);
          }

          if (productMatches.isNotEmpty) {
            final productCodes =
                productMatches.map((p) => p['productCode']).toList();
            final matchingLines = _receiptLines
                .where((line) => productCodes.contains(line.productCode))
                .toList();
            final receiptNos =
                matchingLines.map((line) => line.receiptNo).toSet();

            filtered = _receiptOrders
                .where((order) => receiptNos.contains(order.receiptNo))
                .toList();
          }
        }
      }

      _receiptOrders = filtered;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = '検索に失敗しました: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sync offline data to server
  Future<bool> syncOfflineData(int tenantId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get offline data for this tenant
      final offlineDataList =
          await _repository.getOfflineReceiptDataByTenant(tenantId);

      if (offlineDataList.isEmpty) {
        _errorMessage = 'データ同期なし';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      List<ReceiptStaging> stagingList = [];
      List<ProductErrorImage> errorImagesList = [];

      // Prepare staging data
      for (var offlineData in offlineDataList) {
        for (var scannedLine in offlineData.warehouseReceiptLinesScanned) {
          // Add to staging
          stagingList.add(ReceiptStaging(
            receiptNo: scannedLine.warehouseReceiptNo,
            productCode: scannedLine.productCode,
            unitId: scannedLine.unit,
            orderQty: scannedLine.status > 1 ? 0 : scannedLine.orderQty,
            transQty: scannedLine.actualQty,
            bin: scannedLine.bin,
            lotNo: scannedLine.lotNo,
            expirationDate: scannedLine.expirationDate,
            receiptLineId: scannedLine.id,
            status: scannedLine.status,
            janCode: scannedLine.janCode,
          ));

          // Prepare error images if status > 1
          if (scannedLine.status > 1 &&
              offlineData.dataImage != null &&
              offlineData.dataImage!.isNotEmpty) {
            final errorImages = offlineData.dataImage!
                .asMap()
                .entries
                .map((entry) => ErrorImageData(
                      filePath: '',
                      fileName:
                          '${DateTime.now().toString().split(' ')[0]}_${scannedLine.productCode}_ImgError${entry.key}.png',
                      imageBase64: 'data:image/png;base64,${entry.value.base64}',
                    ))
                .toList();

            errorImagesList.add(ProductErrorImage(
              receiptLineId: scannedLine.id!,
              statusError: scannedLine.status,
              errorImages: errorImages,
            ));
          }

          // Update receipt line
          final originalLine = offlineData.warehouseReceiptLines.firstWhere(
            (line) => line.id == scannedLine.id,
            orElse: () => null as ReceiptLine,
          );

          if (originalLine != null) {
            await _repository.updateWarehouseReceiptOrderLine(
              originalLine.copyWith(
                janCode: scannedLine.janCode,
                updateOperatorId: 'HHT',
              ),
            );
          }
        }
      }

      // Delete existing staging data
      for (var staging in stagingList) {
        final existingStaging =
            await _repository.getWarehouseReceiptStagingByReceiptNo(
          staging.receiptNo,
        );
        for (var existing in existingStaging) {
          await _repository.deleteWarehouseReceiptStaging(existing);
        }
      }

      // Add new staging data
      final stagingSuccess =
          await _repository.addRangeWarehouseReceiptStaging(stagingList);

      // Upload error images
      final imagesSuccess = errorImagesList.isEmpty ||
          await _repository.uploadProductErrorImages(errorImagesList);

      if (stagingSuccess && imagesSuccess) {
        // Update HHT status for each receipt
        for (var staging in stagingList) {
          final receiptOrders =
              await _repository.getWarehouseReceiptOrderByReceiptNo(
            staging.receiptNo,
          );
          if (receiptOrders.isNotEmpty) {
            await _repository.updateHHTStatus(2, receiptOrders.first.id!, 0);
          }
        }

        // Complete warehouse receipt
        await _repository.completeWarehouseReceipt();

        // Remove offline data for this tenant
        await _repository.removeOfflineReceiptDataByTenant(tenantId);
        
        // Refresh offline data
        _offlineData = await _repository.getOfflineReceiptDataList();

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = '同期に失敗しました';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = '同期に失敗しました: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Reset scanned data for a receipt
  Future<bool> resetScannedData(String receiptNo) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Remove offline data
      await _repository.removeOfflineReceiptData(receiptNo);

      // Update HHT status
      final receiptOrders =
          await _repository.getWarehouseReceiptOrderByReceiptNo(receiptNo);
      if (receiptOrders.isNotEmpty) {
        await _repository.updateHHTStatusEmpty(0, receiptOrders.first.id!, 0);
      }

      // Refresh data
      final tenantId = _selectedReceipt?.tenantId;
      if (tenantId != null) {
        await fetchWarehouseReceiptOrders(tenantId);
      }
      
      // Refresh offline data
      _offlineData = await _repository.getOfflineReceiptDataList();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'リセットに失敗しました: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

