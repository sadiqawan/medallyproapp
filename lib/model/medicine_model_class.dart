class MedicineModel {
  String? userID;
  String? userName;
  String doctorName;
  String doctorImage;
  String member;
  String medicineName;
  String intake;
  List<String> time;
  String typeOfMedicine;
  String duration;
  String notes;
  String fronImage;
  String backImage;

  MedicineModel({
    this.userID,
    this.userName,
    required this.doctorName,
    required this.doctorImage,
    required this.member,
    required this.medicineName,
    required this.intake,
    required this.time,
    required this.typeOfMedicine,
    required this.duration,
    required this.notes,
    required this.fronImage,
    required this.backImage,
  });
}