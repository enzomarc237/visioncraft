# VisionCraft Backend

Node.js/Express backend with authentication and project management.

## Features
- JWT Authentication
- User Registration/Login
- Project CRUD Operations
- MongoDB Integration
- Secure Password Hashing

## Setup Instructions

### Prerequisites
- Node.js 16+
- MongoDB (local or cloud)
- Git

### Installation
1. Clone the repository
2. Navigate to backend folder: `cd backend`
3. Install dependencies: `npm install`

### Environment Configuration
1. Copy `.env.example` to `.env`
2. Configure environment variables:
```env
MONGODB_URI=mongodb://127.0.0.1:27017/visioncraft
JWT_SECRET=your-super-secure-secret-key-here
PORT=3000

Running the Server
nodemon server.js

API Endpoints

Authentication
POST /api/auth/register - User registration
POST /api/auth/login - User login

Projects
GET /api/projects - Get user projects
POST /api/projects - Create new project
Full CRUD operations available

Security Features
JWT token authentication
Password hashing with bcrypt
Timing attack protection
Input validation
Rate limiting