import React, { useEffect, useState } from 'react';
import type { ProjectData, ColorPalette, Typography, ScreenMockup } from '../types';
import { RefreshIcon, DownloadIcon, ShareIcon, LoadingSpinner, FileTextIcon } from './icons';
import JSZip from 'jszip';
import jsPDF from 'jspdf';
import html2canvas from 'html2canvas';

interface ResultsPageProps {
  projectData: ProjectData;
  onRegenerate: (part: 'logo' | 'designSystem' | 'screens') => void;
  isRegenerating: { logo: boolean; designSystem: boolean; screens: boolean; };
}

const Section: React.FC<{title: string, children: React.ReactNode, onRegenerate?: () => void, isRegenerating?: boolean}> = ({ title, children, onRegenerate, isRegenerating }) => (
    <section className="mb-16">
        <div className="flex justify-between items-center mb-6">
            <h2 className="text-3xl font-bold text-white">{title}</h2>
            {onRegenerate && (
                <button 
                    onClick={onRegenerate}
                    disabled={isRegenerating}
                    className="flex items-center gap-2 px-4 py-2 bg-gray-700/50 hover:bg-gray-700/80 disabled:opacity-50 disabled:cursor-not-allowed text-gray-300 rounded-lg transition-colors"
                >
                    {isRegenerating ? <div className="animate-spin"><RefreshIcon className="h-4 w-4" /></div> : <RefreshIcon className="h-4 w-4" />}
                    Regenerate
                </button>
            )}
        </div>
        {children}
    </section>
);

const ColorPaletteDisplay: React.FC<{ palette: ColorPalette }> = ({ palette }) => (
    <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-7 gap-4">
        {Object.entries(palette).map(([name, hex]) => (
            <div key={name}>
                <div className="w-full h-24 rounded-lg shadow-lg mb-2" style={{ backgroundColor: hex }}></div>
                <p className="text-sm text-gray-300 capitalize">{name}</p>
                <p className="text-xs text-gray-500 font-mono">{hex}</p>
            </div>
        ))}
    </div>
);

const TypographyDisplay: React.FC<{ typography: Typography }> = ({ typography }) => (
    <div className="space-y-6">
        <div>
            <p className="text-sm text-gray-400 mb-2">Heading Font: <span className="font-medium text-gray-200">{typography.headingFont}</span></p>
            <p style={{ fontFamily: `'${typography.headingFont}', sans-serif` }} className="text-5xl text-white">Aa Bb Cc Dd Ee</p>
        </div>
        <div>
            <p className="text-sm text-gray-400 mb-2">Body Font: <span className="font-medium text-gray-200">{typography.bodyFont}</span></p>
            <p style={{ fontFamily: `'${typography.bodyFont}', sans-serif` }} className="text-lg text-gray-300">The quick brown fox jumps over the lazy dog.</p>
        </div>
    </div>
);

const ScreenMockups: React.FC<{ screens: ScreenMockup[] }> = ({ screens }) => {
    const [view, setView] = useState<'hifi' | 'lofi'>('hifi');

    return (
        <div>
            <div className="flex justify-center mb-6">
                <div className="bg-gray-800 p-1 rounded-lg flex space-x-1">
                    <button onClick={() => setView('hifi')} className={`px-4 py-1.5 text-sm font-medium rounded-md transition-colors ${view === 'hifi' ? 'bg-indigo-600 text-white' : 'text-gray-300 hover:bg-gray-700'}`}>High-Fidelity</button>
                    <button onClick={() => setView('lofi')} className={`px-4 py-1.5 text-sm font-medium rounded-md transition-colors ${view === 'lofi' ? 'bg-indigo-600 text-white' : 'text-gray-300 hover:bg-gray-700'}`}>Low-Fidelity</button>
                </div>
            </div>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
                {screens.map(screen => (
                    <div key={screen.name} className="text-center">
                        <div className={`p-2 rounded-xl bg-gray-800 shadow-2xl transition-all duration-300 ${view === 'hifi' ? 'opacity-100 scale-100' : 'opacity-0 scale-95 h-0 overflow-hidden'}`}>
                            <img src={`data:image/png;base64,${screen.hifi}`} alt={`${screen.name} High-Fidelity Mockup`} className="w-full rounded-lg" />
                        </div>
                         <div className={`p-2 rounded-xl bg-gray-800 shadow-2xl transition-all duration-300 ${view === 'lofi' ? 'opacity-100 scale-100' : 'opacity-0 scale-95 h-0 overflow-hidden'}`}>
                            <img src={`data:image/png;base64,${screen.lofi}`} alt={`${screen.name} Low-Fidelity Wireframe`} className="w-full rounded-lg" />
                        </div>
                        <p className="mt-4 text-lg font-medium text-gray-300">{screen.name}</p>
                    </div>
                ))}
            </div>
        </div>
    );
};

export const ResultsPage: React.FC<ResultsPageProps> = ({ projectData, onRegenerate, isRegenerating }) => {
    
    useEffect(() => {
        const headingFont = projectData.designSystem.typography.headingFont;
        const bodyFont = projectData.designSystem.typography.bodyFont;
        if(headingFont && bodyFont){
            const link = document.createElement('link');
            link.href = `https://fonts.googleapis.com/css2?family=${headingFont.replace(/ /g, '+')}:wght@700&family=${bodyFont.replace(/ /g, '+')}:wght@400&display=swap`;
            link.rel = 'stylesheet';
            document.head.appendChild(link);
        }
    }, [projectData.designSystem.typography]);
    
    const [editedData, setEditedData] = useState({
        tagline: projectData.tagline,
        description: projectData.marketingDescription,
    });

    const [isDownloading, setIsDownloading] = useState(false);
    const [isGeneratingPdf, setIsGeneratingPdf] = useState(false);
    
    const handleTextChange = (field: 'tagline' | 'description', value: string) => {
        setEditedData(prev => ({...prev, [field]: value}));
    };

    const handleDownload = async () => {
        setIsDownloading(true);
        try {
            const zip = new JSZip();

            const projectInfo = `App Name: ${projectData.appName}\nTagline: ${editedData.tagline}\n\nDescription:\n${editedData.description}`;
            zip.file("project_info.txt", projectInfo);
            zip.file("design_system.json", JSON.stringify(projectData.designSystem, null, 2));
            zip.file("logo.png", projectData.logo, { base64: true });

            const screensFolder = zip.folder("screens");
            const hifiFolder = screensFolder.folder("hifi");
            const lofiFolder = screensFolder.folder("lofi");

            for (const screen of projectData.screens) {
                const screenName = screen.name.replace(/\s/g, '_');
                hifiFolder.file(`${screenName}_hifi.png`, screen.hifi, { base64: true });
                lofiFolder.file(`${screenName}_lofi.png`, screen.lofi, { base64: true });
            }
            
            const content = await zip.generateAsync({ type: "blob" });
            const link = document.createElement("a");
            link.href = URL.createObjectURL(content);
            link.download = `${projectData.appName.replace(/\s/g, '_')}_assets.zip`;
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
            URL.revokeObjectURL(link.href);

        } catch (error) {
            console.error("Failed to create zip file:", error);
            alert("An error occurred while preparing your download.");
        } finally {
            setIsDownloading(false);
        }
    };

    const handleDownloadPdf = async () => {
        setIsGeneratingPdf(true);
        const pdfContent = document.getElementById('pdf-content');
        if (!pdfContent) {
            console.error('PDF content element not found');
            setIsGeneratingPdf(false);
            return;
        }

        try {
            const canvas = await html2canvas(pdfContent, {
                scale: 2,
                useCORS: true,
                backgroundColor: '#111827',
            });
            
            const imgData = canvas.toDataURL('image/png');
            const pdf = new jsPDF({
                orientation: 'p',
                unit: 'mm',
                format: 'a4',
            });

            const pdfWidth = pdf.internal.pageSize.getWidth();
            const pdfHeight = pdf.internal.pageSize.getHeight();
            
            const canvasWidth = canvas.width;
            const canvasHeight = canvas.height;
            
            const ratio = canvasWidth / pdfWidth;
            const scaledCanvasHeight = canvasHeight / ratio;

            let heightLeft = scaledCanvasHeight;
            let position = 0;

            pdf.addImage(imgData, 'PNG', 0, position, pdfWidth, scaledCanvasHeight);
            heightLeft -= pdfHeight;

            while (heightLeft > 0) {
                position -= pdfHeight;
                pdf.addPage();
                pdf.addImage(imgData, 'PNG', 0, position, pdfWidth, scaledCanvasHeight);
                heightLeft -= pdfHeight;
            }
            
            pdf.save(`${projectData.appName.replace(/\s/g, '_')}_presentation.pdf`);

        } catch (error) {
            console.error("Failed to generate PDF:", error);
            alert("An error occurred while generating the PDF.");
        } finally {
            setIsGeneratingPdf(false);
        }
    };

    const accentColor = projectData.designSystem.colorPalette.accent;

    return (
        <div className="bg-gray-900 min-h-screen">
            <style>
                {`:root { --accent-color: ${accentColor}; }`}
            </style>
            
            <div className="sticky top-0 z-20 py-4 bg-gray-900/80 backdrop-blur-sm flex justify-end gap-2 max-w-7xl mx-auto px-4 md:px-8">
                <button onClick={() => alert("Share functionality coming soon!")} className="flex items-center gap-2 px-4 py-2 bg-gray-700 hover:bg-gray-600 text-white rounded-lg transition-colors"><ShareIcon/> Share</button>
                <button
                    onClick={handleDownloadPdf}
                    disabled={isGeneratingPdf || isDownloading}
                    className="flex items-center justify-center gap-2 px-4 py-2 w-[190px] bg-teal-600 hover:bg-teal-700 disabled:bg-teal-900 disabled:cursor-wait text-white rounded-lg transition-colors"
                >
                    {isGeneratingPdf ? <><LoadingSpinner /> Creating PDF...</> : <><FileTextIcon/> Download PDF</>}
                </button>
                <button 
                    onClick={handleDownload}
                    disabled={isDownloading || isGeneratingPdf}
                    className="flex items-center justify-center gap-2 px-4 py-2 w-[190px] bg-indigo-600 hover:bg-indigo-700 disabled:bg-indigo-900 disabled:cursor-wait text-white rounded-lg transition-colors"
                >
                    {isDownloading ? <><LoadingSpinner /> Zipping Assets...</> : <><DownloadIcon/> Download Assets</>}
                </button>
            </div>
            
            <div id="pdf-content">
                <header className="py-20 text-center relative overflow-hidden">
                    <div className="absolute inset-0 bg-gray-900" style={{ backgroundImage: `radial-gradient(${accentColor} 0.5px, transparent 0.5px), radial-gradient(transparent 0.5px, transparent 0.5px)`, backgroundSize: '20px 20px', opacity: 0.1 }}></div>
                    <div className="relative z-10 max-w-4xl mx-auto px-4">
                        <div className="flex justify-center items-center mb-6">
                            <img src={`data:image/png;base64,${projectData.logo}`} alt="App Logo" className="h-24 w-24 rounded-3xl shadow-lg" />
                            <button 
                                onClick={() => onRegenerate('logo')}
                                disabled={isRegenerating.logo}
                                className="ml-4 p-2 bg-gray-800/50 hover:bg-gray-800/80 disabled:opacity-50 rounded-full transition-colors"
                            >
                                {isRegenerating.logo ? <div className="animate-spin"><RefreshIcon /></div> : <RefreshIcon />}
                            </button>
                        </div>
                        <h1 className="text-6xl font-extrabold text-white mb-4" style={{ fontFamily: `'${projectData.designSystem.typography.headingFont}', sans-serif` }}>
                            {projectData.appName}
                        </h1>
                        <input 
                            type="text"
                            value={editedData.tagline}
                            onChange={(e) => handleTextChange('tagline', e.target.value)}
                            className="text-xl text-gray-300 bg-transparent text-center w-full focus:outline-none focus:ring-2 focus:ring-accent-color rounded-md"
                            style={{ color: accentColor }}
                        />
                    </div>
                </header>

                <main className="max-w-7xl mx-auto p-4 md:p-8">
                    <Section title="About The Project">
                        <textarea
                            value={editedData.description}
                            onChange={(e) => handleTextChange('description', e.target.value)}
                            className="w-full text-lg text-gray-300 leading-relaxed bg-transparent focus:outline-none focus:ring-2 focus:ring-accent-color rounded-md p-2 min-h-[100px]"
                            style={{ fontFamily: `'${projectData.designSystem.typography.bodyFont}', sans-serif` }}
                        />
                    </Section>
                    
                    <Section title="Design System" onRegenerate={() => onRegenerate('designSystem')} isRegenerating={isRegenerating.designSystem}>
                        <div className="bg-gray-800/50 p-6 rounded-xl space-y-8">
                            <div>
                                <h3 className="text-xl font-semibold text-white mb-4">Color Palette</h3>
                                <ColorPaletteDisplay palette={projectData.designSystem.colorPalette} />
                            </div>
                            <div className="border-t border-gray-700 my-8"></div>
                            <div>
                                <h3 className="text-xl font-semibold text-white mb-4">Typography</h3>
                                <TypographyDisplay typography={projectData.designSystem.typography} />
                            </div>
                        </div>
                    </Section>

                    <Section title="App Screens" onRegenerate={() => onRegenerate('screens')} isRegenerating={isRegenerating.screens}>
                        <ScreenMockups screens={projectData.screens} />
                    </Section>
                </main>

                <footer className="text-center py-8 text-gray-500">
                    <p>Generated by VisionCraft AI</p>
                </footer>
            </div>
        </div>
    );
};