/**
 * Focus Session Dashboard
 * 
 * @description Pomodoro-style focus session timer optimized for data architecture work
 * @created 2024-12-09
 * @lastUpdated 2024-12-09T17:45:00Z  
 * @version 1.0.0
 * @author Tempo Odeyakana
 * @contributors Dan Brick Brickey
 * @audience Data architects, analysts requiring structured focus time
 * @usage Deep work sessions, architecture planning, complex problem-solving
 * @relatedDocs ../docs/meeting-notes/ (session outcomes)
 * @tags focus-management, productivity, pomodoro, data-architecture
 * @framework React with Tailwind CSS
 * @license MIT
 */

import React, { useState, useEffect } from 'react';
import { Play, Pause, RotateCcw, Clock, CheckCircle, Circle, FileText, Target, Brain, Coffee } from 'lucide-react';

const FocusSessionDashboard = () => {
  const [currentPhase, setCurrentPhase] = useState('prep');
  const [timeRemaining, setTimeRemaining] = useState(0);
  const [isRunning, setIsRunning] = useState(false);
  const [sessionData, setSessionData] = useState({
    date: new Date().toISOString().split('T')[0],
    focusArea: '',
    entryPoint: '',
    progressMade: '',
    currentState: '',
    nextSessionEntry: '',
    insights: '',
    stakeholderNotes: ''
  });

  const phases = {
    prep: { name: 'Preparation', duration: 15 * 60, icon: Coffee, color: 'bg-blue-500' },
    warmup: { name: 'Warm-up', duration: 25 * 60, icon: Circle, color: 'bg-green-500' },
    break1: { name: 'Break', duration: 5 * 60, icon: Coffee, color: 'bg-yellow-500' },
    deep1: { name: 'Deep Work 1', duration: 45 * 60, icon: Brain, color: 'bg-purple-600' },
    break2: { name: 'Break', duration: 5 * 60, icon: Coffee, color: 'bg-yellow-500' },
    deep2: { name: 'Deep Work 2', duration: 45 * 60, icon: Brain, color: 'bg-purple-600' },
    dump: { name: 'Brain Dump', duration: 10 * 60, icon: FileText, color: 'bg-orange-500' }
  };

  const phaseOrder = ['prep', 'warmup', 'break1', 'deep1', 'break2', 'deep2', 'dump'];

  useEffect(() => {
    let interval = null;
    if (isRunning && timeRemaining > 0) {
      interval = setInterval(() => {
        setTimeRemaining(time => time - 1);
      }, 1000);
    } else if (timeRemaining === 0 && isRunning) {
      setIsRunning(false);
      // Auto advance to next phase
      const currentIndex = phaseOrder.indexOf(currentPhase);
      if (currentIndex < phaseOrder.length - 1) {
        const nextPhase = phaseOrder[currentIndex + 1];
        setCurrentPhase(nextPhase);
        setTimeRemaining(phases[nextPhase].duration);
      }
    }
    return () => clearInterval(interval);
  }, [isRunning, timeRemaining, currentPhase]);

  const startPhase = (phase) => {
    setCurrentPhase(phase);
    setTimeRemaining(phases[phase].duration);
    setIsRunning(true);
  };

  const toggleTimer = () => {
    if (timeRemaining === 0) {
      setTimeRemaining(phases[currentPhase].duration);
    }
    setIsRunning(!isRunning);
  };

  const resetTimer = () => {
    setIsRunning(false);
    setTimeRemaining(phases[currentPhase].duration);
  };

  const formatTime = (seconds) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  };

  const currentPhaseData = phases[currentPhase];
  const CurrentIcon = currentPhaseData.icon;

  const completedPhases = phaseOrder.slice(0, phaseOrder.indexOf(currentPhase));
  const upcomingPhases = phaseOrder.slice(phaseOrder.indexOf(currentPhase) + 1);

  return (
    <div className="max-w-6xl mx-auto p-6 bg-gray-50 min-h-screen">
      <div className="bg-white rounded-lg shadow-lg p-6 mb-6">
        <h1 className="text-3xl font-bold text-gray-800 mb-2 flex items-center">
          <Target className="mr-3 text-blue-600" />
          Data Architect Focus Session
        </h1>
        <p className="text-gray-600">Cloud Migration Architecture â€¢ Morning Focus Block</p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Timer Section */}
        <div className="lg:col-span-1">
          <div className="bg-white rounded-lg shadow-lg p-6">
            <div className={`w-32 h-32 rounded-full ${currentPhaseData.color} mx-auto flex items-center justify-center mb-4`}>
              <div className="text-center text-white">
                <CurrentIcon size={32} className="mx-auto mb-2" />
                <div className="text-2xl font-bold">{formatTime(timeRemaining)}</div>
              </div>
            </div>
            
            <h3 className="text-xl font-semibold text-center mb-4">{currentPhaseData.name}</h3>
            
            <div className="flex justify-center space-x-3 mb-6">
              <button
                onClick={toggleTimer}
                className="flex items-center px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
              >
                {isRunning ? <Pause size={20} className="mr-2" /> : <Play size={20} className="mr-2" />}
                {isRunning ? 'Pause' : 'Start'}
              </button>
              <button
                onClick={resetTimer}
                className="flex items-center px-4 py-2 bg-gray-600 text-white rounded-lg hover:bg-gray-700 transition-colors"
              >
                <RotateCcw size={20} className="mr-2" />
                Reset
              </button>
            </div>

            {/* Phase Navigation */}
            <div className="space-y-2">
              <h4 className="font-semibold text-gray-700 mb-3">Session Flow</h4>
              {phaseOrder.map((phaseKey) => {
                const phase = phases[phaseKey];
                const PhaseIcon = phase.icon;
                const isCompleted = completedPhases.includes(phaseKey);
                const isCurrent = phaseKey === currentPhase;
                const isUpcoming = upcomingPhases.includes(phaseKey);
                
                return (
                  <button
                    key={phaseKey}
                    onClick={() => startPhase(phaseKey)}
                    className={`w-full flex items-center p-2 rounded-lg transition-colors ${
                      isCurrent ? `${phase.color} text-white` :
                      isCompleted ? 'bg-green-100 text-green-800' :
                      'bg-gray-100 text-gray-600 hover:bg-gray-200'
                    }`}
                  >
                    {isCompleted ? (
                      <CheckCircle size={16} className="mr-2" />
                    ) : (
                      <PhaseIcon size={16} className="mr-2" />
                    )}
                    <span className="text-sm">{phase.name}</span>
                    <span className="ml-auto text-xs">
                      {Math.floor(phase.duration / 60)}min
                    </span>
                  </button>
                );
              })}
            </div>
          </div>
        </div>

        {/* Session Planning & Notes */}
        <div className="lg:col-span-2">
          <div className="bg-white rounded-lg shadow-lg p-6">
            <h3 className="text-xl font-semibold mb-4 flex items-center">
              <FileText className="mr-2 text-blue-600" />
              Session Planning & Brain Dump
            </h3>
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Today's Focus Area
                  </label>
                  <input
                    type="text"
                    value={sessionData.focusArea}
                    onChange={(e) => setSessionData({...sessionData, focusArea: e.target.value})}
                    placeholder="e.g., Data Lake architecture design"
                    className="w-full p-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Entry Point (First Action)
                  </label>
                  <textarea
                    value={sessionData.entryPoint}
                    onChange={(e) => setSessionData({...sessionData, entryPoint: e.target.value})}
                    placeholder="e.g., Review current data ingestion patterns in existing system"
                    className="w-full p-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500 h-20"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Progress Made
                  </label>
                  <textarea
                    value={sessionData.progressMade}
                    onChange={(e) => setSessionData({...sessionData, progressMade: e.target.value})}
                    placeholder="Document accomplishments during session..."
                    className="w-full p-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500 h-20"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Current State
                  </label>
                  <textarea
                    value={sessionData.currentState}
                    onChange={(e) => setSessionData({...sessionData, currentState: e.target.value})}
                    placeholder="Where things stand now..."
                    className="w-full p-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500 h-20"
                  />
                </div>
              </div>

              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Next Session Entry Point
                  </label>
                  <textarea
                    value={sessionData.nextSessionEntry}
                    onChange={(e) => setSessionData({...sessionData, nextSessionEntry: e.target.value})}
                    placeholder="Exact first action for tomorrow..."
                    className="w-full p-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500 h-20"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Technical Insights & Patterns
                  </label>
                  <textarea
                    value={sessionData.insights}
                    onChange={(e) => setSessionData({...sessionData, insights: e.target.value})}
                    placeholder="Architecture insights, performance considerations, etc..."
                    className="w-full p-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500 h-20"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Stakeholder Notes
                  </label>
                  <textarea
                    value={sessionData.stakeholderNotes}
                    onChange={(e) => setSessionData({...sessionData, stakeholderNotes: e.target.value})}
                    placeholder="Updates to communicate, decisions needed from others..."
                    className="w-full p-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500 h-20"
                  />
                </div>
              </div>
            </div>

            <div className="mt-6 flex space-x-3">
              <button className="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors">
                Save Session Notes
              </button>
              <button className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors">
                Export Session Summary
              </button>
              <button 
                onClick={() => setSessionData({
                  date: new Date().toISOString().split('T')[0],
                  focusArea: '',
                  entryPoint: '',
                  progressMade: '',
                  currentState: '',
                  nextSessionEntry: '',
                  insights: '',
                  stakeholderNotes: ''
                })}
                className="px-4 py-2 bg-gray-600 text-white rounded-lg hover:bg-gray-700 transition-colors"
              >
                Clear for New Session
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* Quick Reference */}
      <div className="mt-6 bg-white rounded-lg shadow-lg p-6">
        <h3 className="text-lg font-semibold mb-3 flex items-center">
          <Clock className="mr-2 text-blue-600" />
          Focus Session Guide
        </h3>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 text-sm">
          <div>
            <h4 className="font-medium text-gray-800 mb-2">Preparation (15 min)</h4>
            <ul className="text-gray-600 space-y-1">
              <li>â€¢ Silence notifications</li>
              <li>â€¢ Gather docs & specs</li>
              <li>â€¢ Review yesterday's notes</li>
              <li>â€¢ Set clear intention</li>
            </ul>
          </div>
          <div>
            <h4 className="font-medium text-gray-800 mb-2">Deep Work Phases</h4>
            <ul className="text-gray-600 space-y-1">
              <li>â€¢ Start with smallest action</li>
              <li>â€¢ Build complexity gradually</li>
              <li>â€¢ Focus on architecture decisions</li>
              <li>â€¢ Document as you go</li>
            </ul>
          </div>
          <div>
            <h4 className="font-medium text-gray-800 mb-2">Brain Dump (10 min)</h4>
            <ul className="text-gray-600 space-y-1">
              <li>â€¢ Capture all progress</li>
              <li>â€¢ Note current state</li>
              <li>â€¢ Plan tomorrow's entry</li>
              <li>â€¢ Record insights</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
};

export default FocusSessionDashboard;