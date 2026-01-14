// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bundle_line.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BundleLine _$BundleLineFromJson(Map<String, dynamic> json) => BundleLine(
      id: (json['id'] as num?)?.toInt(),
      transNo: json['transNo'] as String,
      productCode: json['productCode'] as String,
      qty: (json['qty'] as num).toDouble(),
      isDeleted: json['isDeleted'] as bool? ?? false,
      createAt: json['createAt'] == null
          ? null
          : DateTime.parse(json['createAt'] as String),
      updateAt: json['updateAt'] == null
          ? null
          : DateTime.parse(json['updateAt'] as String),
      productName: json['productName'] as String?,
    );

Map<String, dynamic> _$BundleLineToJson(BundleLine instance) =>
    <String, dynamic>{
      'id': instance.id,
      'transNo': instance.transNo,
      'productCode': instance.productCode,
      'qty': instance.qty,
      'isDeleted': instance.isDeleted,
      'createAt': instance.createAt?.toIso8601String(),
      'updateAt': instance.updateAt?.toIso8601String(),
      'productName': instance.productName,
    };
