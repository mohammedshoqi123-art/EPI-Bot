/// زر رد سريع
class QuickReply {
  final String text;
  final String emoji;
  const QuickReply({required this.text, required this.emoji});
}

class Vaccine {
  final String id;
  final String nameAr;
  final String nameEn;
  final String description;
  final int dueWeeks;        // weeks after birth
  final int dueMonths;      // months after birth
  final String doseNumber;  // الجرعة الأولى، الثانية، etc.
  final String route;       // intramuscular, oral, subcutaneous
  final String site;        // injection site
  final String color;       // hex color for UI
  final String iconEmoji;
  final List<String> sideEffects;
  final List<String> contraindications;
  final String notes;

  const Vaccine({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.description,
    this.dueWeeks = 0,
    this.dueMonths = 0,
    required this.doseNumber,
    required this.route,
    required this.site,
    required this.color,
    required this.iconEmoji,
    this.sideEffects = const [],
    this.contraindications = const [],
    this.notes = '',
  });
}

class ChildRecord {
  final String id;
  final String childName;
  final String parentName;
  final DateTime birthDate;
  final String gender; // ذكر / أنثى
  final String governorate;
  final String district;
  final String healthFacility;
  final List<VaccinationEntry> vaccinations;
  final String? notes;

  ChildRecord({
    required this.id,
    required this.childName,
    required this.parentName,
    required this.birthDate,
    required this.gender,
    required this.governorate,
    required this.district,
    required this.healthFacility,
    this.vaccinations = const [],
    this.notes,
  });

  ChildRecord copyWith({
    List<VaccinationEntry>? vaccinations,
  }) {
    return ChildRecord(
      id: id,
      childName: childName,
      parentName: parentName,
      birthDate: birthDate,
      gender: gender,
      governorate: governorate,
      district: district,
      healthFacility: healthFacility,
      vaccinations: vaccinations ?? this.vaccinations,
      notes: notes,
    );
  }
}

class VaccinationEntry {
  final String vaccineId;
  final DateTime? dateGiven;
  final bool isCompleted;
  final String? batchNumber;
  final String? healthWorker;
  final String? notes;

  const VaccinationEntry({
    required this.vaccineId,
    this.dateGiven,
    this.isCompleted = false,
    this.batchNumber,
    this.healthWorker,
    this.notes,
  });
}

class ChatMessage {
  final String id;
  final String text;
  final bool isBot;
  final DateTime timestamp;
  final List<QuickReply>? quickReplies;
  final MessageType type;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isBot,
    required this.timestamp,
    this.quickReplies,
    this.type = MessageType.text,
  });
}

enum MessageType {
  text,
  vaccineInfo,
  scheduleCard,
  reminder,
  warning,
  success,
}
