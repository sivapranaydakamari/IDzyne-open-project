// Removed few important lines in code for not giving complete implementation

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

Future<DateTime?> showCustomDatePicker(
  BuildContext context,
  DateTime? initialDate,
) {
  DateTime today = DateTime.now();
  DateTime firstDate = DateTime(2025, 1, 1);
  DateTime selectedDate = initialDate ?? today;
  DateTime focusedDate = initialDate ?? today;

  return showDialog<DateTime>(
    context: context,
    builder: (context) {
      return Dialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Container(
              width: 320,
              padding: const EdgeInsets.all(12),
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Text(
                  //   "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                  //   style: const TextStyle(
                  //     fontSize: 12,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  // const SizedBox(height: 8),
                  TableCalendar(
                    firstDay: firstDate,
                    lastDay: today,
                    focusedDay: focusedDate,
                    currentDay: today,
                    selectedDayPredicate: (day) => isSameDay(selectedDate, day),
                    onDaySelected: (newSelectedDay, newFocusedDay) {
                      setState(() {
                        selectedDate = newSelectedDay;
                        focusedDate = newFocusedDay;
                      });
                    },
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: GoogleFonts.poppins(
                        fontSize: 16.0,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      leftChevronIcon: Icon(
                        Icons.chevron_left,
                        color: Colors.black,
                      ),
                      rightChevronIcon: Icon(
                        Icons.chevron_right,
                        color: Colors.black,
                      ),
                    ),
                    calendarStyle: CalendarStyle(
                      selectedTextStyle: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.rectangle,
                      ),
                      todayTextStyle: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                      todayDecoration: BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.rectangle,
                      ),
                      defaultTextStyle: TextStyle(color: Colors.black),
                      weekendTextStyle: TextStyle(color: Colors.black),
                      outsideDaysVisible: false,
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: GoogleFonts.poppins(
                        color: Colors.black,
                        fontWeight: FontWeight.w300,
                        fontSize: 12.0,
                      ),
                      weekendStyle: GoogleFonts.poppins(
                        color: Colors.black,
                        fontWeight: FontWeight.w300,
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "Cancel",
                          style: GoogleFonts.poppins(color: Colors.black),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, selectedDate),
                        child: Text(
                          "OK",
                          style: GoogleFonts.poppins(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}

class DepartmentStatsPage extends StatefulWidget {
  final String username;

  const DepartmentStatsPage({super.key, required this.username});

  @override
  State<DepartmentStatsPage> createState() => _DepartmentStatsPageState();
}

class _DepartmentStatsPageState extends State<DepartmentStatsPage> {
  late FocusNode _focusNode;
  bool isLoggedIn = false;
  String? username;

  final Map<String, int> totalStudentCount = {
    "FSD WITH REACT": 197,
    "FSD WITH FLUTTER": 97,
    "AWS": 132,
    "DATA SPECIALIST": 139,
    "SERVICE NOW": 68,
    "VLSI": 61,
  };

  Map<String, int> presentStudentCount = {
    "FSD WITH REACT": 0,
    "FSD WITH FLUTTER": 0,
    "AWS": 0,
    "DATA SPECIALIST": 0,
    "SERVICE NOW": 0,
    "VLSI": 0,
  };

  String searchQuery = '';
  DateTime? selectedDate;
  final Set<int> flippedCards = {};

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    initializePrefsAndData();
  }

  Future<void> initializePrefsAndData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      username = prefs.getString('username');
    });

    final today = DateTime.now();
    final todayMidnight = DateTime(today.year, today.month, today.day);
    setState(() {
      selectedDate = todayMidnight;
    });

    await fetchAttendanceData(todayMidnight.millisecondsSinceEpoch);
  }

  Future<void> fetchAttendanceData(int dateAsInt) async {
    const url =
        'https://example.com/api/attendance/by-date';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'dateAsInt': dateAsInt}),
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        print("API Response: $data");

        Map<String, int> counts = {
          for (var dept in totalStudentCount.keys) dept: 0,
        };

        for (var student in data) {
          final tech =
              (student['technology'] ?? '').toString().trim().toUpperCase();
          for (var dept in totalStudentCount.keys) {
            if (tech.contains(dept.toUpperCase())) {
              counts[dept] = counts[dept]! + 1;
              break;
            }
          }
        }

        setState(() {
          presentStudentCount = counts;
        });
      } else {
        debugPrint('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
    }
  }

  Future<void> _refreshAllData() async {
    if (selectedDate != null) {
      await fetchAttendanceData(selectedDate!.millisecondsSinceEpoch);
    } else {
      final today = DateTime.now();
      final todayMidnight = DateTime(today.year, today.month, today.day);
      setState(() {
        selectedDate = todayMidnight;
      });
      await fetchAttendanceData(todayMidnight.millisecondsSinceEpoch);
    }
  }

  @override
  Widget build(BuildContext context) {
    final departments =
        totalStudentCount.keys
            .where(
              (dept) => dept.toLowerCase().contains(searchQuery.toLowerCase()),
            )
            .toList();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xfff1f2f2),
      body: RefreshIndicator(
        onRefresh: _refreshAllData,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SafeArea(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(
                      horizontal:
                          MediaQuery.of(context).size.width *
                          0.04,
                      vertical:
                          MediaQuery.of(context).size.height *
                          0.015,
                    ),
                    color: Colors.transparent,
                    child: Row(
                      children: [
                        IconButton.outlined(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.arrow_back_ios_new,
                            size:
                                MediaQuery.of(context).size.width *
                                0.045,
                          ),
                          style: ButtonStyle(
                            minimumSize: WidgetStateProperty.all(
                              const Size.square(36),
                            ),
                            shape: WidgetStateProperty.all(
                              const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                          ),
                        ),
        
                        const Spacer(),
        
                        Text(
                          "Statistics",
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize:
                                MediaQuery.of(context).size.width *
                                0.055, // Responsive font
                            fontWeight: FontWeight.bold,
                          ),
                        ),
        
                        // Spacer after title
                        const Spacer(),
        
                        // Empty box to balance the back button (optional if no right-side action)
                        SizedBox(width: 36),
                      ],
                    ),
                  ),
                ),
        
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search Technologys...',
                            hintStyle: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              size: 18,
                              color: Colors.black,
                            ),
                            border: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.black,
                                width: 0.5,
                              ),
                              borderRadius: BorderRadius.zero,
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.black,
                                width: 0.5,
                              ),
                              borderRadius: BorderRadius.zero,
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.black,
                                width: 0.5,
                              ),
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                          cursorColor: Colors.black,
                          cursorHeight: 18,
                          style: GoogleFonts.poppins(color: Colors.black),
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
        
                    SizedBox(
                      height: 50,
                      width: 100,
                      child: InkWell(
                        onTap: () async {
                          final picked = await showCustomDatePicker(
                            context,
                            selectedDate,
                          );
                          if (picked != null) {
                            final pickedMidnight = DateTime(
                              picked.year,
                              picked.month,
                              picked.day,
                            );
                            setState(() => selectedDate = pickedMidnight);
                            await fetchAttendanceData(
                              pickedMidnight.millisecondsSinceEpoch,
                            );
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            border: Border.all(color: Colors.black, width: 1),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: Colors.white,
                                size: 18,
                              ),
                              SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  selectedDate == null
                                      ? "Date"
                                      : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 26),
                Text(
                  "Technology Summary",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 130,
                  child: ListView.builder(
                    clipBehavior: Clip.none,
                    scrollDirection: Axis.horizontal,
                    itemCount: departments.length,
                    itemBuilder: (context, index) {
                      String dept = departments[index];
                      bool isFlipped = flippedCards.contains(index);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            isFlipped
                                ? flippedCards.remove(index)
                                : flippedCards.add(index);
                          });
                        },
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 600),
                          transitionBuilder: (child, animation) {
                            final rotate = Tween(
                              begin: pi,
                              end: 0.0,
                            ).animate(animation);
                            return AnimatedBuilder(
                              animation: rotate,
                              child: child,
                              builder: (context, child) {
                                final angle = isFlipped ? pi : 0.0;
                                return Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.rotationY(
                                    angle + rotate.value,
                                  ),
                                  child: child,
                                );
                              },
                            );
                          },
                          child: Container(
                            key: ValueKey(isFlipped),
                            width: 180,
                            height: 100,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            child:
                                isFlipped
                                    ? Card(
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        side: const BorderSide(
                                          color: Colors.black,
                                        ),
                                      ),
                                      child: Center(
                                        child: Transform(
                                          alignment: Alignment.center,
                                          transform: Matrix4.rotationY(pi),
                                          child: Center(
                                            child: Text(
                                              "Technical Hub",
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                    : Card(
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        side: const BorderSide(
                                          color: Colors.black,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              dept,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              "Total: ${totalStudentCount[dept]}",
                                              style: const TextStyle(
                                                color: Colors.black,
                                              ),
                                            ),
                                            Text(
                                              "Present: ${presentStudentCount[dept]}",
                                              style: const TextStyle(
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 26),
                Text(
                  "Present Students Comparison",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 340,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      gridData: FlGridData(
                        show: true,
                        getDrawingHorizontalLine:
                            (_) => FlLine(color: Colors.grey, strokeWidth: 0.5),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: 10,
                            getTitlesWidget:
                                (value, _) => Text(
                                  value.toInt().toString(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= 0 && index < departments.length) {
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  space: 6,
                                  child: Transform.rotate(
                                    angle: -0.4,
                                    child: Text(
                                      departments[index],
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return SizedBox.shrink();
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(departments.length, (index) {
                        final dept = departments[index];
                        final present = presentStudentCount[dept] ?? 0;
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: present.toDouble(),
                              width: 20,
                              color: Colors.black,
                              borderRadius: BorderRadius.zero,
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
                SizedBox(height: 30,)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
