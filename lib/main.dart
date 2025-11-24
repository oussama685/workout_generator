import 'package:flutter/material.dart';

void main() {
  runApp(WorkoutApp());
}

class WorkoutApp extends StatelessWidget {
  const WorkoutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WorkoutPage(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

class WorkoutPage extends StatefulWidget {
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
          workouts[part]?[level]?[eq] ??
              ["No workout found for this selection"],
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Customize your workout",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),

              SizedBox(height: 25),

              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Body Part",
                  border: OutlineInputBorder(),
                ),
                value: part,
                items: workouts.keys
                    .map((bp) => DropdownMenuItem(
                          value: bp,
                          child: Text(bp),
                        ))
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

              SizedBox(height: 20),

              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Difficulty",
                  border: OutlineInputBorder(),
                ),
                value: level,
                items: part == null
                    ? []
                    : (workouts[part] as Map<String, dynamic>)
                        .keys
                        .map(
                          (lv) => DropdownMenuItem(
                            value: lv,
                            child: Text(lv),
                          ),
                        )
                        .toList(),
                onChanged: (v) {
                  setState(() {
                    level = v;
                    eq = null;
                    finalWorkout.clear();
                  });
                },
              ),

              SizedBox(height: 20),

              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Equipment",
                  border: OutlineInputBorder(),
                ),
                value: eq,
                items: (part == null || level == null)
                    ? []
                    : (workouts[part][level] as Map<String, dynamic>)
                        .keys
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          ),
                        )
                        .toList(),
                onChanged: (v) {
                  setState(() {
                    eq = v;
                    finalWorkout.clear();
                  });
                },
              ),

              SizedBox(height: 30),

              Center(
                child: ElevatedButton(
                  onPressed: generate,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 35,
                      vertical: 14,
                    ),
                    child: Text(
                      "Generate Workout",
                      style: TextStyle(fontSize: 17),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 25),

              if (finalWorkout.isNotEmpty)
                Text(
                  "Your Workout Plan:",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              SizedBox(height: 10),

              ...finalWorkout.map(
                (x) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    "- $x",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
