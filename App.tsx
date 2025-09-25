
import React, { useState, useCallback } from 'react';
import type { UserInput, ProjectData, DesignSystem, ScreenMockup, ProjectStructure } from './types';
import { InputForm } from './components/InputForm';
import { LoadingScreen } from './components/LoadingScreen';
import { ResultsPage } from './components/ResultsPage';
import * as geminiService from './services/geminiService';

interface GenerationState {
    structure?: ProjectStructure;
    designSystem?: DesignSystem;
    logo?: string;
    screens?: ScreenMockup[];
}

function App() {
  const [userInput, setUserInput] = useState<UserInput | null>(null);
  const [projectData, setProjectData] = useState<ProjectData | null>(null);
  const [isLoading, setIsLoading] = useState<boolean>(false);
  const [loadingMessage, setLoadingMessage] = useState<string>('Initializing...');
  const [error, setError] = useState<string | null>(null);
  const [isRegenerating, setIsRegenerating] = useState({ logo: false, designSystem: false, screens: false });
  const [generationState, setGenerationState] = useState<GenerationState>({});

  const runGenerationPipeline = async (input: UserInput, initialState: GenerationState) => {
      setIsLoading(true);
      setError(null);
      let progress = { ...initialState };
      
      try {
          // Step 1: Generate project structure
          if (!progress.structure) {
              setLoadingMessage('Analyzing your idea...');
              const structure = await geminiService.generateProjectStructure(input);
              progress.structure = structure;
              setGenerationState({ ...progress });
          }

          // Step 2: Generate logo and design system
          if (!progress.logo || !progress.designSystem) {
              setLoadingMessage('Crafting brand identity...');
              const promises: Promise<void>[] = [];
              if (!progress.logo) {
                  promises.push(
                      geminiService.generateLogo(progress.structure.logoPrompt).then(logo => {
                          progress.logo = logo;
                      })
                  );
              }
              if (!progress.designSystem) {
                  promises.push(
                      geminiService.generateDesignSystem(progress.structure.designSystemPrompt).then(ds => {
                          progress.designSystem = ds;
                      })
                  );
              }
              await Promise.all(promises);
              setGenerationState({ ...progress });
          }

          // Step 3: Generate screens
          progress.screens = progress.screens || [];
          if (progress.screens.length < progress.structure.screens.length) {
              setLoadingMessage('Building screen mockups...');
              const screensToGenerate = progress.structure.screens.filter(
                  name => !progress.screens.some(s => s.name === name)
              );

              for (const screenName of screensToGenerate) {
                  setLoadingMessage(`Building screen: ${screenName}`);
                  const [lofi, hifi] = await Promise.all([
                      geminiService.generateScreen(screenName, progress.structure.marketingDescription, input.style, null, true),
                      geminiService.generateScreen(screenName, progress.structure.marketingDescription, input.style, progress.designSystem, false)
                  ]);
                  progress.screens.push({ name: screenName, lofi, hifi });
                  setGenerationState({ ...progress });
              }
          }
          
          setProjectData({
              appName: progress.structure.appName,
              tagline: progress.structure.tagline,
              marketingDescription: progress.structure.marketingDescription,
              logo: progress.logo,
              designSystem: progress.designSystem,
              screens: progress.screens,
          });
          setGenerationState({}); // Clear progress on full success

      } catch (err) {
          console.error(err);
          setGenerationState(progress); // Save partial progress
          setError(err instanceof Error ? err.message : 'An unknown error occurred.');
      } finally {
          setIsLoading(false);
      }
  };

  const handleGenerate = async (input: UserInput) => {
    setUserInput(input);
    setProjectData(null);
    setGenerationState({});
    await runGenerationPipeline(input, {});
  };

  const handleContinue = async () => {
      if (!userInput) return;
      await runGenerationPipeline(userInput, generationState);
  };
  
  const handleStartOver = () => {
      setError(null);
      setProjectData(null);
      setUserInput(null);
      setGenerationState({});
  };
  
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
      const canContinue = Object.keys(generationState).length > 0;
      return (
        <div className="flex flex-col items-center justify-center min-h-screen text-white text-center p-4">
          <h2 className="text-2xl text-red-500 font-bold mb-4">Oops! Something went wrong.</h2>
          <p className="text-gray-400 mb-6 max-w-md">{error}</p>
          <div className="flex items-center gap-4">
            <button
              onClick={handleStartOver}
              className="px-6 py-2 bg-gray-600 hover:bg-gray-700 text-white font-bold rounded-lg transition-colors"
            >
              Start Over
            </button>
            {canContinue && (
                <button
                    onClick={handleContinue}
                    className="px-6 py-2 bg-indigo-600 hover:bg-indigo-700 text-white font-bold rounded-lg transition-colors"
                >
                    Continue Generation
                </button>
            )}
          </div>
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
