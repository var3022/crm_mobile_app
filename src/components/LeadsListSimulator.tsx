import React, { useState } from 'react';
import {
  Search,
  Plus,
  MapPin,
  Flag,
  ArrowRight,
  Phone,
  Calendar,
  ChevronDown,
  CheckCircle2,
  X,
  Building2,
  User,
  Home,
  Folder,
  Route,
  ListTodo,
  Camera,
  RotateCcw,
  Sparkles,
  ChevronLeft,
  Mic,
  History,
  Clock,
  XCircle,
  CornerDownLeft,
  ArrowUp,
  Delete
} from 'lucide-react';

export interface LeadItem {
  id: string;
  companyName: string;
  contactName: string;
  contactRole: string;
  distanceKm: number;
  locationArea: string;
  lastActive: string;
  aiScore: number;
  stage: 'New' | 'Contacted' | 'Qualified' | 'Proposal' | 'Won' | 'Lost' | 'Follow-up Due';
  temperature: 'Hot' | 'Warm' | 'Cold' | 'Follow-up Due';
  isNearby?: boolean;
  isFollowUpDue?: boolean;
  isFlagged: boolean;
  phoneNumber: string;
  email: string;
  hasSwipeActionTip?: boolean;
}

export type LeadFilter = 'All' | 'New' | 'Contacted' | 'Qualified' | 'Hot' | 'Follow-up Due' | 'Nearby';

interface LeadsListSimulatorProps {
  onNavigateToDashboard?: () => void;
  onNavigateToNotifications?: () => void;
}

export const LeadsListSimulator: React.FC<LeadsListSimulatorProps> = ({
  onNavigateToDashboard,
  onNavigateToNotifications,
}) => {
  const [selectedFilter, setSelectedFilter] = useState<LeadFilter>('All');
  const [selectedSort, setSelectedSort] = useState<'AI Score' | 'Distance' | 'Company Name'>('AI Score');
  const [isSearchOpen, setIsSearchOpen] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const [recentSearches, setRecentSearches] = useState<string[]>([
    'Technology Solutions',
    'Lower Parel',
    'Pending visits',
  ]);
  const [showKeyboard, setShowKeyboard] = useState(true);
  const [isShiftActive, setIsShiftActive] = useState(false);
  const [searchScope, setSearchScope] = useState<'All' | 'Company' | 'Contact' | 'Location' | 'Hot' | 'High Score'>('All');
  const [isVoiceListening, setIsVoiceListening] = useState(false);
  const [activeNavIndex, setActiveNavIndex] = useState(1); // 1 = Leads

  // Modals & Feedback
  const [showAddModal, setShowAddModal] = useState(false);
  const [showScanModal, setShowScanModal] = useState(false);
  const [showSortModal, setShowSortModal] = useState(false);
  const [selectedLeadForDetail, setSelectedLeadForDetail] = useState<LeadItem | null>(null);
  const [toastMessage, setToastMessage] = useState<string | null>(null);

  // New Lead Form State
  const [newCompany, setNewCompany] = useState('');
  const [newContact, setNewContact] = useState('');
  const [newRole, setNewRole] = useState('');
  const [newArea, setNewArea] = useState('');

  // Primary leads database matching image.png and field sales CRM
  const [leads, setLeads] = useState<LeadItem[]>([
    {
      id: 'lead-1',
      companyName: 'Acme Corp',
      contactName: 'John Doe',
      contactRole: 'CTO',
      distanceKm: 0.8,
      locationArea: 'Nariman Point',
      lastActive: '2 hours ago',
      aiScore: 85,
      stage: 'Qualified',
      temperature: 'Hot',
      isNearby: true,
      isFlagged: true,
      phoneNumber: '+91 98201 12345',
      email: 'john.doe@acmecorp.com',
      hasSwipeActionTip: true,
    },
    {
      id: 'lead-2',
      companyName: 'Acme Industries',
      contactName: 'Vijay Patil',
      contactRole: 'Procurement',
      distanceKm: 3.4,
      locationArea: 'Worli',
      lastActive: '4 hours ago',
      aiScore: 62,
      stage: 'Contacted',
      temperature: 'Warm',
      isNearby: false,
      isFlagged: false,
      phoneNumber: '+91 98202 88765',
      email: 'vijay.patil@acmeindustries.com',
      hasSwipeActionTip: false,
    },
    {
      id: 'lead-3',
      companyName: 'Technology Solutions',
      contactName: 'Rajiv Sen',
      contactRole: 'Head of IT',
      distanceKm: 1.5,
      locationArea: 'Lower Parel',
      lastActive: '1 day ago',
      aiScore: 78,
      stage: 'Qualified',
      temperature: 'Warm',
      isNearby: false,
      isFlagged: false,
      phoneNumber: '+91 98203 11223',
      email: 'rajiv@techsolutions.com',
      hasSwipeActionTip: false,
    },
    {
      id: 'lead-4',
      companyName: 'TechVista Ltd',
      contactName: 'Priya Sharma',
      contactRole: 'HR',
      distanceKm: 1.2,
      locationArea: 'Lower Parel',
      lastActive: 'Yesterday',
      aiScore: 76,
      stage: 'Contacted',
      temperature: 'Warm',
      isFollowUpDue: true,
      isFlagged: false,
      phoneNumber: '+91 98192 98765',
      email: 'priya.sharma@techvista.io',
      hasSwipeActionTip: false,
    },
    {
      id: 'lead-5',
      companyName: 'DataFlow Systems',
      contactName: 'Karan Malhotra',
      contactRole: 'MD',
      distanceKm: 2.5,
      locationArea: 'Andheri East',
      lastActive: '3 days ago',
      aiScore: 45,
      stage: 'New',
      temperature: 'Follow-up Due',
      isFollowUpDue: true,
      isFlagged: false,
      phoneNumber: '+91 98205 55678',
      email: 'karan@dataflow.co.in',
      hasSwipeActionTip: false,
    },
    {
      id: 'lead-6',
      companyName: 'Apex Logistics',
      contactName: 'Vikram Mehta',
      contactRole: 'VP Sales',
      distanceKm: 1.8,
      locationArea: 'BKC',
      lastActive: '5 hours ago',
      aiScore: 88,
      stage: 'Qualified',
      temperature: 'Hot',
      isFlagged: false,
      phoneNumber: '+91 98334 23456',
      email: 'vikram.m@apexlogistics.com',
      hasSwipeActionTip: false,
    },
    {
      id: 'lead-7',
      companyName: 'Nova Pharmaceuticals',
      contactName: 'Dr. Rajesh Iyer',
      contactRole: 'Director',
      distanceKm: 0.6,
      locationArea: 'Worli',
      lastActive: 'Just now',
      aiScore: 92,
      stage: 'New',
      temperature: 'Hot',
      isNearby: true,
      isFlagged: true,
      phoneNumber: '+91 98401 88990',
      email: 'rajesh.iyer@novapharma.org',
      hasSwipeActionTip: false,
    },
  ]);

  const triggerToast = (msg: string) => {
    setToastMessage(msg);
    setTimeout(() => {
      setToastMessage(null);
    }, 2600);
  };

  const handleToggleFlag = (id: string, e?: React.MouseEvent) => {
    e?.stopPropagation();
    setLeads((prev) =>
      prev.map((lead) => {
        if (lead.id === id) {
          const updated = !lead.isFlagged;
          triggerToast(updated ? `Flagged ${lead.companyName}` : `Unflagged ${lead.companyName}`);
          return { ...lead, isFlagged: updated };
        }
        return lead;
      })
    );
  };

  const handleCall = (lead: LeadItem, e?: React.MouseEvent) => {
    e?.stopPropagation();
    triggerToast(`Calling ${lead.contactName} (${lead.phoneNumber})...`);
  };

  const handleLogVisit = (lead: LeadItem, e?: React.MouseEvent) => {
    e?.stopPropagation();
    triggerToast(`Logged in-person visit for ${lead.companyName}!`);
  };

  const handleCreateLead = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newCompany.trim()) return;

    const newLead: LeadItem = {
      id: `lead-${Date.now()}`,
      companyName: newCompany.trim(),
      contactName: newContact.trim() || 'Contact Person',
      contactRole: newRole.trim() || 'Decision Maker',
      distanceKm: 1.4,
      locationArea: newArea.trim() || 'Mumbai Central',
      lastActive: 'Just now',
      aiScore: 84,
      stage: 'New',
      temperature: 'Warm',
      isFlagged: false,
      phoneNumber: '+91 98000 12345',
      email: `contact@${newCompany.toLowerCase().replace(/\\s+/g, '')}.com`,
      hasSwipeActionTip: false,
    };

    setLeads((prev) => [newLead, ...prev]);
    setNewCompany('');
    setNewContact('');
    setNewRole('');
    setNewArea('');
    setShowAddModal(false);
    triggerToast(`Added ${newLead.companyName} to your leads`);
  };

  // Filtered and sorted leads
  const filteredLeads = leads
    .filter((lead) => {
      // Filter chip condition
      if (selectedFilter === 'New') return lead.stage === 'New';
      if (selectedFilter === 'Contacted') return lead.stage === 'Contacted';
      if (selectedFilter === 'Qualified') return lead.stage === 'Qualified';
      if (selectedFilter === 'Hot') return lead.temperature === 'Hot';
      if (selectedFilter === 'Follow-up Due') {
        return lead.isFollowUpDue || lead.temperature === 'Follow-up Due' || lead.stage === 'Follow-up Due';
      }
      if (selectedFilter === 'Nearby') {
        return lead.isNearby || lead.distanceKm <= 1.0;
      }
      return true;
    })
    .filter((lead) => {
      // Search filter condition
      if (!searchQuery.trim()) return true;
      const q = searchQuery.toLowerCase();
      return (
        lead.companyName.toLowerCase().includes(q) ||
        lead.contactName.toLowerCase().includes(q) ||
        lead.locationArea.toLowerCase().includes(q)
      );
    })
    .sort((a, b) => {
      if (selectedSort === 'AI Score') return b.aiScore - a.aiScore;
      if (selectedSort === 'Distance') return a.distanceKm - b.distanceKm;
      if (selectedSort === 'Company Name') return a.companyName.localeCompare(b.companyName);
      return 0;
    });

  // Search results calculation based on searchQuery and searchScope
  const searchResults = leads
    .filter((lead) => {
      if (!searchQuery.trim()) return true;
      const q = searchQuery.toLowerCase().trim();

      if (searchScope === 'Company') {
        return lead.companyName.toLowerCase().includes(q);
      }
      if (searchScope === 'Contact') {
        return (
          lead.contactName.toLowerCase().includes(q) ||
          lead.contactRole.toLowerCase().includes(q)
        );
      }
      if (searchScope === 'Location') {
        return lead.locationArea.toLowerCase().includes(q);
      }
      if (searchScope === 'Hot') {
        return (
          lead.temperature === 'Hot' &&
          (lead.companyName.toLowerCase().includes(q) ||
            lead.contactName.toLowerCase().includes(q) ||
            lead.locationArea.toLowerCase().includes(q))
        );
      }
      if (searchScope === 'High Score') {
        return (
          lead.aiScore >= 80 &&
          (lead.companyName.toLowerCase().includes(q) ||
            lead.contactName.toLowerCase().includes(q) ||
            lead.locationArea.toLowerCase().includes(q))
        );
      }

      // Default: All fields
      return (
        lead.companyName.toLowerCase().includes(q) ||
        lead.contactName.toLowerCase().includes(q) ||
        lead.contactRole.toLowerCase().includes(q) ||
        lead.locationArea.toLowerCase().includes(q) ||
        lead.phoneNumber.toLowerCase().includes(q) ||
        lead.email.toLowerCase().includes(q) ||
        lead.stage.toLowerCase().includes(q)
      );
    })
    .sort((a, b) => b.aiScore - a.aiScore);

  // Helper to highlight matching substrings in search results
  const highlightMatch = (text: string, query: string) => {
    if (!query.trim()) return text;
    const escaped = query.trim().replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    const testRegex = new RegExp(`(${escaped})`, 'i');
    const parts = text.split(new RegExp(`(${escaped})`, 'gi'));
    return (
      <span>
        {parts.map((part, i) =>
          testRegex.test(part) ? (
            <span key={i} className="font-extrabold text-[#111827]">
              {part}
            </span>
          ) : (
            <span key={i} className="font-normal text-[#111827]">
              {part}
            </span>
          )
        )}
      </span>
    );
  };

  // Voice Search simulation handler
  const handleVoiceSearch = () => {
    if (isVoiceListening) return;
    setIsVoiceListening(true);
    triggerToast('🎤 Listening... Speak lead or company');
    setTimeout(() => {
      const candidates = ['Acme Corp', 'TechVista Ltd', 'South Mumbai', 'John Doe', 'BKC'];
      const chosen = candidates[Math.floor(Math.random() * candidates.length)];
      setSearchQuery(chosen);
      setIsVoiceListening(false);
      setRecentSearches((prev) => Array.from(new Set([chosen, ...prev])).slice(0, 6));
      triggerToast(`Voice recognized: "${chosen}"`);
    }, 1100);
  };

  // Calculate dynamic count of New leads for badge
  const newLeadsCount = leads.filter((lead) => lead.stage === 'New').length;

  // Score styling helper
  const getScoreBadgeStyles = (score: number) => {
    if (score >= 80) {
      return {
        bg: 'bg-[#D1FADF]/65',
        border: 'border-[#10B981]',
        text: 'text-[#10B981]',
      };
    } else if (score >= 60) {
      return {
        bg: 'bg-[#FEF3C7]/65',
        border: 'border-[#F59E0B]',
        text: 'text-[#D97706]',
      };
    } else {
      return {
        bg: 'bg-[#FEE2E2]/65',
        border: 'border-[#EF4444]',
        text: 'text-[#DC2626]',
      };
    }
  };

  // Status pill styling helper
  const getStatusPill = (lead: LeadItem) => {
    if (lead.temperature === 'Hot') {
      return (
        <span className="bg-[#D1FADF] text-[#059669] text-[11.5px] font-bold px-2.5 py-0.5 rounded-lg flex items-center space-x-1">
          <span>Hot 🔥</span>
        </span>
      );
    } else if (lead.isFollowUpDue || lead.temperature === 'Follow-up Due' || lead.stage === 'Follow-up Due') {
      return (
        <span className="bg-[#FEF3C7] text-[#D97706] text-[11.5px] font-bold px-2.5 py-0.5 rounded-lg flex items-center space-x-1">
          <span>Follow-up Due</span>
        </span>
      );
    } else if (lead.isNearby && lead.distanceKm <= 0.8) {
      return (
        <span className="bg-[#E0F2FE] text-[#0284C7] text-[11.5px] font-bold px-2.5 py-0.5 rounded-lg flex items-center space-x-1">
          <span>Nearby 📍</span>
        </span>
      );
    } else if (lead.stage === 'Contacted') {
      return (
        <span className="bg-[#DBEAFE] text-[#2563EB] text-[11.5px] font-bold px-2.5 py-0.5 rounded-lg">
          Contacted
        </span>
      );
    } else if (lead.stage === 'Qualified') {
      return (
        <span className="bg-[#E0E7FF] text-[#4F46E5] text-[11.5px] font-bold px-2.5 py-0.5 rounded-lg">
          Qualified
        </span>
      );
    } else {
      return (
        <span className="bg-[#F3F4F6] text-[#4B5563] text-[11.5px] font-bold px-2.5 py-0.5 rounded-lg">
          {lead.stage}
        </span>
      );
    }
  };

  return (
    <div className="flex-1 flex flex-col bg-white relative select-none h-full overflow-hidden font-['Inter',sans-serif]">
      {/* Toast Notification */}
      {toastMessage && (
        <div className="absolute top-4 left-4 right-4 z-50 bg-[#0F4C4C] text-white px-3.5 py-2.5 rounded-xl shadow-lg flex items-center justify-between text-xs animate-in fade-in slide-in-from-top-2 duration-200">
          <div className="flex items-center space-x-2">
            <CheckCircle2 className="w-4 h-4 text-[#34D399] shrink-0" />
            <span className="font-medium">{toastMessage}</span>
          </div>
          <button
            onClick={() => setToastMessage(null)}
            className="text-white/70 hover:text-white text-xs font-bold px-1"
          >
            ✕
          </button>
        </div>
      )}

      {/* Conditional: Search Mode (image.png screenshots 1 & 2) OR Normal Leads View */}
      {isSearchOpen ? (
        /* Dedicated Full Search Mode Interface */
        <div className="flex-1 flex flex-col h-full overflow-hidden bg-white">
          {/* 1. Top Search Header Bar matching image.png */}
          <div className="px-4 pt-3 pb-2.5 flex items-center space-x-2.5 bg-white shrink-0">
            <div className="flex-1 relative flex items-center">
              <Search className="w-5 h-5 text-[#0F4C4C] absolute left-3.5 pointer-events-none stroke-[2]" />
              <input
                type="text"
                autoFocus
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                onKeyDown={(e) => {
                  if (e.key === 'Enter' && searchQuery.trim()) {
                    setRecentSearches((prev) =>
                      Array.from(new Set([searchQuery.trim(), ...prev])).slice(0, 6)
                    );
                  }
                }}
                placeholder=""
                className="w-full pl-11 pr-10 py-2.5 bg-white border-2 border-[#0F4C4C] rounded-2xl text-[15px] font-medium text-[#111827] focus:outline-none"
              />
              {searchQuery ? (
                <button
                  onClick={() => setSearchQuery('')}
                  className="absolute right-3 p-0.5 text-gray-400 hover:text-gray-600 cursor-pointer"
                  title="Clear search"
                >
                  <XCircle className="w-5 h-5 fill-[#9CA3AF] text-white hover:fill-[#6B7280] transition-colors" />
                </button>
              ) : null}
            </div>
            <button
              onClick={() => {
                setIsSearchOpen(false);
                setSearchQuery('');
              }}
              className="text-[15px] font-semibold text-[#111827] hover:text-[#4B5563] cursor-pointer px-1 py-1 shrink-0"
            >
              Cancel
            </button>
          </div>

          {/* 2. Main Search Content */}
          {searchQuery.trim() !== '' && searchResults.length === 0 ? (
            /* SCREEN 2: NO RESULTS FOUND (Centered empty state matching right screenshot) */
            <div className="flex-1 flex flex-col items-center justify-center px-6 py-8 text-center animate-in fade-in duration-200">
              <div className="w-28 h-28 rounded-full bg-[#F3F4F6] flex items-center justify-center mb-6 shrink-0">
                <Search className="w-12 h-12 text-[#9CA3AF] stroke-[1.5]" />
              </div>

              <h2 className="text-[22px] font-extrabold text-[#111827] mb-2 tracking-tight">
                No Results Found
              </h2>

              <p className="text-sm text-[#6B7280] max-w-[280px] leading-relaxed mb-7">
                We couldn't find anything matching your search.
                <br />
                Try adjusting your keywords or filters.
              </p>

              <div className="flex items-center space-x-3">
                <button
                  onClick={() => {
                    setSearchQuery('');
                    setSelectedFilter('All');
                  }}
                  className="px-6 py-2.5 bg-[#CCFBF1] text-[#0F4C4C] hover:bg-[#99F6E4] rounded-full text-sm font-bold transition-colors cursor-pointer"
                >
                  Clear Filters
                </button>
                <button
                  onClick={() => {
                    setSearchQuery('');
                    setSelectedFilter('All');
                    setIsSearchOpen(false);
                  }}
                  className="px-6 py-2.5 bg-[#0F4C4C] text-white hover:bg-[#0c3c3c] rounded-full text-sm font-bold transition-colors cursor-pointer shadow-xs"
                >
                  Browse All Leads
                </button>
              </div>
            </div>
          ) : (
            /* SCREEN 1: RECENT SEARCHES + SEARCH RESULTS (Scrollable) */
            <div className="flex-1 overflow-y-auto px-4 py-2 space-y-4 no-scrollbar">
              {/* RECENT SEARCHES */}
              {recentSearches.length > 0 && (
                <div>
                  <div className="text-xs font-bold text-[#6B7280] tracking-wider uppercase mb-2 px-1">
                    Recent Searches
                  </div>
                  <div className="space-y-1">
                    {recentSearches.map((term, index) => (
                      <div
                        key={index}
                        className="flex items-center justify-between text-sm py-1.5 px-1 hover:bg-gray-50 rounded-lg group"
                      >
                        <button
                          onClick={() => {
                            setSearchQuery(term);
                          }}
                          className="flex items-center space-x-3 text-[#4B5563] hover:text-[#111827] flex-1 text-left cursor-pointer"
                        >
                          <Clock className="w-4 h-4 text-[#9CA3AF] shrink-0" />
                          <span className="font-medium text-[14px]">{term}</span>
                        </button>
                        <button
                          onClick={(e) => {
                            e.stopPropagation();
                            setRecentSearches((prev) => prev.filter((_, i) => i !== index));
                          }}
                          className="p-1 text-[#9CA3AF] hover:text-[#4B5563] cursor-pointer"
                          title="Remove"
                        >
                          <XCircle className="w-4 h-4" />
                        </button>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {/* SEARCH RESULTS */}
              {searchQuery.trim() !== '' && (
                <div>
                  <div className="text-xs font-bold text-[#6B7280] tracking-wider uppercase mb-2.5 px-1">
                    Search Results ({searchResults.length})
                  </div>
                  <div className="space-y-2.5">
                    {searchResults.map((lead) => (
                      <div
                        key={lead.id}
                        onClick={() => setSelectedLeadForDetail(lead)}
                        className="bg-white border border-[#E5E7EB] rounded-2xl p-3.5 shadow-xs flex items-center space-x-3.5 hover:border-[#0F4C4C]/40 transition-all cursor-pointer active:scale-[0.99]"
                      >
                        {/* Score Circle */}
                        <div
                          className={`w-12 h-12 rounded-full border-2 flex items-center justify-center font-extrabold text-base shrink-0 ${
                            lead.aiScore >= 80
                              ? 'border-[#10B981] text-[#10B981]'
                              : lead.aiScore >= 60
                              ? 'border-[#F59E0B] text-[#F59E0B]'
                              : 'border-[#EF4444] text-[#EF4444]'
                          }`}
                        >
                          {lead.aiScore}
                        </div>

                        {/* Lead Details */}
                        <div className="flex-1 min-w-0">
                          <div className="flex items-center justify-between">
                            <h4 className="text-[15px] font-medium text-[#111827] truncate">
                              {highlightMatch(lead.companyName, searchQuery)}
                            </h4>
                            <span
                              className={`text-[11px] font-semibold px-2.5 py-0.5 rounded-md shrink-0 ml-2 ${
                                lead.stage === 'Qualified'
                                  ? 'bg-[#CCFBF1] text-[#0F766E]'
                                  : lead.stage === 'Contacted'
                                  ? 'bg-[#DBEAFE] text-[#2563EB]'
                                  : lead.stage === 'New'
                                  ? 'bg-[#FEF3C7] text-[#D97706]'
                                  : 'bg-gray-100 text-gray-700'
                              }`}
                            >
                              {lead.stage}
                            </span>
                          </div>
                          <div className="text-xs text-[#4B5563] mt-0.5 truncate">
                            {highlightMatch(lead.contactName, searchQuery)} · {lead.contactRole}
                          </div>
                          <div className="flex items-center text-xs text-[#6B7280] mt-1 space-x-1">
                            <MapPin className="w-3.5 h-3.5 text-[#9CA3AF] shrink-0" />
                            <span className="truncate">
                              {lead.distanceKm} km · {highlightMatch(lead.locationArea, searchQuery)}
                            </span>
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              )}
            </div>
          )}

          {/* 3. Bottom Simulated Mobile Keyboard (Matches Screen 1 in image.png) */}
          {!(searchQuery.trim() !== '' && searchResults.length === 0) && showKeyboard && (
            <div className="bg-[#D1D5DB]/60 pt-2 pb-3 px-1 shrink-0 border-t border-gray-300 animate-in slide-in-from-bottom duration-150">
              {/* Keyboard row 1 */}
              <div className="flex justify-center gap-1.5 mb-1.5">
                {['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'].map((key) => (
                  <button
                    key={key}
                    onClick={() => {
                      setSearchQuery((prev) => prev + (isShiftActive ? key : key.toLowerCase()));
                    }}
                    className="flex-1 max-w-[34px] h-10 bg-white rounded-md shadow-xs text-sm font-semibold text-[#111827] flex items-center justify-center active:bg-gray-200 transition-colors cursor-pointer"
                  >
                    {isShiftActive ? key : key.toLowerCase()}
                  </button>
                ))}
              </div>

              {/* Keyboard row 2 */}
              <div className="flex justify-center gap-1.5 px-3 mb-1.5">
                {['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'].map((key) => (
                  <button
                    key={key}
                    onClick={() => {
                      setSearchQuery((prev) => prev + (isShiftActive ? key : key.toLowerCase()));
                    }}
                    className="flex-1 max-w-[34px] h-10 bg-white rounded-md shadow-xs text-sm font-semibold text-[#111827] flex items-center justify-center active:bg-gray-200 transition-colors cursor-pointer"
                  >
                    {isShiftActive ? key : key.toLowerCase()}
                  </button>
                ))}
              </div>

              {/* Keyboard row 3 */}
              <div className="flex justify-center gap-1.5 mb-1.5">
                {/* Shift key */}
                <button
                  onClick={() => setIsShiftActive(!isShiftActive)}
                  className={`w-10 h-10 rounded-md shadow-xs flex items-center justify-center active:bg-gray-400 transition-colors cursor-pointer ${
                    isShiftActive ? 'bg-[#0F4C4C] text-white' : 'bg-[#9CA3AF]/60 text-[#111827]'
                  }`}
                  title="Shift"
                >
                  <ArrowUp className="w-4 h-4 stroke-[2.5]" />
                </button>

                {['Z', 'X', 'C', 'V', 'B', 'N', 'M'].map((key) => (
                  <button
                    key={key}
                    onClick={() => {
                      setSearchQuery((prev) => prev + (isShiftActive ? key : key.toLowerCase()));
                    }}
                    className="flex-1 max-w-[34px] h-10 bg-white rounded-md shadow-xs text-sm font-semibold text-[#111827] flex items-center justify-center active:bg-gray-200 transition-colors cursor-pointer"
                  >
                    {isShiftActive ? key : key.toLowerCase()}
                  </button>
                ))}

                {/* Backspace key */}
                <button
                  onClick={() => setSearchQuery((prev) => prev.slice(0, -1))}
                  className="w-10 h-10 bg-[#9CA3AF]/60 text-[#111827] rounded-md shadow-xs flex items-center justify-center active:bg-gray-400 transition-colors cursor-pointer"
                  title="Backspace"
                >
                  <Delete className="w-4 h-4 stroke-[2]" />
                </button>
              </div>

              {/* Spacebar row */}
              <div className="flex justify-center px-12 pt-0.5">
                <button
                  onClick={() => setSearchQuery((prev) => prev + ' ')}
                  className="w-full h-9 bg-white rounded-md shadow-xs text-xs font-semibold text-gray-400 flex items-center justify-center active:bg-gray-200 transition-colors cursor-pointer"
                >
                  space
                </button>
              </div>
            </div>
          )}
        </div>
      ) : (
        <>
          {/* 1. Header: Title "Leads" + Circular Search & Add Action Buttons */}
          <div className="px-5 pt-4 pb-2 flex items-center justify-between bg-white shrink-0">
            <h1 className="text-[30px] font-black text-[#111827] tracking-tight leading-none">
              Leads
            </h1>
            <div className="flex items-center space-x-2">
              {/* Quick toggle to test 0 leads empty state vs demo leads */}
              <button
                onClick={() => {
                  if (leads.length > 0) {
                    setLeads([]);
                    triggerToast('Empty State (0 leads) activated');
                  } else {
                    setLeads([
                      {
                        id: 'lead-1',
                        companyName: 'Acme Corp',
                        contactName: 'John Doe',
                        contactRole: 'CTO',
                        distanceKm: 0.8,
                        locationArea: 'Nariman Point',
                        lastActive: '2 hours ago',
                        aiScore: 85,
                        stage: 'Qualified',
                        temperature: 'Hot',
                        isNearby: true,
                        isFlagged: true,
                        phoneNumber: '+91 98201 12345',
                        email: 'john.doe@acmecorp.com',
                        hasSwipeActionTip: true,
                      },
                      {
                        id: 'lead-2',
                        companyName: 'Acme Industries',
                        contactName: 'Vijay Patil',
                        contactRole: 'Procurement',
                        distanceKm: 3.4,
                        locationArea: 'Worli',
                        lastActive: 'Yesterday',
                        aiScore: 62,
                        stage: 'Contacted',
                        temperature: 'Warm',
                        isFollowUpDue: true,
                        isFlagged: false,
                        phoneNumber: '+91 98192 98765',
                        email: 'vijay.patil@acmeind.com',
                        hasSwipeActionTip: false,
                      },
                      {
                        id: 'lead-3',
                        companyName: 'Technology Solutions',
                        contactName: 'Rajiv Sen',
                        contactRole: 'Head of IT',
                        distanceKm: 1.5,
                        locationArea: 'Lower Parel',
                        lastActive: '1 day ago',
                        aiScore: 78,
                        stage: 'Qualified',
                        temperature: 'Warm',
                        isFlagged: false,
                        phoneNumber: '+91 98205 77890',
                        email: 'rajiv.sen@techsolutions.com',
                        hasSwipeActionTip: false,
                      },
                      {
                        id: 'lead-4',
                        companyName: 'DataFlow Systems',
                        contactName: 'Karan Malhotra',
                        contactRole: 'MD',
                        distanceKm: 2.5,
                        locationArea: 'Andheri East',
                        lastActive: '3 days ago',
                        aiScore: 45,
                        stage: 'New',
                        temperature: 'Follow-up Due',
                        isFollowUpDue: true,
                        isFlagged: false,
                        phoneNumber: '+91 98205 55678',
                        email: 'karan@dataflow.co.in',
                        hasSwipeActionTip: false,
                      },
                      {
                        id: 'lead-5',
                        companyName: 'Apex Logistics',
                        contactName: 'Vikram Mehta',
                        contactRole: 'VP Sales',
                        distanceKm: 1.8,
                        locationArea: 'BKC',
                        lastActive: '5 hours ago',
                        aiScore: 88,
                        stage: 'Qualified',
                        temperature: 'Hot',
                        isFlagged: false,
                        phoneNumber: '+91 98334 23456',
                        email: 'vikram.m@apexlogistics.com',
                        hasSwipeActionTip: false,
                      },
                      {
                        id: 'lead-6',
                        companyName: 'Nova Pharmaceuticals',
                        contactName: 'Dr. Rajesh Iyer',
                        contactRole: 'Purchase Director',
                        distanceKm: 0.9,
                        locationArea: 'Worli',
                        lastActive: 'Just now',
                        aiScore: 91,
                        stage: 'New',
                        temperature: 'Hot',
                        isNearby: true,
                        isFlagged: true,
                        phoneNumber: '+91 98401 88990',
                        email: 'rajesh.iyer@novapharma.org',
                        hasSwipeActionTip: false,
                      },
                    ]);
                    triggerToast('Demo leads restored');
                  }
                }}
                className="px-2.5 py-1 rounded-full bg-[#E8F7F7] text-[#0F4C4C] hover:bg-[#d6f0f0] text-[11px] font-bold flex items-center space-x-1 cursor-pointer transition-colors"
                title={leads.length > 0 ? "Switch to 0 Leads Empty State" : "Restore Demo Leads"}
              >
                {leads.length > 0 ? (
                  <span>Simulate 0 Leads</span>
                ) : (
                  <>
                    <RotateCcw className="w-3 h-3" />
                    <span>Restore Leads</span>
                  </>
                )}
              </button>

              {/* Circular Search Button */}
              <button
                onClick={() => {
                  setIsSearchOpen(true);
                }}
                className={`w-9 h-9 rounded-full border flex items-center justify-center transition-colors cursor-pointer shadow-xs ${
                  isSearchOpen
                    ? 'bg-[#E8F7F7] border-[#0F4C4C] text-[#0F4C4C]'
                    : 'bg-white border-[#E5E7EB] text-[#111827] hover:bg-gray-50'
                }`}
                title="Search Leads"
              >
                <Search className="w-4 h-4" />
              </button>

              {/* Circular Add (+) Button */}
              <button
                onClick={() => setShowAddModal(true)}
                className="w-9 h-9 rounded-full bg-[#0F4C4C] hover:bg-[#0c3c3c] text-white flex items-center justify-center transition-transform active:scale-95 cursor-pointer shadow-xs"
                title="Add New Lead"
              >
                <Plus className="w-4.5 h-4.5 stroke-[2.5]" />
              </button>
            </div>
          </div>

          {/* 2. Horizontal Filter Chips Carousel */}
      <div className="py-2 shrink-0">
        <div className="flex items-center space-x-2 px-5 overflow-x-auto no-scrollbar">
          {[
            { key: 'All', label: 'All', count: leads.length },
            { key: 'New', label: 'New', count: leads.filter((l) => l.stage === 'New').length },
            { key: 'Contacted', label: 'Contacted', count: leads.filter((l) => l.stage === 'Contacted').length },
            { key: 'Qualified', label: 'Qualified', count: leads.filter((l) => l.stage === 'Qualified').length },
            { key: 'Hot', label: 'Hot 🔥', count: leads.filter((l) => l.temperature === 'Hot').length },
            {
              key: 'Follow-up Due',
              label: 'Follow-up Due',
              count: leads.filter(
                (l) => l.isFollowUpDue || l.temperature === 'Follow-up Due' || l.stage === 'Follow-up Due'
              ).length,
            },
            {
              key: 'Nearby',
              label: 'Nearby 📍',
              count: leads.filter((l) => l.isNearby || l.distanceKm <= 1.0).length,
            },
          ].map((chip) => {
            const isSelected = selectedFilter === chip.key;
            return (
              <button
                key={chip.key}
                onClick={() => setSelectedFilter(chip.key as LeadFilter)}
                className={`px-3.5 py-1.5 rounded-full text-xs font-semibold whitespace-nowrap transition-all cursor-pointer flex items-center space-x-1.5 ${
                  isSelected
                    ? 'bg-[#0F4C4C] text-white font-bold shadow-xs'
                    : 'bg-[#E8F7F7] text-[#0F4C4C] hover:bg-[#d6f0f0]'
                }`}
              >
                <span>{chip.label}</span>
                <span
                  className={`text-[10.5px] font-bold rounded-full min-w-[18px] h-[18px] px-1.5 flex items-center justify-center leading-none ${
                    isSelected ? 'bg-black/20 text-white' : 'bg-white text-[#0F4C4C]'
                  }`}
                >
                  {chip.count}
                </span>
              </button>
            );
          })}
        </div>
      </div>

      {/* 3. Main Content: Empty State (Matching image.png) OR Populated Leads List */}
      {leads.length === 0 ? (
        <div className="flex-1 flex flex-col items-center justify-center text-center px-6 py-6 overflow-y-auto no-scrollbar">
          {/* Pale mint circular container with clipboard checklist */}
          <div className="w-[124px] h-[124px] rounded-full bg-[#E8F7F7] flex items-center justify-center mb-6 shrink-0">
            <svg width="46" height="50" viewBox="0 0 46 50" fill="none" xmlns="http://www.w3.org/2000/svg">
              {/* Clipboard Body */}
              <rect x="6" y="8" width="34" height="38" rx="6" stroke="#0F4C4C" strokeWidth="2.5" />
              {/* Top Clip Arch */}
              <path d="M16 8V5C16 3.89543 16.8954 3 18 3H28C29.1046 3 30 3.89543 30 5V8" stroke="#0F4C4C" strokeWidth="2.5" strokeLinecap="round" />
              {/* Checklist items: 3 bullet points & lines */}
              <circle cx="14" cy="18" r="2.2" fill="#0F4C4C" />
              <line x1="19" y1="18" x2="33" y2="18" stroke="#0F4C4C" strokeWidth="2.5" strokeLinecap="round" />
              <circle cx="14" cy="27" r="2.2" fill="#0F4C4C" />
              <line x1="19" y1="27" x2="33" y2="27" stroke="#0F4C4C" strokeWidth="2.5" strokeLinecap="round" />
              <circle cx="14" cy="36" r="2.2" fill="#0F4C4C" />
              <line x1="19" y1="36" x2="33" y2="36" stroke="#0F4C4C" strokeWidth="2.5" strokeLinecap="round" />
            </svg>
          </div>

          {/* Heading */}
          <h2 className="text-[22px] font-extrabold text-[#111827] tracking-tight mb-2.5">
            No Leads Yet
          </h2>

          {/* Subtitle */}
          <p className="text-sm leading-relaxed text-[#4B5563] max-w-[310px] mb-8">
            Your assigned leads will appear here. You can also add leads manually or scan visiting cards.
          </p>

          {/* Action Buttons */}
          <div className="w-full max-w-[340px] space-y-3">
            <button
              onClick={() => setShowAddModal(true)}
              className="w-full py-3.5 bg-[#0F4C4C] hover:bg-[#0c3c3c] text-white rounded-2xl font-bold text-[15px] flex items-center justify-center space-x-2 transition-all shadow-xs cursor-pointer active:scale-98"
            >
              <Plus className="w-5 h-5 stroke-[2.5]" />
              <span>Add New Lead</span>
            </button>

            <button
              onClick={() => setShowScanModal(true)}
              className="w-full py-3.5 border-2 border-[#0F4C4C] text-[#0F4C4C] hover:bg-[#E8F7F7]/50 rounded-2xl font-bold text-[15px] flex items-center justify-center space-x-2 transition-all cursor-pointer active:scale-98 bg-transparent"
            >
              <Camera className="w-5 h-5 stroke-[2]" />
              <span>Scan Visiting Card</span>
            </button>
          </div>
        </div>
      ) : (
        <>
          {/* 3. Sub-header: Count on Left & Sort by on Right */}
          <div className="px-5 py-2 flex items-center justify-between text-xs shrink-0">
            <span className="text-[#6B7280]">
              Showing {filteredLeads.length} leads
            </span>
            <button
              onClick={() => setShowSortModal(true)}
              className="font-bold text-[#0F4C4C] flex items-center space-x-1 cursor-pointer hover:underline"
            >
              <span>Sorted by {selectedSort}</span>
              <ChevronDown className="w-3.5 h-3.5 stroke-[2.5]" />
            </button>
          </div>

          {/* 4. Main Scrollable Leads List Area */}
          <div className="flex-1 overflow-y-auto px-5 pt-1 pb-4 space-y-3 no-scrollbar">
            {filteredLeads.length === 0 ? (
              <div className="py-12 flex flex-col items-center justify-center text-center">
                <div className="w-12 h-12 rounded-full bg-gray-100 flex items-center justify-center text-[#9CA3AF] mb-3">
                  <Building2 className="w-6 h-6" />
                </div>
                <p className="text-sm font-bold text-[#111827]">No matching leads</p>
                <p className="text-xs text-[#6B7280] mt-1">Try selecting a different filter or search keyword.</p>
                <button
                  onClick={() => {
                    setSelectedFilter('All');
                    setSearchQuery('');
                  }}
                  className="mt-3 px-3 py-1.5 bg-[#E8F7F7] text-[#0F4C4C] rounded-lg text-xs font-bold cursor-pointer"
                >
                  Reset Filters
                </button>
              </div>
            ) : (
              filteredLeads.map((lead) => {
                const badgeStyle = getScoreBadgeStyles(lead.aiScore);
                const isHighlighted = lead.hasSwipeActionTip;

                return (
                  <div
                    key={lead.id}
                    onClick={() => setSelectedLeadForDetail(lead)}
                    className={`bg-white rounded-2xl border transition-all cursor-pointer overflow-hidden shadow-xs hover:shadow-sm ${
                      isHighlighted
                        ? 'border-[#0F4C4C] ring-1 ring-[#0F4C4C]/20'
                        : 'border-[#E5E7EB]'
                    }`}
                  >
                    {/* Upper Body Details */}
                    <div className="p-4 flex items-start space-x-3.5">
                      {/* Left: AI Score Circle Badge */}
                      <div
                        className={`w-[52px] h-[52px] rounded-full border-2 flex items-center justify-center shrink-0 ${badgeStyle.bg} ${badgeStyle.border}`}
                      >
                        <span className={`text-[17px] font-black ${badgeStyle.text} leading-none tracking-tight`}>
                          {lead.aiScore}
                        </span>
                      </div>

                      {/* Middle Info Column */}
                      <div className="flex-1 min-w-0">
                        <h3 className="text-[16.5px] font-bold text-[#111827] leading-tight truncate">
                          {lead.companyName}
                        </h3>
                        <p className="text-[13.5px] text-[#4B5563] mt-0.5 truncate">
                          {lead.contactName} · {lead.contactRole}
                        </p>

                        {/* Location Pin & Distance */}
                        <div className="flex items-center text-[12.5px] text-[#6B7280] mt-1 space-x-1">
                          <MapPin className="w-3.5 h-3.5 text-[#9CA3AF] shrink-0" />
                          <span className="truncate">
                            {lead.distanceKm} km · {lead.locationArea}
                          </span>
                        </div>

                        {/* Last Active */}
                        <p className="text-[11.5px] text-[#9CA3AF] mt-0.5">
                          Last active: {lead.lastActive}
                        </p>
                      </div>

                      {/* Right: Status Pill & Flag Icon */}
                      <div className="flex flex-col items-end justify-between shrink-0 h-[64px]">
                        {getStatusPill(lead)}

                        <button
                          onClick={(e) => handleToggleFlag(lead.id, e)}
                          className="p-1 text-[#D1D5DB] hover:text-[#F59E0B] transition-colors cursor-pointer"
                          title={lead.isFlagged ? 'Unflag' : 'Flag'}
                        >
                          <Flag
                            className={`w-4 h-4 transition-colors ${
                              lead.isFlagged
                                ? 'text-[#F59E0B] fill-[#F59E0B]'
                                : 'text-[#D1D5DB]'
                            }`}
                          />
                        </button>
                      </div>
                    </div>

                    {/* Bottom Banner Strip: Swipe Action Tip / Quick Action */}
                    {lead.hasSwipeActionTip ? (
                      <div className="bg-[#E8F7F7] px-4 py-2 border-t border-[#D2EEEE] flex items-center justify-between">
                        <span className="text-[12px] font-semibold text-[#0F4C4C] tracking-tight">
                          Swipe left to call, right to log visit
                        </span>
                        <ArrowRight className="w-3.5 h-3.5 text-[#0F4C4C] shrink-0" />
                      </div>
                    ) : (
                      /* Quick Action Touch Bar on hover/click */
                      <div className="px-4 py-1.5 bg-[#F9FAFB] border-t border-[#F3F4F6] flex items-center justify-between text-xs text-[#6B7280]">
                        <button
                          onClick={(e) => handleCall(lead, e)}
                          className="flex items-center space-x-1 text-[#0F4C4C] font-semibold hover:underline cursor-pointer"
                        >
                          <Phone className="w-3.5 h-3.5" />
                          <span>Call Lead</span>
                        </button>
                        <div className="w-px h-3 bg-gray-200" />
                        <button
                          onClick={(e) => handleLogVisit(lead, e)}
                          className="flex items-center space-x-1 text-[#10B981] font-semibold hover:underline cursor-pointer"
                        >
                          <Calendar className="w-3.5 h-3.5" />
                          <span>Log Visit</span>
                        </button>
                      </div>
                    )}
                  </div>
                );
              })
            )}
          </div>
        </>
      )}

      {/* 4. Floating Rounded Bottom Navigation Bar matching image.png and CRM Pro Design System */}
      <div className="mx-3.5 mb-3 bg-white rounded-3xl border border-[#E5E7EB] shadow-xs px-3 py-2 flex justify-around items-center shrink-0 z-20">
        {/* Home Tab */}
        <button
          onClick={() => {
            setActiveNavIndex(0);
            onNavigateToDashboard?.();
          }}
          className="flex flex-col items-center py-1 px-2.5 rounded-full transition-all cursor-pointer text-[#9CA3AF] hover:text-[#4B5563]"
        >
          <Home className="w-5 h-5" />
          <span className="text-[10.5px] font-medium mt-0.5">Home</span>
        </button>

        {/* Leads Tab (Active - highlighted just like Home when Dashboard is viewed) */}
        <button
          onClick={() => setActiveNavIndex(1)}
          className="flex flex-col items-center py-1 px-3.5 rounded-full transition-all cursor-pointer bg-[#E6F4F2] text-[#0F4C4C]"
        >
          <Folder className="w-5 h-5" />
          <span className="text-[10.5px] font-bold mt-0.5">Leads</span>
        </button>

        {/* Visits Tab */}
        <button
          onClick={() => {
            setActiveNavIndex(2);
            triggerToast('Visits screen coming up in next sprint!');
          }}
          className="flex flex-col items-center py-1 px-2.5 rounded-full transition-all cursor-pointer text-[#9CA3AF] hover:text-[#4B5563]"
        >
          <Route className="w-5 h-5" />
          <span className="text-[10.5px] font-medium mt-0.5">Visits</span>
        </button>

        {/* Tasks Tab */}
        <button
          onClick={() => {
            setActiveNavIndex(3);
            triggerToast('Tasks screen coming up in next sprint!');
          }}
          className="flex flex-col items-center py-1 px-2.5 rounded-full transition-all cursor-pointer text-[#9CA3AF] hover:text-[#4B5563]"
        >
          <ListTodo className="w-5 h-5" />
          <span className="text-[10.5px] font-medium mt-0.5">Tasks</span>
        </button>

        {/* Profile Tab */}
        <button
          onClick={() => {
            setActiveNavIndex(4);
            triggerToast('Profile & Settings tab');
          }}
          className="flex flex-col items-center py-1 px-2.5 rounded-full transition-all cursor-pointer text-[#9CA3AF] hover:text-[#4B5563]"
        >
          <User className="w-5 h-5" />
          <span className="text-[10.5px] font-medium mt-0.5">Profile</span>
        </button>
      </div>
        </>
      )}

      {/* Sort Bottom Sheet Modal */}
      {showSortModal && (
        <div className="absolute inset-0 z-50 bg-black/40 flex flex-col justify-end animate-in fade-in duration-200">
          <div className="bg-white rounded-t-3xl p-5 shadow-2xl border-t border-[#E5E7EB] animate-in slide-in-from-bottom duration-250">
            <div className="w-9 h-1 bg-gray-200 rounded-full mx-auto mb-4" />
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-base font-bold text-[#111827]">Sort Leads By</h3>
              <button
                onClick={() => setShowSortModal(false)}
                className="w-7 h-7 rounded-full bg-gray-100 flex items-center justify-center text-gray-500 hover:text-black cursor-pointer"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <div className="space-y-2 mb-4">
              {(['AI Score', 'Distance', 'Company Name'] as const).map((option) => {
                const isSelected = selectedSort === option;
                return (
                  <button
                    key={option}
                    onClick={() => {
                      setSelectedSort(option);
                      setShowSortModal(false);
                      triggerToast(`Sorted by ${option}`);
                    }}
                    className={`w-full p-3 rounded-xl flex items-center justify-between text-xs font-semibold transition-all cursor-pointer ${
                      isSelected
                        ? 'bg-[#E8F7F7] text-[#0F4C4C] border border-[#0F4C4C]'
                        : 'bg-gray-50 text-[#374151] hover:bg-gray-100 border border-transparent'
                    }`}
                  >
                    <span>{option}</span>
                    {isSelected && <CheckCircle2 className="w-4 h-4 text-[#0F4C4C]" />}
                  </button>
                );
              })}
            </div>
          </div>
        </div>
      )}

      {/* Add New Lead Bottom Sheet Modal */}
      {showAddModal && (
        <div className="absolute inset-0 z-50 bg-black/40 flex flex-col justify-end animate-in fade-in duration-200">
          <div className="bg-white rounded-t-3xl p-5 shadow-2xl border-t border-[#E5E7EB] animate-in slide-in-from-bottom duration-250">
            <div className="w-9 h-1 bg-gray-200 rounded-full mx-auto mb-3" />
            <div className="flex items-center justify-between mb-3">
              <h3 className="text-base font-extrabold text-[#111827]">Add New Field Lead</h3>
              <button
                onClick={() => setShowAddModal(false)}
                className="w-7 h-7 rounded-full bg-gray-100 flex items-center justify-center text-gray-500 hover:text-black cursor-pointer"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <form onSubmit={handleCreateLead} className="space-y-3">
              <div>
                <label className="text-[11px] font-semibold text-[#6B7280] block mb-1">
                  Company Name *
                </label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Zenith Tech Solutions"
                  value={newCompany}
                  onChange={(e) => setNewCompany(e.target.value)}
                  className="w-full px-3 py-2 bg-[#F9FAFB] border border-[#E5E7EB] rounded-xl text-xs text-[#111827] focus:outline-none focus:border-[#0F4C4C]"
                />
              </div>

              <div className="grid grid-cols-2 gap-2">
                <div>
                  <label className="text-[11px] font-semibold text-[#6B7280] block mb-1">
                    Contact Name
                  </label>
                  <input
                    type="text"
                    placeholder="e.g. Rajesh Nair"
                    value={newContact}
                    onChange={(e) => setNewContact(e.target.value)}
                    className="w-full px-3 py-2 bg-[#F9FAFB] border border-[#E5E7EB] rounded-xl text-xs text-[#111827] focus:outline-none focus:border-[#0F4C4C]"
                  />
                </div>
                <div>
                  <label className="text-[11px] font-semibold text-[#6B7280] block mb-1">
                    Designation / Role
                  </label>
                  <input
                    type="text"
                    placeholder="e.g. Purchase Head"
                    value={newRole}
                    onChange={(e) => setNewRole(e.target.value)}
                    className="w-full px-3 py-2 bg-[#F9FAFB] border border-[#E5E7EB] rounded-xl text-xs text-[#111827] focus:outline-none focus:border-[#0F4C4C]"
                  />
                </div>
              </div>

              <div>
                <label className="text-[11px] font-semibold text-[#6B7280] block mb-1">
                  Location Area
                </label>
                <input
                  type="text"
                  placeholder="e.g. Bandra West, Mumbai"
                  value={newArea}
                  onChange={(e) => setNewArea(e.target.value)}
                  className="w-full px-3 py-2 bg-[#F9FAFB] border border-[#E5E7EB] rounded-xl text-xs text-[#111827] focus:outline-none focus:border-[#0F4C4C]"
                />
              </div>

              <div className="pt-2">
                <button
                  type="submit"
                  className="w-full py-3 bg-[#0F4C4C] hover:bg-[#0c3c3c] text-white rounded-xl text-xs font-bold shadow-xs transition-transform active:scale-98 cursor-pointer"
                >
                  Save Lead
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Lead Detail Quick Sheet */}
      {selectedLeadForDetail && (
        <div className="absolute inset-0 z-50 bg-black/40 flex flex-col justify-end animate-in fade-in duration-200">
          <div className="bg-white rounded-t-3xl p-5 shadow-2xl border-t border-[#E5E7EB] animate-in slide-in-from-bottom duration-250">
            <div className="w-9 h-1 bg-gray-200 rounded-full mx-auto mb-3" />
            <div className="flex items-start justify-between mb-3">
              <div>
                <div className="flex items-center space-x-2">
                  <h3 className="text-lg font-black text-[#111827]">
                    {selectedLeadForDetail.companyName}
                  </h3>
                  {getStatusPill(selectedLeadForDetail)}
                </div>
                <p className="text-xs text-[#6B7280] mt-0.5">
                  {selectedLeadForDetail.contactName} · {selectedLeadForDetail.contactRole}
                </p>
              </div>
              <button
                onClick={() => setSelectedLeadForDetail(null)}
                className="w-7 h-7 rounded-full bg-gray-100 flex items-center justify-center text-gray-500 hover:text-black cursor-pointer"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <div className="p-3 bg-[#F9FAFB] rounded-xl border border-[#E5E7EB] space-y-2 text-xs mb-4">
              <div className="flex justify-between">
                <span className="text-gray-500">AI Score</span>
                <span className="font-extrabold text-[#10B981]">{selectedLeadForDetail.aiScore}/100</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-500">Distance</span>
                <span className="font-semibold text-gray-800">{selectedLeadForDetail.distanceKm} km · {selectedLeadForDetail.locationArea}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-500">Phone</span>
                <span className="font-mono text-gray-800">{selectedLeadForDetail.phoneNumber}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-500">Last Activity</span>
                <span className="text-gray-800">{selectedLeadForDetail.lastActive}</span>
              </div>
            </div>

            <div className="grid grid-cols-2 gap-2">
              <button
                onClick={() => {
                  handleCall(selectedLeadForDetail);
                  setSelectedLeadForDetail(null);
                }}
                className="py-2.5 bg-[#0F4C4C] text-white rounded-xl text-xs font-bold flex items-center justify-center space-x-1.5 cursor-pointer shadow-xs hover:bg-[#0c3c3c]"
              >
                <Phone className="w-3.5 h-3.5" />
                <span>Call Contact</span>
              </button>

              <button
                onClick={() => {
                  handleLogVisit(selectedLeadForDetail);
                  setSelectedLeadForDetail(null);
                }}
                className="py-2.5 bg-[#10B981] text-white rounded-xl text-xs font-bold flex items-center justify-center space-x-1.5 cursor-pointer shadow-xs hover:bg-[#059669]"
              >
                <Calendar className="w-3.5 h-3.5" />
                <span>Log Visit</span>
              </button>
            </div>
          </div>
        </div>
      )}

      {/* 8. Scan Visiting Card Modal with AI Card Scanner Simulation */}
      {showScanModal && (
        <div className="absolute inset-0 z-50 bg-black/50 flex flex-col justify-end animate-in fade-in duration-200">
          <div className="bg-white rounded-t-3xl p-5 shadow-2xl border-t border-[#E5E7EB] animate-in slide-in-from-bottom duration-250">
            <div className="w-9 h-1 bg-gray-200 rounded-full mx-auto mb-3" />
            <div className="flex items-center justify-between mb-3">
              <div className="flex items-center space-x-2">
                <Camera className="w-5 h-5 text-[#0F4C4C]" />
                <h3 className="text-base font-extrabold text-[#111827]">Scan Visiting Card</h3>
              </div>
              <button
                onClick={() => setShowScanModal(false)}
                className="w-7 h-7 rounded-full bg-gray-100 flex items-center justify-center text-gray-500 hover:text-black cursor-pointer"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            {/* Simulated OCR Scanner Frame */}
            <div className="relative h-44 rounded-2xl bg-gray-900 border-2 border-[#0F4C4C] overflow-hidden flex flex-col items-center justify-center p-4 text-white">
              <div className="absolute inset-4 border-2 border-dashed border-[#10B981]/60 rounded-xl pointer-events-none" />
              <div className="z-10 bg-white/10 backdrop-blur-xs p-3 rounded-xl border border-white/20 text-left w-full max-w-[280px]">
                <div className="flex items-center space-x-1.5 text-[#34D399] text-xs font-bold mb-1">
                  <Sparkles className="w-3.5 h-3.5" />
                  <span>AI OCR Card Detected</span>
                </div>
                <div className="text-sm font-bold text-white">Apex Solutions Ltd.</div>
                <div className="text-xs text-gray-300">Rajesh Sharma • VP Procurement</div>
                <div className="text-[11px] text-gray-400 mt-1">+91 98211 44556 • Bandra Kurla Complex</div>
              </div>
            </div>

            <p className="text-xs text-center text-gray-500 mt-2 mb-4">
              Hold the business card steady within the frame for instant AI contact extraction.
            </p>

            <button
              onClick={() => {
                const scannedLead: LeadItem = {
                  id: `scanned-${Date.now()}`,
                  companyName: 'Apex Solutions Ltd.',
                  contactName: 'Rajesh Sharma',
                  contactRole: 'VP Procurement',
                  distanceKm: 0.5,
                  locationArea: 'BKC',
                  lastActive: 'Just now (Scanned)',
                  aiScore: 93,
                  stage: 'New',
                  temperature: 'Hot',
                  isNearby: true,
                  isFlagged: false,
                  phoneNumber: '+91 98211 44556',
                  email: 'r.sharma@apexsolutions.in',
                };
                setLeads((prev) => [scannedLead, ...prev]);
                setShowScanModal(false);
                triggerToast('Scanned visiting card added to leads!');
              }}
              className="w-full py-3.5 bg-[#0F4C4C] hover:bg-[#0c3c3c] text-white rounded-xl text-xs font-bold shadow-xs transition-transform active:scale-98 cursor-pointer"
            >
              Confirm & Add Scanned Lead
            </button>
          </div>
        </div>
      )}
    </div>
  );
};
