import 'package:cloud_firestore/cloud_firestore.dart' hide Settings;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/monthly.dart';
import 'package:frontend/settings.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class Mainpage1 extends StatefulWidget {
  const Mainpage1({super.key});

  @override
  Mainpage1State createState() => Mainpage1State();
}

class Mainpage1State extends State<Mainpage1> {
  int _indexSelection = 1; // 1 = current page
  double salary = 0.0;
  double totalExpenses = 0.0;
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
    final firestore = FirebaseFirestore.instance;
    final now = DateTime.now();

    // 1. Get user salary
    final userDoc =
        await firestore
            .collection('user_answers')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .get();
    salary = double.tryParse(userDoc['question2'].toString()) ?? 0;

    // 2. Get current month & year
    final currentMonth = now.month;
    final currentYear = now.year;

    // 3. Get predicted transactions
    final transactions =
        await firestore.collection('predicted_transactions').get();

    // 4. Sum monthly expenses
    // ignore: avoid_types_as_parameter_names
    totalExpenses = transactions.docs.fold(0.0, (sum, doc) {
      final data = doc.data();
      final dateStr = data['Predicted_Date'] ?? '';
      final amount = (data['Predicted_Amount'] ?? 0).toDouble();
      final txnDate = DateTime.tryParse(dateStr);

      if (txnDate != null &&
          txnDate.month == currentMonth &&
          txnDate.year == currentYear) {
        return sum + amount;
      }
      return sum;
    });

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Avoid dividing by zero
    final percent = salary > 0 ? (totalExpenses / salary).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFF363D7D),
      body: Stack(
        children: [
          // We use a SingleChildScrollView to allow vertical scrolling if needed
          SingleChildScrollView(
            child: Column(
              children: [
                // Top Greeting & Circular Chart
                const SizedBox(height: 60),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    StreamBuilder<DocumentSnapshot>(
                      stream:
                          FirebaseFirestore.instance
                              .collection('user_answers')
                              .doc(FirebaseAuth.instance.currentUser?.uid)
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: SizedBox(),
                          );
                        }
                        String userName = '';
                        if (snapshot.hasData && snapshot.data!.exists) {
                          userName =
                              (snapshot.data!.data() as Map)['question1'] ?? '';
                        }
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'مرحبا $userName!',
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                  ],
                ),

                // Circular Percent Indicator
                CircularPercentIndicator(
                  radius: 100.0,
                  lineWidth: 10.0,
                  percent: percent,
                  header: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "ميزانيتك الحالية",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  center: Text(
                    // e.g. "500 / 2000"
                    "${totalExpenses.toStringAsFixed(0)} / ${salary.toStringAsFixed(0)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  backgroundColor: Colors.grey[300]!,
                  progressColor:
                      percent > 0.8
                          ? Colors.red
                          : percent > 0.5
                          ? Colors.yellow
                          : Colors.blue,
                ),

                const SizedBox(height: 20),

                // EXPENSE DETAILS SECTION
                // In your screenshot, there's a separate container with "تفاصيل المصروفات" etc.
                Container(
                  width: double.infinity,
                  // Give some height or let it expand automatically
                  padding: const EdgeInsets.all(16.0),
                  margin: const EdgeInsets.only(top: 16.0),
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Title
                      const Text(
                        "تفاصيل المصروفات",
                        textDirection:
                            TextDirection.rtl, // For proper Arabic alignment
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Example of a horizontal bar or a summary row:
                      // (If you want an overall progress bar for the month)
                      Row(
                        children: [
                          Expanded(
                            child: Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()..scale(-1.0, 1.0),
                              child: LinearProgressIndicator(
                                value: percent,
                                backgroundColor: Colors.grey[300],
                                color:
                                    percent > 0.8
                                        ? Colors.red
                                        : percent > 0.5
                                        ? Colors.yellow
                                        : Colors.blue,
                                minHeight: 8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "${(percent * 100).toStringAsFixed(0)}%",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      // Show a list of transactions from Firestore
                      // We can do a FutureBuilder or StreamBuilder on the predicted_transactions
                      StreamBuilder<QuerySnapshot>(
                        stream:
                            FirebaseFirestore.instance
                                .collection('predicted_transactions')
                                .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final docs = snapshot.data!.docs;

                          // Filter by current month if desired
                          final now = DateTime.now();
                          final currentMonth = now.month;
                          final currentYear = now.year;

                          final filteredDocs =
                              docs.where((doc) {
                                final data = doc.data() as Map<String, dynamic>;
                                final dateStr = data['Predicted_Date'] ?? '';
                                final txnDate = DateTime.tryParse(dateStr);
                                if (txnDate == null) return false;
                                return txnDate.month == currentMonth &&
                                    txnDate.year == currentYear;
                              }).toList();

                          // sort transactions by latest date on top
                          filteredDocs.sort((a, b) {
                            final dateA = DateTime.tryParse(
                              (a.data()
                                      as Map<
                                        String,
                                        dynamic
                                      >)['Predicted_Date'] ??
                                  '',
                            );
                            final dateB = DateTime.tryParse(
                              (b.data()
                                      as Map<
                                        String,
                                        dynamic
                                      >)['Predicted_Date'] ??
                                  '',
                            );
                            return dateB!.compareTo(dateA!);
                          });

                          if (filteredDocs.isEmpty) {
                            return const Text(
                              "لا توجد مصروفات متوقعة لهذا الشهر",
                              textDirection: TextDirection.rtl,
                            );
                          }

                          return ListView.builder(
                            // Put ListView in a constrained box or shrinkWrap it
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredDocs.length,
                            itemBuilder: (context, index) {
                              final data =
                                  filteredDocs[index].data()
                                      as Map<String, dynamic>;
                              final shopName =
                                  data['Predicted_Shop_Name'] ?? '—';
                              final amount =
                                  data['Predicted_Amount']?.toDouble() ?? 0.0;
                              final dateStr = data['Predicted_Date'] ?? '';

                              return Card(
                                elevation: 2,
                                color: Color(0xFF363D7D),
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  title: Text(
                                    shopName,
                                    textDirection: TextDirection.rtl,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  subtitle: Text(
                                    dateStr,
                                    textDirection: TextDirection.rtl,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                  leading: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "${amount.toStringAsFixed(2)}",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Image.asset(
                                        'assets/images/rial.png',
                                        width: 20,
                                        height: 20,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return Icon(
                                            Icons.error,
                                            color: Colors.red,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Add some bottom padding so it doesn’t get covered by the nav bar
                const SizedBox(height: 120),
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

          if (isLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.white70),
            ),
        ],
      ),
    );
  }
}
