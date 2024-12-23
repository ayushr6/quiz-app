const mongoose = require('mongoose');

const QuizSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
  },
  difficulty: {
    type: String,
    enum: ['Easy', 'Medium', 'Hard'],
    required: true,
  },
  numberOfQuestions: {
    type: Number,
    required: true,
  },
  description: {
    type: String,
  },
}, { timestamps: true });

module.exports = mongoose.model('Quiz', QuizSchema);
