import 'package:jwt_auth/data/comment_config.dart';

class Report {
  final int id;
  final String userName;
  final String mobile;
  final String? acc;
  final String? sector;
  final String? place;
  final String? createdAt;
  final String? lastComment;
  final List<CommentData>? comments;
  final List<int>? problems;
  final List<int>? solutions;
  final bool enable = true;

  Report({
    required this.userName,
    required this.mobile,
    required this.id,
    this.acc,
    this.sector,
    this.place,
    this.createdAt,
    this.lastComment,
    this.comments,
    this.problems,
    this.solutions,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    // Parse the comments list
    final List<CommentData> commentsList = [];
    final commentsJson = json['comments'];
    if (commentsJson is List) {
      commentsList.addAll(commentsJson
          .map((comment) =>
              comment != null ? CommentData.fromJson(comment) : null)
          .where((comment) => comment != null)
          .cast<CommentData>());
    }

    // Parse the problems list
    final List<int> problemsList = [];
    final problemsJson = json['problem'];
    if (problemsJson is List) {
      problemsList
          .addAll(problemsJson.where((problem) => problem is int).cast<int>());
    }

    // Parse the solutions list as an array of integers
    final List<int> solutionsList = [];
    final solutionsJson = json['solutions'];
    if (solutionsJson is List) {
      solutionsList.addAll(
          solutionsJson.where((solution) => solution is int).cast<int>());
    }

    return Report(
      id: json['id'] as int,
      userName: json['name'],
      mobile: json['phone'],
      acc: json['account'],
      sector: json['sector'],
      place: json['place'],
      createdAt: json['created_at'],
      lastComment:
          json['last_comment'] != null ? json['last_comment']['comment'] : '',
      comments: commentsList,
      problems: problemsList,
      solutions: solutionsList,
    );
  }
}
