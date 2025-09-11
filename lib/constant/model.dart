class MCQ {    
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
      selectedOption: json['selected_option'], // optional
    );
  }

  final String correctOption;
  final String explanation;
  final String id;
  bool isBookmarked;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String question;
  String? selectedOption;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'option_a': optionA,
      'option_b': optionB,
      'option_c': optionC,
      'option_d': optionD,
      'correct_option': correctOption,
      'explanation': explanation,
      'is_bookmarked': isBookmarked ? 1 : 0,
      'selected_option': selectedOption,
    };
  }
}


class UserTable {
  static String email = "";
  static String googleId = "";
  static String name = "";
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

  final String createdAt;
  final int duration;
  final int examId;
  final int id;
  final String title;
  final int totalMarks;
}


class MockQuestion {
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

  final String correctAns;
  final int id;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String question;
}

class SyllabusPDF {
  SyllabusPDF({
    required this.id,
    required this.examName,
    required this.pdfTitle,
    required this.pdfUrl,
  });

  factory SyllabusPDF.fromJson(Map<String, dynamic> json) {
    return SyllabusPDF(
      id: json['id']?.toString() ?? '',
      examName: json['exam_name'] ?? '',
      pdfTitle: json['pdf_title'] ?? '',
      pdfUrl: json['pdf_url'] ?? '',
    );
  }

  final String examName;
  final String id;
  final String pdfTitle;
  final String pdfUrl;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exam_name': examName,
      'pdf_title': pdfTitle,
      'pdf_url': pdfUrl,
    };
  }
}


class DailyQuizQuestion {
  DailyQuizQuestion({
    required this.id,
    required this.question,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctAns,
  });

  factory DailyQuizQuestion.fromJson(Map<String, dynamic> json) {
    return DailyQuizQuestion(
      id: json['id'],
      question: json['question'],
      optionA: json['option_a'],
      optionB: json['option_b'],
      optionC: json['option_c'],
      optionD: json['option_d'],
      correctAns: json['correct_ans'],
    );
  }

  final String correctAns;
  final int id;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String question;
}


class BannerModel {
  BannerModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.link,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      imageUrl: json['image_url'] ?? '',
      link: json['link'],
    );
  }

  final String id;
  final String imageUrl;
  final String? link;
  final String title;
}

