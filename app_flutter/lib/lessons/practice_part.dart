import 'listening_data.dart';
import 'test_data.dart';

/// One part of the daily practice session (screen 31): a lesson page (22
/// listening, 10 test) runs with injected content inside the session's one
/// progress (`offset` + its own steps of `total`), skips its own end card and
/// results, and writes its outcome here.
class PracticePart {
  PracticePart({
    required this.offset,
    required this.total,
    required this.title,
    this.listen,
    this.test,
  });

  final int offset;
  final int total;

  /// Header title of the part.
  final String title;
  final ListenContent? listen;
  final TestContent? test;

  int right = 0;
  int count = 0;
  int points = 0;
}
