import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// Set by the lesson flow when the last lesson of a course is finished (the
/// lesson, unit and course screens then close back to the courses screen,
/// which plays the completion sequence). Index into [courses].
final courseCompleted = ValueNotifier<int?>(null);

/// Course card style (owner, 2026-11-21): illustrated card with the `emblem`
/// art as a translucent background (default). Review aid: `?cards=gold|green|
/// abstract|emblem`, `?cards=classic` = the reference-03 card.
String? cardArtSet = 'emblem';

/// The 12 courses, from the Angular app (`src/assets/data/courses.json`).
/// Progress always starts at 0 (owner, 2026-11-20).
class Course {
  const Course({
    required this.title,
    required this.description,
    this.icon,
    this.locked = true,
    this.progress = 0,
  });

  final String title;
  final String description;

  /// Course icon from the shared library (`assets/ui/courses/`, ASSETS.md).
  final String? icon;
  final bool locked;
  final double progress;
}

const courses = <Course>[
  Course(
    icon: 'assets/ui/courses/course_01.webp',
    title: 'أساسيات التجويد',
    description: 'المبادئ الأساسية للتجويد وقواعد التلاوة الصحيحة للمبتدئين',
    locked: false,
  ),
  Course(
    icon: 'assets/ui/courses/course_02.svg',
    title: 'النون والميم المشددتان',
    description:
        'دراسة متعمقة لأحكام النون والميم المشددتين في التلاوة القرآنية',
  ),
  Course(
    icon: 'assets/ui/courses/course_03.svg',
    title: 'مخارج الحروف',
    description: 'دورة متخصصة في مخارج الحروف العربية وصفاتها',
  ),
  Course(
    icon: 'assets/ui/courses/course_04.svg',
    title: 'النون الساكنة والتنوين',
    description: 'دراسة شاملة لأحكام النون الساكنة والتنوين',
  ),
  Course(
    icon: 'assets/ui/courses/course_05.svg',
    title: 'الميم الساكنة',
    description: 'تعمق في أحكام الميم الساكنة وتطبيقاتها',
  ),
  Course(
    icon: 'assets/ui/courses/course_06.svg',
    title: 'المد الطبيعي',
    description: 'أساسيات المد الطبيعي وقواعده الأساسية',
  ),
  Course(
    icon: 'assets/ui/courses/course_07.svg',
    title: 'المد الفرعي',
    description: 'دراسة أنواع المد الفرعي وتطبيقاته',
  ),
  Course(
    icon: 'assets/ui/courses/course_08.svg',
    title: 'مد البدل',
    description: 'فهم وتطبيق أحكام مد البدل في التلاوة',
  ),
  Course(
    icon: 'assets/ui/courses/course_09.svg',
    title: 'المد العارض للسكون',
    description: 'دراسة المد العارض للسكون وأحكامه',
  ),
  Course(
    icon: 'assets/ui/courses/course_10.svg',
    title: 'المد اللازم',
    description: 'تعمق في دراسة أنواع المد اللازم',
  ),
  Course(
    icon: 'assets/ui/courses/course_11.svg',
    title: 'القلقلة',
    description: 'دراسة أحكام القلقلة وتطبيقاتها في التلاوة',
  ),
  Course(
    icon: 'assets/ui/courses/course_12.svg',
    title: 'تجويد متقدم',
    description: 'موضوعات متقدمة في علم التجويد والتلاوة المتميزة',
  ),
];

/// Progress of the courses path (saved on the device, `ProgressStore`): the
/// course in progress ([current]; the ones before it are completed, the ones
/// after it locked) and the bar of each course as last shown.
class CoursesProgress {
  CoursesProgress()
    : current = math.max(0, courses.indexWhere((c) => c.locked) - 1),
      bars = [for (final c in courses) c.progress];

  int current;
  final List<double> bars;
}

CoursesProgress coursesProgress = CoursesProgress();

/// Settings «إعادة ضبط التقدم»: back to the first course at 0.
void resetCoursesProgress() => coursesProgress = CoursesProgress();
