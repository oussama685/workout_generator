import 'package:flutter/material.dart';
import 'api.dart';
import 'login_page.dart';
import 'my_workouts_page.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  String? part;
  String? level;
  String? eq;

  List<String> finalWorkout = [];

  final Map<String, dynamic> workouts = {
    "Arms": {
      "Beginner": {
        "No Equipment": [
          "Push-ups – 3 × 10",
          "Tricep dips – 3 × 12",
          "Arm circles – 30 sec",
          "Close-grip push-ups – 3 × 8",
        ],
        "Dumbbells": [
          "Bicep curls – 3 × 12",
          "Hammer curls – 3 × 10",
          "Tricep extension – 3 × 12",
        ],
      },
      "Intermediate": {
        "No Equipment": [
          "Diamond push-ups – 3 × 10",
          "Decline push-ups – 3 × 12",
          "Bench dips – 3 × 15",
        ],
        "Dumbbells": [
          "Zottman curls – 3 × 10",
          "Concentration curls – 3 × 12",
          "Tricep kickbacks – 3 × 15",
        ]
      }
    },
    "Abs": {
      "Beginner": {
        "No Equipment": [
          "Crunches – 3 × 15",
          "Plank – 30 sec",
          "Leg raises – 3 × 10",
        ],
        "Resistance Band": [
          "Band twists – 3 × 15",
          "Kneeling band crunch – 3 × 12",
        ]
      },
      "Intermediate": {
        "No Equipment": [
          "Toe touches – 3 × 20",
          "Bicycle crunches – 3 × 20",
          "Flutter kicks – 30 sec",
        ]
      }
    },
    "Legs": {
      "Beginner": {
        "No Equipment": [
          "Squats – 3 × 15",
          "Lunges – 3 × 12",
          "Wall sit – 30 sec",
        ],
        "Dumbbells": [
          "Goblet squat – 3 × 12",
          "Dumbbell RDL – 3 × 12",
        ]
      },
      "Intermediate": {
        "No Equipment": [
          "Jump squats – 3 × 12",
          "Bulgarian split squats – 3 × 10",
          "Glute bridges – 3 × 15",
        ]
      }
    }
  };

  void generate() {
    if (part != null && level != null && eq != null) {
      setState(() {
        finalWorkout = List<String>.from(
          workouts[part]?[level]?[eq] ?? ["No workout found for this selection"],
        );
      });
    }
  }

  List<Map<String, dynamic>> parseExercises(List<String> lines) {
    return lines.map((line) {
      final parts = line.split("–");
      final name = parts[0].trim();

      int sets = 1;
      int reps = 0;

      if (parts.length > 1) {
        final right = parts[1].trim(); // "3 × 10" OR "30 sec"
        if (right.contains("×")) {
          final nums = right.split("×").map((e) => e.trim()).toList();
          sets = int.tryParse(nums[0]) ?? 1;
          reps = int.tryParse(nums[1]) ?? 0;
        } else {
          reps = int.tryParse(right.split(" ").first) ?? 0;
        }
      }

      return {"name": name, "sets": sets, "reps": reps};
    }).toList();
  }

  Future<void> saveCurrentWorkout() async {
    if (part == null || level == null || eq == null || finalWorkout.isEmpty) return;

    try {
      await Api.saveWorkout(
        bodyPart: part!,
        difficulty: level!,
        equipment: eq!,
        exercises: parseExercises(finalWorkout),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Workout saved ✅")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> logout() async {
    await Api.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Workout Generator"),
        actions: [
          IconButton(
            tooltip: "My Workouts",
            icon: const Icon(Icons.fitness_center),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyWorkoutsPage()),
              );
            },
          ),
          IconButton(
            tooltip: "Logout",
            icon: const Icon(Icons.logout),
            onPressed: logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Customize your workout",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 25),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Body Part",
                  border: OutlineInputBorder(),
                ),
                value: part,
                items: workouts.keys
                    .map((bp) => DropdownMenuItem(value: bp, child: Text(bp)))
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    part = v;
                    level = null;
                    eq = null;
                    finalWorkout.clear();
                  });
                },
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Difficulty",
                  border: OutlineInputBorder(),
                ),
                value: level,
                items: part == null
                    ? []
                    : (workouts[part] as Map<String, dynamic>)
                        .keys
                        .map((lv) => DropdownMenuItem(value: lv, child: Text(lv)))
                        .toList(),
                onChanged: (v) {
                  setState(() {
                    level = v;
                    eq = null;
                    finalWorkout.clear();
                  });
                },
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Equipment",
                  border: OutlineInputBorder(),
                ),
                value: eq,
                items: (part == null || level == null)
                    ? []
                    : (workouts[part][level] as Map<String, dynamic>)
                        .keys
                        .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                        .toList(),
                onChanged: (v) {
                  setState(() {
                    eq = v;
                    finalWorkout.clear();
                  });
                },
              ),

              const SizedBox(height: 30),

              Center(
                child: ElevatedButton(
                  onPressed: generate,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 35, vertical: 14),
                    child: Text("Generate Workout", style: TextStyle(fontSize: 17)),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              if (finalWorkout.isNotEmpty) ...[
                const Text(
                  "Your Workout Plan:",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ...finalWorkout.map(
                  (x) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Text("- $x", style: const TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: saveCurrentWorkout,
                    child: const Text("Save Workout"),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
