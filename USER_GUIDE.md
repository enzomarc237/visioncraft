# AI Design Inspiration Hub - User Guide

Welcome to AI Design Inspiration Hub! This guide will help you get started with organizing your design inspiration and serving it to AI agents.

## Table of Contents

1. [Getting Started](#getting-started)
2. [Managing Screenshots](#managing-screenshots)
3. [Organizing Your Library](#organizing-your-library)
4. [Searching and Filtering](#searching-and-filtering)
5. [MCP Server for AI Agents](#mcp-server-for-ai-agents)
6. [Exporting Data](#exporting-data)
7. [Tips and Best Practices](#tips-and-best-practices)
8. [Troubleshooting](#troubleshooting)

---

## Getting Started

### First Launch

When you first launch AI Design Inspiration Hub, you'll see an empty library with a prompt to upload your first screenshot.

### Main Interface

The application has two main sections:

- **Screenshots**: Your design library where you can view, search, and manage all your screenshots
- **Settings**: Configure the MCP server and manage API keys for AI agents

### Menubar Access

The app icon in your macOS menubar provides quick access to:
- Show/hide the main window
- Upload screenshots
- Open settings
- Quit the application

---

## Managing Screenshots

### Uploading Screenshots

There are two ways to upload screenshots:

#### Method 1: Using the Upload Button

1. Click the **Upload** button in the toolbar
2. Fill in the metadata form:
   - **Title**: Give your screenshot a descriptive name
   - **Description**: Add details about the design
   - **Tags**: Add comma-separated tags (e.g., "mobile, login, blue")
   - **Categories**: Add comma-separated categories (e.g., "Authentication, Mobile Apps")
   - **Source URL**: Optionally add where you found this design
3. Click **Upload** and select your image file
4. The screenshot will be uploaded and automatically analyzed

#### Method 2: Drag and Drop

1. Simply drag an image file from Finder
2. Drop it onto the application window
3. Fill in the metadata and confirm

### Supported Image Formats

- PNG
- JPG/JPEG
- SVG
- WebP

### Automatic Analysis

After uploading, the app automatically analyzes your screenshot to extract:

- **Color Palette**: Dominant colors with their hex codes
- **Layout Information**: Layout type and structure
- **UI Components**: Detected interface elements (future enhancement)
- **Typography**: Font styles and sizes (future enhancement)

This analysis runs in the background and doesn't interrupt your work.

### Viewing Screenshot Details

Click on any screenshot in the grid to view:

- Full-size image
- All metadata (title, description, tags, categories)
- Extracted design specifications
- Color palette visualization
- Upload and creation dates

---

## Organizing Your Library

### Tags

Tags are flexible labels you can assign to screenshots. Use tags for:

- Design patterns: "carousel", "form", "navigation"
- Platforms: "mobile", "web", "desktop"
- Styles: "minimalist", "modern", "vintage"
- Industries: "ecommerce", "healthcare", "fintech"

**Best Practices for Tags:**
- Use lowercase for consistency
- Keep tags short and specific
- Create a personal tag vocabulary and stick to it
- Use multiple tags per screenshot for better findability

### Categories

Categories help you organize screenshots hierarchically:

- **Authentication**: Login, signup, password reset
- **E-commerce**: Product pages, checkout, cart
- **Dashboards**: Analytics, admin panels, reports
- **Mobile Apps**: iOS, Android, cross-platform

**Best Practices for Categories:**
- Create broad categories for major design types
- Use sub-categories for specific use cases
- Assign 1-3 categories per screenshot
- Be consistent with naming conventions

### Editing Metadata

To edit screenshot metadata:

1. Open the screenshot detail view
2. Click the edit icon (future feature)
3. Update the fields
4. Save changes

---

## Searching and Filtering

### Search Bar

The search bar at the top of the Screenshots view searches through:
- Screenshot titles
- Descriptions
- Associated tags

**Search Tips:**
- Use specific keywords for better results
- Search is case-insensitive
- Partial matches are supported

### Filtering by Tags

1. Click on a tag in any screenshot card
2. The view filters to show only screenshots with that tag
3. Add more tags to refine your search (AND logic)

### Filtering by Categories

Similar to tags, click on a category to filter your view.

### Clearing Filters

Click the "Clear Filters" button to reset and view all screenshots.

---

## MCP Server for AI Agents

The MCP (Model Context Protocol) Server allows AI agents to access your design inspiration data.

### Starting the MCP Server

1. Go to **Settings**
2. Configure the port (default: 8080)
3. Click **Start Server**
4. The server status indicator will turn green

### Generating API Keys

API keys authenticate AI agents connecting to your server:

1. In Settings, click **Generate New API Key**
2. Copy the generated key
3. Provide this key to your AI agent
4. Store it securely (it won't be shown again)

### Managing API Keys

- **View**: All active keys are listed in the Settings page
- **Copy**: Click the clipboard icon to copy a key
- **Delete**: Click the trash icon to revoke a key

**Security Note:** Deleted keys immediately lose access to your server.

### Configuring AI Agents

To connect an AI agent to your MCP server:

1. Ensure the MCP server is running
2. Provide the agent with:
   - Server URL: `http://localhost:8080`
   - API Key: One of your generated keys
3. The agent can now access your design library

See [API_DOCUMENTATION.md](API_DOCUMENTATION.md) for technical details.

### MCP Server Endpoints

Your AI agents can:

- **List screenshots** with filters (tags, categories, dates)
- **Get metadata** for specific screenshots
- **Access design specifications** (colors, layout, components)

---

## Exporting Data

### Export to JSON

Export your entire library or selected screenshots:

1. Click the **Export** button in the toolbar
2. Choose a location to save the JSON file
3. The export includes:
   - All screenshot metadata
   - Design specifications
   - Image file references

### Export Format

The exported JSON file follows a structured schema suitable for:

- Backup and recovery
- Data migration
- Integration with other tools
- Training datasets for ML models

### What's Included

Each exported screenshot contains:
- Complete metadata (title, description, tags, categories)
- Design analysis results (colors, layout, components)
- File references
- Timestamps

---

## Tips and Best Practices

### Building a Quality Library

1. **Be Consistent**: Use consistent naming and tagging conventions
2. **Add Context**: Fill in descriptions to remember why you saved each screenshot
3. **Tag Generously**: More tags = better findability
4. **Regular Maintenance**: Periodically review and clean up your library

### Optimizing for AI Agents

1. **Descriptive Titles**: Help AI understand the design's purpose
2. **Detailed Tags**: Enable AI to find relevant examples quickly
3. **Source URLs**: Provide context about design origins
4. **Diverse Library**: Include varied designs for comprehensive inspiration

### Performance Tips

1. **Image Sizes**: Compress large images before uploading
2. **Batch Uploads**: Upload multiple screenshots at once
3. **Regular Backups**: Export your library periodically
4. **Close Unused Apps**: Free up resources for image analysis

### Workflow Suggestions

**For Individual Designers:**
- Save inspiration as you browse
- Tag by project or client
- Use categories for design patterns
- Export for portfolio documentation

**For Design Teams:**
- Establish shared tagging vocabulary
- Use categories for projects
- Document design systems
- Share exports with team members

**For AI Developers:**
- Curate high-quality examples
- Tag by UI component types
- Include edge cases and variations
- Regularly update design specs

---

## Troubleshooting

### Upload Issues

**Problem**: Image won't upload
- **Solution**: Ensure the file is a supported format (PNG, JPG, SVG, WebP)
- **Solution**: Check file size (very large files may take longer)
- **Solution**: Verify you have disk space available

**Problem**: Upload succeeds but image doesn't appear
- **Solution**: Refresh the view by searching or filtering
- **Solution**: Restart the application

### Search and Filter Issues

**Problem**: Search returns no results
- **Solution**: Check spelling and try different keywords
- **Solution**: Clear filters and search again
- **Solution**: Verify screenshots have the tags/categories you're searching for

**Problem**: Too many results
- **Solution**: Add more specific tags to your filter
- **Solution**: Use the search bar with specific terms
- **Solution**: Filter by date range

### MCP Server Issues

**Problem**: Server won't start
- **Solution**: Check if the port is already in use by another application
- **Solution**: Try a different port in Settings
- **Solution**: Check macOS firewall settings

**Problem**: AI agent can't connect
- **Solution**: Verify the server is running (green indicator)
- **Solution**: Confirm you're using the correct API key
- **Solution**: Check the agent is connecting to the right port
- **Solution**: Ensure the agent is using `http://localhost:PORT`

**Problem**: API key doesn't work
- **Solution**: Generate a new API key
- **Solution**: Ensure you're copying the complete key
- **Solution**: Check for extra spaces when pasting

### Performance Issues

**Problem**: App is slow with many screenshots
- **Solution**: Use search and filters to narrow the view
- **Solution**: Close and reopen the app
- **Solution**: Reduce the number of tags per screenshot

**Problem**: Image analysis takes too long
- **Solution**: Analysis runs in background, you can continue working
- **Solution**: Reduce image file sizes before uploading
- **Solution**: Upload fewer images at once

### Data Issues

**Problem**: Lost screenshots after restart
- **Solution**: Check if database file exists in Application Support folder
- **Solution**: Restore from a previous JSON export
- **Solution**: Check if you have multiple app instances

**Problem**: Export fails
- **Solution**: Ensure you have write permissions for the destination folder
- **Solution**: Try exporting to a different location
- **Solution**: Check available disk space

### Getting Help

If you continue to experience issues:

1. Check the [README.md](README.md) for additional information
2. Review the [API_DOCUMENTATION.md](API_DOCUMENTATION.md) for MCP server details
3. Open an issue on the project's GitHub repository
4. Include:
   - macOS version
   - App version
   - Steps to reproduce the issue
   - Any error messages

---

## Keyboard Shortcuts (Future Feature)

Planned keyboard shortcuts:

- `⌘N`: New upload
- `⌘F`: Focus search
- `⌘,`: Open settings
- `⌘Q`: Quit application
- `⌘R`: Refresh view

---

## Feedback and Feature Requests

We'd love to hear from you! If you have:

- Feature suggestions
- Bug reports
- Usability feedback
- Documentation improvements

Please share them through the project's GitHub repository.

---

**Thank you for using AI Design Inspiration Hub!**

We hope this tool helps you organize your design inspiration and unlock new creative possibilities with AI.