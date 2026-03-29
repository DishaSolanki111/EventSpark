// ============================================
// EventSpark - Node.js Backend (server.js)
// ============================================
// Run: node server.js
// Make sure XAMPP MySQL is running on port 3306
// ============================================

const express    = require('express');
const mysql      = require('mysql2');
const bcrypt     = require('bcrypt');
const session    = require('express-session');
const cors       = require('cors');
const path       = require('path');

const app  = express();
const PORT = 5000;

// ── Middleware ──────────────────────────────
app.use(cors({ origin: 'http://localhost:5000', credentials: true }));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname)));

app.use(session({
    secret: 'eventspark_secret_key_2024',
    resave: false,
    saveUninitialized: false,
    cookie: { secure: false, maxAge: 24 * 60 * 60 * 1000 }
}));

// ── Database Connection ─────────────────────
const db = mysql.createConnection({
    host:     'localhost',
    user:     'root',
    password: '',           // XAMPP default: empty string
    database: 'eventspark',
    port:     3306
});

db.connect((err) => {
    if (err) {
        console.error('❌ DB Connection Failed:', err.message);
        process.exit(1);
    }
    console.log('✅ Connected to MySQL - eventspark database');
});

// ── Helper ──────────────────────────────────
function isLoggedIn(req, res, next) {
    if (req.session && req.session.user) return next();
    res.status(401).json({ success: false, message: 'Please login first.' });
}

// ============================================================
// AUTH ROUTES
// ============================================================

// ── Customer Registration ────────────────────
app.post('/register-customer', async (req, res) => {
    const { fname, email, phone, pass, cnfpass } = req.body;

    if (!fname || !email || !phone || !pass || !cnfpass)
        return res.send('<script>alert("All fields are required!"); history.back();</script>');

    if (pass !== cnfpass)
        return res.send('<script>alert("Passwords do not match!"); history.back();</script>');

    if (phone.length !== 10 || !/^[0-9]+$/.test(phone))
        return res.send('<script>alert("Phone number must be exactly 10 digits!"); history.back();</script>');

    try {
        db.query('SELECT customer_id FROM customers WHERE email = ?', [email], async (err, rows) => {
            if (err) return res.send('<script>alert("Database error"); history.back();</script>');
            if (rows.length > 0)
                return res.send('<script>alert("Email already registered! Please login."); window.location="finallogin.html";</script>');

            const hashedPass = await bcrypt.hash(pass, 10);
            db.query(
                'INSERT INTO customers (fname, email, phone, pass) VALUES (?, ?, ?, ?)',
                [fname, email, phone, hashedPass],
                (err2) => {
                    if (err2) return res.send('<script>alert("Registration failed: ' + err2.message + '"); history.back();</script>');
                    res.send('<script>alert("Registration successful! Please login."); window.location="finallogin.html";</script>');
                }
            );
        });
    } catch (e) {
        res.send('<script>alert("Server error"); history.back();</script>');
    }
});

// ── Manager Registration ─────────────────────
app.post('/register-manager', async (req, res) => {
    const { fname, email, mob, company, experience, specialization, pass, cnfpass } = req.body;

    if (!fname || !email || !mob || !pass || !cnfpass || !specialization)
        return res.send('<script>alert("All fields are required!"); history.back();</script>');

    if (pass !== cnfpass)
        return res.send('<script>alert("Passwords do not match!"); history.back();</script>');

    if (mob.length !== 10 || !/^[0-9]+$/.test(mob))
        return res.send('<script>alert("Phone number must be exactly 10 digits!"); history.back();</script>');

    try {
        // Check email
        db.query('SELECT manager_id FROM managers WHERE email = ?', [email], async (err, rows) => {
            if (err) return res.send('<script>alert("Database error"); history.back();</script>');
            if (rows.length > 0)
                return res.send('<script>alert("Email already registered! Please login."); window.location="finallogin.html";</script>');

            // Lookup category_id
            db.query('SELECT category_id FROM categories WHERE category_name = ?', [specialization], async (err2, cats) => {
                if (err2 || cats.length === 0)
                    return res.send('<script>alert("Invalid specialization selected."); history.back();</script>');

                const category_id = cats[0].category_id;
                const hashedPass  = await bcrypt.hash(pass, 10);

                db.query(
                    'INSERT INTO managers (fname, email, mob, company, experience, category_id, pass) VALUES (?, ?, ?, ?, ?, ?, ?)',
                    [fname, email, mob, company || '', experience || 0, category_id, hashedPass],
                    (err3) => {
                        if (err3) return res.send('<script>alert("Registration failed: ' + err3.message + '"); history.back();</script>');
                        res.send('<script>alert("Manager registration successful! Please login."); window.location="finallogin.html";</script>');
                    }
                );
            });
        });
    } catch (e) {
        res.send('<script>alert("Server error"); history.back();</script>');
    }
});

// ── Login (Customer + Manager) ───────────────
app.post('/login', async (req, res) => {
    const { email, pass, identity } = req.body;

    if (!email || !pass || !identity)
        return res.send('<script>alert("All fields required!"); history.back();</script>');

    const role = identity.trim().toLowerCase();

    if (role === 'customer') {
        db.query('SELECT * FROM customers WHERE email = ?', [email], async (err, rows) => {
            if (err || rows.length === 0)
                return res.send('<script>alert("Invalid email or password!"); history.back();</script>');

            const user = rows[0];
            const match = await bcrypt.compare(pass, user.pass);
            if (!match)
                return res.send('<script>alert("Invalid email or password!"); history.back();</script>');

            req.session.user = { id: user.customer_id, name: user.fname, role: 'customer' };
            res.redirect('/event.html');
        });

    } else if (role === 'manager') {
        db.query('SELECT * FROM managers WHERE email = ?', [email], async (err, rows) => {
            if (err || rows.length === 0)
                return res.send('<script>alert("Invalid email or password!"); history.back();</script>');

            const user = rows[0];
            const match = await bcrypt.compare(pass, user.pass);
            if (!match)
                return res.send('<script>alert("Invalid email or password!"); history.back();</script>');

            req.session.user = { id: user.manager_id, name: user.fname, role: 'manager' };
            res.redirect('/manager_dashboard.html');
        });

    } else {
        res.send('<script>alert("Invalid role! Type: customer or manager"); history.back();</script>');
    }
});

// ── Logout ───────────────────────────────────
app.get('/logout', (req, res) => {
    req.session.destroy();
    res.redirect('/home.html');
});

// ── Session Info API ─────────────────────────
app.get('/session-info', (req, res) => {
    if (req.session.user) {
        res.json({ loggedIn: true, user: req.session.user });
    } else {
        res.json({ loggedIn: false });
    }
});

// ============================================================
// EVENT ROUTES
// ============================================================

// ── Get All Events (public) ──────────────────
app.get('/events', (req, res) => {
    const { category, search } = req.query;
    let sql = `
        SELECT e.*, c.category_name AS category, c.icon AS category_icon,
               m.fname AS manager_name, m.company
        FROM events e
        JOIN categories c ON e.category_id = c.category_id
        JOIN managers   m ON e.manager_id  = m.manager_id
        WHERE e.status = 'upcoming'
    `;
    const params = [];

    if (category && category !== 'all') {
        sql += ' AND c.category_name = ?';
        params.push(category);
    }
    if (search) {
        sql += ' AND (e.title LIKE ? OR e.description LIKE ? OR e.venue LIKE ?)';
        const like = `%${search}%`;
        params.push(like, like, like);
    }
    sql += ' ORDER BY e.event_date ASC';

    db.query(sql, params, (err, rows) => {
        if (err) return res.status(500).json({ success: false, error: err.message });
        res.json({ success: true, events: rows });
    });
});

// ── Get Single Event ─────────────────────────
app.get('/events/:id', (req, res) => {
    const sql = `
        SELECT e.*, c.category_name AS category, c.icon AS category_icon,
               m.fname AS manager_name, m.company
        FROM events e
        JOIN categories c ON e.category_id = c.category_id
        JOIN managers   m ON e.manager_id  = m.manager_id
        WHERE e.event_id = ?
    `;
    db.query(sql, [req.params.id], (err, rows) => {
        if (err || rows.length === 0)
            return res.status(404).json({ success: false, message: 'Event not found' });
        res.json({ success: true, event: rows[0] });
    });
});

// ── Create Event (manager only) ──────────────
app.post('/events/create', isLoggedIn, (req, res) => {
    if (req.session.user.role !== 'manager')
        return res.status(403).json({ success: false, message: 'Only managers can create events.' });

    const { title, description, category, venue, event_date, event_time, total_seats, price } = req.body;
    if (!title || !category || !venue || !event_date || !event_time || !total_seats || !price)
        return res.status(400).json({ success: false, message: 'All fields required.' });

    // Lookup category_id from category name
    db.query('SELECT category_id FROM categories WHERE category_name = ?', [category], (err, cats) => {
        if (err || cats.length === 0)
            return res.status(400).json({ success: false, message: 'Invalid category.' });

        const category_id = cats[0].category_id;
        db.query(
            `INSERT INTO events (manager_id, category_id, title, description, venue, event_date, event_time, total_seats, available_seats, price)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
            [req.session.user.id, category_id, title, description || '', venue, event_date, event_time, total_seats, total_seats, price],
            (err2, result) => {
                if (err2) return res.status(500).json({ success: false, error: err2.message });
                res.json({ success: true, message: 'Event created successfully!', event_id: result.insertId });
            }
        );
    });
});

// ── Update Event ─────────────────────────────
app.put('/events/:id', isLoggedIn, (req, res) => {
    if (req.session.user.role !== 'manager')
        return res.status(403).json({ success: false, message: 'Forbidden' });

    const { title, description, venue, event_date, event_time, price, status } = req.body;
    db.query(
        `UPDATE events SET title=?, description=?, venue=?, event_date=?, event_time=?, price=?, status=?
         WHERE event_id=? AND manager_id=?`,
        [title, description, venue, event_date, event_time, price, status, req.params.id, req.session.user.id],
        (err, result) => {
            if (err) return res.status(500).json({ success: false, error: err.message });
            if (result.affectedRows === 0)
                return res.status(404).json({ success: false, message: 'Event not found or unauthorized.' });
            res.json({ success: true, message: 'Event updated!' });
        }
    );
});

// ── Delete Event ─────────────────────────────
app.delete('/events/:id', isLoggedIn, (req, res) => {
    if (req.session.user.role !== 'manager')
        return res.status(403).json({ success: false, message: 'Forbidden' });

    db.query(
        'DELETE FROM events WHERE event_id = ? AND manager_id = ?',
        [req.params.id, req.session.user.id],
        (err, result) => {
            if (err) return res.status(500).json({ success: false, error: err.message });
            res.json({ success: true, message: 'Event deleted.' });
        }
    );
});

// ── Manager's own events ─────────────────────
app.get('/my-events', isLoggedIn, (req, res) => {
    if (req.session.user.role !== 'manager')
        return res.status(403).json({ success: false, message: 'Forbidden' });

    const sql = `
        SELECT e.*, c.category_name AS category, c.icon AS category_icon
        FROM events e
        JOIN categories c ON e.category_id = c.category_id
        WHERE e.manager_id = ?
        ORDER BY e.event_date DESC
    `;
    db.query(sql, [req.session.user.id], (err, rows) => {
        if (err) return res.status(500).json({ success: false, error: err.message });
        res.json({ success: true, events: rows });
    });
});

// ============================================================
// BOOKING ROUTES
// ============================================================

// ── Book an Event ────────────────────────────
app.post('/book', isLoggedIn, (req, res) => {
    if (req.session.user.role !== 'customer')
        return res.status(403).json({ success: false, message: 'Only customers can book events.' });

    const { event_id, seats_booked } = req.body;
    const seats = parseInt(seats_booked) || 1;

    db.query('SELECT * FROM events WHERE event_id = ? AND status = "upcoming"', [event_id], (err, rows) => {
        if (err || rows.length === 0)
            return res.status(404).json({ success: false, message: 'Event not found or not available.' });

        const event = rows[0];
        if (event.available_seats < seats)
            return res.status(400).json({ success: false, message: `Only ${event.available_seats} seats available.` });

        const total = event.price * seats;

        db.query(
            'INSERT INTO bookings (customer_id, event_id, seats_booked, total_amount) VALUES (?, ?, ?, ?)',
            [req.session.user.id, event_id, seats, total],
            (err2, result) => {
                if (err2) {
                    if (err2.code === 'ER_DUP_ENTRY')
                        return res.status(400).json({ success: false, message: 'You have already booked this event.' });
                    return res.status(500).json({ success: false, error: err2.message });
                }
                res.json({ success: true, message: 'Booking confirmed!', booking_id: result.insertId, total_amount: total });
            }
        );
    });
});

// ── My Bookings ──────────────────────────────
app.get('/my-bookings', isLoggedIn, (req, res) => {
    if (req.session.user.role !== 'customer')
        return res.status(403).json({ success: false, message: 'Forbidden' });

    const sql = `
        SELECT b.*, e.title, e.venue, e.event_date, e.event_time, e.price,
               c.category_name AS category, c.icon AS category_icon
        FROM bookings b
        JOIN events     e ON b.event_id    = e.event_id
        JOIN categories c ON e.category_id = c.category_id
        WHERE b.customer_id = ?
        ORDER BY b.booked_at DESC
    `;
    db.query(sql, [req.session.user.id], (err, rows) => {
        if (err) return res.status(500).json({ success: false, error: err.message });
        res.json({ success: true, bookings: rows });
    });
});

// ── Cancel Booking ───────────────────────────
app.put('/bookings/:id/cancel', isLoggedIn, (req, res) => {
    db.query(
        'UPDATE bookings SET booking_status = "cancelled" WHERE booking_id = ? AND customer_id = ?',
        [req.params.id, req.session.user.id],
        (err, result) => {
            if (err) return res.status(500).json({ success: false, error: err.message });
            if (result.affectedRows === 0)
                return res.status(404).json({ success: false, message: 'Booking not found.' });
            res.json({ success: true, message: 'Booking cancelled.' });
        }
    );
});

// ── Event Bookings for Manager ───────────────
app.get('/event-bookings/:event_id', isLoggedIn, (req, res) => {
    if (req.session.user.role !== 'manager')
        return res.status(403).json({ success: false, message: 'Forbidden' });

    const sql = `
        SELECT b.booking_id, b.seats_booked, b.total_amount, b.booking_status, b.booked_at,
               c.fname AS customer_name, c.email AS customer_email, c.phone AS customer_phone
        FROM bookings b
        JOIN customers c ON b.customer_id = c.customer_id
        JOIN events e    ON b.event_id    = e.event_id
        WHERE b.event_id = ? AND e.manager_id = ?
        ORDER BY b.booked_at DESC
    `;
    db.query(sql, [req.params.event_id, req.session.user.id], (err, rows) => {
        if (err) return res.status(500).json({ success: false, error: err.message });
        res.json({ success: true, bookings: rows });
    });
});

// ── Start Server ──────────────────────────────
app.listen(PORT, () => {
    console.log(`\n🚀 EventSpark running at http://localhost:${PORT}`);
    console.log(`📄 Home: http://localhost:${PORT}/home.html\n`);
});
