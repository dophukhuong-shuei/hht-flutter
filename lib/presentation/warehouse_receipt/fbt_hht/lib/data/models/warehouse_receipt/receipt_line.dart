import 'package:json_annotation/json_annotation.dart';

part 'receipt_line.g.dart';

@JsonSerializable()
class ReceiptLine {
  final int? id;
  @JsonKey(name: 'receiptNo')
  final String receiptNo;
  @JsonKey(name: 'productCode')
  final String productCode;
  @JsonKey(name: 'unitId')
  final int? unitId;
  @JsonKey(name: 'unitName')
  final String? unitName;
  @JsonKey(name: 'orderQty')
  final double orderQty;
  @JsonKey(name: 'transQty')
  final double? transQty;
  @JsonKey(name: 'bin')
  final String? bin;
  @JsonKey(name: 'lotNo')
  final String? lotNo;
  @JsonKey(name: 'expirationDate')
  final String? expirationDate;
  @JsonKey(name: 'putaway')
  final double? putaway;
  @JsonKey(name: 'status')
  final int status;
  @JsonKey(name: 'arrivalNo')
  final String? arrivalNo;
  @JsonKey(name: 'receiptLineIdParent')
  final int? receiptLineIdParent;
  @JsonKey(name: 'janCode')
  final String? janCode;
  @JsonKey(name: 'isDeleted')
  final bool isDeleted;
  @JsonKey(name: 'createAt')
  final DateTime? createAt;
  @JsonKey(name: 'updateAt')
  final DateTime? updateAt;
  @JsonKey(name: 'createOperatorId')
  final String? createOperatorId;
  @JsonKey(name: 'updateOperatorId')
  final String? updateOperatorId;

  // Additional fields for UI
  final String? productName;
  final List<String>? errorImages;

  ReceiptLine({
    this.id,
    required this.receiptNo,
    required this.productCode,
    this.unitId,
    this.unitName,
    required this.orderQty,
    this.transQty,
    this.bin,
    this.lotNo,
    this.expirationDate,
    this.putaway,
    this.status = 1,
    this.arrivalNo,
    this.receiptLineIdParent,
    this.janCode,
    this.isDeleted = false,
    this.createAt,
    this.updateAt,
    this.createOperatorId,
    this.updateOperatorId,
    this.productName,
    this.errorImages,
  });

  factory ReceiptLine.fromJson(Map<String, dynamic> json) =>
      _$ReceiptLineFromJson(json);

  Map<String, dynamic> toJson() => _$ReceiptLineToJson(this);

  ReceiptLine copyWith({
    int? id,
    String? receiptNo,
    String? productCode,
    int? unitId,
    String? unitName,
    double? orderQty,
    double? transQty,
    String? bin,
    String? lotNo,
    String? expirationDate,
    double? putaway,
    int? status,
    String? arrivalNo,
    int? receiptLineIdParent,
    String? janCode,
    bool? isDeleted,
    DateTime? createAt,
    DateTime? updateAt,
    String? createOperatorId,
    String? updateOperatorId,
    String? productName,
    List<String>? errorImages,
  }) {
    return ReceiptLine(
      id: id ?? this.id,
      receiptNo: receiptNo ?? this.receiptNo,
      productCode: productCode ?? this.productCode,
      unitId: unitId ?? this.unitId,
      unitName: unitName ?? this.unitName,
      orderQty: orderQty ?? this.orderQty,
      transQty: transQty ?? this.transQty,
      bin: bin ?? this.bin,
      lotNo: lotNo ?? this.lotNo,
      expirationDate: expirationDate ?? this.expirationDate,
      putaway: putaway ?? this.putaway,
      status: status ?? this.status,
      arrivalNo: arrivalNo ?? this.arrivalNo,
      receiptLineIdParent: receiptLineIdParent ?? this.receiptLineIdParent,
      janCode: janCode ?? this.janCode,
      isDeleted: isDeleted ?? this.isDeleted,
      createAt: createAt ?? this.createAt,
      updateAt: updateAt ?? this.updateAt,
      createOperatorId: createOperatorId ?? this.createOperatorId,
      updateOperatorId: updateOperatorId ?? this.updateOperatorId,
      productName: productName ?? this.productName,
      errorImages: errorImages ?? this.errorImages,
    );
  }
}

