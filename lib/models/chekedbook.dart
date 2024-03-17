class Checkedbook {
  late String barcode;
  late String callNo;
  late String title;
  late String author;
  late String collectionName;
  late String itemStatusName;
  late int collectionId;
  late String found;
  late String recorder;
  late String note;
  late DateTime checktime;
  late String recorderemail;
  late int count;
  late bool exportstatus;
  Checkedbook(
      this.barcode,
      this.callNo,
      this.title,
      this.author,
      this.collectionName,
      this.itemStatusName,
      this.collectionId,
      this.found,
      this.recorder,
      this.recorderemail,
      this.note,
      this.checktime,
      this.count,
      this.exportstatus);
}
