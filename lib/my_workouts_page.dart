import 'package:flutter/material.dart';
import 'api.dart';

class MyWorkoutsPage extends StatefulWidget {
  const MyWorkoutsPage({super.key});

  @override
  State<MyWorkoutsPage> createState() => _MyWorkoutsPageState();
}

class _MyWorkoutsPageState extends State<MyWorkoutsPage> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = Api.getMyWorkouts();
  }

  Future<void> refresh() async {
    setState(() {
      _future = Api.getMyWorkouts();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Saved Workouts")),
      body: FutureBuilder<List<dynamic>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Text("Error: ${snap.error}"),
              ),
            );
          }

          final workouts = snap.data ?? [];
          if (workouts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("No saved workouts yet."),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: refresh,
                      child: const Text("Refresh"),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: workouts.length,
              itemBuilder: (context, i) {
                final w = workouts[i] as Map<String, dynamic>;

                final bodyPart = w["body_part"]?.toString() ?? "";
                final difficulty = w["difficulty"]?.toString() ?? "";
                final equipment = w["equipment"]?.toString() ?? "";
                final createdAt = w["created_at"]?.toString() ?? "";

                final exercises = (w["exercises"] as List<dynamic>? ?? [])
                    .cast<Map<String, dynamic>>();

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$bodyPart • $difficulty • $equipment",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (createdAt.isNotEmpty)
                          Text("Saved: $createdAt", style: const TextStyle(fontSize: 12)),
                        const SizedBox(height: 10),
                        const Text("Exercises:", style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        ...exercises.map((ex) {
                          final name = ex["name"]?.toString() ?? "";
                          final sets = ex["sets"]?.toString() ?? "";
                          final reps = ex["reps"]?.toString() ?? "";
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text("- $name  ($sets x $reps)"),
                          );
                        }),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
