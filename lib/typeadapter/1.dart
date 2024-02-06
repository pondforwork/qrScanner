import 'package:hive/hive.dart';
import 'package:qr_scan/models/chekedbook.dart';

class CheckedbookAdapter extends TypeAdapter<Checkedbook> {
  @override
  final int typeId = 0; // Should match the typeId in @HiveType annotation

  @override
  Checkedbook read(BinaryReader reader) {
    // Implement deserialization logic
    // Example: return Checkedbook(barcode: reader.readString(), ...);
  }

  @override
  void write(BinaryWriter writer, Checkedbook obj) {
    // Implement serialization logic
    // Example: writer.writeString(obj.barcode);
  }
}
