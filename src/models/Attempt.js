const mongoose = require('mongoose');

const AttemptSchema = new mongoose.Schema(
  {
    quizId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Quiz',
      required: true,
    },
    userId: {
      type: String, // Can be updated to ObjectId if user model exists
      required: true,
    },
    score: {
      type: Number,
      required: true,
    },
    totalQuestions: {
      type: Number, // New field for total number of questions in the quiz
      required: true,
    },
    dateTaken: {
      type: Date,
      default: Date.now,
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Attempt', AttemptSchema);
