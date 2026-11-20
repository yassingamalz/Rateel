import 'package:flutter/foundation.dart';

/// Set by the lesson flow when the last lesson of a course is finished (the
/// lesson, unit and course screens then close back to the courses screen,
/// which plays the completion sequence). Index into [courses].
final courseCompleted = ValueNotifier<int?>(null);

/// The 12 courses, from the Angular app (`src/assets/data/courses.json`).
/// Progress is a demo value until real data is wired.
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

  /// Course icon from the shared library (`assets/ui/courses/`). Null until the
  /// owner delivers it (ChatGPT prompts in docs/flutter/prompts/03-courses/).
  final String? icon;
  final bool locked;
  final double progress;
}

const courses = <Course>[
  Course(
    title: 'أساسيات التجويد',
    description: 'المبادئ الأساسية للتجويد وقواعد التلاوة الصحيحة للمبتدئين',
    icon: 'assets/ui/courses/course_01.webp',
    locked: false,
    progress: 0.3,
  ),
  Course(
    title: 'النون والميم المشددتان',
    description:
        'دراسة متعمقة لأحكام النون والميم المشددتين في التلاوة القرآنية',
  ),
  Course(
    title: 'مخارج الحروف',
    description: 'دورة متخصصة في مخارج الحروف العربية وصفاتها',
  ),
  Course(
    title: 'النون الساكنة والتنوين',
    description: 'دراسة شاملة لأحكام النون الساكنة والتنوين',
  ),
  Course(
    title: 'الميم الساكنة',
    description: 'تعمق في أحكام الميم الساكنة وتطبيقاتها',
  ),
  Course(
    title: 'المد الطبيعي',
    description: 'أساسيات المد الطبيعي وقواعده الأساسية',
  ),
  Course(
    title: 'المد الفرعي',
    description: 'دراسة أنواع المد الفرعي وتطبيقاته',
  ),
  Course(
    title: 'مد البدل',
    description: 'فهم وتطبيق أحكام مد البدل في التلاوة',
  ),
  Course(
    title: 'المد العارض للسكون',
    description: 'دراسة المد العارض للسكون وأحكامه',
  ),
  Course(title: 'المد اللازم', description: 'تعمق في دراسة أنواع المد اللازم'),
  Course(
    title: 'القلقلة',
    description: 'دراسة أحكام القلقلة وتطبيقاتها في التلاوة',
  ),
  Course(
    title: 'تجويد متقدم',
    description: 'موضوعات متقدمة في علم التجويد والتلاوة المتميزة',
  ),
];
