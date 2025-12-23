import 'package:json_annotation/json_annotation.dart';

part 'receipt_order.g.dart';

@JsonSerializable()
class ReceiptOrder {
  final int? id;
  @JsonKey(name: 'receiptNo')
  final String receiptNo;
  @JsonKey(name: 'supplierId')
  final int supplierId;
  @JsonKey(name: 'tenantId')
  final int tenantId;
  @JsonKey(name: 'status')
  final int status;
  @JsonKey(name: 'hhtStatus')
  final int? hhtStatus;
  @JsonKey(name: 'hhtInfo')
  final String? hhtInfo;
  @JsonKey(name: 'scheduledArrivalNumber')
  final String? scheduledArrivalNumber;
  @JsonKey(name: 'isDeleted')
  final bool isDeleted;
  @JsonKey(name: 'createAt')
  final DateTime? createAt;
  @JsonKey(name: 'updateAt')
  final DateTime? updateAt;

  // Additional fields for UI
  final String? supplierName;
  final String? productNames;
  final int? scanStatus; // -1: not scanned, 2: scanned, 3: handled by other

  ReceiptOrder({
    this.id,
    required this.receiptNo,
    required this.supplierId,
    required this.tenantId,
    required this.status,
    this.hhtStatus,
    this.hhtInfo,
    this.scheduledArrivalNumber,
    this.isDeleted = false,
    this.createAt,
    this.updateAt,
    this.supplierName,
    this.productNames,
    this.scanStatus,
  });

  factory ReceiptOrder.fromJson(Map<String, dynamic> json) =>
      _$ReceiptOrderFromJson(json);

  Map<String, dynamic> toJson() => _$ReceiptOrderToJson(this);

  ReceiptOrder copyWith({
    int? id,
    String? receiptNo,
    int? supplierId,
    int? tenantId,
    int? status,
    int? hhtStatus,
    String? hhtInfo,
    String? scheduledArrivalNumber,
    bool? isDeleted,
    DateTime? createAt,
    DateTime? updateAt,
    String? supplierName,
    String? productNames,
    int? scanStatus,
  }) {
    return ReceiptOrder(
      id: id ?? this.id,
      receiptNo: receiptNo ?? this.receiptNo,
      supplierId: supplierId ?? this.supplierId,
      tenantId: tenantId ?? this.tenantId,
      status: status ?? this.status,
      hhtStatus: hhtStatus ?? this.hhtStatus,
      hhtInfo: hhtInfo ?? this.hhtInfo,
      scheduledArrivalNumber:
          scheduledArrivalNumber ?? this.scheduledArrivalNumber,
      isDeleted: isDeleted ?? this.isDeleted,
      createAt: createAt ?? this.createAt,
      updateAt: updateAt ?? this.updateAt,
      supplierName: supplierName ?? this.supplierName,
      productNames: productNames ?? this.productNames,
      scanStatus: scanStatus ?? this.scanStatus,
    );
  }
}

