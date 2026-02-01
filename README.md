# 🎓 E-Learning Quiz App

A Flutter mobile application that allows users to take a multiple-choice quiz, track their score in real time, and view detailed results at the end of the quiz.

---

## 📱 Features

### 🏠 Home Screen
- App title / logo (for branding).
- **Start Quiz** button to begin the quiz.

### ❓ Quiz Screen
- Fetches **10– multiple-choice questions** from: 
  - OR Remote API (e.g. Open Trivia DB).
- Each question includes:
  - Question text.
  - **4 answer options**.
- User can:
  - Select **only one answer**.
  - Move to the next question using **Next** button.
- Validation:
  - User **cannot proceed** without selecting an answer.

### 📊 Score Tracking
- Tracks correct answers in real time.
- Stores user-selected answers temporarily until the quiz ends.

### 🏁 Results Screen
- Displays final score  
  _Example: You scored 7/10_
- Shows a detailed summary:
  - All questions.
  - User’s selected answer (highlighted).
  - Correct answer (highlighted differently).
- **Retake Quiz** button to restart the quiz.

---

## 🛠️ Technologies Used

- **Flutter**
- **Dart**
- REST API
- Material UI

---

## 📂 Project Structure (Example)

