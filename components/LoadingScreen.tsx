
import React, { useState, useEffect } from 'react';
import { LoadingSpinner } from './icons';

interface LoadingScreenProps {
  loadingMessage: string;
}

const steps = [
  "Analyzing your brilliant idea...",
  "Crafting a unique brand identity...",
  "Designing a stunning logo...",
  "Developing a cohesive color palette...",
  "Pairing the perfect typography...",
  "Sketching low-fidelity wireframes...",
  "Building high-fidelity mockups...",
  "Assembling your project presentation...",
  "Putting on the finishing touches...",
];

export const LoadingScreen: React.FC<LoadingScreenProps> = ({ loadingMessage }) => {
  const [currentStepIndex, setCurrentStepIndex] = useState(0);

  useEffect(() => {
    const interval = setInterval(() => {
      setCurrentStepIndex((prevIndex) => (prevIndex + 1) % steps.length);
    }, 3000);
    return () => clearInterval(interval);
  }, []);

  return (
    <div className="flex flex-col items-center justify-center min-h-screen text-white p-4">
      <LoadingSpinner />
      <h2 className="text-2xl font-bold mt-6 mb-2">{loadingMessage}</h2>
      <p className="text-gray-400 text-lg transition-opacity duration-500">
        {steps[currentStepIndex]}
      </p>
    </div>
  );
};
