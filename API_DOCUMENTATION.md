# AI Design Inspiration Hub - MCP Server API Documentation

## Overview

The AI Design Inspiration Hub MCP (Model Context Protocol) Server provides a RESTful API for AI agents to access design inspiration data. All endpoints require authentication via API key.

## Base URL

```
http://localhost:8080
```

(Port can be configured in the application settings)

## Authentication

All API requests (except `/health`) must include an `Authorization` header with a valid API key:

```
Authorization: Bearer YOUR_API_KEY
```

API keys can be generated in the application's Settings page.

### Authentication Errors

**403 Forbidden** - Invalid or missing API key
```json
{
  "error": {
    "code": 403,
    "message": "Invalid API key"
  }
}
```

## Endpoints

### Health Check

**GET** `/health`

Check if the MCP server is running.

**Authentication:** Not required

**Response:**
```json
{
  "status": "healthy",
  "service": "AI Design Inspiration Hub MCP Server"
}
```

---

### List Screenshots

**POST** `/mcp/list-screenshots`

Retrieve a paginated and filterable list of screenshots.

**Authentication:** Required

**Request Body:**
```json
{
  "filter": {
    "tags": ["string"],              // Optional: Filter by tags (AND logic)
    "categories": ["string"],        // Optional: Filter by categories (OR logic)
    "component_types": ["string"],   // Optional: Filter by UI component types
    "date_from": "ISO8601",          // Optional: Filter by creation date (from)
    "date_to": "ISO8601",            // Optional: Filter by creation date (to)
    "title_query": "string"          // Optional: Search in title and description
  },
  "pagination": {
    "limit": 20,                     // Optional: Max 100, Default: 20
    "offset": 0                      // Optional: Default: 0
  }
}
```

**Example Request:**
```json
{
  "filter": {
    "tags": ["mobile", "login"],
    "categories": ["Authentication"],
    "title_query": "modern",
    "date_from": "2024-01-01T00:00:00Z",
    "date_to": "2024-12-31T23:59:59Z"
  },
  "pagination": {
    "limit": 10,
    "offset": 0
  }
}
```

**Response:**
```json
{
  "screenshots": [
    {
      "id": "uuid",
      "title": "Modern Login Screen",
      "description": "A minimalist login interface",
      "image_path": "/path/to/image.png",
      "creation_date": "2024-06-15T14:00:00Z",
      "tags": ["mobile", "login", "minimalist"],
      "categories": ["Authentication", "Mobile Apps"]
    }
  ],
  "total_count": 42
}
```

**Error Responses:**

- **400 Bad Request** - Invalid request parameters
- **500 Internal Server Error** - Server error

---

### Get Screenshot Metadata

**POST** `/mcp/get-screenshot-metadata`

Retrieve detailed metadata for a specific screenshot.

**Authentication:** Required

**Request Body:**
```json
{
  "screenshot_id": "uuid"  // Required
}
```

**Response:**
```json
{
  "id": "uuid",
  "title": "Dashboard UI Concept",
  "description": "A clean dashboard design with data visualizations",
  "image_path": "/path/to/image.png",
  "creation_date": "2024-06-15T14:00:00Z",
  "source_url": "https://dribbble.com/shots/...",
  "upload_timestamp": "2024-06-16T09:00:00Z",
  "tags": ["dashboard", "analytics", "charts"],
  "categories": ["Dashboards", "Data Visualization"],
  "has_design_specs": true
}
```

**Error Responses:**

- **400 Bad Request** - Missing `screenshot_id` parameter
- **404 Not Found** - Screenshot not found
- **500 Internal Server Error** - Server error

---

### Get Design Specifications

**POST** `/mcp/get-design-specifications`

Retrieve detailed, AI-parsable design specifications for a screenshot.

**Authentication:** Required

**Request Body:**
```json
{
  "screenshot_id": "uuid"  // Required
}
```

**Response:**
```json
{
  "id": "uuid",
  "screenshot_id": "uuid",
  "layout_structure": {
    "type": "grid",
    "description": "3-column grid layout with fixed sidebar",
    "properties": {
      "columns": 3,
      "aspect_ratio": 1.77,
      "width": 1920,
      "height": 1080
    }
  },
  "ui_components": [
    {
      "type": "button",
      "label": "Sign In",
      "bounding_box": {
        "x": 100,
        "y": 200,
        "width": 150,
        "height": 40
      },
      "properties": {
        "background_color": "#007AFF",
        "text_color": "#FFFFFF",
        "border_radius": "4px"
      }
    },
    {
      "type": "text_input",
      "label": "Email",
      "bounding_box": {
        "x": 50,
        "y": 150,
        "width": 300,
        "height": 40
      },
      "properties": {
        "placeholder": "Enter your email",
        "input_type": "email"
      }
    }
  ],
  "color_palette": [
    {
      "hex": "#FFFFFF",
      "role": "background",
      "usage_context": "main_background",
      "proportion": 0.65
    },
    {
      "hex": "#007AFF",
      "role": "primary",
      "usage_context": "buttons_links",
      "proportion": 0.15
    },
    {
      "hex": "#333333",
      "role": "text",
      "usage_context": "body_text",
      "proportion": 0.12
    }
  ],
  "typography": [
    {
      "font_family": "San Francisco",
      "font_size_px": 16,
      "font_weight": 400,
      "font_style": "normal",
      "line_height_ratio": 1.5,
      "color_hex": "#333333",
      "sample_text": "Welcome back",
      "context": "body_text"
    },
    {
      "font_family": "San Francisco",
      "font_size_px": 28,
      "font_weight": 700,
      "font_style": "normal",
      "line_height_ratio": 1.2,
      "color_hex": "#000000",
      "context": "heading_1"
    }
  ],
  "general_design_info": {
    "image_dimensions": {
      "width": 1920,
      "height": 1080
    },
    "perceived_style": ["minimalist", "modern"],
    "spacing_unit": "8px"
  },
  "analysis_timestamp": "2024-06-16T09:05:00Z",
  "analysis_engine_version": "0.1.0"
}
```

**Error Responses:**

- **400 Bad Request** - Missing `screenshot_id` parameter
- **404 Not Found** - Design specifications not found
- **500 Internal Server Error** - Server error

---

## Data Types

### Layout Structure
```typescript
{
  type: string;                    // e.g., "grid", "flexbox", "horizontal", "vertical"
  description?: string;            // Human-readable description
  properties?: {                   // Additional layout properties
    [key: string]: any;
  };
}
```

### UI Component
```typescript
{
  type: string;                    // e.g., "button", "text_input", "image", "card"
  label?: string;                  // Component label or text
  bounding_box?: {                 // Position in the image
    x: number;
    y: number;
    width: number;
    height: number;
  };
  properties?: {                   // Component-specific properties
    [key: string]: any;
  };
}
```

### Color Info
```typescript
{
  hex: string;                     // e.g., "#FFFFFF"
  role?: string;                   // e.g., "primary", "secondary", "background"
  usage_context?: string;          // e.g., "button_background", "text_color"
  proportion?: number;             // 0.0 to 1.0
}
```

### Typography Style
```typescript
{
  font_family?: string;            // e.g., "Roboto", "San Francisco"
  font_size_px?: number;
  font_weight?: string | number;   // e.g., "bold", 400, 700
  font_style?: string;             // e.g., "normal", "italic"
  line_height_ratio?: number;
  color_hex?: string;              // e.g., "#000000"
  sample_text?: string;
  context?: string;                // e.g., "heading_1", "body_text"
}
```

---

## Rate Limiting

Currently, there are no rate limits on the MCP server. This may be added in future versions.

## Versioning

Current API version: **1.0**

API version may be included in future releases via a version path segment (e.g., `/v1/mcp/list-screenshots`).

## Best Practices

1. **Pagination**: Always use pagination when listing screenshots to avoid large response payloads
2. **Filtering**: Use specific filters to narrow down results and improve performance
3. **Caching**: Consider caching design specifications on the client side as they don't change frequently
4. **Error Handling**: Always check for error responses and handle them appropriately
5. **API Keys**: Keep API keys secure and rotate them periodically

## Example Integration (Python)

```python
import requests

BASE_URL = "http://localhost:8080"
API_KEY = "your-api-key-here"

headers = {
    "Authorization": f"Bearer {API_KEY}",
    "Content-Type": "application/json"
}

# List screenshots with filter
response = requests.post(
    f"{BASE_URL}/mcp/list-screenshots",
    headers=headers,
    json={
        "filter": {
            "tags": ["mobile", "login"]
        },
        "pagination": {
            "limit": 10
        }
    }
)

screenshots = response.json()["screenshots"]

# Get design specs for first screenshot
if screenshots:
    screenshot_id = screenshots[0]["id"]
    specs_response = requests.post(
        f"{BASE_URL}/mcp/get-design-specifications",
        headers=headers,
        json={"screenshot_id": screenshot_id}
    )
    
    design_specs = specs_response.json()
    print(f"Color palette: {design_specs['color_palette']}")
```

## Support

For issues or questions about the API, please refer to the main documentation or open an issue on the project repository.