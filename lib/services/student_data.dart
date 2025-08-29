// Removed few important lines in code for not giving complete implementation

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

/// Model representing a student.
class Student {
  final String image;
  final String roll;
  final String date;
  final String time;
  final String technologyName;

  Student({
    required this.image,
    required this.roll,
    required this.date,
    required this.time,
    required this.technologyName,
  });

  /// Creates a Student from general user JSON.
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      // image: _studentImageUrl(json['rollNumber']),
      roll: json['rollNumber'] ?? 'Unknown',
      technologyName: json['technologyName'] ?? '',
      date: DateFormat('dd MMM yyyy').format(DateTime.now()),
      time: '--:--', image: '',
    );
  }
  
  static Future<void> fromAttendanceJson(json) async {}

  /// Creates a Student from attendance JSON.
  // factory Student.fromAttendanceJson(Map<String, dynamic> json) {
  //   final dateTime = DateTime.fromMillisecondsSinceEpoch(json['dateAsInt'] ?? 0);
  //   // return Student(
  //   //   // image: _studentImageUrl(json['roll']),
  //   //   roll: json['roll'] ?? 'Unknown',
  //   //   technologyName: json['technology'] ?? '',
  //   //   date: DateFormat('dd MMM yyyy').format(dateTime),
  //   //   time: DateFormat('HH:mm').format(dateTime),
  //   // );
  // }

  /// Helper to generate student image URL.
//   static String _studentImageUrl(String? roll) =>
//       "https://info.aec.edu.in/adityacentral/StudentPhotos/${roll ?? 'Unknown'}.jpg";
}

/// Handles mapping between UI technology names and API technology names.
// class TechnologyMapper {
//   static const Map<String, String> _apiMap = {
//     'Flutter': 'FSD With Flutter',
//     'React Native': 'FSD With React Native',
//     'Service Now': 'SERVICE NOW',
//     'AWS': 'AWS Development with DevOps',
//     'VLSI': 'VLSI',
//     'Data specialist': 'Data Specialist',
//   };

//   static String? mapToApi(String uiTech) => _apiMap[uiTech];
// }

/// Service for fetching and managing student data.
class StudentDataService {
  static const String _userApiUrl = 'https://example.com/api/user/all';
  static const String _attendanceApiUrl = 'https://example.com/api/attendance/today';

  static final List<Student> _presentList = [];

  /// Returns the current list of present students.
  static List<Student> get presentList => List.unmodifiable(_presentList);

  /// Fetches today's present students, optionally filtered by technology.
  static Future<void> fetchTodayPresentStudents({String technology = 'All Tech'}) async {
    try {
      final response = await http.get(Uri.parse(_attendanceApiUrl));
      if (response.statusCode != 200) throw Exception('Failed to load today\'s attendance');

      final List<dynamic> jsonData = json.decode(response.body);
      final allPresent = jsonData.map((json) => Student.fromAttendanceJson(json)).toList();

      final techApiName = TechnologyMapper.mapToApi(technology);
      final filteredPresent = techApiName == null
          ? allPresent
          : allPresent.where((s) => s.technologyName.toUpperCase() == techApiName.toUpperCase()).toList();

      _presentList
        ..clear()
        ..addAll(filteredPresent as Iterable<Student>);

      debugPrint('Filtered present students: ${_presentList.length}');
    } catch (e) {
      debugPrint('Error fetching today\'s present students: $e');
    }
  }

  /// Fetches students who have not marked attendance, optionally filtered by technology.
  // static Future<List<Student>> fetchUnmarkedStudents({String technology = 'All Tech'}) async {
  //   try {
  //     final response = await http.get(Uri.parse(_userApiUrl));
  //     if (response.statusCode != 200) throw Exception('Failed to load students');

  //     final List<dynamic> jsonData = json.decode(response.body);
  //     final allStudents = jsonData.map((json) => Student.fromJson(json)).toList();

  //     final techApiName = TechnologyMapper.mapToApi(technology);
  //     final filteredStudents = techApiName == null
  //         ? allStudents
  //         : allStudents.where((s) => s.technologyName.toUpperCase() == techApiName.toUpperCase()).toList();

  //     final unmarked = filteredStudents
  //         .where((student) => !_presentList.any((p) => p.roll == student.roll))
  //         .toList();

  //     return unmarked;
  //   } catch (e) {
  //     debugPrint('Error fetching students: $e');
  //     return [];
  //   }
  // }

  static getPresentList() {}

  static fetchUnmarkedStudents() {}
}

extension on Future<void> {
  get technologyName => null;
}

class TechnologyMapper {
  static mapToApi(String technology) {}
}
