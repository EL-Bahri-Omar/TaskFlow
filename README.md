# TaskFlow – Intelligent Task Management

A Flutter mobile application for managing tasks individually and collaboratively, with a Node.js/Express REST API backend and MongoDB database.

## 📱 Features

### Core Features
- **Authentication** – Register & Login with JWT token-based auth
- **Task Management (CRUD)** – Create, read, update, delete tasks with status, priority, due date
- **Project Management** – Organize tasks by projects with color coding
- **Collaboration** – Assign tasks to team members, manage project members
- **Dashboard** – Overview with task statistics and recent tasks
- **Profile** – User info, activity summary, logout

### Bonus Features
- ✅ **Dark Mode** – Toggle between light/dark themes (persisted)
- ✅ **REST API Backend** – Express.js + MongoDB
- ✅ **Clean Architecture** – MVC (Backend) + MVVM (Flutter)

## 🏗️ Architecture

### Backend (MVC)
```
backend/
├── server.js              # Entry point
├── config/db.js           # MongoDB connection
├── models/                # (M) Mongoose schemas
│   ├── User.js
│   ├── Task.js
│   └── Project.js
├── controllers/           # (C) Business logic
│   ├── authController.js
│   ├── taskController.js
│   └── projectController.js
├── routes/                # (V) API routes
│   ├── authRoutes.js
│   ├── taskRoutes.js
│   └── projectRoutes.js
└── middleware/auth.js     # JWT middleware
```

### Flutter (MVVM)
```
lib/
├── main.dart
├── data/
│   ├── constants.dart     # App constants
│   ├── notifiers.dart     # ValueNotifiers (state management)
│   ├── models/            # Data models
│   └── services/          # API services
└── views/
    ├── widget_tree.dart   # Main scaffold
    ├── pages/             # App screens
    └── widgets/           # Reusable widgets
```

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter (Dart) |
| State Management | ValueNotifier + ValueListenableBuilder |
| Backend | Node.js + Express.js |
| Database | MongoDB (localhost:27017) |
| Authentication | JWT (JSON Web Tokens) |
| Architecture | MVC (Backend) + MVVM (Flutter) |

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.x+)
- Node.js (18+)
- MongoDB (running on localhost:27017)

### Backend Setup
```bash
cd backend
npm install
node server.js
```
The API server will start on `http://localhost:3000`.

### Flutter Setup
```bash
flutter pub get
flutter run
```

> **Note:** For Android emulator, the API URL is configured as `http://10.0.2.2:3000/api`. For web or desktop testing, change it to `http://localhost:3000/api` in `lib/data/constants.dart`.

## 📡 API Endpoints

### Auth
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/register` | Register new user |
| POST | `/api/auth/login` | Login user |
| GET | `/api/auth/me` | Get current user |
| GET | `/api/auth/users` | Get all users |

### Tasks
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/tasks` | List tasks (with filters) |
| GET | `/api/tasks/stats` | Get task statistics |
| POST | `/api/tasks` | Create task |
| GET | `/api/tasks/:id` | Get single task |
| PUT | `/api/tasks/:id` | Update task |
| DELETE | `/api/tasks/:id` | Delete task |

### Projects
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/projects` | List projects |
| POST | `/api/projects` | Create project |
| GET | `/api/projects/:id` | Get project with tasks |
| PUT | `/api/projects/:id` | Update project |
| DELETE | `/api/projects/:id` | Delete project |

## 📸 Screens

1. **Welcome Page** – App landing with Lottie animation
2. **Onboarding Page** – Feature overview
3. **Login Page** – Email/password authentication
4. **Register Page** – Create new account
5. **Home Dashboard** – Stats grid + recent tasks
6. **Tasks Page** – Filterable task list with FAB
7. **Task Detail** – Create/edit task form
8. **Projects Page** – Project cards with progress
9. **Project Detail** – Project info + tasks
10. **Profile Page** – User info + activity stats
11. **Settings Page** – Dark mode + about info

## 👨‍💻 Author
EL Bahri Omar

# Mini-Projet Flutter – TaskFlow
