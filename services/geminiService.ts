
import { GoogleGenAI, Type } from "@google/genai";
import type { UserInput, DesignSystem, ProjectStructure, ScreenMockup } from '../types';

const API_KEY = process.env.API_KEY;

if (!API_KEY) {
  throw new Error("API_KEY environment variable is not set");
}

const ai = new GoogleGenAI({ apiKey: API_KEY });

const structureSchema = {
  type: Type.OBJECT,
  properties: {
    appName: { type: Type.STRING, description: "A catchy and relevant name for the app (if the user didn't provide one, create one)." },
    tagline: { type: Type.STRING, description: "A short, compelling slogan for the app." },
    marketingDescription: { type: Type.STRING, description: "A professional, one-paragraph marketing description of the app." },
    screens: {
      type: Type.ARRAY,
      items: { type: Type.STRING },
      description: "An array of 3-4 essential screen names based on the features, e.g., 'Onboarding', 'Home Dashboard', 'Profile', 'Settings'."
    },
    designSystemPrompt: {
      type: Type.STRING,
      description: "A detailed text prompt for another AI to generate a design system. It should incorporate the user's chosen style and the app's context. Mention color theory and font pairing principles."
    },
    logoPrompt: {
      type: Type.STRING,
      description: "A concise, descriptive prompt for an image generation AI to create a simple, modern, vector-style logo for the app. The logo should be abstract and iconic."
    },
  },
  required: ["appName", "tagline", "marketingDescription", "screens", "designSystemPrompt", "logoPrompt"]
};

const designSystemSchema = {
    type: Type.OBJECT,
    properties: {
        colorPalette: {
            type: Type.OBJECT,
            properties: {
                primary: { type: Type.STRING, format: "hex-color" },
                secondary: { type: Type.STRING, format: "hex-color" },
                accent: { type: Type.STRING, format: "hex-color" },
                neutralLight: { type: Type.STRING, format: "hex-color" },
                neutralDark: { type: Type.STRING, format: "hex-color" },
                background: { type: Type.STRING, format: "hex-color" },
                text: { type: Type.STRING, format: "hex-color" }
            },
            required: ["primary", "secondary", "accent", "neutralLight", "neutralDark", "background", "text"]
        },
        typography: {
            type: Type.OBJECT,
            properties: {
                headingFont: { type: Type.STRING, description: "Name of a Google Font for headings" },
                bodyFont: { type: Type.STRING, description: "Name of a Google Font for body text" }
            },
            required: ["headingFont", "bodyFont"]
        }
    },
    required: ["colorPalette", "typography"]
};

export async function generateProjectStructure(userInput: UserInput): Promise<ProjectStructure> {
  const prompt = `
    You are an expert product strategist and UI/UX designer. Based on the user's input, generate a structured JSON object to kickstart a project presentation.

    User Input:
    - App Name: ${userInput.appName || "Not provided"}
    - Idea: ${userInput.idea}
    - Features: ${userInput.features}
    - Target Audience: ${userInput.audience}
    - Style: ${userInput.style}

    Generate a JSON object conforming to the provided schema.
  `;

  const response = await ai.models.generateContent({
    model: 'gemini-2.5-flash',
    contents: prompt,
    config: {
        responseMimeType: "application/json",
        responseSchema: structureSchema,
    }
  });

  return JSON.parse(response.text);
}


export async function generateDesignSystem(prompt: string): Promise<DesignSystem> {
  const fullPrompt = `
    You are a world-class brand designer. Based on the following prompt, generate a design system as a JSON object that conforms to the schema.

    Prompt: ${prompt}
  `;
  const response = await ai.models.generateContent({
    model: 'gemini-2.5-flash',
    contents: fullPrompt,
    config: {
        responseMimeType: "application/json",
        responseSchema: designSystemSchema,
    }
  });

  return JSON.parse(response.text);
}

async function generateImage(prompt: string): Promise<string> {
    const response = await ai.models.generateImages({
        model: 'imagen-4.0-generate-001',
        prompt: prompt,
        config: {
          numberOfImages: 1,
          outputMimeType: 'image/png',
          aspectRatio: '1:1',
        },
    });

    if (!response.generatedImages || response.generatedImages.length === 0 || !response.generatedImages[0].image?.imageBytes) {
        throw new Error("Image generation failed. The API did not return an image. This could be due to safety settings, rate limits, or other API issues.");
    }
    
    return response.generatedImages[0].image.imageBytes;
}

export async function generateLogo(prompt: string): Promise<string> {
    return generateImage(prompt);
}

export async function generateScreen(
    screenName: string, 
    appDescription: string, 
    style: string, 
    designSystem: DesignSystem | null,
    isLoFi: boolean
): Promise<string> {
    let prompt;

    if (isLoFi) {
        prompt = `Generate a simple, black and white, low-fidelity wireframe for a mobile app screen.
        - Screen to design: "${screenName}"
        - App Context: "${appDescription}"
        - Instructions: The wireframe should only use basic shapes (rectangles, circles), lines, and placeholder text (e.g., 'Lorem Ipsum'). The goal is to show layout and structure, not visual design. The image should be clean and clear. Use a white background and black/grey lines.`;
    } else if (designSystem) {
        prompt = `Generate a single, high-fidelity, visually stunning UI mockup for a mobile app screen.
        - App Context: "${appDescription}"
        - Screen to design: "${screenName}"
        - Aesthetic Style: ${style}, professional, modern, clean, Behance-worthy.
        - Design System:
          - Primary Color: ${designSystem.colorPalette.primary}
          - Secondary Color: ${designSystem.colorPalette.secondary}
          - Accent Color: ${designSystem.colorPalette.accent}
          - Background: ${designSystem.colorPalette.background}
          - Text: ${designSystem.colorPalette.text}
          - Heading Font: ${designSystem.typography.headingFont}
          - Body Font: ${designSystem.typography.bodyFont}
        - Instructions: Do not include any device frames, just the UI itself. The design should be complete, with placeholder text and relevant icons. Output aspect ratio must be 9:16.`;
    } else {
        throw new Error("Design system is required for high-fidelity mockups.");
    }
    
    const response = await ai.models.generateImages({
      model: 'imagen-4.0-generate-001',
      prompt: prompt,
      config: {
        numberOfImages: 1,
        outputMimeType: 'image/png',
        aspectRatio: isLoFi ? '1:1' : '9:16',
      },
    });

    if (!response.generatedImages || response.generatedImages.length === 0 || !response.generatedImages[0].image?.imageBytes) {
        throw new Error(`Screen generation for "${screenName}" failed. The API did not return an image. This could be due to safety settings, rate limits, or other API issues.`);
    }

    return response.generatedImages[0].image.imageBytes;
}
