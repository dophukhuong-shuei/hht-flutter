class ApiEndpoints {
  // Auth
  static const String login = '/api/Account/identity/loginasync';
  static const String loginByQR = '/api/Account/identity/loginht';
  static const String refreshToken = '/api/Account/identity/refresh-token';
  
  // Master Data
  static const String products = '/api/Products';
  static const String productsByCode = '/api/Products/get-by-product-code';
  static const String productsList = '/api/Products/get-product-list';
  static const String productsWithInventory = '/api/Products/GetAllDtoAsync';
  static const String suppliers = '/api/Suppliers';
  static const String bins = '/api/Bins';
  static const String units = '/api/Units';
  static const String locations = '/api/Locations';
  static const String vendors = '/api/Vendors';
  static const String roles = '/api/Account/identity/user-with-role';
  
  // Warehouse Receipt
  static const String warehouseReceipt = '/api/WarehouseReceiptOrder';
  static const String warehouseReceiptLines = '/api/WarehouseReceiptOrderLine';
  static const String warehouseReceiptStaging = '/api/WarehouseReceiptStaging';
  
  // Putaway
  static const String putaway = '/api/WarehousePutAway';
  static const String putawayLines = '/api/WarehousePutAwayLine';
  static const String putawayStaging = '/api/WarehousePutAwayStaging';
  
  // Picking
  static const String pickingList = '/api/WarehousePickingList';
  static const String pickingLines = '/api/WarehousePickingLine';
  static const String pickingStaging = '/api/WarehousePickingStaging';
  
  // Bundle
  static const String bundle = '/api/InventBundle';
  static const String bundleLines = '/api/InventBundleLine';
  
  // Bin Movement
  static const String inventTransfer = '/api/InventTransfer';
  
  // Bin Audit
  static const String stockTake = '/api/InventStockTakeRecording';
  
  // Common
  static const String updateHHTStatus = '/api/Common/UpdateHHTStatusAsync';
  static const String devices = '/api/Devices';
}

