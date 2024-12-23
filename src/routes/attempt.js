const express = require('express');
const Attempt = require('../models/Attempt');

const router = express.Router();

// Fetch attempts for a quiz by a user
router.get('/:quizId/user/:userId', async (req, res) => {
  try {
    const { quizId, userId } = req.params;
    const attempts = await Attempt.find({ quizId, userId });
    res.status(200).json(attempts);
  } catch (error) {
    console.error('Error fetching attempts:', error);
    res.status(500).json({ error: 'Failed to fetch attempts.' });
  }
});

// Get all attempts for a specific quiz
router.get('/:quizId/attempts', async (req, res) => {
  const { quizId } = req.params;

  try {
    // Fetch attempts for the given quizId
    const attempts = await Attempt.find({ quizId }).sort({ dateTaken: -1 });

    // Respond with the attempts
    res.status(200).json(attempts);
  } catch (error) {
    console.error('Error fetching attempts:', error);
    res.status(500).json({ error: 'Failed to fetch attempts' });
  }
});

// Save an attempt
router.post('/', async (req, res) => {
  try {
    const { quizId, userId, score, totalQuestions, dateTaken } = req.body;
    console.log(1);
    // Validate required fields
    if (!quizId || !userId || score === undefined || !totalQuestions) {
      console.log(111)
      return res.status(400).json({ error: 'Missing required fields.' });
    }

    // Create a new attempt
    const newAttempt = new Attempt({
      quizId,
      userId,
      score,
      totalQuestions,
      dateTaken: dateTaken || new Date(),
    });

    await newAttempt.save();

    res.status(201).json({ message: 'Attempt saved successfully.' });
  } catch (error) {
    console.error('Error saving attempt:', error);
    res.status(500).json({ error: 'Failed to save attempt.' });
  }
});


module.exports = router;
