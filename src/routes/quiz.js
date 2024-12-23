const express = require('express');
const fs = require('fs');
const path = require('path');
const Quiz = require('../models/Quiz');
const Question = require('../models/Questions');

const router = express.Router();

router.get('/', async (req, res) => {
    try {
      const quizzes = await Quiz.find({});
      res.status(200).json(quizzes);
    } catch (error) {
      console.error('Error fetching quizzes:', error);
      res.status(500).json({ error: 'Failed to fetch quizzes.' });
    }
  });

// Fetch questions for a specific quiz
router.get('/:quizId/questions', async (req, res) => {
    try {
      const { quizId } = req.params;
      const questions = await Question.find({ quizId });
      res.status(200).json(questions);
    } catch (error) {
      console.error('Error fetching questions:', error);
      res.status(500).json({ error: 'Failed to fetch questions.' });
    }
  });
  

// Update quizzes API
router.post('/update', async (req, res) => {
  try {
    const filePath = path.join(__dirname, '../data/quizzes.json');
    const data = fs.readFileSync(filePath, 'utf-8');
    const quizzes = JSON.parse(data);

    // Clear existing quizzes and questions
    await Quiz.deleteMany({});
    await Question.deleteMany({});
    for (const quiz of quizzes) {
      // Create quiz
      const newQuiz = await Quiz.create({
        name: quiz.name,
        difficulty: quiz.difficulty,
        numberOfQuestions: quiz.numberOfQuestions,
        description: quiz.description,
      });
      // Create questions for the quiz
      for (const question of quiz.questions) {
        await Question.create({
          quizId: newQuiz._id,
          questionText: question.questionText,
          type: question.type,
          options: question.options || [],
          correctAnswers: question.correctAnswers || [],
        });
      }
    }

    res.status(200).json({ message: 'Quizzes updated successfully.' });
  } catch (error) {
    console.error('Error updating quizzes:', error);
    res.status(500).json({ error: 'Failed to update quizzes.' });
  }
});

module.exports = router;
