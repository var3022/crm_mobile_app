import React, { useState } from 'react';
import {
  Phone,
  ArrowRight,
  MapPin,
  Compass,
  Navigation,
  Sparkles,
  X,
  Clock,
  Building2,
  User,
  Calendar,
  ChevronRight,
  Home,
  Folder,
  Route,
  ListTodo,
  CheckCircle2,
  ExternalLink,
  Layers,
  ArrowLeft,
  Search,
  Filter
} from 'lucide-react';

export interface NearbyLeadItem {
  id: string;
  companyName: string;
  contactName: string;
  contactRole: string;
  distanceKm: number;
  locationArea: string;
  lastVisit: string;
  phoneNumber: string;
  email: string;
  aiScore: number;
  stage: 'Qualified' | 'Contacted' | 'New';
  markerColor: string;
  coords: { x: number; y: number }; // percentage inside map canvas
}

interface NearbyLeadsSimulatorProps {
  onBackToLeadsList?: () => void;
  onNavigateToDashboard?: () => void;
  onNavigateToNotifications?: () => void;
}

export const NearbyLeadsSimulator: React.FC<NearbyLeadsSimulatorProps> = ({
  onBackToLeadsList,
  onNavigateToDashboard,
  onNavigateToNotifications,
}) => {
  // View mode: 'Map' or 'List' (defaults to 'Map' matching image.png)
  const [viewMode, setViewMode] = useState<'Map' | 'List'>('Map');

  // Selected distance radius filter: 1 km, 2 km (active in screenshot), 5 km, 10 km
  const [selectedRadius, setSelectedRadius] = useState<number>(2);

  // Active Bottom Nav Tab index (1 = Leads)
  const [activeNavIndex, setActiveNavIndex] = useState<number>(1);

  // Selected lead for detail/navigation
  const [selectedLead, setSelectedLead] = useState<NearbyLeadItem | null>(null);

  // Call simulation modal state
  const [callModalLead, setCallModalLead] = useState<NearbyLeadItem | null>(null);

  // Directions/Route simulation modal state
  const [routeModalLead, setRouteModalLead] = useState<NearbyLeadItem | null>(null);

  // Cluster tooltip/modal state
  const [showClusterModal, setShowClusterModal] = useState<boolean>(false);

  // Toast feedback
  const [toastMessage, setToastMessage] = useState<string | null>(null);

  const triggerToast = (msg: string) => {
    setToastMessage(msg);
    setTimeout(() => {
      setToastMessage(null);
    }, 2800);
  };

  // Database of nearby leads matching image.png and South Mumbai field sales route
  const allLeads: NearbyLeadItem[] = [
    {
      id: 'lead-1',
      companyName: 'Acme Corp',
      contactName: 'John Doe',
      contactRole: 'CTO',
      distanceKm: 0.8,
      locationArea: 'Nariman Point, South Mumbai',
      lastVisit: 'Yesterday',
      phoneNumber: '+91 98201 12345',
      email: 'john.doe@acmecorp.com',
      aiScore: 94,
      stage: 'Qualified',
      markerColor: '#EF4444', // Red callout marker in image.png
      coords: { x: 42, y: 26 },
    },
    {
      id: 'lead-2',
      companyName: 'TechVista Ltd',
      contactName: 'Priya Sharma',
      contactRole: 'HR Director',
      distanceKm: 1.2,
      locationArea: 'Lower Parel, South Mumbai',
      lastVisit: '3 days ago',
      phoneNumber: '+91 98192 98765',
      email: 'priya.sharma@techvista.io',
      aiScore: 76,
      stage: 'Contacted',
      markerColor: '#F59E0B', // Amber callout marker in image.png
      coords: { x: 74, y: 36 },
    },
    {
      id: 'lead-3',
      companyName: 'DataFlow Systems',
      contactName: 'Karan Malhotra',
      contactRole: 'Managing Director',
      distanceKm: 2.5,
      locationArea: 'Girgaon Chowpatty',
      lastVisit: 'No recent visits',
      phoneNumber: '+91 98205 55678',
      email: 'karan@dataflow.co.in',
      aiScore: 45,
      stage: 'New',
      markerColor: '#6B7280',
      coords: { x: 28, y: 38 },
    },
    {
      id: 'lead-4',
      companyName: 'Nova Pharmaceuticals',
      contactName: 'Dr. Rajesh Iyer',
      contactRole: 'Purchase Director',
      distanceKm: 0.9,
      locationArea: 'Worli Seaface',
      lastVisit: '4 days ago',
      phoneNumber: '+91 98401 88990',
      email: 'rajesh.iyer@novapharma.org',
      aiScore: 91,
      stage: 'Qualified',
      markerColor: '#10B981',
      coords: { x: 50, y: 48 },
    },
    {
      id: 'lead-5',
      companyName: 'Apex Logistics',
      contactName: 'Vikram Mehta',
      contactRole: 'VP Sales',
      distanceKm: 1.8,
      locationArea: 'Fort Commercial Center',
      lastVisit: '1 week ago',
      phoneNumber: '+91 98334 23456',
      email: 'vikram.m@apexlogistics.com',
      aiScore: 88,
      stage: 'Qualified',
      markerColor: '#0F4C4C',
      coords: { x: 38, y: 52 },
    },
    {
      id: 'lead-6',
      companyName: 'Technology Solutions',
      contactName: 'Rajiv Sen',
      contactRole: 'Head of IT',
      distanceKm: 4.8,
      locationArea: 'Churchgate Heritage Dist.',
      lastVisit: '2 weeks ago',
      phoneNumber: '+91 98205 77890',
      email: 'rajiv.sen@techsolutions.com',
      aiScore: 78,
      stage: 'Contacted',
      markerColor: '#3B82F6',
      coords: { x: 58, y: 22 },
    },
    {
      id: 'lead-7',
      companyName: 'Metro Health Systems',
      contactName: 'Dr. Sunita Rao',
      contactRole: 'Chief Administrator',
      distanceKm: 8.4,
      locationArea: 'Bandra-Kurla Complex',
      lastVisit: 'Last month',
      phoneNumber: '+91 98210 11223',
      email: 'sunita.rao@metrohealth.org',
      aiScore: 82,
      stage: 'Qualified',
      markerColor: '#8B5CF6',
      coords: { x: 82, y: 15 },
    },
  ];

  // Filter leads by chosen radius
  const filteredLeads = allLeads
    .filter((lead) => lead.distanceKm <= selectedRadius)
    .sort((a, b) => a.distanceKm - b.distanceKm);

  return (
    <div className="flex-1 flex flex-col bg-white relative select-none h-full overflow-hidden font-['Inter',sans-serif]">
      {/* Toast Notification */}
      {toastMessage && (
        <div className="absolute top-12 left-4 right-4 z-50 bg-[#0F4C4C] text-white px-3.5 py-2.5 rounded-xl shadow-lg flex items-center justify-between text-xs animate-in fade-in slide-in-from-top-2 duration-200">
          <div className="flex items-center space-x-2">
            <Sparkles className="w-4 h-4 text-[#99F6E4] shrink-0" />
            <span className="font-medium">{toastMessage}</span>
          </div>
          <button
            onClick={() => setToastMessage(null)}
            className="text-white/70 hover:text-white text-xs font-bold px-1 cursor-pointer"
          >
            ✕
          </button>
        </div>
      )}

      {/* 1. Top Header: Title "Nearby Leads" + Map/List Segmented Toggle */}
      <div className="px-5 pt-4 pb-2 flex items-center justify-between bg-white shrink-0">
        <div className="flex items-center space-x-2">
          {onBackToLeadsList && (
            <button
              onClick={onBackToLeadsList}
              className="w-8 h-8 rounded-full bg-gray-100 hover:bg-gray-200 flex items-center justify-center text-[#111827] cursor-pointer transition-colors -ml-1 mr-1"
              title="Back to All Leads"
            >
              <ArrowLeft className="w-4 h-4" />
            </button>
          )}
          <h1 className="text-[26px] font-black text-[#111827] tracking-tight leading-none">
            Nearby Leads
          </h1>
        </div>

        {/* Map | List Segmented Toggle matching image.png */}
        <div className="flex bg-[#F3F4F6] p-1 rounded-xl border border-[#E5E7EB]">
          <button
            onClick={() => setViewMode('Map')}
            className={`px-3 py-1 rounded-lg text-xs font-bold transition-all cursor-pointer ${
              viewMode === 'Map'
                ? 'bg-[#0F4C4C] text-white shadow-xs'
                : 'text-[#4B5563] hover:text-[#111827]'
            }`}
          >
            Map
          </button>
          <button
            onClick={() => setViewMode('List')}
            className={`px-3 py-1 rounded-lg text-xs font-bold transition-all cursor-pointer ${
              viewMode === 'List'
                ? 'bg-[#0F4C4C] text-white shadow-xs'
                : 'text-[#4B5563] hover:text-[#111827]'
            }`}
          >
            List
          </button>
        </div>
      </div>

      {/* 3. Distance Radius Filter Pills (1 km, 2 km, 5 km, 10 km) */}
      <div className="px-5 py-2 flex items-center space-x-2 shrink-0 overflow-x-auto no-scrollbar">
        {[1, 2, 5, 10].map((radius) => {
          const isSelected = selectedRadius === radius;
          return (
            <button
              key={radius}
              onClick={() => {
                setSelectedRadius(radius);
                triggerToast(`Filtered to leads within ${radius} km radius`);
              }}
              className={`px-4 py-1.5 rounded-full text-xs font-bold transition-all cursor-pointer shrink-0 ${
                isSelected
                  ? 'bg-[#0F4C4C] text-white shadow-xs'
                  : 'bg-[#E8F7F7] text-[#0F4C4C] hover:bg-[#d6f0f0]'
              }`}
            >
              {radius} km
            </button>
          );
        })}
      </div>

      {/* 4. Main Body: Split Map View (from screenshot) OR Full List View */}
      {viewMode === 'Map' ? (
        <div className="flex-1 flex flex-col overflow-hidden">
          {/* 4A. Visual Illustrated South Mumbai Map Canvas (Faithful to image.png) */}
          <div className="px-4 py-1 shrink-0">
            <div className="relative w-full h-[230px] rounded-2xl border border-[#E5E7EB] bg-[#FAF7EE] overflow-hidden shadow-xs">
              {/* Detailed Stylized Vector SVG of South Mumbai Coastline & Urban Grid */}
              <svg
                viewBox="0 0 380 230"
                className="w-full h-full object-cover"
                preserveAspectRatio="xMidYMid slice"
              >
                <defs>
                  {/* Subtle water gradient */}
                  <linearGradient id="seaGrad" x1="0%" y1="0%" x2="100%" y2="100%">
                    <stop offset="0%" stopColor="#DFEDF2" />
                    <stop offset="100%" stopColor="#C9E2EB" />
                  </linearGradient>

                  {/* Land gradient */}
                  <linearGradient id="landGrad" x1="0%" y1="0%" x2="100%" y2="100%">
                    <stop offset="0%" stopColor="#F9F6ED" />
                    <stop offset="100%" stopColor="#EFE8D8" />
                  </linearGradient>

                  {/* Pastel block fills for historical urban neighborhoods */}
                  <pattern id="cityPattern" width="40" height="40" patternUnits="userSpaceOnUse">
                    <rect x="2" y="2" width="16" height="16" fill="#FEE2E2" opacity="0.45" rx="2" />
                    <rect x="20" y="2" width="18" height="16" fill="#FEF3C7" opacity="0.5" rx="2" />
                    <rect x="2" y="20" width="16" height="18" fill="#E0F2FE" opacity="0.5" rx="2" />
                    <rect x="20" y="20" width="18" height="18" fill="#DCFCE7" opacity="0.4" rx="2" />
                  </pattern>
                </defs>

                {/* Ocean Background (Arabian Sea & Back Bay) */}
                <rect width="380" height="230" fill="url(#seaGrad)" />

                {/* Coastline Waves texture */}
                <path
                  d="M 10,70 Q 30,65 50,70 Q 70,75 90,70"
                  fill="none"
                  stroke="#BCD7E0"
                  strokeWidth="1"
                  opacity="0.6"
                />
                <path
                  d="M 15,160 Q 40,155 65,160 Q 90,165 115,160"
                  fill="none"
                  stroke="#BCD7E0"
                  strokeWidth="1"
                  opacity="0.6"
                />

                {/* South Mumbai Landmass (Peninsula contour with Malabar Hill, Marine Drive, Nariman Point, Colaba) */}
                <path
                  d="M 15,100 
                     C 30,85 70,60 120,40 
                     C 170,20 220,15 280,30 
                     C 320,40 360,55 375,80 
                     C 385,100 370,140 330,160 
                     C 290,180 250,195 200,185 
                     C 160,175 130,150 95,145 
                     C 60,140 35,125 15,100 Z"
                  fill="url(#landGrad)"
                  stroke="#D3C9B8"
                  strokeWidth="1.5"
                />

                {/* Urban District Blocks Pattern */}
                <path
                  d="M 30,95 
                     C 70,65 130,45 220,32 
                     C 270,25 320,45 355,80 
                     C 360,110 335,150 280,170 
                     C 220,185 150,165 100,140 
                     C 60,120 40,110 30,95 Z"
                  fill="url(#cityPattern)"
                />

                {/* Major Arterial Roads & Marine Drive Curve */}
                {/* Marine Drive Coastal Arc */}
                <path
                  d="M 25,100 C 60,135 110,148 160,155 C 210,162 260,160 300,140"
                  fill="none"
                  stroke="#FFFFFF"
                  strokeWidth="3.5"
                  strokeLinecap="round"
                />
                <path
                  d="M 25,100 C 60,135 110,148 160,155 C 210,162 260,160 300,140"
                  fill="none"
                  stroke="#FBBF24"
                  strokeWidth="1.5"
                  strokeDasharray="4,3"
                />

                {/* Primary North-South Arteries */}
                <path
                  d="M 125,42 C 145,80 165,115 178,160"
                  fill="none"
                  stroke="#FFFFFF"
                  strokeWidth="2.5"
                />
                <path
                  d="M 220,30 C 215,70 210,110 215,155"
                  fill="none"
                  stroke="#FFFFFF"
                  strokeWidth="2.5"
                />
                <path
                  d="M 285,35 C 275,75 260,110 245,150"
                  fill="none"
                  stroke="#FFFFFF"
                  strokeWidth="2"
                />

                {/* Cross Connecting Avenues */}
                <line x1="80" y1="70" x2="310" y2="70" stroke="#FFFFFF" strokeWidth="1.8" />
                <line x1="100" y1="105" x2="340" y2="105" stroke="#FFFFFF" strokeWidth="1.8" />
                <line x1="130" y1="135" x2="280" y2="135" stroke="#FFFFFF" strokeWidth="1.8" />

                {/* Vintage Map Compass Rose in lower-right corner */}
                <g transform="translate(345, 195) scale(0.65)" opacity="0.45">
                  <circle cx="0" cy="0" r="16" fill="none" stroke="#78716C" strokeWidth="1" />
                  <polygon points="0,-16 4,0 0,16 -4,0" fill="#78716C" />
                  <polygon points="-16,0 0,4 16,0 0,-4" fill="#A8A29E" />
                  <text
                    x="0"
                    y="-20"
                    textAnchor="middle"
                    fontSize="9"
                    fontWeight="bold"
                    fill="#78716C"
                  >
                    N
                  </text>
                </g>

                {/* Distance Scale Bar on bottom-left */}
                <g transform="translate(18, 212)" opacity="0.6">
                  <line x1="0" y1="0" x2="45" y2="0" stroke="#78716C" strokeWidth="1.5" />
                  <line x1="0" y1="-3" x2="0" y2="3" stroke="#78716C" strokeWidth="1.5" />
                  <line x1="22.5" y1="-2" x2="22.5" y2="2" stroke="#78716C" strokeWidth="1" />
                  <line x1="45" y1="-3" x2="45" y2="3" stroke="#78716C" strokeWidth="1.5" />
                  <text x="22.5" y="-5" textAnchor="middle" fontSize="8" fill="#78716C" fontWeight="bold">
                    1 km
                  </text>
                </g>
              </svg>

              {/* Vintage Stencil Title Banner: "SOUTH MUMBAI" */}
              <div className="absolute top-2 left-0 right-0 flex justify-center pointer-events-none">
                <span className="font-serif tracking-[0.22em] text-[13px] font-black text-[#78716C] uppercase select-none opacity-80 drop-shadow-xs">
                  SOUTH MUMBAI
                </span>
              </div>

              {/* MAP OVERLAY MARKERS (Exactly matching image.png) */}

              {/* 1. Acme Corp Marker (Red Badge + Location Pin Icon) */}
              <div
                onClick={() => {
                  setSelectedLead(allLeads[0]);
                  triggerToast('Acme Corp selected (0.8 km)');
                }}
                className="absolute top-[26%] left-[34%] -translate-x-1/2 flex flex-col items-center cursor-pointer transition-transform hover:scale-110 active:scale-95 z-20 group"
              >
                <div className="bg-[#EF4444] text-white text-[11px] font-extrabold px-2 py-0.5 rounded-md shadow-md flex items-center space-x-1 whitespace-nowrap">
                  <span>Acme Corp</span>
                </div>
                <div className="w-5 h-5 -mt-1 text-[#EF4444] flex items-center justify-center">
                  <MapPin className="w-5 h-5 fill-[#EF4444] text-white drop-shadow-md" />
                </div>
              </div>

              {/* 2. Current User Location Glowing Blue Indicator */}
              <div
                className="absolute top-[49%] left-[49%] -translate-x-1/2 -translate-y-1/2 z-10 pointer-events-none"
                title="Your Current Location"
              >
                <div className="relative flex items-center justify-center">
                  {/* Outer pulse */}
                  <div className="absolute w-8 h-8 rounded-full bg-[#3B82F6]/30 animate-ping" />
                  {/* Outer ring */}
                  <div className="w-5 h-5 rounded-full border-2 border-white bg-[#3B82F6] shadow-md flex items-center justify-center">
                    {/* Inner core */}
                    <div className="w-1.5 h-1.5 rounded-full bg-white" />
                  </div>
                </div>
              </div>

              {/* 3. TechVista Marker (Amber Badge + Pin Icon) */}
              <div
                onClick={() => {
                  setSelectedLead(allLeads[1]);
                  triggerToast('TechVista Ltd selected (1.2 km)');
                }}
                className="absolute top-[48%] left-[71%] -translate-x-1/2 flex flex-col items-center cursor-pointer transition-transform hover:scale-110 active:scale-95 z-20 group"
              >
                <div className="bg-[#F59E0B] text-white text-[11px] font-extrabold px-2.5 py-0.5 rounded-md shadow-md flex items-center space-x-1 whitespace-nowrap">
                  <span>TechVista</span>
                </div>
                <div className="w-5 h-5 -mt-1 text-[#F59E0B] flex items-center justify-center">
                  <MapPin className="w-5 h-5 fill-[#F59E0B] text-white drop-shadow-md" />
                </div>
              </div>

              {/* 4. Cluster Count Badge: "5" (Dark Teal Circle) */}
              <div
                onClick={() => setShowClusterModal(true)}
                className="absolute top-[52%] left-[17%] -translate-x-1/2 -translate-y-1/2 z-20 cursor-pointer transition-transform hover:scale-110 active:scale-95"
                title="5 Leads Cluster in Marine Drive / Chowpatty"
              >
                <div className="w-8 h-8 rounded-full bg-[#0F4C4C] border-2 border-white text-white font-extrabold text-[13px] flex items-center justify-center shadow-lg shadow-black/20">
                  5
                </div>
              </div>

              {/* Additional pins when radius is 5 km or 10 km */}
              {selectedRadius >= 5 && (
                <div
                  onClick={() => {
                    setSelectedLead(allLeads[2]);
                    triggerToast('DataFlow Systems selected (2.5 km)');
                  }}
                  className="absolute top-[68%] left-[32%] -translate-x-1/2 flex flex-col items-center cursor-pointer transition-transform hover:scale-110 active:scale-95 z-20 animate-in fade-in zoom-in-75 duration-200"
                >
                  <div className="bg-[#6B7280] text-white text-[10px] font-bold px-1.5 py-0.5 rounded-md shadow-md">
                    DataFlow
                  </div>
                  <MapPin className="w-4 h-4 fill-[#6B7280] text-white -mt-0.5" />
                </div>
              )}
            </div>
          </div>

          {/* 4B. Section Header: NEARBY LEADS (SORTED BY DISTANCE) */}
          <div className="px-5 pt-3 pb-1.5 flex items-center justify-between shrink-0">
            <h2 className="text-[11px] font-extrabold text-[#6B7280] tracking-wider uppercase">
              Nearby Leads (Sorted by Distance)
            </h2>
            <span className="text-[11px] font-bold text-[#9CA3AF]">
              {filteredLeads.length} {filteredLeads.length === 1 ? 'lead' : 'leads'} within {selectedRadius} km
            </span>
          </div>

          {/* 4C. Scrollable List of Lead Cards (Exact match to cards in image.png) */}
          <div className="flex-1 overflow-y-auto px-4 pb-2 space-y-2.5 no-scrollbar">
            {filteredLeads.length === 0 ? (
              <div className="py-12 flex flex-col items-center justify-center text-center">
                <div className="w-12 h-12 rounded-full bg-[#F3F4F6] flex items-center justify-center mb-3">
                  <MapPin className="w-6 h-6 text-[#9CA3AF]" />
                </div>
                <p className="text-sm font-bold text-[#111827]">No leads in {selectedRadius} km radius</p>
                <p className="text-xs text-[#6B7280] mt-1 max-w-[240px]">
                  Try selecting the 5 km or 10 km filter chip above to see more sales leads.
                </p>
                <button
                  onClick={() => setSelectedRadius(5)}
                  className="mt-3 px-4 py-1.5 rounded-full bg-[#0F4C4C] text-white text-xs font-bold shadow-xs cursor-pointer"
                >
                  Expand to 5 km
                </button>
              </div>
            ) : (
              filteredLeads.map((lead) => {
                const isSelected = selectedLead?.id === lead.id;
                return (
                  <div
                    key={lead.id}
                    onClick={() => setSelectedLead(lead)}
                    className={`bg-white rounded-2xl border p-3.5 shadow-xs flex items-center space-x-3 transition-all cursor-pointer active:scale-[0.99] ${
                      isSelected
                        ? 'border-[#0F4C4C] ring-2 ring-[#0F4C4C]/15 bg-[#F9FBFA]'
                        : 'border-[#E5E7EB] hover:border-[#0F4C4C]/40'
                    }`}
                  >
                    {/* Distance Pill Badge on left (e.g. "0.8 km", "1.2 km", "2.5 km") */}
                    <div className="px-3 py-1.5 rounded-xl bg-[#CCFBF1] text-[#0F4C4C] text-xs font-black tracking-tight shrink-0 flex items-center justify-center min-w-[62px]">
                      {lead.distanceKm.toFixed(1)} km
                    </div>

                    {/* Lead Title & Last Visit Timestamp */}
                    <div className="flex-1 min-w-0 pr-1">
                      <div className="flex items-center space-x-1.5">
                        <h3 className="text-[15px] font-bold text-[#111827] truncate">
                          {lead.companyName}
                        </h3>
                        {lead.aiScore >= 90 && (
                          <span className="w-2 h-2 rounded-full bg-[#10B981] shrink-0" title="Hot AI Lead" />
                        )}
                      </div>
                      <p className="text-xs font-medium text-[#6B7280] truncate mt-0.5">
                        {lead.lastVisit.startsWith('Last visit')
                          ? lead.lastVisit
                          : `Last visit: ${lead.lastVisit}`}
                      </p>
                    </div>

                    {/* Action 1: Call Button (Circular Pale Mint with Teal Phone) */}
                    <button
                      onClick={(e) => {
                        e.stopPropagation();
                        setCallModalLead(lead);
                      }}
                      className="w-9 h-9 rounded-full bg-[#D1FAE5] hover:bg-[#A7F3D0] active:scale-95 text-[#0F4C4C] flex items-center justify-center transition-all cursor-pointer shrink-0 shadow-2xs"
                      title={`Call ${lead.contactName}`}
                    >
                      <Phone className="w-4 h-4 fill-current stroke-0" />
                    </button>

                    {/* Action 2: Direction / Details Arrow (Circular Pale Mint with Teal Arrow) */}
                    <button
                      onClick={(e) => {
                        e.stopPropagation();
                        setRouteModalLead(lead);
                      }}
                      className="w-9 h-9 rounded-full bg-[#CCFBF1] hover:bg-[#99F6E4] active:scale-95 text-[#0F4C4C] flex items-center justify-center transition-all cursor-pointer shrink-0 shadow-2xs"
                      title="View Route & Navigate"
                    >
                      <ArrowRight className="w-4 h-4 stroke-[2.5]" />
                    </button>
                  </div>
                );
              })
            )}
          </div>
        </div>
      ) : (
        /* FULL LIST VIEW MODE (when 'List' toggle is active) */
        <div className="flex-1 flex flex-col overflow-hidden px-4">
          <div className="py-2.5 flex items-center justify-between shrink-0">
            <span className="text-xs font-bold text-[#4B5563]">
              Showing {filteredLeads.length} leads within {selectedRadius} km
            </span>
            <span className="text-xs font-bold text-[#0F4C4C] bg-[#E6F4F2] px-2.5 py-0.5 rounded-full">
              Sorted by Distance
            </span>
          </div>

          <div className="flex-1 overflow-y-auto space-y-2.5 pb-2 no-scrollbar">
            {filteredLeads.map((lead) => (
              <div
                key={lead.id}
                onClick={() => setSelectedLead(lead)}
                className="bg-white rounded-2xl border border-[#E5E7EB] p-3.5 shadow-xs flex items-center space-x-3 hover:border-[#0F4C4C]/40 transition-all cursor-pointer"
              >
                <div className="px-3 py-1.5 rounded-xl bg-[#CCFBF1] text-[#0F4C4C] text-xs font-black tracking-tight shrink-0">
                  {lead.distanceKm.toFixed(1)} km
                </div>

                <div className="flex-1 min-w-0 pr-1">
                  <h3 className="text-[15px] font-bold text-[#111827] truncate">
                    {lead.companyName}
                  </h3>
                  <div className="text-xs text-[#4B5563] truncate mt-0.5">
                    {lead.contactName} · {lead.contactRole}
                  </div>
                  <div className="text-[11px] text-[#6B7280] truncate mt-0.5">
                    {lead.locationArea} · {lead.lastVisit}
                  </div>
                </div>

                <button
                  onClick={(e) => {
                    e.stopPropagation();
                    setCallModalLead(lead);
                  }}
                  className="w-9 h-9 rounded-full bg-[#D1FAE5] hover:bg-[#A7F3D0] text-[#0F4C4C] flex items-center justify-center transition-all cursor-pointer shrink-0"
                >
                  <Phone className="w-4 h-4 fill-current stroke-0" />
                </button>

                <button
                  onClick={(e) => {
                    e.stopPropagation();
                    setRouteModalLead(lead);
                  }}
                  className="w-9 h-9 rounded-full bg-[#CCFBF1] hover:bg-[#99F6E4] text-[#0F4C4C] flex items-center justify-center transition-all cursor-pointer shrink-0"
                >
                  <ArrowRight className="w-4 h-4 stroke-[2.5]" />
                </button>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* 5. Floating Rounded Bottom Navigation Bar matching image.png and CRM Pro Design System */}
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

        {/* Leads Tab (Active - mint pill container with teal icon) */}
        <button
          onClick={() => {
            setActiveNavIndex(1);
            onBackToLeadsList?.();
          }}
          className="flex flex-col items-center py-1 px-3.5 rounded-full transition-all cursor-pointer bg-[#E6F4F2] text-[#0F4C4C]"
        >
          <Folder className="w-5 h-5" />
          <span className="text-[10.5px] font-bold mt-0.5">Leads</span>
        </button>

        {/* Visits Tab */}
        <button
          onClick={() => {
            setActiveNavIndex(2);
            triggerToast('Visits itinerary & route planner');
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
            triggerToast('Profile & Field Settings');
          }}
          className="flex flex-col items-center py-1 px-2.5 rounded-full transition-all cursor-pointer text-[#9CA3AF] hover:text-[#4B5563]"
        >
          <User className="w-5 h-5" />
          <span className="text-[10.5px] font-medium mt-0.5">Profile</span>
        </button>
      </div>

      {/* 6. Quick Phone Call Modal */}
      {callModalLead && (
        <div className="absolute inset-0 z-50 bg-black/50 flex flex-col justify-end animate-in fade-in duration-200">
          <div className="bg-white rounded-t-3xl p-5 shadow-2xl border-t border-[#E5E7EB] animate-in slide-in-from-bottom duration-250">
            <div className="w-10 h-1 bg-gray-200 rounded-full mx-auto mb-4" />
            <div className="flex items-center justify-between mb-4">
              <div>
                <h3 className="text-base font-bold text-[#111827]">
                  Call {callModalLead.contactName}
                </h3>
                <p className="text-xs text-[#6B7280]">
                  {callModalLead.companyName} · {callModalLead.contactRole}
                </p>
              </div>
              <button
                onClick={() => setCallModalLead(null)}
                className="w-7 h-7 rounded-full bg-gray-100 flex items-center justify-center text-gray-500 hover:text-black cursor-pointer"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <div className="p-3 bg-[#F9FAFB] rounded-xl border border-[#E5E7EB] mb-4">
              <div className="text-xs text-[#6B7280]">Mobile Phone</div>
              <div className="text-sm font-extrabold text-[#0F4C4C] mt-0.5">
                {callModalLead.phoneNumber}
              </div>
            </div>

            <div className="space-y-2">
              <a
                href={`tel:${callModalLead.phoneNumber}`}
                onClick={() => {
                  triggerToast(`Dialing ${callModalLead.phoneNumber}...`);
                  setCallModalLead(null);
                }}
                className="w-full py-3 bg-[#0F4C4C] text-white rounded-xl text-xs font-bold shadow-xs hover:bg-[#0c3c3c] flex items-center justify-center space-x-2 transition-transform active:scale-98 cursor-pointer"
              >
                <Phone className="w-4 h-4 fill-current stroke-0" />
                <span>Call Client Directly</span>
              </a>

              <button
                onClick={() => {
                  triggerToast(`Logged call note for ${callModalLead.companyName}`);
                  setCallModalLead(null);
                }}
                className="w-full py-2.5 bg-[#E8F7F7] text-[#0F4C4C] rounded-xl text-xs font-bold hover:bg-[#d6f0f0] transition-colors cursor-pointer"
              >
                Log Call Outcome in CRM
              </button>
            </div>
          </div>
        </div>
      )}

      {/* 7. Route Directions & Navigation Modal */}
      {routeModalLead && (
        <div className="absolute inset-0 z-50 bg-black/50 flex flex-col justify-end animate-in fade-in duration-200">
          <div className="bg-white rounded-t-3xl p-5 shadow-2xl border-t border-[#E5E7EB] animate-in slide-in-from-bottom duration-250">
            <div className="w-10 h-1 bg-gray-200 rounded-full mx-auto mb-4" />
            <div className="flex items-center justify-between mb-3">
              <div>
                <span className="text-[11px] font-bold text-[#0F766E] bg-[#CCFBF1] px-2 py-0.5 rounded-md">
                  {routeModalLead.distanceKm.toFixed(1)} km away
                </span>
                <h3 className="text-base font-bold text-[#111827] mt-1">
                  Navigate to {routeModalLead.companyName}
                </h3>
              </div>
              <button
                onClick={() => setRouteModalLead(null)}
                className="w-7 h-7 rounded-full bg-gray-100 flex items-center justify-center text-gray-500 hover:text-black cursor-pointer"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <div className="p-3 bg-[#FAF7EE] rounded-xl border border-[#E5E7EB] mb-4 space-y-1.5 text-xs text-[#4B5563]">
              <div className="flex items-center space-x-2">
                <MapPin className="w-4 h-4 text-[#EF4444] shrink-0" />
                <span className="font-semibold text-[#111827]">{routeModalLead.locationArea}</span>
              </div>
              <div className="flex items-center space-x-2">
                <Clock className="w-4 h-4 text-[#6B7280] shrink-0" />
                <span>Est. travel time: ~{Math.round(routeModalLead.distanceKm * 4 + 4)} mins in South Mumbai traffic</span>
              </div>
            </div>

            <div className="space-y-2">
              <button
                onClick={() => {
                  triggerToast(`Starting GPS turn-by-turn navigation to ${routeModalLead.companyName}`);
                  setRouteModalLead(null);
                }}
                className="w-full py-3 bg-[#0F4C4C] text-white rounded-xl text-xs font-bold shadow-xs hover:bg-[#0c3c3c] flex items-center justify-center space-x-2 transition-transform active:scale-98 cursor-pointer"
              >
                <Navigation className="w-4 h-4 fill-current stroke-0" />
                <span>Start Turn-by-Turn Navigation</span>
              </button>
              <button
                onClick={() => {
                  triggerToast(`Visit added to today's schedule`);
                  setRouteModalLead(null);
                }}
                className="w-full py-2.5 bg-gray-100 text-[#111827] rounded-xl text-xs font-bold hover:bg-gray-200 transition-colors cursor-pointer"
              >
                Schedule Check-in Visit Today
              </button>
            </div>
          </div>
        </div>
      )}

      {/* 8. Cluster Modal: Shows 5 leads in South Mumbai Cluster */}
      {showClusterModal && (
        <div className="absolute inset-0 z-50 bg-black/50 flex flex-col justify-end animate-in fade-in duration-200">
          <div className="bg-white rounded-t-3xl p-5 shadow-2xl border-t border-[#E5E7EB] animate-in slide-in-from-bottom duration-250 max-h-[75%] flex flex-col">
            <div className="w-10 h-1 bg-gray-200 rounded-full mx-auto mb-4" />
            <div className="flex items-center justify-between mb-3 shrink-0">
              <div className="flex items-center space-x-2">
                <div className="w-7 h-7 rounded-full bg-[#0F4C4C] text-white text-xs font-bold flex items-center justify-center">
                  5
                </div>
                <div>
                  <h3 className="text-base font-bold text-[#111827]">
                    Cluster: Marine Drive & Chowpatty
                  </h3>
                  <p className="text-xs text-[#6B7280]">5 nearby sales leads in close vicinity</p>
                </div>
              </div>
              <button
                onClick={() => setShowClusterModal(false)}
                className="w-7 h-7 rounded-full bg-gray-100 flex items-center justify-center text-gray-500 hover:text-black cursor-pointer"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <div className="flex-1 overflow-y-auto space-y-2 py-1 no-scrollbar">
              {allLeads.slice(0, 5).map((l) => (
                <div
                  key={l.id}
                  onClick={() => {
                    setSelectedLead(l);
                    setShowClusterModal(false);
                    triggerToast(`Selected ${l.companyName}`);
                  }}
                  className="p-3 rounded-xl border border-gray-200 hover:border-[#0F4C4C] flex items-center justify-between cursor-pointer transition-colors"
                >
                  <div>
                    <div className="text-xs font-bold text-[#111827]">{l.companyName}</div>
                    <div className="text-[11px] text-gray-500">{l.contactName} · {l.locationArea}</div>
                  </div>
                  <span className="text-xs font-bold text-[#0F4C4C] bg-[#CCFBF1] px-2 py-0.5 rounded-md">
                    {l.distanceKm} km
                  </span>
                </div>
              ))}
            </div>

            <button
              onClick={() => setShowClusterModal(false)}
              className="mt-3 w-full py-2.5 bg-[#0F4C4C] text-white rounded-xl text-xs font-bold hover:bg-[#0c3c3c] cursor-pointer shrink-0"
            >
              Done
            </button>
          </div>
        </div>
      )}
    </div>
  );
};
