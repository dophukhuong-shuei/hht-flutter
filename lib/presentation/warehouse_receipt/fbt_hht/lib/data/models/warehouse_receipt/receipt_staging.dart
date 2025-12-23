import 'package:json_annotation/json_annotation.dart';

part 'receipt_staging.g.dart';

/// Model for staging data (offline scanned data)
@JsonSerializable()
class ReceiptStaging {
  final int? id;
  @JsonKey(name: 'receiptNo')
  final String receiptNo;
  @JsonKey(name: 'productCode')
  final String productCode;
  @JsonKey(name: 'unitId')
  final int? unitId;
  @JsonKey(name: 'orderQty')
  final double orderQty;
  @JsonKey(name: 'transQty')
  final double transQty;
  @JsonKey(name: 'bin')
  final String? bin;
  @JsonKey(name: 'lotNo')
  final String? lotNo;
  @JsonKey(name: 'expirationDate')
  final String? expirationDate;
  @JsonKey(name: 'receiptLineId')
  final int? receiptLineId;
  @JsonKey(name: 'status')
  final int status;
  @JsonKey(name: 'janCode')
  final String? janCode;
  @JsonKey(name: 'createAt')
  final DateTime? createAt;
  @JsonKey(name: 'updateAt')
  final DateTime? updateAt;

  ReceiptStaging({
    this.id,
    required this.receiptNo,
    required this.productCode,
    this.unitId,
    required this.orderQty,
    required this.transQty,
    this.bin,
    this.lotNo,
    this.expirationDate,
    this.receiptLineId,
    this.status = 1,
    this.janCode,
    this.createAt,
    this.updateAt,
  });

  factory ReceiptStaging.fromJson(Map<String, dynamic> json) =>
      _$ReceiptStagingFromJson(json);

  Map<String, dynamic> toJson() => _$ReceiptStagingToJson(this);
}

/// Model for product error images
@JsonSerializable()
class ProductErrorImage {
  @JsonKey(name: 'receiptLineId')
  final int receiptLineId;
  @JsonKey(name: 'statusError')
  final int statusError;
  @JsonKey(name: 'errorImages')
  final List<ErrorImageData> errorImages;

  ProductErrorImage({
    required this.receiptLineId,
    required this.statusError,
    required this.errorImages,
  });

  factory ProductErrorImage.fromJson(Map<String, dynamic> json) =>
      _$ProductErrorImageFromJson(json);

  Map<String, dynamic> toJson() => _$ProductErrorImageToJson(this);
}

@JsonSerializable()
class ErrorImageData {
  @JsonKey(name: 'filePath')
  final String filePath;
  @JsonKey(name: 'fileName')
  final String fileName;
  @JsonKey(name: 'imageBase64')
  final String imageBase64;

  ErrorImageData({
    required this.filePath,
    required this.fileName,
    required this.imageBase64,
  });

  factory ErrorImageData.fromJson(Map<String, dynamic> json) =>
      _$ErrorImageDataFromJson(json);

  Map<String, dynamic> toJson() => _$ErrorImageDataToJson(this);
}

/// Model for offline scanned receipt (stored locally)
@JsonSerializable()
class OfflineReceiptData {
  @JsonKey(name: 'WarehouseReceiptNo')
  final String warehouseReceiptNo;
  @JsonKey(name: 'TenantId')
  final int tenantId;
  @JsonKey(name: 'WarehouseReceiptLinesScanned')
  final List<ScannedReceiptLine> warehouseReceiptLinesScanned;
  @JsonKey(name: 'WarehouseReceiptLines')
  final List<ReceiptLine> warehouseReceiptLines;
  @JsonKey(name: 'dataImage')
  final List<ImageData>? dataImage;

  OfflineReceiptData({
    required this.warehouseReceiptNo,
    required this.tenantId,
    required this.warehouseReceiptLinesScanned,
    required this.warehouseReceiptLines,
    this.dataImage,
  });

  factory OfflineReceiptData.fromJson(Map<String, dynamic> json) =>
      _$OfflineReceiptDataFromJson(json);

  Map<String, dynamic> toJson() => _$OfflineReceiptDataToJson(this);
}

@JsonSerializable()
class ScannedReceiptLine {
  @JsonKey(name: 'WarehouseReceiptNo')
  final String warehouseReceiptNo;
  @JsonKey(name: 'ProductCode')
  final String productCode;
  @JsonKey(name: 'Unit')
  final int? unit;
  @JsonKey(name: 'OrderQty')
  final double orderQty;
  @JsonKey(name: 'ActualQty')
  final double actualQty;
  @JsonKey(name: 'Bin')
  final String? bin;
  @JsonKey(name: 'LotNo')
  final String? lotNo;
  @JsonKey(name: 'ExpirationDate')
  final String? expirationDate;
  @JsonKey(name: 'id')
  final int? id;
  @JsonKey(name: 'Status')
  final int status;
  @JsonKey(name: 'janCode')
  final String? janCode;

  ScannedReceiptLine({
    required this.warehouseReceiptNo,
    required this.productCode,
    this.unit,
    required this.orderQty,
    required this.actualQty,
    this.bin,
    this.lotNo,
    this.expirationDate,
    this.id,
    this.status = 1,
    this.janCode,
  });

  factory ScannedReceiptLine.fromJson(Map<String, dynamic> json) =>
      _$ScannedReceiptLineFromJson(json);

  Map<String, dynamic> toJson() => _$ScannedReceiptLineToJson(this);
}

@JsonSerializable()
class ImageData {
  @JsonKey(name: 'base64')
  final String base64;
  @JsonKey(name: 'uri')
  final String? uri;

  ImageData({
    required this.base64,
    this.uri,
  });

  factory ImageData.fromJson(Map<String, dynamic> json) =>
      _$ImageDataFromJson(json);

  Map<String, dynamic> toJson() => _$ImageDataToJson(this);
}

