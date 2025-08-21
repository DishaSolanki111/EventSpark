const express = require("express");
const mysql = require("mysql");
const bodyParser = require("body-parser");
const cors = require("cors");

const app = express();
app.use(cors());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());

// MySQL connection
const db = mysql.createConnection({
  host: "localhost",
  user: "root",       // your MySQL username
  password: "your_password",       // your MySQL password
  database: "eventspark"
});

db.connect(err => {
  if (err) throw err;
  console.log("MySQL Connected...");
});

// ------------------- ROUTES -------------------

// Customer Registration
app.post("/register-customer", (req, res) => {
  const { fname, email, mob, pass } = req.body;
  const sql = "INSERT INTO customer (fullname, email, phone, password) VALUES (?, ?, ?, ?)";
  db.query(sql, [fname, email, mob, pass], (err, result) => {
    if (err) return res.status(500).send(err);
    // res.send({ message: "Customer registered successfully" });
    res.redirect("http://localhost:5500/event.html");
  });
});

// Event Manager Registration
app.post("/register-manager", (req, res) => {
  const { fname, email, mob, company, experience, specialization, pass } = req.body;
  const sql = `INSERT INTO event_manager 
      (fullname, email, phone, company, experience, specialization, password) 
      VALUES (?, ?, ?, ?, ?, ?, ?)`;
  db.query(sql, [fname, email, mob, company, experience, specialization, pass], (err, result) => {
    if (err) return res.status(500).send(err);
    // res.send({ message: "Event Manager registered successfully" });
    res.redirect("http://localhost:5500/event.html");

  });
});

// Common Login
app.post("/login", (req, res) => {
  const { id, pass, identity } = req.body;
  let table = identity === "customer" ? "customer" : "event_manager";

  const sql = `SELECT * FROM ${table} WHERE email = ? AND password = ?`;
  db.query(sql, [id, pass], (err, result) => {
    if (err) return res.status(500).send(err);
    if (result.length > 0) {
      res.send({ message: "Login successful", user: result[0] });
    } else {
      res.status(401).send({ message: "Invalid credentials" });
    }
  });
});

// Start server
app.listen(5000, () => console.log("Server running on http://localhost:5000"));
