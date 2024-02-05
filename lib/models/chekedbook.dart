import 'package:hive_flutter/hive_flutter.dart';

@HiveType(typeId: 0,adapterName: 'ChekedbookAdapter')
class Checkedbook extends HiveObject {
  @HiveField(0)
  late String barcode;

  @HiveField(1)
  late String callNo;

  @HiveField(2)
  late String title;

  @HiveField(3)
  late String collectionName;

  @HiveField(4)
  late String itemStatusName;

  @HiveField(5)
  late String collectionId;

  @HiveField(6)
  late int found;

  Checkedbook({required this.barcode,required this.callNo,required this.title,required this.collectionName,required this.itemStatusName,required this.collectionId,required this.found});
}