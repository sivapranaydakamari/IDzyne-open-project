// Removed few important lines in code for not giving complete implementation

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:idzyne/AttendanceOverviewScreen.dart';
import 'package:idzyne/statistics.dart';
import 'package:idzyne/studentID.dart';
import 'package:idzyne/widgets/bug_report_dialog.dart';
import 'dart:convert';
import 'services/student_data.dart';
import 'login_signup_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:idzyne/widgets/custom_bottom_navbar.dart';



class HomeScreen extends StatefulWidget {
  final String userName;
  final String userId;
  const HomeScreen({super.key, required this.userName, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late FocusNode _focusNode;
  final TextEditingController _rollController = TextEditingController();

  String activeButton = 'BarcodeScanner';
  bool isLoading = false;
  Map<String, dynamic>? studentData;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    _focusNode = FocusNode();

    // _rollController.addListener(() {
    //   setState(() {});
    // });

    // _focusNode.addListener(() {
    //   if (_focusNode.hasFocus) {
    //     setState(() {});
    //   }
    // });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _rollController.dispose();
    super.dispose();
  }

  Future<void> fetchStudentDetails(String rollNumber) async {
    setState(() {
      isLoading = true;
      studentData = null;
    });

    final url = Uri.parse(
      'https://example.com/api/user/roll/$rollNumber',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        studentData = data;
        isLoading = false;
      });
      showStudentCard(studentData!);
    } else {
      setState(() {
        studentData = null;
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Student not found')));
    }
  }

  Future<void> _refreshAllData() async {
    await StudentDataService.fetchTodayPresentStudents();
    await StudentDataService.fetchUnmarkedStudents();

    setState(() {});
  }

  void startScan() async {
    final barcode = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ScannerScreen()));

    if (barcode != null && barcode is String) {
      fetchStudentDetails(barcode);
    }
  }

  void showStudentCard(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    final result = await showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      barrierDismissible: true,
      barrierLabel: "Student ID",
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: IDCardPage(
            // id: data['_id'],
            // name: data['name'],
            // rollNo: data['rollNumber'],
            // imageUrl:
            //     "https://info.aec.edu.in/adityacentral/StudentPhotos/${data['rollNumber']}.jpg",
            // tech: data['technologyName'],
            // addedBy: widget.userId,
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
        );

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));

        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(scale: scaleAnimation, child: child),
        );
      },
    );

    if (result == true) {
      _refreshAllData();
    }
  }

  String formatName(String fullName) {
    String last = fullName.trim().split(' ').last;
    return "${last[0].toUpperCase()}${last.substring(1).toLowerCase()}";
  }

  void _onTabSelected(String selected) {
    FocusScope.of(context).unfocus();

    if (selected == 'dashboard') {
      setState(() {
        _currentIndex = 1;
        activeButton = 'dashboard';
      });
    } else if (selected == 'profile') {
      setState(() {
        _currentIndex = 2;
        activeButton = 'profile';
      });
    } else if (selected == 'BarcodeScanner') {
      Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: Duration(milliseconds: 400),
          pageBuilder:
              (context, animation, secondaryAnimation) => const ScannerScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, -1.0);
            const end = Offset.zero;
            const curve = Curves.easeOut;

            final tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      ).then((barcode) {
        if (barcode != null && barcode is String) {
          fetchStudentDetails(barcode);
        }
      });
    }
  }

  // Object _buildCurrentPage() {
  //   switch (_currentIndex) {
  //     case 0:
  //       return _buildScannerPage();
  //     case 1:
  //       return _buildDashboardPage();
  //     case 2:
  //       return dummy();
  //     default:
  //       return _buildScannerPage();
  //   }
  // }

  Widget _buildScannerPage() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Row(
        children: [
          // Removed few important lines in code for not giving complete implementation
          SizedBox(height: 50),
          Text(
            'Hi ${formatName(widget.userName)},',
            style: GoogleFonts.poppins(
              fontSize: screenWidth * 0.09,
              fontWeight: FontWeight.w700,
              color: const Color(0xff747675),
            ),
          ),
          SizedBox(height: 1),
          Text(
            'Scan a student ID to',
            style: GoogleFonts.poppins(
              fontSize: screenWidth * 0.07,
              fontWeight: FontWeight.w700,
              shadows: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 600,
                  offset: Offset(0, 6),
                ),
              ],
            ),
          ),
          SizedBox(height: 1),
          Text(
            'mark attendance!',
            style: GoogleFonts.poppins(
              fontSize: screenWidth * 0.07,
              fontWeight: FontWeight.w700,
              shadows: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 600,
                  offset: Offset(0, 6),
                ),
              ],
            ),
          ),
          SizedBox(height: screenHeight * 0.04),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  transitionDuration: Duration(milliseconds: 400),
                  pageBuilder:
                      (context, animation, secondaryAnimation) =>
                          const ScannerScreen(),
                  transitionsBuilder: (
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ) {
                    const begin = Offset(0.0, -1.0);
                    const end = Offset.zero;
                    const curve = Curves.easeOut;
                    
                    final tween = Tween(
                      begin: begin,
                      end: end,
                    ).chain(CurveTween(curve: curve));
                    
                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
                ),
              ).then((barcode) {
                if (barcode != null && barcode is String) {
                  fetchStudentDetails(barcode);
                }
              });
            },
            child: Container(
              width: double.infinity,
              height: screenHeight * 0.30,
              padding: EdgeInsets.all(screenWidth * 0.06),
              decoration: BoxDecoration(
                color: Colors.white54,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 70,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.document_scanner_outlined,
                    size: 48,
                    color: Colors.black54,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Start Scanning',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      shadows: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 600,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            "Student without an ID? Simply enter their roll number manually.",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xff747675),
              shadows: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 600,
                  offset: Offset(0, 6),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  focusNode: _focusNode,
                  autofocus: false,
                  controller: _rollController,
                  cursorRadius: Radius.circular(90),
                  cursorHeight: 18,
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.transparent,
                    hintText: "Enter roll number ...",
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.black54,
                      fontSize: 12,
                      shadows: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 60,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    suffixIcon:
                        _rollController.text.isNotEmpty
                            ? IconButton(
                              iconSize: 18,
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                _rollController.clear();
                              },
                            )
                            : null,
                  ),
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                  readOnly: false,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  color: Colors.black,
                ),
                height: 48.4,
                width: 100,
                child: TextButton(
                  onPressed: () async {
                    final roll =
                        _rollController.text.trim().toUpperCase();
                    if (roll.isEmpty) return;
                    
                    FocusScope.of(context).unfocus();
                    
                    await fetchStudentDetails(roll);
                  },
                  child: Text(
                    "Send",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (isLoading) Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  // Widget _buildDashboardPage() {
  //   return DepartmentStatsPage(username: widget.userName);
  // }

  // void _performLogout() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.clear();

  //   Navigator.pushReplacement(
  //     context,
  //     MaterialPageRoute(builder: (context) => const LoginScreen()),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xfff1f2f2),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            final mediaQuery = MediaQuery.of(context);
            final screenWidth2 = mediaQuery.size.width;
            final screenHeight = mediaQuery.size.height;
            
            showDialog(
              context: context,
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  backgroundColor: Colors.white,
                  clipBehavior: Clip.hardEdge,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  elevation: 2,
                  title: Text(
                    'LOGOUT CONFIRMATION',
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      fontSize: screenWidth2 * 0.055,
                    ),
                  ),
                  content: Text(
                    'Are you sure you want to logout?',
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: screenWidth2 * 0.04,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: Container(
                        width: screenWidth2 * 0.25,
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth2 * 0.02,
                          vertical: screenHeight * 0.015,
                        ),
                        color: Colors.black,
                        alignment: Alignment.center,
                        child: Text(
                          'CANCEL',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth2 * 0.035,
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        _performLogout();
                      },
                      child: Container(
                        width: screenWidth2 * 0.25,
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth2 * 0.02,
                          vertical: screenHeight * 0.015,
                        ),
                        color: Colors.black,
                        alignment: Alignment.center,
                        child: Text(
                          'LOGOUT',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth2 * 0.035,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
          icon: Icon(Icons.logout_rounded, size: screenWidth * 0.07),
          color: Colors.black87,
        ),
        actions: [
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder:
                  (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
              child: Icon(
                Icons.help_outline,
                key: ValueKey('help'),
                color: Colors.black87,
                size: screenWidth * 0.07,
              ),
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Color(0xfff1f2f2),
                shape: LinearBorder(side: BorderSide(color: Colors.black)),
                isScrollControlled: true,
                builder:
                    (context) => Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.support_agent,
                            size: 40,
                            color: Colors.black,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Help & Support',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 15),
                          ListTile(
                            leading: Icon(Icons.bug_report_outlined),
                            title: Text("Report a bug"),
                            onTap: () {
                              Navigator.pop(context);
                              showBugReportPopup(context);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.question_answer_outlined),
                            title: const Text("FAQs"),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.feedback_outlined),
                            title: const Text("Send Feedback"),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                          SizedBox(height: 20),
                          Text('Made with love🤍 by Team Quantum!'),
                        ],
                      ),
                    ),
              );
            },
          ),
        ],
      ),
      // body: _buildCurrentPage(),

      bottomNavigationBar: CustomBottomNavBar(
        activeButton: activeButton,
        onTabSelected: (selected) {
          FocusScope.of(context).unfocus();

          if (selected == 'profile') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => dummy(),
              ),
            ).then((_) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _focusNode.unfocus();
                FocusScope.of(context).unfocus();
              });
              setState(() {});
            });
          } else if (selected == 'dashboard') {
            Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: Duration(milliseconds: 400),
                pageBuilder:
                    (context, animation, secondaryAnimation) =>
                        DepartmentStatsPage(username: widget.userName),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  const begin = Offset(-1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeOut;

                  final tween = Tween(
                    begin: begin,
                    end: end,
                  ).chain(CurveTween(curve: curve));
                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
              ),
            ).then((_) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _focusNode.unfocus();
                FocusScope.of(context).unfocus();
              });
              setState(() {});
            });
          } else if (selected == 'BarcodeScanner') {
            Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: Duration(milliseconds: 400),
                pageBuilder:
                    (context, animation, secondaryAnimation) =>
                        const ScannerScreen(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  const begin = Offset(0.0, -1.0);
                  const end = Offset.zero;
                  const curve = Curves.easeOut;

                  final tween = Tween(
                    begin: begin,
                    end: end,
                  ).chain(CurveTween(curve: curve));

                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
              ),
            ).then((barcode) {
              if (barcode != null && barcode is String) {
                fetchStudentDetails(barcode);
              }
            });
          }
        },
        showScannerIcon: true,
      ),
    );
  }

  Widget dummy() {
    return Center(
      child: Text("Profile Page"),
    );
  }
}

class _buildDashboardPage {
}

class _performLogout {
}

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool _hasScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Scan Student ID",
          style: GoogleFonts.poppins(color: Colors.white),
        ),
      ),
      body: AiBarcodeScanner(
        borderRadius: 0,
        borderWidth: 2,
        fit: BoxFit.contain,
        bottomBarText: 'Scan ID card',
        bottomBarTextStyle: GoogleFonts.poppins(),
        onDetect: (capture) {
          if (_hasScanned) return;
          _hasScanned = true;

          final barcode = capture.barcodes.first.rawValue;
          if (barcode != null) {
            Navigator.of(context).pop(barcode);
          }
        },
        onScan: (_) {},
      ),
    );
  }
}
