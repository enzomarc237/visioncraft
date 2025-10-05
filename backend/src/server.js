require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');

// Validate required environment variables
if (!process.env.JWT_SECRET) {
  console.error('❌ ERROR: JWT_SECRET environment variable is required');
  process.exit(1); 
}

if (!process.env.MONGODB_URI) {
  console.warn('⚠️ WARNING: MONGODB_URI not set, using local MongoDB');
}

const app = express();
const port = process.env.PORT || 3000;

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // limit each IP to 100 requests per windowMs
});

// Middleware
app.use(helmet());
app.use(limiter);
app.use(cors());
app.use(express.json({ limit: '10mb' })); // For base64 images

// Routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/projects', require('./routes/projects'));

// Health check
app.get('/api/health', (req, res) => {
  res.json({ 
    message: 'Server is running', 
    timestamp: new Date().toISOString() 
  });
});

// MongoDB connection
mongoose.connect(process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/visioncraft')
.then(() => console.log("✅ MongoDB Connected Successfully"))
.catch(err => console.error("❌ MongoDB Connection Error:", err));

// Start server with graceful shutdown handling
const server = app.listen(port, () => {
  console.log(`🚀 Server running on http://localhost:${port}/`);
});

// Graceful shutdown for unhandled promise rejections
process.on('unhandledRejection', (err) => {
  console.log('❌ UNHANDLED REJECTION! Shutting down gracefully...');
  console.log(err.name, err.message);
  
  // Close server first, then exit process
  server.close(() => {
    console.log('💥 Process terminated due to unhandled promise rejection');
    process.exit(1);
  });
});

// Graceful shutdown for SIGTERM (Docker, Kubernetes, etc.)
process.on('SIGTERM', () => {
  console.log('👋 SIGTERM RECEIVED. Shutting down gracefully...');
  server.close(() => {
    console.log('💥 Process terminated');
  });
});