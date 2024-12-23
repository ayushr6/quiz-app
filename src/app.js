const express = require('express');
const connectDB = require('./config/db');
require('dotenv').config();

const authRoutes = require('./routes/auth');
const quizRoutes = require('./routes/quiz');
const attempRoutes = require('./routes/attempt');

const app = express();

// Connect to database
connectDB();

// Middleware
app.use(express.json());

app.get('/', (req, res) => {
  res.send('API is running...');
});

// Use auth routes
app.use('/auth', authRoutes);
app.use('/quiz', quizRoutes);
app.use('/attempt', attempRoutes);

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
