const express = require('express');
const cors = require('cors');
const connectDB = require('./config/db');

require('dotenv').config();

connectDB();

const app = express();

// Middleware - increase limit for base64 avatar uploads
app.use(cors());
app.use(express.json({ limit: '10mb' }));

// Routes
app.use('/api/auth', require('./routes/authRoutes'));
app.use('/api/tasks', require('./routes/taskRoutes'));
app.use('/api/projects', require('./routes/projectRoutes'));
app.use('/api/notifications', require('./routes/notificationRoutes'));

// Health check
app.get('/', (req, res) => {
  res.json({ message: 'TaskFlow API is running' });
});

const PORT = process.env.PORT || 3000;

app.listen(PORT, '0.0.0.0', () => {
  console.log(`TaskFlow API Server running on port ${PORT}`);
});
