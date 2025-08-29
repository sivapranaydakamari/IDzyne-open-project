// Removed few important lines in code for not giving complete implementation

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

void showBugReportPopup(BuildContext context) {
  final TextEditingController descriptionController = TextEditingController();
  String selectedCategory = 'Bug report';
  FocusNode dropdownFocusNode = FocusNode();

  List<String> categories = [
    'Bug report',
    'Suggestion',
    'Improvement',
    'Other',
  ];

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        backgroundColor: Color(0xfff1f2f2),
        child: Container(
          width: 350,
          padding: EdgeInsets.all(24),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // removed some important lines of code for not giving the complete implementation
                  Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: Colors.black54, size: 22),
                    splashRadius: 20,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Support Category',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 6),
                  // Removed few important lines in code for not giving complete implementation
                  DropdownButtonFormField<String>(
                    focusNode: dropdownFocusNode,
                    value: selectedCategory,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      // labelText: "Category",
                      labelStyle: GoogleFonts.poppins(color: Colors.black54),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.zero,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    icon: Icon(Icons.arrow_drop_down, color: Colors.black87),
                    dropdownColor: Colors.white,
                    items:
                        categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(
                              category,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                          );
                        }).toList(),
                    onTap: () {
                      FocusScope.of(context).unfocus();

                      Future.delayed(Duration(milliseconds: 1400), () {
                        dropdownFocusNode.requestFocus();
                      });
                    },
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value!;
                      });
                    },
                  ),

                  SizedBox(height: 18),
                  Text(
                    'Description',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 6),
                  TextField(
                    controller: descriptionController,
                    maxLines: 5,
                    decoration: InputDecoration.collapsed(
                      hintText: 'Describe the issue...',
                    ),
                    style: GoogleFonts.poppins(fontSize: 15),
                  ),

                  SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 10,
                        ),
                        child: Text(
                          'Submit',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      );
    },
  );
}

Future<bool> submitBugReport({
  required String category,
  required String description,
}) async {
  try {
    final url = Uri.parse(
        'https://your-backend-api.com/submit-bug-report');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'category': category,
        'description': description,
        'device': '${Platform.operatingSystem} - ${Platform.version}',
      }),
    );

    return response.statusCode == 200;
  } catch (e) {
    print('Bug report failed: $e');
    return false;
  }
}
