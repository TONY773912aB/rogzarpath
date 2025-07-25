// models/mcq_model.dart
class MCQ {
  final String id;
  final String question;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctOption;
  final String explanation;
  bool isBookmarked;
  String? selectedOption;

  MCQ({
    required this.id,
    required this.question,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctOption,
    required this.explanation,
    required this.isBookmarked,
    this.selectedOption,
  });

  factory MCQ.fromJson(Map<String, dynamic> json) {
    return MCQ(
      id: json['id'],
      question: json['question'],
      optionA: json['option_a'],
      optionB: json['option_b'],
      optionC: json['option_c'],
      optionD: json['option_d'],
      correctOption: json['correct_option'],
      explanation: json['explanation'],
      isBookmarked: json['is_bookmarked'] == 1,
    );
  }
}


class UserTable {
  static String googleId = "";
  static String name = "";
  static String email = "";
  static String photoUrl = "";

  static void setUser({
    required String id,
    required String userName,
    required String userEmail,
    required String userPhoto,
  }) {
    googleId = id;
    name = userName;
    email = userEmail;
    photoUrl = userPhoto;
  }

  static void clear() {
    googleId = "";
    name = "";
    email = "";
    photoUrl = "";
  }
}


class MockTest {
  final int id;
  final int examId;
  final String title;
  final int duration;
  final int totalMarks;
  final String createdAt;

  MockTest({
    required this.id,
    required this.examId,
    required this.title,
    required this.duration,
    required this.totalMarks,
    required this.createdAt,
  });

  factory MockTest.fromJson(Map<String, dynamic> json) {
    return MockTest(
      id: int.parse(json['id'].toString()),
      examId: int.parse(json['exam_id'].toString()),
      title: json['title'],
      duration: int.parse(json['duration'].toString()),
      totalMarks: int.parse(json['total_marks'].toString()),
      createdAt: json['created_at'],
    );
  }
}


class MockQuestion {
  final int id;
  final String question;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctAns;

  MockQuestion({
    required this.id,
    required this.question,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctAns,
  });

  factory MockQuestion.fromJson(Map<String, dynamic> json) {
    return MockQuestion(
      id: int.parse(json['id'].toString()),
      question: json['question'],
      optionA: json['option_a'],
      optionB: json['option_b'],
      optionC: json['option_c'],
      optionD: json['option_d'],
      correctAns: json['correct_ans'],
    );
  }
}
