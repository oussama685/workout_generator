require("dotenv").config();
const express = require("express");
const mysql = require("mysql2/promise");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const cors = require("cors");

const app = express();

app.use(cors({ origin: true, credentials: true }));
app.use(express.json());

const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD || "",
  database: process.env.DB_NAME,
});

// Health check
app.get("/", (req, res) => res.json({ ok: true }));

// JWT middleware
function auth(req, res, next) {
  const header = req.headers.authorization || "";
  const token = header.startsWith("Bearer ") ? header.slice(7) : null;
  if (!token) return res.status(401).json({ message: "Missing token" });

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.userId = decoded.userId;
    next();
  } catch {
    return res.status(401).json({ message: "Invalid token" });
  }
}

// Register
app.post("/auth/register", async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) return res.status(400).json({ message: "Missing fields" });
    if (password.length < 6) return res.status(400).json({ message: "Password must be 6+ chars" });

    const [existing] = await pool.query("SELECT id FROM users WHERE email=?", [email]);
    if (existing.length > 0) return res.status(400).json({ message: "Email already exists" });

    const hashed = await bcrypt.hash(password, 10);

    const [result] = await pool.query(
      "INSERT INTO users (email, password) VALUES (?,?)",
      [email, hashed]
    );

    const token = jwt.sign({ userId: result.insertId }, process.env.JWT_SECRET, { expiresIn: "7d" });
    res.json({ token });
  } catch (err) {
    console.error("REGISTER ERROR:", err);
    res.status(500).json({ message: "Server error", error: err.message });
  }
});

// Login
app.post("/auth/login", async (req, res) => {
  try {
    const { email, password } = req.body;

    const [rows] = await pool.query("SELECT * FROM users WHERE email=?", [email]);
    if (rows.length === 0) return res.status(400).json({ message: "Invalid credentials" });

    const user = rows[0];
    const ok = await bcrypt.compare(password, user.password);
    if (!ok) return res.status(400).json({ message: "Invalid credentials" });

    const token = jwt.sign({ userId: user.id }, process.env.JWT_SECRET, { expiresIn: "7d" });
    res.json({ token });
  } catch (err) {
    console.error("LOGIN ERROR:", err);
    res.status(500).json({ message: "Server error", error: err.message });
  }
});

// Save workout
app.post("/workouts", auth, async (req, res) => {
  try {
    const { bodyPart, difficulty, equipment, exercises } = req.body;

    if (!bodyPart || !difficulty || !equipment) {
      return res.status(400).json({ message: "Missing workout fields" });
    }
    if (!Array.isArray(exercises) || exercises.length === 0) {
      return res.status(400).json({ message: "Exercises required" });
    }

    const [w] = await pool.query(
      "INSERT INTO workouts (user_id, body_part, difficulty, equipment) VALUES (?,?,?,?)",
      [req.userId, bodyPart, difficulty, equipment]
    );
    const workoutId = w.insertId;

    for (const ex of exercises) {
      const name = String(ex.name ?? "").trim();
      const sets = Number(ex.sets ?? 1);
      const reps = Number(ex.reps ?? 0);
      if (!name) continue;

      await pool.query(
        "INSERT INTO workout_exercises (workout_id, name, sets, reps) VALUES (?,?,?,?)",
        [workoutId, name, sets, reps]
      );
    }

    res.json({ message: "Workout saved", workoutId });
  } catch (err) {
    console.error("SAVE WORKOUT ERROR:", err);
    res.status(500).json({ message: "Server error", error: err.message });
  }
});

// Get my workouts
app.get("/workouts", auth, async (req, res) => {
  try {
    const [workouts] = await pool.query(
      "SELECT * FROM workouts WHERE user_id=? ORDER BY created_at DESC",
      [req.userId]
    );

    for (const w of workouts) {
      const [ex] = await pool.query(
        "SELECT name, sets, reps FROM workout_exercises WHERE workout_id=?",
        [w.id]
      );
      w.exercises = ex;
    }

    res.json(workouts);
  } catch (err) {
    console.error("GET WORKOUTS ERROR:", err);
    res.status(500).json({ message: "Server error", error: err.message });
  }
});

app.listen(process.env.PORT, () => {
  console.log(`Backend running on port ${process.env.PORT}`);
});
