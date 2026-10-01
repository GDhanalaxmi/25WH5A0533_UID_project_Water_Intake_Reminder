import 'package:flutter/material.dart';

void main() {
  runApp(const WaterReminderApp());
}

class WaterReminderApp extends StatefulWidget {
  const WaterReminderApp({super.key});

  @override
  State<WaterReminderApp> createState() => _WaterReminderAppState();
}

class _WaterReminderAppState extends State<WaterReminderApp> {
  bool darkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Water Intake Reminder',
      theme: ThemeData(
        brightness: darkMode ? Brightness.dark : Brightness.light,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor:
            darkMode ? const Color(0xff101820) : const Color(0xfff2f9ff),
        useMaterial3: true,
      ),
      home: HomeScreen(
        darkMode: darkMode,
        onThemeChanged: () {
          setState(() {
            darkMode = !darkMode;
          });
        },
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final bool darkMode;
  final VoidCallback onThemeChanged;

  const HomeScreen({
    super.key,
    required this.darkMode,
    required this.onThemeChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int waterDrunk = 0;
  int dailyGoal = 2000;

  List<int> history = [];

  late AnimationController animationController;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  double get progress {
    double value = waterDrunk / dailyGoal;

    if (value > 1) {
      return 1;
    }

    return value;
  }

  void addWater(int amount) {
    setState(() {
      waterDrunk += amount;
      history.add(amount);
    });

    animationController.forward(from: 0);
  }

  void undoWater() {
    if (history.isEmpty) {
      return;
    }

    setState(() {
      int lastAmount = history.removeLast();
      waterDrunk -= lastAmount;

      if (waterDrunk < 0) {
        waterDrunk = 0;
      }
    });
  }

  void resetWater() {
    setState(() {
      waterDrunk = 0;
      history.clear();
    });
  }

  void showGoalDialog() {
    TextEditingController controller =
        TextEditingController(text: dailyGoal.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set Daily Goal'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Water goal in ml',
              hintText: 'Example: 2000',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                int? newGoal = int.tryParse(controller.text);

                if (newGoal == null || newGoal <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Enter a valid water goal'),
                    ),
                  );
                  return;
                }

                setState(() {
                  dailyGoal = newGoal;
                });

                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void openHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryScreen(
          history: history,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Water Intake Reminder',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: widget.onThemeChanged,
            icon: Icon(
              widget.darkMode ? Icons.light_mode : Icons.dark_mode,
            ),
          ),
          IconButton(
            onPressed: openHistory,
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: width < 600 ? 20 : 80,
          vertical: 20,
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),

            const Icon(
              Icons.water_drop,
              size: 70,
              color: Colors.blue,
            ),

            const SizedBox(height: 10),

            const Text(
              'Stay Hydrated!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              'Track your daily water intake',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 30),

            AnimatedBuilder(
              animation: animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1 + animationController.value * 0.04,
                  child: child,
                );
              },
              child: ProgressCard(
                waterDrunk: waterDrunk,
                dailyGoal: dailyGoal,
                progress: progress,
              ),
            ),

            const SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                QuickButton(
                  amount: 100,
                  onTap: () {
                    addWater(100);
                  },
                ),
                QuickButton(
                  amount: 250,
                  onTap: () {
                    addWater(250);
                  },
                ),
                QuickButton(
                  amount: 500,
                  onTap: () {
                    addWater(500);
                  },
                ),
              ],
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: showGoalDialog,
                icon: const Icon(Icons.flag),
                label: const Text(
                  'Set Daily Goal',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton.icon(
                onPressed: undoWater,
                icon: const Icon(Icons.undo),
                label: const Text(
                  'Undo Last Intake',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton.icon(
                onPressed: resetWater,
                icon: const Icon(Icons.refresh),
                label: const Text(
                  'Reset Today',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 30),

            InfoCard(
              title: 'Today',
              value: '$waterDrunk ml',
              icon: Icons.water_drop,
            ),

            const SizedBox(height: 12),

            InfoCard(
              title: 'Daily Goal',
              value: '$dailyGoal ml',
              icon: Icons.flag,
            ),

            const SizedBox(height: 12),

            InfoCard(
              title: 'Remaining',
              value:
                  '${waterDrunk >= dailyGoal ? 0 : dailyGoal - waterDrunk} ml',
              icon: Icons.local_drink,
            ),

            const SizedBox(height: 30),

            if (waterDrunk >= dailyGoal)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.green.withOpacity(0.15),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 45,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Daily Goal Completed!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Great job staying hydrated today.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class ProgressCard extends StatelessWidget {
  final int waterDrunk;
  final int dailyGoal;
  final double progress;

  const ProgressCard({
    super.key,
    required this.waterDrunk,
    required this.dailyGoal,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    int percentage = ((waterDrunk / dailyGoal) * 100).round();

    if (percentage > 100) {
      percentage = 100;
    }

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const Text(
              'Daily Progress',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 180,
                  height: 180,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 15,
                    backgroundColor: Colors.grey.shade300,
                  ),
                ),
                Column(
                  children: [
                    const Icon(
                      Icons.water_drop,
                      size: 40,
                      color: Colors.blue,
                    ),
                    Text(
                      '$percentage%',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            Text(
              '$waterDrunk ml / $dailyGoal ml',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuickButton extends StatelessWidget {
  final int amount;
  final VoidCallback onTap;

  const QuickButton({
    super.key,
    required this.amount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
      ),
      child: Text(
        '+$amount ml',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const InfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class HistoryScreen extends StatelessWidget {
  final List<int> history;

  const HistoryScreen({
    super.key,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    int total = history.fold(0, (sum, item) => sum + item);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's History"),
      ),
      body: history.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.water_drop_outlined,
                    size: 70,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'No water intake recorded yet.',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Card(
                  margin: const EdgeInsets.all(20),
                  child: ListTile(
                    leading: const Icon(
                      Icons.water_drop,
                      color: Colors.blue,
                    ),
                    title: const Text('Total Intake'),
                    trailing: Text(
                      '$total ml',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text('${index + 1}'),
                        ),
                        title: Text(
                          '${history[index]} ml',
                        ),
                        subtitle: const Text(
                          'Water intake',
                        ),
                        trailing: const Icon(
                          Icons.water_drop,
                          color: Colors.blue,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}