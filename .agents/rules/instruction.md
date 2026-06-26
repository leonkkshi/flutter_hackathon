---
trigger: always_on
---

FPT University
FLUTTER HACKATHON
Student Task Manager App

1. General Information
Item
Description
Hackathon Name
Flutter Hackathon
Topic
Student Task Manager App
Technology
Flutter, Dart, SQLite, Provider, MVVM
Duration
7:30 – 9:45
Team Size
5 students/team
Format
Relay Coding / Team Coding
Level
Basic
Output
A runnable Flutter mobile application



2. Background
In real life, students often need to manage their daily study tasks such as homework, assignments, exams, project deadlines, and self-study plans.

In this Hackathon, each team will build a simple Student Task Manager App using Flutter. The application allows users to log in, view study tasks, add new tasks, mark tasks as completed, and delete tasks.

The purpose of this Hackathon is to help students practice Flutter UI, navigation, state management, SQLite local storage, CRUD operations, and teamwork in a limited time.


3. Objectives
After completing this Hackathon, students should be able to:

Objective
Description
O1
Build a simple Flutter application with multiple screens
O2
Apply routing and navigation between pages
O3
Design UI using common Flutter widgets
O4
Store and retrieve data using SQLite
O5
Apply basic MVVM structure
O6
Work effectively in a relay coding team



4. Application Requirements
The team must build a Flutter application named:

Student Task Manager App

The app must include the following main features:

Login
Home dashboard
Task list
Add new task
Mark task as completed / pending
Delete task
Store task data using SQLite


5. Functional Requirements
FR1. Login Page
The app must start with the Login Page.
Input Fields
Field
Type
Required
Email
Text
Yes
Password
Text
Yes

Login Account
Email: admin@gmail.com

Password: 123456
Expected Behavior
Case
Expected Result
Correct email and password
Navigate to Home Page
Incorrect email or password
Show error message


Suggested error message:

Invalid email or password


FR2. Home Page
After login successfully, the user is redirected to Home Page.
Home Page must display
Welcome to Student Task Manager App
Statistics
Information
Description
Total Tasks
Number of all tasks
Completed Tasks
Number of completed tasks
Pending Tasks
Number of unfinished tasks

Buttons
Button
Action
Go to Task List
Navigate to Task List Page
Logout
Return to Login Page



FR3. Task List Page
The Task List Page displays all tasks saved in SQLite.

Each task item must show:

Field
Description
Title
Task title
Description
Task description
Deadline
Task deadline
Status
Completed / Pending


Each task item must have:

Action
Description
Checkbox
Mark task as completed or pending
Delete Button
Delete the task



FR4. Add Task
The user can add a new task.

The Add Task form must include:

Field
Type
Required
Title
Text
Yes
Description
Text
Yes
Deadline
Text or DatePicker
Yes


After saving, the new task must be stored in SQLite and displayed in the Task List Page.


FR5. Update Task Status
The user can update the status of a task.

Status
Meaning
0
Pending
1
Completed


When the user checks or unchecks the checkbox, the task status must be updated in SQLite.


FR6. Delete Task
The user can delete a task from the list.

After deleting, the task must be removed from SQLite and the UI must be updated.


6. Technical Requirements
6.1 Required Dependencies
The project should use the following packages:

dependencies:

  flutter:

    sdk: flutter

  provider: ^6.1.2

  sqflite: ^2.4.2+1

  path: ^1.9.0


7. Team Assignment
Each team has 5 members. Each member is responsible for one part of the application.

Member
Role
Main Responsibility
Student 1
Project Setup Developer
Create project structure, routing, initial pages
Student 2
Login Developer
Build Login Page and login logic
Student 3
Home Developer
Build Home Page and dashboard
Student 4
Database Developer
Build TaskModel, SQLite database, TaskService
Student 5
Feature Integration Developer
Build Task List, Add Task, Delete Task, Update Status



8. Relay Coding Rule
This Hackathon follows the relay coding format.
Rules
Each student is responsible for one assigned part.
The next student continues from the previous student’s code.
Students may fix minor bugs from previous parts to make the app run.
The final product must be integrated into one runnable Flutter project.
Each team must prepare a short demo at the end.


9. Timeline
Time
Activity
15 min
Hackathon introduction, team setup, topic explanation
90 min
Coding time, Testing, bug fixing, demo preparation
30 min
Team demo, Summary, feedback, result announcement



10. Submission Requirements
Each team must submit:

No.
Item
Description
1
Source code
Complete Flutter project
2
README.md
Team information and completed features
3
Screenshots
Main screens of the app
4
Demo
Live demo



README Template
Team Name:

Members:

1. Student 1:

2. Student 2:

3. Student 3:

4. Student 4:

5. Student 5:

Topic:

Student Task Manager App

Login Account:

Email: admin@gmail.com

Password: 123456

Completed Features:

- Login

- Home Page

- Task List

- Add Task

- Update Task Status

- Delete Task

- SQLite Storage

Uncompleted Features:

- ...

Contribution:

Student 1:

Student 2:

Student 3:

Student 4:

Student 5:

How to run:

1. flutter pub get

2. flutter run


11. Evaluation Criteria
Total score: 10 points

Criteria
Description
Point
App Execution
App runs successfully without build errors
1.0
Login Feature
Login page works correctly with validation
1.0
Home Page
Home page displays welcome text, statistics, and navigation
1.0
SQLite Database
Database, table, and CRUD methods are implemented correctly
1.5
Add Task
User can add a new task successfully
1.5
Task List
Tasks are displayed correctly using ListView
1.0
Update Status
User can mark task as completed or pending
1.0
Delete Task
User can delete a task successfully
1.0
UI/UX
Interface is clear and easy to use
0.7
Code Organization
Code is structured properly using MVVM
0.8


Total: 10 points


12. Bonus Points
Maximum bonus: +1 point

Bonus Feature
Point
Search task by title
+0.25
Filter tasks by status
+0.25
Select deadline using DatePicker
+0.25
Good UI design with status color
+0.25



13. Demo Requirements
Each team has 2–3 minutes to demo.

The demo should include:

Login
View Home Page
Add a new task
View task list
Mark task as completed
Delete a task
Explain team contribution


14. Important Notes
The app must be runnable.
SQLite is required.
The UI does not need to be complex, but it must be clear.
Code should be separated into folders and files.
Students should avoid putting all logic directly inside UI files.
Each team should focus on completing required features before adding bonus features.


15. Final Topic Statement
Flutter Relay Hackathon: Student Task Manager App

Build a Flutter mobile application that helps students manage their study tasks. The application must support login, dashboard, task list, add task, update task status, delete task, and local data storage using SQLite. The project should follow a simple MVVM structure and be completed by a team of 5 students within 120 minutes.
