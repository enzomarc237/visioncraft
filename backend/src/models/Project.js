const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const screenMockupSchema = new Schema({
  screenName: {
    type: String,
    required: true
  },
  imageData: {
    type: String,
    required: true
  },
  isLoFi: {
    type: Boolean,
    default: true
  },
  generatedAt: {
    type: Date,
    default: Date.now
  }
});

const projectSchema = new Schema({
  userId: { 
    type: Schema.Types.ObjectId, 
    ref: 'User', 
    required: true 
  },
  projectName: { 
    type: String, 
    required: true,
    trim: true,
    maxlength: 100
  },
  
  // AI generation fields
  appName: {
    type: String,
    trim: true,
    maxlength: 50
  },
  tagline: {
    type: String,
    trim: true,
    maxlength: 200
  },
  marketingDescription: {
    type: String,
    trim: true,
    maxlength: 1000
  },
  screens: [{
    type: String,
    trim: true
  }],
  designSystemPrompt: String,
  logoPrompt: String,
  
  // Design system
  colorPalette: {
    primary: String,
    secondary: String,
    accent: String,
    neutralLight: String,
    neutralDark: String,
    background: String,
    text: String
  },
  typography: {
    headingFont: String,
    bodyFont: String
  },
  
  // Generated assets
  logo: String,
  screenMockups: [screenMockupSchema],
  
  // Metadata
  isActive: {
    type: Boolean,
    default: true
  },
  lastModified: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true // Adds createdAt and updatedAt automatically
});

// Index for better query performance
projectSchema.index({ userId: 1, createdAt: -1 });
projectSchema.index({ 'screenMockups.generatedAt': -1 });

module.exports = mongoose.model('Project', projectSchema);