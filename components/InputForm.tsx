
import React, { useState } from 'react';
import type { UserInput } from '../types';
import { STYLE_OPTIONS } from '../constants';
import { WandIcon } from './icons';

interface InputFormProps {
  onGenerate: (userInput: UserInput) => void;
  isLoading: boolean;
}

export const InputForm: React.FC<InputFormProps> = ({ onGenerate, isLoading }) => {
  const [userInput, setUserInput] = useState<UserInput>({
    appName: '',
    idea: '',
    features: '',
    audience: '',
    style: STYLE_OPTIONS[0],
  });

  const handleChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>
  ) => {
    const { name, value } = e.target;
    setUserInput((prev) => ({ ...prev, [name]: value }));
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (userInput.idea && userInput.features) {
      onGenerate(userInput);
    } else {
      alert('Please fill in the idea and key features.');
    }
  };

  const inputClass = "w-full p-3 bg-gray-700/50 border border-gray-600 rounded-lg text-gray-200 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-indigo-500 transition-all";
  const labelClass = "block mb-2 text-sm font-medium text-gray-300";

  return (
    <div className="max-w-3xl mx-auto p-4 md:p-8">
      <div className="text-center mb-8">
        <div className="inline-flex items-center justify-center h-16 w-16 bg-indigo-600/20 text-indigo-400 rounded-full mb-4 ring-8 ring-indigo-500/10">
            <WandIcon />
        </div>
        <h1 className="text-4xl md:text-5xl font-bold text-white mb-2">VisionCraft</h1>
        <p className="text-lg text-gray-400">Transform your app idea into a visual masterpiece.</p>
      </div>

      <form onSubmit={handleSubmit} className="space-y-6">
        <div>
          <label htmlFor="idea" className={labelClass}>
            Your Idea <span className="text-red-500">*</span>
          </label>
          <textarea
            id="idea"
            name="idea"
            value={userInput.idea}
            onChange={handleChange}
            placeholder="e.g., A mobile app to help city dwellers find and book shared garden plots."
            className={`${inputClass} min-h-[100px]`}
            required
          />
        </div>

        <div>
          <label htmlFor="features" className={labelClass}>
            Key Features <span className="text-red-500">*</span>
          </label>
          <textarea
            id="features"
            name="features"
            value={userInput.features}
            onChange={handleChange}
            placeholder="1. Interactive map of gardens&#10;2. Booking system&#10;3. User profiles&#10;4. Messaging between gardeners"
            className={`${inputClass} min-h-[100px]`}
            required
          />
        </div>

        <div className="grid md:grid-cols-2 gap-6">
          <div>
            <label htmlFor="appName" className={labelClass}>App Name (Optional)</label>
            <input
              type="text"
              id="appName"
              name="appName"
              value={userInput.appName}
              onChange={handleChange}
              placeholder="e.g., UrbanBloom"
              className={inputClass}
            />
          </div>
          <div>
            <label htmlFor="audience" className={labelClass}>Target Audience</label>
            <input
              type="text"
              id="audience"
              name="audience"
              value={userInput.audience}
              onChange={handleChange}
              placeholder="e.g., Young professionals, families"
              className={inputClass}
            />
          </div>
        </div>
        
        <div>
          <label htmlFor="style" className={labelClass}>Style / Ambiance</label>
          <select
            id="style"
            name="style"
            value={userInput.style}
            onChange={handleChange}
            className={inputClass}
          >
            {STYLE_OPTIONS.map((style) => (
              <option key={style} value={style}>{style}</option>
            ))}
          </select>
        </div>

        <div className="pt-4">
          <button
            type="submit"
            className="w-full bg-indigo-600 hover:bg-indigo-700 disabled:bg-indigo-900 disabled:text-gray-400 disabled:cursor-not-allowed text-white font-bold py-4 px-4 rounded-lg text-lg transition-all duration-300 shadow-lg shadow-indigo-600/30 flex items-center justify-center"
            disabled={isLoading}
          >
            {isLoading ? 'Crafting your vision...' : 'Generate Project'}
          </button>
        </div>
      </form>
    </div>
  );
};
