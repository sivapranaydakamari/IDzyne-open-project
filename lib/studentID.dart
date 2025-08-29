// Removed few important lines in code for not giving complete implementation

import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:vibration/vibration.dart';

class IDCardPage extends StatefulWidget {
  // remove late and uncomment the below lines
  late final String userId;
  late final String studentName;
  late final String rollNo;
  late final String imageUrl;
  late final String tech;
  late final String addedBy;

  // const IDCardPage({
  //   super.key,
  //   required this.userId,
  //   required this.studentName,
  //   required this.rollNo,
  //   required this.imageUrl,
  //   required this.tech,
  //   required this.addedBy,
  // });

  @override
  State<IDCardPage> createState() => _IDCardPageState();
}

class _IDCardPageState extends State<IDCardPage> {
  bool _isSubmitting = false;
  // String _getTodayDate() {
  //   final now = DateTime.now();
  //   return '${now.day.toString().padLeft(2, '0')} '
  //       '${_monthName(now.month)} '
  //       '${now.year}';
  // }

  // String _getCurrentTime() {
  //   final now = DateTime.now();
  //   return '${now.hour.toString().padLeft(2, '0')}:'
  //       '${now.minute.toString().padLeft(2, '0')}';
  // }

  // String _monthName(int month) {
  //   const months = [
  //     '',
  //     'Jan',
  //     'Feb',
  //     'Mar',
  //     'Apr',
  //     'May',
  //     'Jun',
  //     'Jul',
  //     'Aug',
  //     'Sep',
  //     'Oct',
  //     'Nov',
  //     'Dec',
  //   ];
  //   return months[month];
  // }

  Future<void> markAttendance() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    final url = Uri.parse(
      'https://example.com/api/attendance/add',
    );

    final bodyData = {'userId': widget.userId, 'addedBy': widget.addedBy};

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(bodyData),
      );

      setState(() {
        _isSubmitting = false;
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (await Vibration.hasVibrator()) {
          Vibration.vibrate(duration: 100);
        }

        // final student = Student(
        //   image: widget.imageUrl,
        //   roll: widget.rollNo,
        //   date: _getTodayDate(),
        //   time: _getCurrentTime(),
        // );

        // StudentDataService.addToPresentList(student);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.studentName} marked as present!'),
            backgroundColor: Colors.green,
            duration: Duration(milliseconds: 500),
          ),
        );
      } else {
        final errorMsg = jsonDecode(response.body)['message'] ?? 'Failed';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
            duration: Duration(milliseconds: 500),
          ),
        );
      }

      //   Future.delayed(Duration(milliseconds: 500), () {
      //     if (mounted) {
      //       final student = Student(
      //         image: widget.imageUrl,
      //         roll: widget.rollNo,
      //         date: _getTodayDate(),
      //         time: _getCurrentTime(),
      //       );
      //       Navigator.of(context).pop(student);
      //     }
      //   });
      // } catch (e) {
      //   setState(() {
      //     _isSubmitting = false;
      //   });

      Future.delayed(Duration(seconds: 1), () {
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      });
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error connecting to server'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.6),
      body: Center(
        child: Row(
          children: [
            Container(
              width: width * 0.75,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/Thub.png',
                    height: 56,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 12),
                        
                  Container(
                    width: 100,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      border: Border.all(color: Colors.black),
                      image: DecorationImage(
                        image: NetworkImage(widget.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                        
                  Text(
                    widget.studentName.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                        
                  // Text(
                  //   widget.rollNo,
                  //   style: GoogleFonts.poppins(
                  //     fontSize: 12,
                  //     fontWeight: FontWeight.w600,
                  //     color: Colors.black87,
                  //   ),
                  // ),
                  // const SizedBox(height: 14),
                        
                  // Text(
                  //   widget.tech,
                  //   style: GoogleFonts.poppins(
                  //     fontSize: 12,
                  //     fontWeight: FontWeight.w600,
                  //     color: Colors.black87,
                  //   ),
                  //   textAlign: TextAlign.center,
                  // ),
                  // const SizedBox(height: 20),
                        
                  _buildBarcode(widget.rollNo),
                ],
              ),
            ),
                        
            const SizedBox(height: 20),
                        
            OutlinedButton(
              onPressed: _isSubmitting ? null : markAttendance,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Colors.black, width: 1.5),
                shape: const RoundedRectangleBorder(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 122.5,
                  vertical: 12,
                ),
              ),
              child: Text(
                "Present",
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
                        
            const SizedBox(height: 16),
                        
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Close",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildBarcode(String code) {
  return BarcodeWidget(
    barcode: Barcode.code128(),
    data: code,
    width: 200,
    height: 60,
    drawText: false,
    backgroundColor: Colors.white,
    color: Colors.black,
  );
}
