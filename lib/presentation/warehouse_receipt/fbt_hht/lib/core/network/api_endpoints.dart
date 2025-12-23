class ApiEndpoints {
  // Auth
  static const String login = '/api/Account/identity/loginasync';
  static const String loginByQR = '/api/Account/identity/loginht';
  static const String refreshToken = '/api/Account/identity/refresh-token';

  // Warehouse Receipt
  static const String warehouseReceiptOrder = '/api/WarehouseReceiptOrder';
  static const String warehouseReceiptOrderById =
      '/api/WarehouseReceiptOrder/{id}';
  static const String warehouseReceiptOrderByReceiptNo =
      '/api/WarehouseReceiptOrder/GetByMasterCodeAsync/{receiptNo}';
  static const String warehouseReceiptOrderUpdate =
      '/api/WarehouseReceiptOrder/update';
  static const String completeWarehouseReceipt =
      '/api/WarehouseReceiptOrder/complete-putaway-receipts';

  // Warehouse Receipt Line
  static const String warehouseReceiptOrderLine =
      '/api/WarehouseReceiptOrderLine';
  static const String warehouseReceiptOrderLineById =
      '/api/WarehouseReceiptOrderLine/{id}';
  static const String warehouseReceiptOrderLineByReceiptNo =
      '/api/WarehouseReceiptOrderLine/GetByMasterCodeAsync/{receiptNo}';
  static const String warehouseReceiptOrderLineUpdate =
      '/api/WarehouseReceiptOrderLine/update';

  // Warehouse Receipt Staging
  static const String warehouseReceiptStaging = '/api/WarehouseReceiptStaging';
  static const String warehouseReceiptStagingById =
      '/api/WarehouseReceiptStaging/{id}';
  static const String warehouseReceiptStagingByReceiptNo =
      '/api/WarehouseReceiptStaging/GetByMasterCodeAsync/{receiptNo}';
  static const String warehouseReceiptStagingAddRange =
      '/api/WarehouseReceiptStaging/AddRange';
  static const String warehouseReceiptStagingInsert =
      '/api/WarehouseReceiptStaging/insert';
  static const String warehouseReceiptStagingUpdate =
      '/api/WarehouseReceiptStaging/update';
  static const String warehouseReceiptStagingDelete =
      '/api/WarehouseReceiptStaging/delete';
  static const String warehouseReceiptStagingUploadImage =
      '/api/WarehouseReceiptStaging/UploadProductErrorImageAsync';

  // Common
  static const String updateHHTStatus =
      '/api/Common/UpdateHHTStatusAsync';
  static const String downloadFile =
      '/api/Devices/DownloadApiAsync?pathFile={pathFile}';

  // Products
  static const String products = '/api/Products';
  static const String productByJanCode =
      '/api/Products/GetByJanCodeAsync/{janCode}';
  static const String productByProductCode =
      '/api/Products/GetByProductCodeAsync/{productCode}';

  // Suppliers
  static const String suppliers = '/api/Suppliers';
  static const String supplierById = '/api/Suppliers/{id}';

  // Tenants
  static const String tenants = '/api/Tenants';

  // Units
  static const String units = '/api/Units';
}

