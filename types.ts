
export interface UserInput {
  appName: string;
  idea: string;
  features: string;
  audience: string;
  style: string;
}

export interface ColorPalette {
  primary: string;
  secondary: string;
  accent: string;
  neutralLight: string;
  neutralDark: string;
  background: string;
  text: string;
}

export interface Typography {
  headingFont: string;
  bodyFont: string;
}

export interface DesignSystem {
  colorPalette: ColorPalette;
  typography: Typography;
}

export interface ScreenMockup {
  name: string;
  lofi: string; // base64 image string
  hifi: string; // base64 image string
}

export interface ProjectData {
  appName: string;
  tagline: string;
  marketingDescription: string;
  logo: string; // base64 image string
  designSystem: DesignSystem;
  screens: ScreenMockup[];
}

export interface ProjectStructure {
  appName: string;
  tagline: string;
  marketingDescription: string;
  screens: string[];
  designSystemPrompt: string;
  logoPrompt: string;
}
