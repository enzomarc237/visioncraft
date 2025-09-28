const express = require('express');
const Project = require('../models/Project');
const auth = require('../middleware/auth');
const router = express.Router();

router.use(auth);

// GET /api/projects - Get all projects for authenticated user
router.get('/', async (req, res) => {
  try {
    const projects = await Project.find({ userId: req.user._id })
      .sort({ createdAt: -1 });
    
    res.json({
      message: 'Projects retrieved successfully',
      count: projects.length,
      projects
    });
  } catch (error) {
    console.error('Get projects error:', error);
    res.status(500).json({ 
      message: 'Error retrieving projects',
      error: error.message 
    });
  }
});

// POST /api/projects - Save new project
router.post('/', async (req, res) => {
  try {
    const { projectName, appName, tagline, marketingDescription, screens, designSystemPrompt, logoPrompt } = req.body;

    // Validation
    if (!projectName) {
      return res.status(400).json({ 
        message: 'Project name is required' 
      });
    }

    const projectData = {
      userId: req.user._id,
      projectName,
      appName,
      tagline,
      marketingDescription,
      screens: screens || [],
      designSystemPrompt,
      logoPrompt,
      // Initialize empty structures
      colorPalette: req.body.colorPalette || {},
      typography: req.body.typography || {},
      screenMockups: req.body.screenMockups || []
    };

    const project = new Project(projectData);
    const savedProject = await project.save();

    res.status(201).json({
      message: 'Project created successfully',
      project: savedProject
    });
  } catch (error) {
    console.error('Create project error:', error);
    
    if (error.name === 'ValidationError') {
      return res.status(400).json({ 
        message: 'Validation error',
        errors: Object.values(error.errors).map(e => e.message)
      });
    }
    
    res.status(500).json({ 
      message: 'Error creating project',
      error: error.message 
    });
  }
});

// GET /api/projects/:id - Get specific project
router.get('/:id', async (req, res) => {
  try {
    const project = await Project.findOne({ 
      _id: req.params.id, 
      userId: req.user._id 
    });

    if (!project) {
      return res.status(404).json({ 
        message: 'Project not found' 
      });
    }

    res.json({
      message: 'Project retrieved successfully',
      project
    });
  } catch (error) {
    console.error('Get project error:', error);
    
    if (error.name === 'CastError') {
      return res.status(400).json({ 
        message: 'Invalid project ID' 
      });
    }
    
    res.status(500).json({ 
      message: 'Error retrieving project',
      error: error.message 
    });
  }
});

// PUT /api/projects/:id - Update project
router.put('/:id', async (req, res) => {
  try {
    const updates = req.body;
    
    // Remove userId from updates to prevent changing ownership
    delete updates.userId;

    const project = await Project.findOneAndUpdate(
      { 
        _id: req.params.id, 
        userId: req.user._id 
      },
      updates,
      { 
        new: true, 
        runValidators: true 
      }
    );

    if (!project) {
      return res.status(404).json({ 
        message: 'Project not found' 
      });
    }

    res.json({
      message: 'Project updated successfully',
      project
    });
  } catch (error) {
    console.error('Update project error:', error);
    
    if (error.name === 'ValidationError') {
      return res.status(400).json({ 
        message: 'Validation error',
        errors: Object.values(error.errors).map(e => e.message)
      });
    }
    
    if (error.name === 'CastError') {
      return res.status(400).json({ 
        message: 'Invalid project ID' 
      });
    }
    
    res.status(500).json({ 
      message: 'Error updating project',
      error: error.message 
    });
  }
});

// DELETE /api/projects/:id - Delete project
router.delete('/:id', async (req, res) => {
  try {
    const project = await Project.findOneAndDelete({ 
      _id: req.params.id, 
      userId: req.user._id 
    });

    if (!project) {
      return res.status(404).json({ 
        message: 'Project not found' 
      });
    }

    res.json({
      message: 'Project deleted successfully',
      projectId: req.params.id
    });
  } catch (error) {
    console.error('Delete project error:', error);
    
    if (error.name === 'CastError') {
      return res.status(400).json({ 
        message: 'Invalid project ID' 
      });
    }
    
    res.status(500).json({ 
      message: 'Error deleting project',
      error: error.message 
    });
  }
});

module.exports = router;