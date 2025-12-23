/// Application Configuration
/// Same as React Native env/info.js
class AppConfig {
  static const String version = '1.10.2';
  static const String build = '1';
  static const String date = '2025-10-27';
  static const String env = 'Development';
  
  // API Host - same as React Native
  static const String host = 'http://133.167.47.242:9500';
  
  // API Timeout
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // Storage Keys (same as React Native AsyncStorage)
  static const String keyUserToken = 'userToken';
  static const String keyUserName = 'userName';
  static const String keyPassword = 'passWord';
  static const String keyAccount = 'account';
  static const String keyDataToken = 'dataToken';
  static const String keyLoginType = 'loginType';
  
  // Warehouse Receipt Keys
  static const String keyWHReceiptLineScanned = 'WHReceiptLineScanned';
  static const String keyDataWarehouseReceipt = 'dataWarehouseReceipt';
  static const String keyDataReceiptLines = 'dataReceiptLines';
  static const String keyDataProducts = 'dataProducts';
  static const String keyDataSuppliers = 'dataSuppliers';
  static const String keyDataWarehouseReceiptLine = 'dataWarehouseReceiptLine';
  static const String keyHHTInfo = 'hhtInfo';
  static const String keyCountCurrentHistories = 'countCurrentHistories';
}

