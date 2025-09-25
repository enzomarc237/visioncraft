
import React, { useState, useCallback } from 'react';
import type { UserInput, ProjectData, DesignSystem, ScreenMockup, ProjectStructure } from './types';
import { InputForm } from './components/InputForm';
import { LoadingScreen } from './components/LoadingScreen';
import { ResultsPage } from './components/ResultsPage';
import * as geminiService from './services/geminiService';

function App() {
  const [userInput, setUserInput] = useState<UserInput | null>(null);
  const [projectData, setProjectData] = useState<ProjectData | null>(null);
  const [isLoading, setIsLoading] = useState<boolean>(false);
  const [loadingMessage, setLoadingMessage] = useState<string>('Initializing...');
  const [error, setError] = useState<string | null>(null);
  const [isRegenerating, setIsRegenerating] = useState({ logo: false, designSystem: false, screens: false });

  const handleGenerate = useCallback(async (input: UserInput) => {
    setIsLoading(true);
    setError(null);
    setUserInput(input);
    setProjectData(null);

    try {
      setLoadingMessage('Analyzing your idea...');
      const structure: ProjectStructure = await geminiService.generateProjectStructure(input);

      setLoadingMessage('Crafting brand identity...');
      const [logo, designSystem] = await Promise.all([
        geminiService.generateLogo(structure.logoPrompt),
        geminiService.generateDesignSystem(structure.designSystemPrompt)
      ]);

      setLoadingMessage('Building screen mockups...');
      const screenPromises: Promise<ScreenMockup>[] = structure.screens.map(async (screenName) => {
        const [lofi, hifi] = await Promise.all([
            geminiService.generateScreen(screenName, structure.marketingDescription, input.style, null, true),
            geminiService.generateScreen(screenName, structure.marketingDescription, input.style, designSystem, false)
        ]);
        return { name: screenName, lofi, hifi };
      });
      const screens = await Promise.all(screenPromises);

      setProjectData({
        appName: structure.appName,
        tagline: structure.tagline,
        marketingDescription: structure.marketingDescription,
        logo,
        designSystem,
        screens
      });

    } catch (err) {
      console.error(err);
      setError(err instanceof Error ? err.message : 'An unknown error occurred.');
    } finally {
      setIsLoading(false);
    }
  }, []);
  
  const handleRegenerate = useCallback(async (part: 'logo' | 'designSystem' | 'screens') => {
      if (!projectData || !userInput) return;

      setIsRegenerating(prev => ({ ...prev, [part]: true }));
      setError(null);

      try {
          if (part === 'logo') {
              const structure = await geminiService.generateProjectStructure(userInput);
              const newLogo = await geminiService.generateLogo(structure.logoPrompt);
              setProjectData(prev => prev ? { ...prev, logo: newLogo } : null);
          }
          if (part === 'designSystem') {
              const structure = await geminiService.generateProjectStructure(userInput);
              const newDesignSystem = await geminiService.generateDesignSystem(structure.designSystemPrompt);
              setProjectData(prev => prev ? { ...prev, designSystem: newDesignSystem } : null);
          }
          if (part === 'screens') {
               const screenPromises: Promise<ScreenMockup>[] = projectData.screens.map(async (screen) => {
                const [lofi, hifi] = await Promise.all([
                    geminiService.generateScreen(screen.name, projectData.marketingDescription, userInput.style, null, true),
                    geminiService.generateScreen(screen.name, projectData.marketingDescription, userInput.style, projectData.designSystem, false)
                ]);
                return { name: screen.name, lofi, hifi };
              });
              const newScreens = await Promise.all(screenPromises);
              setProjectData(prev => prev ? { ...prev, screens: newScreens } : null);
          }
      } catch (err) {
          console.error(err);
          setError(err instanceof Error ? `Failed to regenerate ${part}: ${err.message}` : `An unknown error occurred during regeneration.`);
      } finally {
           setIsRegenerating(prev => ({ ...prev, [part]: false }));
      }
  }, [projectData, userInput]);


  const renderContent = () => {
    if (isLoading) {
      return <LoadingScreen loadingMessage={loadingMessage} />;
    }
    if (error) {
      return (
        <div className="flex flex-col items-center justify-center min-h-screen text-white text-center p-4">
          <h2 className="text-2xl text-red-500 font-bold mb-4">Oops! Something went wrong.</h2>
          <p className="text-gray-400 mb-6 max-w-md">{error}</p>
          <button
            onClick={() => {
                setError(null);
                setProjectData(null);
                setUserInput(null);
            }}
            className="px-6 py-2 bg-indigo-600 hover:bg-indigo-700 text-white font-bold rounded-lg transition-colors"
          >
            Try Again
          </button>
        </div>
      );
    }
    if (projectData) {
      return <ResultsPage projectData={projectData} onRegenerate={handleRegenerate} isRegenerating={isRegenerating} />;
    }
    return <InputForm onGenerate={handleGenerate} isLoading={isLoading} />;
  };

  return (
    <div className="bg-gray-900 min-h-screen">
      <main>{renderContent()}</main>
    </div>
  );
}

export default App;
