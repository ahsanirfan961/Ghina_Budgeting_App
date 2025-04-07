import 'package:cloud_firestore/cloud_firestore.dart' hide Settings;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/main_page.dart';
import 'package:frontend/settings.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class MonthlyExpensesPage extends StatefulWidget {
  const MonthlyExpensesPage({super.key});

  @override
  MonthlyExpensesPageState createState() => MonthlyExpensesPageState();
}

class MonthlyExpensesPageState extends State<MonthlyExpensesPage> {
  // Store the total expenses per month (0 = January, 11 = December)
  List<double> monthlyExpenses = List.filled(12, 0.0);
  double monthlySalary = 0.0;
  int _indexSelection = 0; // 1 = current page

  // New state for year selection
  List<int> availableYears = [];
  int selectedYear = DateTime.now().year;

  // Track which month is selected on the bar chart
  int selectedMonthIndex = DateTime.now().month - 1; // default to current month

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _navigateToPage(int index, Widget page) {
    setState(() {
      _indexSelection = index;
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  Future<void> _loadData() async {
    try {
      final firestore = FirebaseFirestore.instance;

      // 1. Fetch user’s monthly salary
      final userDoc =
          await firestore
              .collection('user_answers')
              .doc(FirebaseAuth.instance.currentUser?.uid)
              .get();

      monthlySalary = double.tryParse(userDoc['question2'].toString()) ?? 0.0;

      // 2. Fetch predicted transactions
      final txnSnapshot =
          await firestore.collection('predicted_transactions').get();

      // Reset the expenses array
      monthlyExpenses = List.filled(12, 0.0);
      // Collect available years
      Set<int> yearsSet = {};

      // 3. Sum up expenses by month for the selected year
      for (final doc in txnSnapshot.docs) {
        final data = doc.data();
        final amount = (data['Predicted_Amount'] ?? 0).toDouble();
        final dateStr = data['Predicted_Date'] ?? '';
        final date = DateTime.tryParse(dateStr);
        if (date != null) {
          yearsSet.add(date.year);
          if (date.year == selectedYear) {
            final monthIndex = date.month - 1; // 0-based index
            monthlyExpenses[monthIndex] += amount;
          }
        }
      }
      availableYears = yearsSet.toList()..sort();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Utility: get Arabic month names or any custom names
  final List<String> monthNames = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];

  @override
  Widget build(BuildContext context) {
    // Identify highest and lowest expense months
    double maxExpense = monthlyExpenses.reduce((a, b) => a > b ? a : b);
    double minExpense = monthlyExpenses.reduce((a, b) => a < b ? a : b);

    int maxIndex = monthlyExpenses.indexOf(maxExpense);
    int minIndex = monthlyExpenses.indexOf(minExpense);

    // The currently selected month’s total expense
    double currentMonthExpense = monthlyExpenses[selectedMonthIndex];

    return Scaffold(
      backgroundColor: Color(0xFF363D7D),
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text(
              'المصروفات الشهرية',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25,
                color: Colors.white,
              ),
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
        backgroundColor: Color(0xFF363D7D),
        elevation: 0,
      ),
      body: Stack(
        children: [
          if (isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.white))
          else
            SingleChildScrollView(
              child: Column(
                children: [
                  // New: Year selection dropdown
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        DropdownButton<int>(
                          value: selectedYear,
                          dropdownColor: Color(0xFF505AA9),
                          style: const TextStyle(color: Colors.white),
                          iconEnabledColor: Colors.white,
                          onChanged: (year) {
                            if (year != null) {
                              setState(() {
                                selectedYear = year;
                                isLoading = true;
                              });
                              _loadData();
                            }
                          },
                          items:
                              availableYears.map((year) {
                                return DropdownMenuItem<int>(
                                  value: year,
                                  child: Text(
                                    year.toString(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                );
                              }).toList(),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'اختر السنة',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    ),
                  ),
                  // Top card with monthly info
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Color(0xFF505AA9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Monthly Salary
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              monthlySalary.toStringAsFixed(0),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                            const SizedBox(width: 8),
                            Image.asset(
                              'assets/images/rial.png',
                              width: 20,
                              height: 20,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.error, color: Colors.red);
                              },
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'المبلغ الإجمالي:',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Selected month’s expenses
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              currentMonthExpense.toStringAsFixed(0),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                            const SizedBox(width: 8),
                            Image.asset(
                              'assets/images/rial.png',
                              width: 20,
                              height: 20,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.error, color: Colors.red);
                              },
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'المبلغ الحالي (${monthNames[selectedMonthIndex]}):',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        // Show the ratio of expense increase or decrease compared to the previous month
                        Builder(
                          builder: (context) {
                            double previousMonthExpense =
                                selectedMonthIndex > 0
                                    ? monthlyExpenses[selectedMonthIndex - 1]
                                    : 0.0;
                            double difference =
                                currentMonthExpense - previousMonthExpense;
                            double ratio =
                                previousMonthExpense > 0
                                    ? (difference / previousMonthExpense) * 100
                                    : 0;

                            return Text(
                              previousMonthExpense > 0
                                  ? '${ratio.abs().toStringAsFixed(1)}% ${difference > 0 ? 'أعلى' : 'أدنى'}'
                                  : 'لا يوجد بيانات للشهر السابق',
                              style: TextStyle(
                                color:
                                    difference > 0
                                        ? Colors.redAccent
                                        : Colors.greenAccent,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              textDirection: TextDirection.rtl,
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // Bar chart container
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Color(0xFF505AA9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SfCartesianChart(
                      primaryXAxis: CategoryAxis(
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      primaryYAxis: NumericAxis(
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Color(0xFF505AA9),
                      plotAreaBackgroundColor: Colors.transparent,
                      // Enable point selection for clickable bars
                      selectionType: SelectionType.point,
                      onSelectionChanged: (details) {
                        setState(() {
                          // When a bar is tapped, update the selectedMonthIndex to the tapped bar's index.
                          print(details.pointIndex);
                          selectedMonthIndex = details.pointIndex;
                        });
                      },

                      series: <CartesianSeries<_MonthExpense, String>>[
                        ColumnSeries<_MonthExpense, String>(
                          dataSource: _getChartData(),
                          xValueMapper: (data, _) => data.monthName,
                          yValueMapper: (data, _) => data.expense,
                          pointColorMapper: (data, _) => data.color,
                          dataLabelSettings: DataLabelSettings(isVisible: true),
                          selectionBehavior: SelectionBehavior(enable: true),
                        ),
                      ],
                    ),
                  ),

                  // Highest & Lowest expense summary
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 80, 90, 176),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  maxExpense.toStringAsFixed(0),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textDirection: TextDirection.rtl,
                                ),
                                const SizedBox(width: 8),
                                Image.asset(
                                  'assets/images/rial.png',
                                  width: 20,
                                  height: 20,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.error, color: Colors.red);
                                  },
                                ),
                              ],
                            ),
                            Text(
                              'الشهر الأعلى إنفاقاً: ${monthNames[maxIndex]}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  minExpense.toStringAsFixed(0),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textDirection: TextDirection.rtl,
                                ),
                                const SizedBox(width: 8),
                                Image.asset(
                                  'assets/images/rial.png',
                                  width: 20,
                                  height: 20,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.error, color: Colors.red);
                                  },
                                ),
                              ],
                            ),
                            Text(
                              'الشهر الأقل إنفاقاً: ${monthNames[minIndex]}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 80), // Extra space
                ],
              ),
            ),
          // Bottom Navigation Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 100,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.show_chart,
                      color:
                          _indexSelection == 0
                              ? Color(0xFF9FB5DA)
                              : Colors.black,
                      size: 40,
                    ),
                    onPressed: () => _navigateToPage(0, MonthlyExpensesPage()),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.home,
                      color:
                          _indexSelection == 1
                              ? Color(0xFF9FB5DA)
                              : Colors.black,
                      size: 40,
                    ),
                    onPressed: () => _navigateToPage(1, Mainpage1()),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.person,
                      color:
                          _indexSelection == 2
                              ? Color(0xFF9FB5DA)
                              : Colors.black,
                      size: 40,
                    ),
                    onPressed: () => _navigateToPage(2, Settings()),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build chart data list
  List<_MonthExpense> _getChartData() {
    // Create data objects for each month
    List<_MonthExpense> chartData = [];
    for (int i = 0; i < 12; i++) {
      chartData.add(
        _MonthExpense(
          monthNames[i],
          monthlyExpenses[i],
          // Optionally color the selected bar differently
          i == selectedMonthIndex ? Colors.orange : Colors.blueAccent,
        ),
      );
    }
    return chartData;
  }
}

/// Simple data model for chart
class _MonthExpense {
  final String monthName;
  final double expense;
  final Color color;

  _MonthExpense(this.monthName, this.expense, this.color);
}
