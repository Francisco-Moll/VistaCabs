require('dotenv').config();
const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();
app.use(cors());
app.use(bodyParser.json());

// sql connection config
const db = mysql.createConnection({
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME
});

// connect to mysql
db.connect(err => {
    if (err) {
        console.error('Database connection failed:', err);
    } else {
        console.log('Connected to MySQL database.');
    }
});

// // handle form submission
// app.post('/submit', (req, res) => {
//     const formData = req.body;

//     // dynamically create sql query
//     const key = Object.keys(formData).join(', ');
//     const values = Object.values(formData).map(val => `'${val}'`).join(', ');

//     const sql = `INSERT INTO products (${keys}) VALUES (${values})`;

//     db.query(sql, (err, result) => {
//         if (err) {
//             console.error('Database error:', err);
//             res.status(500).json({ message: 'Database error' });
//         } else { 
//             res.json({ message: 'Form data saved successfully' });
//         }
//     });
// });

app.post('/submit', (req, res) => {
    const formData = req.body;

    if (!formData.name || !formData.manufacturer || !formData.quantity) {
        return res.status(400).json({ message: 'Missing required fields' });
    }

    const keys = Object.keys(formData);
    const values = Object.values(formData);
    const placeholders = keys.map(() => '?').join(', ');

    const sql = `INSERT INTO products (${keys.join(', ')}) VALUES (${placeholders})`;

    db.query(sql, values, (err, result) => {
        if (err) {
            console.error('Database insertion error:', err);
            return res.status(500).json({ message: 'Database error' });
        }
        res.json({ message: 'Product added successfullyu!', data: result });
    });
});

// start server
const PORT = process.env.PORT || 3000;
app. listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});