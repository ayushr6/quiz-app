const mongoose = require('mongoose');

const QuestionSchema = new mongoose.Schema({
  quizId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Quiz',
    required: true,
  },
  questionText: {
    type: String,
    required: true,
  },
  type: {
    type: String,
    enum: ['multiple_choice', 'numerical_input', 'multiple_selection'],
    required: true,
  },
  options: {
    type: [String], // applicable for multiple choice/selection
    default: []
  },
  correctAnswers: {
    type: [Number], // store indices of correct options for multiple_choice/multiple_selection
    default: []
  }
}, { timestamps: true });

module.exports = mongoose.model('Question', QuestionSchema);
