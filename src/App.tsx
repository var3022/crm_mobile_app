/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import React, { useState, useEffect, useRef } from 'react';
import {
  Smartphone,
  FileCode,
  CheckCircle2,
  Copy,
  Check,
  Eye,
  EyeOff,
  Mail,
  Lock,
  Building2,
  Terminal,
  User,
  ChevronDown,
  Briefcase,
  Award,
  ChevronLeft,
  RotateCcw,
  ShieldCheck,
  Shield,
  ArrowRight,
  ExternalLink,
  Sparkles,
  AlertTriangle,
  AlertCircle,
  Circle,
  CheckCheck,
  ScanFace,
  MapPin,
  Camera,
  Mic,
  Bell,
  Database,
  Calendar,
  Cloud,
  Home,
  Folder,
  Route,
  ListTodo,
  Plus,
  Bot,
  Handshake,
  Settings,
  ChevronRight,
  UserPlus
} from 'lucide-react';
import { LeadsListSimulator } from './components/LeadsListSimulator';
import { NearbyLeadsSimulator } from './components/NearbyLeadsSimulator';
import { leadsListDartCode } from './data/leadsDartCode';
import { nearbyLeadsDartCode } from './data/nearbyLeadsDartCode';

export default function App() {
  const [selectedScreen, setSelectedScreen] = useState<'leads-list' | 'nearby-leads' | 'dashboard' | 'notifications' | 'empty-notifications' | 'intro-slide-three' | 'intro-slide-two' | 'app-intro-walkthrough' | 'onboarding-complete' | 'onboarding-offline-setup' | 'onboarding-notifications' | 'onboarding-microphone' | 'onboarding-camera' | 'onboarding-location' | 'onboarding-welcome' | 'biometric' | 'biometric-fail' | 'logout-confirmation' | 'onboarding-skip-confirmation' | 'success' | 'reset' | 'otp' | 'forgot' | 'verification' | 'signup' | 'signin' | 'splash'>('nearby-leads');
  const [activeTab, setActiveTab] = useState<'preview' | 'code' | 'instructions'>('preview');
  const [copied, setCopied] = useState(false);

  // Logout Confirmation Screen State
  const [isLogoutModalOpen, setIsLogoutModalOpen] = useState(true);
  const [logoutSigningOut, setLogoutSigningOut] = useState(false);
  const [logoutToast, setLogoutToast] = useState<string | null>(null);

  // Onboarding Skip Confirmation Screen State
  const [isSkipModalOpen, setIsSkipModalOpen] = useState(true);
  const [skipConfirmationToast, setSkipConfirmationToast] = useState<string | null>(null);
  const [skippedFromScreen, setSkippedFromScreen] = useState<
    'onboarding-location' | 'onboarding-camera' | 'onboarding-microphone' | 'onboarding-notifications' | 'onboarding-offline-setup'
  >('onboarding-offline-setup');

  const triggerSkipConfirmation = (
    fromScreen: 'onboarding-location' | 'onboarding-camera' | 'onboarding-microphone' | 'onboarding-notifications' | 'onboarding-offline-setup',
    message?: string
  ) => {
    setSkippedFromScreen(fromScreen);
    setIsSkipModalOpen(true);
    if (message) {
      setSkipConfirmationToast(message);
    }
    setSelectedScreen('onboarding-skip-confirmation');
  };

  // Dashboard & Notification Screen 2 (Notifications) & Screen 3 (Empty Notifications) State
  const [notificationToast, setNotificationToast] = useState<string | null>(null);
  const [notificationFilter, setNotificationFilter] = useState<'All' | 'Unread' | 'Leads' | 'Visits'>('All');
  const [notificationNavIndex, setNotificationNavIndex] = useState(0);
  const [showNotificationSettingsModal, setShowNotificationSettingsModal] = useState(false);
  const [notificationSettings, setNotificationSettings] = useState({
    leads: true,
    visits: true,
    proposals: true,
    deals: true,
  });
  const [notificationsList, setNotificationsList] = useState([
    {
      id: '1',
      title: 'New lead assigned: Acme Corp',
      time: '2 hours ago',
      category: 'leads',
      isUnread: true,
      iconType: 'user',
      iconBg: '#E0F2F1',
      iconColor: '#0F4C4C',
      actionText: 'View Lead',
    },
    {
      id: '2',
      title: 'Visit with TechVista in 30 min',
      time: '30 min ago',
      category: 'visits',
      isUnread: true,
      iconType: 'calendar',
      iconBg: '#FEF3C7',
      iconColor: '#D97706',
    },
    {
      id: '3',
      title: 'John at Acme opened your proposal',
      time: '1 hour ago',
      category: 'leads',
      isUnread: true,
      iconType: 'eye',
      iconBg: '#DBEAFE',
      iconColor: '#2563EB',
    },
    {
      id: '4',
      title: 'Follow-up with DataFlow is due today',
      time: '3 hours ago',
      category: 'tasks',
      isUnread: false,
      iconType: 'alert',
      iconBg: '#FEF3C7',
      iconColor: '#D97706',
    },
    {
      id: '5',
      title: 'Deal moved to Negotiation',
      time: 'Yesterday',
      category: 'deals',
      isUnread: false,
      iconType: 'handshake',
      iconBg: '#EDE9FE',
      iconColor: '#7C3AED',
    },
  ]);

  const triggerNotificationToast = (msg: string) => {
    setNotificationToast(msg);
    setTimeout(() => {
      setNotificationToast(null);
    }, 2600);
  };

  const handleMarkAllNotificationsRead = () => {
    setNotificationsList(prev => prev.map(n => ({ ...n, isUnread: false })));
    triggerNotificationToast('All notifications marked as read');
  };

  const toggleNotificationItemRead = (id: string) => {
    setNotificationsList(prev =>
      prev.map(n => (n.id === id ? { ...n, isUnread: !n.isUnread } : n))
    );
  };

  const handleClearAllNotifications = () => {
    setNotificationsList([]);
    triggerNotificationToast('All notifications cleared • Empty state active');
  };

  const handleRestoreNotifications = () => {
    setNotificationsList([
      {
        id: '1',
        title: 'New lead assigned: Acme Corp',
        time: '2 hours ago',
        category: 'leads',
        isUnread: true,
        iconType: 'user',
        iconBg: '#E0F2F1',
        iconColor: '#0F4C4C',
        actionText: 'View Lead',
      },
      {
        id: '2',
        title: 'Visit with TechVista in 30 min',
        time: '30 min ago',
        category: 'visits',
        isUnread: true,
        iconType: 'calendar',
        iconBg: '#FEF3C7',
        iconColor: '#D97706',
        actionText: '',
      },
      {
        id: '3',
        title: 'John at Acme opened your proposal',
        time: '1 hour ago',
        category: 'leads',
        isUnread: true,
        iconType: 'eye',
        iconBg: '#DBEAFE',
        iconColor: '#2563EB',
        actionText: '',
      },
      {
        id: '4',
        title: 'Follow-up with DataFlow is due today',
        time: '3 hours ago',
        category: 'tasks',
        isUnread: false,
        iconType: 'alert',
        iconBg: '#FEF3C7',
        iconColor: '#D97706',
        actionText: '',
      },
      {
        id: '5',
        title: 'Deal moved to Negotiation',
        time: 'Yesterday',
        category: 'deals',
        isUnread: false,
        iconType: 'handshake',
        iconBg: '#EDE9FE',
        iconColor: '#7C3AED',
        actionText: '',
      },
    ]);
    triggerNotificationToast('Demo notifications loaded');
  };

  // Dashboard & Notification Screen 1 State
  const [dashboardToast, setDashboardToast] = useState<string | null>(null);
  const [dashboardNavIndex, setDashboardNavIndex] = useState(0);
  const [dashboardScheduleItems, setDashboardScheduleItems] = useState([
    {
      id: '1',
      time: '09:30 AM',
      status: 'completed',
      company: 'Acme Corp',
      contact: 'John Doe (CTO)',
      location: 'Nariman Point, South Mumbai',
      isCompleted: true,
    },
    {
      id: '2',
      time: '11:45 AM',
      status: 'completed',
      company: 'TechVista Ltd',
      contact: 'Priya Sharma (HR)',
      location: 'Lower Parel, Mumbai',
      isCompleted: true,
    },
    {
      id: '3',
      time: '02:30 PM',
      status: 'upcoming',
      company: 'DataFlow Systems',
      contact: 'Karan Malhotra (MD)',
      location: 'Andheri East, Mumbai',
      isCompleted: false,
    },
  ]);

  const triggerDashboardToast = (msg: string) => {
    setDashboardToast(msg);
    setTimeout(() => {
      setDashboardToast(null);
    }, 2800);
  };

  // Onboarding Screen 10: Intro Slide Three State
  const [introSlideThreeToast, setIntroSlideThreeToast] = useState<string | null>(null);

  const handleGetStartedIntroSlideThree = () => {
    setIntroSlideThreeToast("Walkthrough completed! Proceeding to Biometric Login...");
    setTimeout(() => {
      setIntroSlideThreeToast(null);
      setSelectedScreen('biometric');
    }, 600);
  };

  const handleSkipIntroSlideThree = () => {
    setIntroSlideThreeToast("Walkthrough skipped. Proceeding to Biometric Login...");
    setTimeout(() => {
      setIntroSlideThreeToast(null);
      setSelectedScreen('biometric');
    }, 500);
  };

  // Onboarding Screen 9: Intro Slide Two State
  const [introSlideTwoToast, setIntroSlideTwoToast] = useState<string | null>(null);

  const handleNextIntroSlideTwo = () => {
    setIntroSlideTwoToast("Proceeding to next walkthrough slide...");
    setTimeout(() => {
      setIntroSlideTwoToast(null);
      setSelectedScreen('intro-slide-three');
    }, 600);
  };

  const handleSkipIntroSlideTwo = () => {
    setIntroSlideTwoToast("Walkthrough skipped. Proceeding to Biometric Login...");
    setTimeout(() => {
      setIntroSlideTwoToast(null);
      setSelectedScreen('biometric');
    }, 500);
  };

  // Onboarding Screen 8: App Intro Walkthrough State
  const [walkthroughPage, setWalkthroughPage] = useState(0);
  const [walkthroughToast, setWalkthroughToast] = useState<string | null>(null);

  const walkthroughSlides = [
    {
      title: "Plan Your Day",
      subtitle: "AI-optimized routes, smart scheduling, and morning briefings to maximize your visits.",
      type: "map",
    },
    {
      title: "Track Your Visits",
      subtitle: "GPS-verified check-ins, real-time visit tracking, and automated meeting logs kept instantly in sync.",
      type: "track-visits",
    },
    {
      title: "Win with AI Insights",
      subtitle: "Smart lead scoring, deal win probability, and personalized day-coaching to close deals faster.",
      type: "ai-insights",
    },
  ];

  const handleNextWalkthrough = () => {
    if (walkthroughPage < walkthroughSlides.length - 1) {
      setWalkthroughPage(walkthroughPage + 1);
    } else {
      setWalkthroughToast("Intro complete! Proceeding to Biometric Security...");
      setTimeout(() => {
        setWalkthroughToast(null);
        setSelectedScreen('biometric');
      }, 700);
    }
  };

  const handleSkipWalkthrough = () => {
    setWalkthroughToast("Walkthrough skipped. Proceeding to Biometric Security...");
    setTimeout(() => {
      setWalkthroughToast(null);
      setSelectedScreen('biometric');
    }, 500);
  };

  // Onboarding: Complete State
  const [completeToast, setCompleteToast] = useState<string | null>(null);
  const handleOnboardingFinish = () => {
    setCompleteToast("Field kit ready! Starting App Walkthrough...");
    setTimeout(() => {
      setCompleteToast(null);
      setSelectedScreen('app-intro-walkthrough');
    }, 800);
  };

  // Onboarding Screen 6: Offline Setup State
  const [downloadProgress, setDownloadProgress] = useState(60);
  const [downloadedLeads, setDownloadedLeads] = useState(72);
  const [isDownloading, setIsDownloading] = useState(false);
  const [isDownloadCompleted, setIsDownloadCompleted] = useState(false);
  const [offlineToast, setOfflineToast] = useState<string | null>(null);

  const handleStartDownload = () => {
    if (isDownloading || isDownloadCompleted) return;
    setIsDownloading(true);

    let current = downloadedLeads;
    const interval = setInterval(() => {
      current += 4;
      if (current >= 120) {
        current = 120;
        clearInterval(interval);
        setDownloadedLeads(120);
        setDownloadProgress(100);
        setIsDownloading(false);
        setIsDownloadCompleted(true);
        setOfflineToast('Offline cache ready! South Mumbai territory synced.');
        setTimeout(() => {
          setOfflineToast(null);
          setSelectedScreen('onboarding-complete');
        }, 1200);
      } else {
        setDownloadedLeads(current);
        setDownloadProgress(Math.round((current / 120) * 100));
      }
    }, 80);
  };

  const handleSkipOffline = () => {
    triggerSkipConfirmation('onboarding-offline-setup');
  };

  // Onboarding Notifications State (Screen 5)
  const [notificationsStatus, setNotificationsStatus] = useState<'idle' | 'requesting' | 'granted'>('idle');
  const [notificationsToast, setNotificationsToast] = useState<string | null>(null);

  const handleAllowNotifications = () => {
    if (notificationsStatus === 'requesting' || notificationsStatus === 'granted') return;
    setNotificationsStatus('requesting');
    setTimeout(() => {
      setNotificationsStatus('granted');
      setNotificationsToast('Notifications enabled! Push channels calibrated for field sales.');
      setTimeout(() => {
        setNotificationsToast(null);
        setSelectedScreen('onboarding-offline-setup');
      }, 1200);
    }, 700);
  };

  const handleSkipNotifications = () => {
    triggerSkipConfirmation('onboarding-notifications');
  };

  // Onboarding Microphone State (Screen 4)
  const [microphoneStatus, setMicrophoneStatus] = useState<'idle' | 'requesting' | 'granted'>('idle');
  const [microphoneToast, setMicrophoneToast] = useState<string | null>(null);

  const handleAllowMicrophone = () => {
    if (microphoneStatus === 'requesting' || microphoneStatus === 'granted') return;
    setMicrophoneStatus('requesting');
    setTimeout(() => {
      setMicrophoneStatus('granted');
      setMicrophoneToast('Microphone access granted! Hands-free minutes & AI speech transcription enabled.');
      setTimeout(() => {
        setMicrophoneToast(null);
        setSelectedScreen('onboarding-notifications');
      }, 900);
    }, 700);
  };

  const handleSkipMicrophone = () => {
    triggerSkipConfirmation('onboarding-microphone');
  };

  // Onboarding Camera State (Screen 3)
  const [cameraStatus, setCameraStatus] = useState<'idle' | 'requesting' | 'granted'>('idle');
  const [cameraToast, setCameraToast] = useState<string | null>(null);

  const handleAllowCamera = () => {
    if (cameraStatus === 'requesting' || cameraStatus === 'granted') return;
    setCameraStatus('requesting');
    setTimeout(() => {
      setCameraStatus('granted');
      setCameraToast('Camera access granted! OCR ready for visiting cards and site compliance.');
      setTimeout(() => {
        setCameraToast(null);
        setSelectedScreen('onboarding-microphone');
      }, 900);
    }, 700);
  };

  const handleSkipCamera = () => {
    triggerSkipConfirmation('onboarding-camera');
  };

  // Onboarding Location State (Screen 2)
  const [locationStatus, setLocationStatus] = useState<'idle' | 'requesting' | 'granted'>('idle');
  const [locationToast, setLocationToast] = useState<string | null>(null);

  const handleAllowLocation = () => {
    if (locationStatus === 'requesting' || locationStatus === 'granted') return;
    setLocationStatus('requesting');
    setTimeout(() => {
      setLocationStatus('granted');
      setLocationToast('Location access granted! GPS calibrated for South Mumbai operations.');
      setTimeout(() => {
        setLocationToast(null);
        setSelectedScreen('onboarding-camera');
      }, 900);
    }, 700);
  };

  const handleSkipLocation = () => {
    triggerSkipConfirmation('onboarding-location');
  };

  // Onboarding Welcome State
  const [completedSteps, setCompletedSteps] = useState<string[]>([]);
  const [onboardingSuccessMessage, setOnboardingSuccessMessage] = useState<string | null>(null);

  const toggleOnboardingStep = (stepId: string) => {
    setCompletedSteps((prev) =>
      prev.includes(stepId) ? prev.filter((id) => id !== stepId) : [...prev, stepId]
    );
  };

  const handleLetsGo = () => {
    const allStepIds = ['location', 'camera', 'microphone', 'notifications', 'offline_data'];
    setCompletedSteps(allStepIds);
    setOnboardingSuccessMessage("Field kit ready! Proceeding to Location setup...");
    setTimeout(() => {
      setOnboardingSuccessMessage(null);
      setSelectedScreen('onboarding-location');
    }, 900);
  };

  // Biometric Login State
  const [biometricScanning, setBiometricScanning] = useState<boolean>(false);
  const [biometricSuccess, setBiometricSuccess] = useState<boolean>(false);

  const handleTriggerBiometric = () => {
    if (biometricScanning) return;
    setBiometricScanning(true);
    setBiometricSuccess(false);
    setTimeout(() => {
      setBiometricScanning(false);
      setBiometricSuccess(true);
    }, 1200);
  };

  // Screen 7: Reset Password ("Set New Password") State
  const [resetNewPassword, setResetNewPassword] = useState<string>('');
  const [resetConfirmPassword, setResetConfirmPassword] = useState<string>('');
  const [resetObscureNew, setResetObscureNew] = useState<boolean>(true);
  const [resetObscureConfirm, setResetObscureConfirm] = useState<boolean>(true);
  const [resetAttempted, setResetAttempted] = useState<boolean>(false);
  const [resetNewTouched, setResetNewTouched] = useState<boolean>(false);
  const [resetConfirmTouched, setResetConfirmTouched] = useState<boolean>(false);
  const [resetLoading, setResetLoading] = useState<boolean>(false);
  const [resetSuccessMessage, setResetSuccessMessage] = useState<string | null>(null);

  // Screen 6: OTP Verification State
  const [otpDigits, setOtpDigits] = useState<string[]>(['', '', '', '', '', '']);
  const [activeOtpIndex, setActiveOtpIndex] = useState<number>(0);
  const [focusedIndex, setFocusedIndex] = useState<number | null>(null);
  const [otpCountdown, setOtpCountdown] = useState<number>(45);
  const [otpLoading, setOtpLoading] = useState<boolean>(false);
  const [otpError, setOtpError] = useState<string | null>(null);
  const [otpSuccessMessage, setOtpSuccessMessage] = useState<string | null>(null);
  const otpInputRefs = useRef<(HTMLInputElement | null)[]>([]);

  // Screen 5: Forgot Password Form State
  const [forgotEmail, setForgotEmail] = useState('');
  const [forgotAttempted, setForgotAttempted] = useState(false);
  const [forgotLoading, setForgotLoading] = useState(false);
  const [forgotSuccessMessage, setForgotSuccessMessage] = useState<string | null>(null);

  // Email Verification State (Screen 4)
  const [countdown, setCountdown] = useState(45);
  const [isResending, setIsResending] = useState(false);
  const [verificationFeedback, setVerificationFeedback] = useState<string | null>(null);

  // Sign In Form State
  const [signInEmail, setSignInEmail] = useState('');
  const [signInPassword, setSignInPassword] = useState('');
  const [showSignInPassword, setShowSignInPassword] = useState(false);
  const [signInAttempted, setSignInAttempted] = useState(false);

  // Sign Up Form State
  const [fullName, setFullName] = useState('');
  const [signUpEmail, setSignUpEmail] = useState('');
  const [countryCode, setCountryCode] = useState('+91');
  const [phone, setPhone] = useState('');
  const [companyName, setCompanyName] = useState('');
  const [designation, setDesignation] = useState('');
  const [signUpAttempted, setSignUpAttempted] = useState(false);
  const [showCountryDropdown, setShowCountryDropdown] = useState(false);
  const [showDesignationDropdown, setShowDesignationDropdown] = useState(false);
  const [submittedSuccess, setSubmittedSuccess] = useState(false);

  const countryCodes = ['+91', '+1', '+44', '+65', '+971', '+61'];
  const designations = [
    'Field Sales Executive',
    'Area Sales Manager',
    'Senior Sales Representative',
    'Territory Lead',
    'Business Development Executive',
    'Sales Director',
  ];

  // Validation rules for Sign Up
  const fullNameError = signUpAttempted && !fullName.trim() ? 'Full name is required' : '';
  const signUpEmailError =
    signUpAttempted && !signUpEmail.trim()
      ? 'Email address is required'
      : signUpAttempted && (!signUpEmail.includes('@') || !signUpEmail.includes('.'))
      ? 'Email address is invalid'
      : '';
  const phoneError = signUpAttempted && !phone.trim() ? 'Phone number is required' : '';
  const companyError = signUpAttempted && !companyName.trim() ? 'Company name is required' : '';
  const designationError = signUpAttempted && !designation ? 'Please select a designation' : '';

  // Validation rules for Sign In
  const signInEmailError =
    signInAttempted && !signInEmail.trim()
      ? 'Email address is required'
      : signInAttempted && (!signInEmail.includes('@') || !signInEmail.includes('.'))
      ? 'Email address is invalid'
      : '';
  const signInPasswordError = signInAttempted && !signInPassword.trim() ? 'Password is required' : '';

  const handleSignUpSubmit = (e?: React.FormEvent) => {
    if (e) e.preventDefault();
    setSignUpAttempted(true);
    if (
      fullName.trim() &&
      signUpEmail.trim() &&
      signUpEmail.includes('@') &&
      phone.trim() &&
      companyName.trim() &&
      designation
    ) {
      setSubmittedSuccess(true);
      setTimeout(() => {
        setSubmittedSuccess(false);
        setCountdown(45);
        setSelectedScreen('verification');
      }, 1000);
    }
  };

  const handleSignInSubmit = (e?: React.FormEvent) => {
    if (e) e.preventDefault();
    setSignInAttempted(true);
    if (signInEmail.trim() && signInPassword.trim()) {
      setSubmittedSuccess(true);
      setTimeout(() => setSubmittedSuccess(false), 3000);
    }
  };

  // Verification Screen Timer Effect
  useEffect(() => {
    if (selectedScreen !== 'verification') return;
    if (countdown <= 0) return;
    const interval = setInterval(() => {
      setCountdown((prev) => (prev > 0 ? prev - 1 : 0));
    }, 1000);
    return () => clearInterval(interval);
  }, [countdown, selectedScreen]);

  // Screen 6: OTP Countdown Timer
  useEffect(() => {
    if (selectedScreen !== 'otp' || otpCountdown <= 0) return;
    const interval = setInterval(() => {
      setOtpCountdown((prev) => (prev > 0 ? prev - 1 : 0));
    }, 1000);
    return () => clearInterval(interval);
  }, [otpCountdown, selectedScreen]);

  // Disappear invalid code warning whenever all boxes are empty
  useEffect(() => {
    const isAllEmpty = otpDigits.every((d) => !d || d.trim() === '');
    if (isAllEmpty && otpError) {
      setOtpError(null);
    }
  }, [otpDigits, otpError]);

  // Check if all 6 digits are entered
  const isOtpComplete = otpDigits.every((d) => d.trim() !== '') && otpDigits.join('').length === 6;
  const isVerifyDisabled = !isOtpComplete || otpLoading;

  const handleOtpChange = (index: number, value: string) => {
    const digitsOnly = value.replace(/\D/g, '');
    setOtpError(null);

    if (digitsOnly.length > 1) {
      const newDigits = [...otpDigits];
      for (let i = 0; i < 6 && i < digitsOnly.length; i++) {
        newDigits[i] = digitsOnly[i];
      }
      setOtpDigits(newDigits);
      const nextIndex = Math.min(digitsOnly.length, 5);
      setActiveOtpIndex(nextIndex);
      otpInputRefs.current[nextIndex]?.focus();
      return;
    }

    const newDigits = [...otpDigits];
    newDigits[index] = digitsOnly.slice(-1);
    setOtpDigits(newDigits);

    if (digitsOnly.length > 0) {
      if (index < 5) {
        setActiveOtpIndex(index + 1);
        otpInputRefs.current[index + 1]?.focus();
      } else {
        otpInputRefs.current[index]?.blur();
      }
    }
  };

  const handleOtpKeyDown = (index: number, e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Backspace') {
      setOtpError(null);
      if (!otpDigits[index] && index > 0) {
        const newDigits = [...otpDigits];
        newDigits[index - 1] = '';
        setOtpDigits(newDigits);
        setActiveOtpIndex(index - 1);
        otpInputRefs.current[index - 1]?.focus();
      } else {
        const newDigits = [...otpDigits];
        newDigits[index] = '';
        setOtpDigits(newDigits);
      }
    } else if (e.key === 'ArrowLeft' && index > 0) {
      setActiveOtpIndex(index - 1);
      otpInputRefs.current[index - 1]?.focus();
    } else if (e.key === 'ArrowRight' && index < 5) {
      setActiveOtpIndex(index + 1);
      otpInputRefs.current[index + 1]?.focus();
    }
  };

  const handleOtpResend = () => {
    if (otpCountdown > 0 || otpLoading) return;
    setOtpLoading(true);
    setOtpError(null);
    setTimeout(() => {
      setOtpLoading(false);
      setOtpCountdown(45);
      setOtpSuccessMessage('New 6-digit code sent to j***@company.com');
      setTimeout(() => setOtpSuccessMessage(null), 3500);
    }, 600);
  };

  const handleVerifyOtp = () => {
    const code = otpDigits.join('');
    if (code.length < 6) {
      return;
    }
    setOtpLoading(true);
    setOtpError(null);
    setTimeout(() => {
      setOtpLoading(false);
      if (code === '123456') {
        setOtpSuccessMessage('Identity verified successfully!');
        setTimeout(() => {
          setSelectedScreen('reset');
        }, 1500);
      } else {
        setOtpError('Invalid code. Please check and try again.');
      }
    }, 700);
  };

  // Screen 7: Criteria evaluation
  const resetRuleLength = resetNewPassword.length >= 8;
  const resetRuleUpperLower = /[a-z]/.test(resetNewPassword) && /[A-Z]/.test(resetNewPassword);
  const resetRuleNumber = /[0-9]/.test(resetNewPassword);
  const resetRuleSpecial = /[!@#$%^&*(),.?":{}|<>_\-]/.test(resetNewPassword);

  const resetStrengthScore =
    (resetRuleLength ? 1 : 0) +
    (resetRuleUpperLower ? 1 : 0) +
    (resetRuleNumber ? 1 : 0) +
    (resetRuleSpecial ? 1 : 0);

  const resetStrengthLabel =
    resetNewPassword.length === 0
      ? ''
      : resetStrengthScore <= 1
      ? 'Weak'
      : resetStrengthScore === 2
      ? 'Medium'
      : 'Strong';

  const resetStrengthColor =
    resetStrengthScore <= 1 ? '#EF4444' : resetStrengthScore === 2 ? '#F59E0B' : '#10B981';

  const resetStrengthPercent =
    resetNewPassword.length === 0 ? 0 : Math.round((resetStrengthScore / 4) * 100);

  // Errors for Screen 7: show warnings on respective cases fail (all 4 cases applicable)
  const resetNewError =
    resetAttempted && resetNewPassword.length === 0
      ? 'Password must be at least 8 characters'
      : (resetAttempted || resetNewTouched) && resetNewPassword.length > 0
      ? !resetRuleLength
        ? 'Password must be at least 8 characters'
        : !resetRuleUpperLower
        ? 'Must include uppercase & lowercase letters'
        : !resetRuleNumber
        ? 'Must include a number'
        : !resetRuleSpecial
        ? 'Must include a special character'
        : null
      : null;

  const resetConfirmError =
    resetAttempted && resetConfirmPassword.length === 0
      ? 'Passwords do not match'
      : (resetAttempted || resetConfirmTouched) &&
        resetConfirmPassword.length > 0 &&
        resetConfirmPassword !== resetNewPassword
      ? 'Passwords do not match'
      : null;

  const isResetFormValid =
    resetRuleLength &&
    resetRuleUpperLower &&
    resetRuleNumber &&
    resetRuleSpecial &&
    resetConfirmPassword.length > 0 &&
    resetConfirmPassword === resetNewPassword;

  const handleResetPasswordSubmit = () => {
    setResetAttempted(true);
    setResetNewTouched(true);
    setResetConfirmTouched(true);

    if (!isResetFormValid) {
      return;
    }

    setResetLoading(true);
    setTimeout(() => {
      setResetLoading(false);
      setSelectedScreen('success');
    }, 700);
  };

  const resetPasswordDartCode = `import "package:flutter/material.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_typography.dart";
import "../../../core/theme/app_dimensions.dart";
import "../../../core/theme/app_spacing.dart";

/// Screen 7: Reset Password Screen ("Set New Password")
/// Pixel-accurate reproduction of the CRM Pro Field Sales Set New Password screen.
class ResetPasswordScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final ValueChanged<String>? onResetSuccess;
  final VoidCallback? onSignInTap;
  final String? initialPassword;
  final String? initialConfirmPassword;

  const ResetPasswordScreen({
    super.key,
    this.onBack,
    this.onResetSuccess,
    this.onSignInTap,
    this.initialPassword,
    this.initialConfirmPassword,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _hasAttemptedSubmit = false;
  bool _newPasswordTouched = false;
  bool _confirmPasswordTouched = false;
  bool _showSuccessToast = false;
  String _successToastMessage = "";

  @override
  void initState() {
    super.initState();
    _newPasswordController = TextEditingController(text: widget.initialPassword ?? "");
    _confirmPasswordController = TextEditingController(text: widget.initialConfirmPassword ?? "");

    _newPasswordController.addListener(_onPasswordChanged);
    _confirmPasswordController.addListener(_onConfirmPasswordChanged);
  }

  @override
  void dispose() {
    _newPasswordController.removeListener(_onPasswordChanged);
    _confirmPasswordController.removeListener(_onConfirmPasswordChanged);
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onPasswordChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onConfirmPasswordChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  // Password validation criteria
  bool get _hasMinLength => _newPasswordController.text.length >= 8;
  bool get _hasUpperAndLower {
    final text = _newPasswordController.text;
    return RegExp(r"(?=.*[a-z])(?=.*[A-Z])").hasMatch(text);
  }
  bool get _hasNumber => RegExp(r"[0-9]").hasMatch(_newPasswordController.text);
  bool get _hasSpecialChar => RegExp(r'[!@#\\$%^&*(),.?":{}|<>_\\-]').hasMatch(_newPasswordController.text);

  int get _strengthScore {
    int score = 0;
    if (_hasMinLength) score++;
    if (_hasUpperAndLower) score++;
    if (_hasNumber) score++;
    if (_hasSpecialChar) score++;
    return score;
  }

  String get _strengthLabel {
    final text = _newPasswordController.text;
    if (text.isEmpty) return "";
    final score = _strengthScore;
    if (score <= 1) return "Weak";
    if (score == 2) return "Medium";
    return "Strong";
  }

  Color get _strengthColor {
    final score = _strengthScore;
    if (score <= 1) return AppColors.error;
    if (score == 2) return AppColors.warning;
    return AppColors.success;
  }

  double get _strengthProgress {
    final text = _newPasswordController.text;
    if (text.isEmpty) return 0.0;
    return (_strengthScore / 4).clamp(0.0, 1.0);
  }

  String? get _newPasswordError {
    final text = _newPasswordController.text;
    if (_hasAttemptedSubmit && text.isEmpty) {
      return "Password must be at least 8 characters";
    }
    if ((_hasAttemptedSubmit || _newPasswordTouched) && text.isNotEmpty) {
      if (!_hasMinLength) {
        return "Password must be at least 8 characters";
      }
      if (!_hasUpperAndLower) {
        return "Must include uppercase & lowercase letters";
      }
      if (!_hasNumber) {
        return "Must include a number";
      }
      if (!_hasSpecialChar) {
        return "Must include a special character";
      }
    }
    return null;
  }

  String? get _confirmPasswordError {
    final newPass = _newPasswordController.text;
    final confirmPass = _confirmPasswordController.text;
    if (_hasAttemptedSubmit && confirmPass.isEmpty) {
      return "Passwords do not match";
    }
    if ((_hasAttemptedSubmit || _confirmPasswordTouched) && confirmPass.isNotEmpty && newPass != confirmPass) {
      return "Passwords do not match";
    }
    return null;
  }

  bool get _isFormValid {
    final newPass = _newPasswordController.text;
    final confirmPass = _confirmPasswordController.text;
    return _hasMinLength &&
        _hasUpperAndLower &&
        _hasNumber &&
        _hasSpecialChar &&
        confirmPass.isNotEmpty &&
        newPass == confirmPass;
  }

  void _handleResetPassword() {
    setState(() {
      _hasAttemptedSubmit = true;
      _newPasswordTouched = true;
      _confirmPasswordTouched = true;
    });

    if (!_isFormValid) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _showSuccessToast = true;
        _successToastMessage = "Password reset successfully! Redirecting to Sign In...";
      });

      widget.onResetSuccess?.call(_newPasswordController.text);

      Future.delayed(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        widget.onSignInTap?.call();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.spacing24,
                          vertical: AppSpacing.spacing16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Back Button
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Semantics(
                                button: true,
                                label: "Back to previous screen",
                                child: InkWell(
                                  onTap: widget.onBack ?? () => Navigator.of(context).maybePop(),
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.chevron_left_rounded,
                                      size: 30,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Feedback Toast
                            if (_showSuccessToast) ...[
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.successLight,
                                  border: Border.all(
                                    color: AppColors.success.withValues(alpha: 0.3),
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      color: AppColors.success,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _successToastMessage,
                                        style: AppTypography.caption.copyWith(
                                          color: const Color(0xFF065F46),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 20),

                            // Headline
                            Text(
                              "Set New Password",
                              style: AppTypography.h1.copyWith(
                                color: const Color(0xFF0F172A),
                                fontWeight: FontWeight.w800,
                                fontSize: 26,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Your new password must be different from previous used passwords.",
                              style: AppTypography.bodyMedium.copyWith(
                                color: const Color(0xFF64748B),
                                fontSize: 14,
                                height: 1.45,
                              ),
                            ),

                            const SizedBox(height: 28),

                            // Field 1: New Password
                            _buildLabel("New Password"),
                            const SizedBox(height: 8),
                            _buildPasswordField(
                              controller: _newPasswordController,
                              isObscured: _obscureNewPassword,
                              onToggleObscure: () {
                                setState(() {
                                  _obscureNewPassword = !_obscureNewPassword;
                                });
                              },
                              hasError: _newPasswordError != null,
                              onChanged: (val) {
                                setState(() {
                                  if (val.isNotEmpty) {
                                    _newPasswordTouched = true;
                                  } else if (!_hasAttemptedSubmit) {
                                    _newPasswordTouched = false;
                                  }
                                });
                              },
                              hintText: "Enter new password",
                            ),

                            // New Password Error Message
                            if (_newPasswordError != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                _newPasswordError!,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.error,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],

                            const SizedBox(height: 18),

                            // Password Strength Row & Meter
                            if (_newPasswordController.text.isNotEmpty) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Password Strength",
                                    style: AppTypography.bodySmall.copyWith(
                                      color: const Color(0xFF334155),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    _strengthLabel,
                                    style: AppTypography.bodySmall.copyWith(
                                      color: _strengthColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: SizedBox(
                                  height: 4,
                                  child: LinearProgressIndicator(
                                    value: _strengthProgress,
                                    backgroundColor: const Color(0xFFE2E8F0),
                                    valueColor: AlwaysStoppedAnimation<Color>(_strengthColor),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                            ],

                            // Field 2: Confirm New Password
                            _buildLabel("Confirm New Password"),
                            const SizedBox(height: 8),
                            _buildPasswordField(
                              controller: _confirmPasswordController,
                              isObscured: _obscureConfirmPassword,
                              onToggleObscure: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                              hasError: _confirmPasswordError != null,
                              onChanged: (val) {
                                setState(() {
                                  if (val.isNotEmpty) {
                                    _confirmPasswordTouched = true;
                                  } else if (!_hasAttemptedSubmit) {
                                    _confirmPasswordTouched = false;
                                  }
                                });
                              },
                              hintText: "Confirm new password",
                            ),

                            // Confirm Password Error Message
                            if (_confirmPasswordError != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                _confirmPasswordError!,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.error,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],

                            const SizedBox(height: 22),

                            // Requirements Checklist
                            _buildRuleItem(
                              isMet: _hasMinLength,
                              text: "At least 8 characters long",
                            ),
                            const SizedBox(height: 10),
                            _buildRuleItem(
                              isMet: _hasUpperAndLower,
                              text: "Includes uppercase & lowercase",
                            ),
                            const SizedBox(height: 10),
                            _buildRuleItem(
                              isMet: _hasNumber,
                              text: "Includes a number",
                            ),
                            const SizedBox(height: 10),
                            _buildRuleItem(
                              isMet: _hasSpecialChar,
                              text: "Includes a special character",
                            ),

                            const SizedBox(height: 32),

                            // Primary CTA: Reset Password Button (disabled until all cases pass)
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: (_isLoading || !_isFormValid) ? null : _handleResetPassword,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isFormValid ? AppColors.primary : AppColors.primary.withOpacity(0.4),
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: AppColors.primary.withOpacity(0.4),
                                  disabledForegroundColor: Colors.white.withOpacity(0.7),
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.4,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : Text(
                                        "Reset Password",
                                        style: AppTypography.buttonLarge.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                        ),
                                      ),
                              ),
                            ),

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: AppTypography.bodySmall.copyWith(
        color: const Color(0xFF0F172A),
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required bool isObscured,
    required VoidCallback onToggleObscure,
    required bool hasError,
    required ValueChanged<String> onChanged,
    required String hintText,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: hasError ? const Color(0xFFFDE8E8) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasError ? const Color(0xFFF87171) : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: isObscured,
        onChanged: onChanged,
        style: AppTypography.bodyMedium.copyWith(
          color: const Color(0xFF0F172A),
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: const Color(0xFF94A3B8),
            fontSize: 15,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: Icon(
              isObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: const Color(0xFF64748B),
              size: 20,
            ),
            onPressed: onToggleObscure,
            splashRadius: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildRuleItem({
    required bool isMet,
    required String text,
  }) {
    return Row(
      children: [
        if (isMet)
          const Icon(
            Icons.check_rounded,
            color: Color(0xFF10B981),
            size: 18,
          )
        else
          Container(
            width: 16,
            height: 16,
            margin: const EdgeInsets.only(left: 1, right: 1),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF94A3B8),
                width: 1.5,
              ),
            ),
          ),
        const SizedBox(width: 10),
        Text(
          text,
          style: AppTypography.bodySmall.copyWith(
            color: isMet ? const Color(0xFF334155) : const Color(0xFF64748B),
            fontWeight: isMet ? FontWeight.w500 : FontWeight.w400,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}`;

  const onboardingWelcomeDartCode = `import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_typography.dart";
import "../../../core/theme/app_dimensions.dart";
import "../../../core/theme/app_spacing.dart";

/// Setup step model for Onboarding Welcome checklist
class SetupStepItem {
  final String id;
  final String title;
  final IconData icon;
  final String? description;

  const SetupStepItem({
    required this.id,
    required this.title,
    required this.icon,
    this.description,
  });
}

/// Onboarding Screen 1: Onboarding Welcome Screen
/// Pixel-accurate implementation matching the CRM Pro Field Sales design system.
class OnboardingWelcomeScreen extends StatefulWidget {
  final String userName;
  final String userInitials;
  final String companyName;
  final String assignedTerritory;
  final List<SetupStepItem> steps;
  final VoidCallback? onLetsGo;

  const OnboardingWelcomeScreen({
    super.key,
    this.userName = "Arjun",
    this.userInitials = "AM",
    this.companyName = "Acme Industries",
    this.assignedTerritory = "South Mumbai",
    this.steps = const [
      SetupStepItem(
        id: "location",
        title: "Location Access",
        icon: Icons.location_on_outlined,
        description: "Enables client geolocation and route tracking",
      ),
      SetupStepItem(
        id: "camera",
        title: "Camera Access",
        icon: Icons.camera_alt_outlined,
        description: "Enables invoice and visual proof scanning",
      ),
      SetupStepItem(
        id: "microphone",
        title: "Microphone Access",
        icon: Icons.mic_none_outlined,
        description: "Enables audio memos and visit notes",
      ),
      SetupStepItem(
        id: "notifications",
        title: "Notifications",
        icon: Icons.notifications_none_outlined,
        description: "Delivers urgent field visit updates and reminders",
      ),
      SetupStepItem(
        id: "offline_data",
        title: "Offline Data Setup",
        icon: Icons.dns_outlined,
        description: "Syncs territory master data for offline work",
      ),
    ],
    this.onLetsGo,
  });

  @override
  State<OnboardingWelcomeScreen> createState() => _OnboardingWelcomeScreenState();
}

class _OnboardingWelcomeScreenState extends State<OnboardingWelcomeScreen> {
  final Set<String> _completedStepIds = {};

  void _toggleStep(String stepId) {
    setState(() {
      if (_completedStepIds.contains(stepId)) {
        _completedStepIds.remove(stepId);
      } else {
        _completedStepIds.add(stepId);
      }
    });
  }

  void _handleLetsGo() {
    if (widget.onLetsGo != null) {
      widget.onLetsGo!();
    } else {
      Navigator.of(context).pushNamed("/onboarding-step-2");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // 1. Top Avatar Badge: Centered dark teal squircle with white initials ("AM")
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.18),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    widget.userInitials,
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 2. Greeting Headline: "Hi Arjun!"
              Text(
                "Hi \${widget.userName}!",
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.6,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 8),

              // 3. Subtitle / Description
              Text(
                "Let's set up your field kit in under a minute to prepare for \${widget.assignedTerritory} territory operations.",
                style: GoogleFonts.inter(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),

              const SizedBox(height: 20),

              // 4. Company & Territory Info Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFD1FADF),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.business_center_outlined,
                        size: 20,
                        color: Color(0xFF0F766E),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.companyName,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Assigned Territory: \${widget.assignedTerritory}",
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 5. Section Header: "REQUIRED SETUP PROGRESS"
              Text(
                "REQUIRED SETUP PROGRESS",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6B7280),
                  letterSpacing: 0.6,
                ),
              ),

              const SizedBox(height: 8),

              // 6. Checklist Items
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  itemCount: widget.steps.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = widget.steps[index];
                    final isCompleted = _completedStepIds.contains(item.id);

                    return InkWell(
                      onTap: () => _toggleStep(item.id),
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              size: 22,
                              color: isCompleted
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                item.title,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isCompleted
                                    ? const Color(0xFF10B981)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isCompleted
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFD1D5DB),
                                  width: 1.8,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: isCompleted
                                  ? const Icon(
                                      Icons.check,
                                      size: 14,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 7. Bottom CTA Button: "Let's Go"
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0, top: 12.0),
                child: SizedBox(
                  width: double.infinity,
                  height: AppDimensions.buttonHeight,
                  child: ElevatedButton(
                    onPressed: _handleLetsGo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                      ),
                    ),
                    child: Text(
                      "Let's Go",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
`;

  const onboardingLocationDartCode = `import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_typography.dart";
import "../../../core/theme/app_dimensions.dart";
import "../../../core/theme/app_spacing.dart";

/// Screen 2 of Onboarding: Location Permission
/// Follows CRM Pro Flutter/Dart design system and architecture.
class OnboardingLocationScreen extends StatefulWidget {
  final VoidCallback? onAllowLocation;
  final VoidCallback? onSkip;

  const OnboardingLocationScreen({
    super.key,
    this.onAllowLocation,
    this.onSkip,
  });

  @override
  State<OnboardingLocationScreen> createState() =>
      _OnboardingLocationScreenState();
}

class _OnboardingLocationScreenState extends State<OnboardingLocationScreen> {
  bool _isRequesting = false;
  bool _isGranted = false;

  void _handleAllowLocation() async {
    if (_isRequesting || _isGranted) return;

    setState(() {
      _isRequesting = true;
    });

    // Simulate location permission request latency
    await Future.delayed(const Duration(milliseconds: 700));

    if (mounted) {
      setState(() {
        _isRequesting = false;
        _isGranted = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Location permission granted successfully!"),
          backgroundColor: AppColors.primary,
          duration: Duration(seconds: 2),
        ),
      );

      if (widget.onAllowLocation != null) {
        widget.onAllowLocation!();
      } else {
        Navigator.of(context).pushNamed("/onboarding-step-3");
      }
    }
  }

  void _handleSkip() {
    if (widget.onSkip != null) {
      widget.onSkip!();
    } else {
      Navigator.of(context).pushNamed("/onboarding-step-3");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // 1. Top Progress Indicator (Step 2 of Onboarding: ~25%)
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  height: 4.5,
                  width: double.infinity,
                  color: const Color(0xFFE5E7EB),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.25,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary, // #0F4C4C
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 2. Hero Graphic Card: Light mint container with custom route/nodes illustration
              Container(
                width: double.infinity,
                height: 210,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF9), // Soft mint tint
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: CustomPaint(
                  size: const Size(140, 140),
                  painter: _RouteIllustrationPainter(),
                ),
              ),

              const SizedBox(height: 28),

              // 3. Title: "Enable Location"
              Text(
                "Enable Location",
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.6,
                  height: 1.15,
                ),
              ),

              const SizedBox(height: 10),

              // 4. Subtitle / Purpose Explanation
              Text(
                "We use GPS to verify your check-ins, optimize your routes, and show nearby leads.",
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),

              const SizedBox(height: 24),

              // 5. Value Propositions List (3 key benefits with checkmark icons)
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: const [
                    _BenefitItem(
                      title: "Accurate Check-ins",
                      description:
                          "Geofenced visits automatically logs meetings at the client's office.",
                    ),
                    SizedBox(height: 20),
                    _BenefitItem(
                      title: "Smart Route Optimization",
                      description:
                          "Minimize commute fatigue with dynamic sequence plans.",
                    ),
                    SizedBox(height: 20),
                    _BenefitItem(
                      title: "Nearby Client Alerts",
                      description:
                          "Discover unassigned hot prospects within 1 km of your current site.",
                    ),
                  ],
                ),
              ),

              // 6. Bottom Action Controls
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
                child: Column(
                  children: [
                    // Primary CTA: "Allow Location Access"
                    SizedBox(
                      width: double.infinity,
                      height: AppDimensions.buttonHeight,
                      child: ElevatedButton(
                        onPressed: _handleAllowLocation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusButton,
                            ),
                          ),
                        ),
                        child: _isRequesting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                _isGranted
                                    ? "Location Access Granted"
                                    : "Allow Location Access",
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: -0.2,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Secondary Action: "Skip for now"
                    TextButton(
                      onPressed: _handleSkip,
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF6B7280),
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                      ),
                      child: Text(
                        "Skip for now",
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper widget to render each value proposition item with a green checkmark badge
class _BenefitItem extends StatelessWidget {
  final String title;
  final String description;

  const _BenefitItem({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          margin: const EdgeInsets.only(top: 2),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFD1FADF),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.check,
            size: 14,
            color: Color(0xFF0F766E),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Custom painter for the route & nodes illustration matching the reference image
class _RouteIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const tealColor = Color(0xFF0F4C4C);

    final strokePaint = Paint()
      ..color = tealColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final nodeFillPaint = Paint()
      ..color = const Color(0xFFF0FDF9)
      ..style = PaintingStyle.fill;

    // 1. Draw outer boundary L-bracket frame
    final framePath = Path();
    framePath.moveTo(size.width * 0.15, size.height * 0.18);
    framePath.lineTo(size.width * 0.15, size.height * 0.80);
    framePath.quadraticBezierTo(
      size.width * 0.15,
      size.height * 0.88,
      size.width * 0.24,
      size.height * 0.88,
    );
    framePath.lineTo(size.width * 0.82, size.height * 0.88);
    canvas.drawPath(framePath, strokePaint);

    // 2. Define node positions (3 connected route waypoints)
    final nodeA = Offset(size.width * 0.52, size.height * 0.28);
    final nodeB = Offset(size.width * 0.68, size.height * 0.48);
    final nodeC = Offset(size.width * 0.42, size.height * 0.70);

    final leadInEnd = Offset(size.width * 0.80, size.height * 0.22);
    canvas.drawLine(leadInEnd, nodeA, strokePaint);
    canvas.drawLine(nodeA, nodeB, strokePaint);
    canvas.drawLine(nodeB, nodeC, strokePaint);

    const nodeRadius = 8.5;
    final nodes = [nodeA, nodeB, nodeC];

    for (final node in nodes) {
      canvas.drawCircle(node, nodeRadius, nodeFillPaint);
      canvas.drawCircle(node, nodeRadius, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
`;

  const onboardingCameraDartCode = `import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_dimensions.dart";
import "../../../core/theme/app_spacing.dart";

/// Screen 3 of Onboarding: Camera Permission
/// Follows CRM Pro Flutter/Dart design system and architecture.
class OnboardingCameraScreen extends StatefulWidget {
  final VoidCallback? onAllowCamera;
  final VoidCallback? onSkip;

  const OnboardingCameraScreen({
    super.key,
    this.onAllowCamera,
    this.onSkip,
  });

  @override
  State<OnboardingCameraScreen> createState() => _OnboardingCameraScreenState();
}

class _OnboardingCameraScreenState extends State<OnboardingCameraScreen> {
  bool _isRequesting = false;
  bool _isGranted = false;

  void _handleAllowCamera() async {
    if (_isRequesting || _isGranted) return;

    setState(() {
      _isRequesting = true;
    });

    // Simulate camera permission request latency
    await Future.delayed(const Duration(milliseconds: 700));

    if (mounted) {
      setState(() {
        _isRequesting = false;
        _isGranted = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Camera permission granted successfully!"),
          backgroundColor: AppColors.primary,
          duration: Duration(seconds: 2),
        ),
      );

      if (widget.onAllowCamera != null) {
        widget.onAllowCamera!();
      } else {
        Navigator.of(context).pushNamed("/onboarding-step-4");
      }
    }
  }

  void _handleSkip() {
    if (widget.onSkip != null) {
      widget.onSkip!();
    } else {
      Navigator.of(context).pushNamed("/onboarding-step-4");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // 1. Top Progress Indicator (Step 3 of Onboarding: ~42%)
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  height: 4.5,
                  width: double.infinity,
                  color: const Color(0xFFE5E7EB),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.42,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary, // #0F4C4C
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 2. Hero Graphic Card: Light mint container with custom camera line illustration
              Container(
                width: double.infinity,
                height: 210,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF9), // Soft mint tint
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: CustomPaint(
                  size: const Size(106, 106),
                  painter: _CameraIllustrationPainter(),
                ),
              ),

              const SizedBox(height: 28),

              // 3. Title: "Enable Camera"
              Text(
                "Enable Camera",
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.6,
                  height: 1.15,
                ),
              ),

              const SizedBox(height: 10),

              // 4. Subtitle / Purpose Explanation
              Text(
                "Capture visiting cards, customer photos, and documents during visits.",
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),

              const SizedBox(height: 24),

              // 5. Value Propositions List (3 key benefits with mint checkmark badges)
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: const [
                    _BenefitItem(
                      title: "Business Card OCR",
                      description:
                          "Instant lead translation from physical cards directly to the CRM.",
                    ),
                    SizedBox(height: 20),
                    _BenefitItem(
                      title: "Site Verification",
                      description:
                          "Upload physical storefront images as meeting proof for compliance.",
                    ),
                    SizedBox(height: 20),
                    _BenefitItem(
                      title: "Receipt Scans",
                      description:
                          "Instantly log client lunch bills to expenses on the fly.",
                    ),
                  ],
                ),
              ),

              // 6. Bottom Action Controls
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
                child: Column(
                  children: [
                    // Primary CTA: "Allow Camera Access"
                    SizedBox(
                      width: double.infinity,
                      height: AppDimensions.buttonHeight,
                      child: ElevatedButton(
                        onPressed: _handleAllowCamera,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusButton,
                            ),
                          ),
                        ),
                        child: _isRequesting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                _isGranted
                                    ? "Camera Access Granted"
                                    : "Allow Camera Access",
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: -0.2,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Secondary Action: "Skip for now"
                    TextButton(
                      onPressed: _handleSkip,
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF6B7280),
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                      ),
                      child: Text(
                        "Skip for now",
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper widget to render each value proposition item with a mint checkmark badge
class _BenefitItem extends StatelessWidget {
  final String title;
  final String description;

  const _BenefitItem({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          margin: const EdgeInsets.only(top: 2),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFD1FADF),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.check,
            size: 14,
            color: Color(0xFF0F766E),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Custom painter for the camera outline illustration matching the reference image
class _CameraIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const tealColor = Color(0xFF0F4C4C);

    final strokePaint = Paint()
      ..color = tealColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final scale = size.width / 24.0;

    // Draw clean iconic camera outline with angled slopes and rounded corners
    final path = Path();
    path.moveTo(14.5 * scale, 4.0 * scale);
    path.lineTo(9.5 * scale, 4.0 * scale);
    path.lineTo(7.0 * scale, 7.0 * scale);
    path.lineTo(4.0 * scale, 7.0 * scale);
    path.arcToPoint(
      Offset(2.0 * scale, 9.0 * scale),
      radius: Radius.circular(2.0 * scale),
      clockwise: false,
    );
    path.lineTo(2.0 * scale, 18.0 * scale);
    path.arcToPoint(
      Offset(4.0 * scale, 20.0 * scale),
      radius: Radius.circular(2.0 * scale),
      clockwise: false,
    );
    path.lineTo(20.0 * scale, 20.0 * scale);
    path.arcToPoint(
      Offset(22.0 * scale, 18.0 * scale),
      radius: Radius.circular(2.0 * scale),
      clockwise: false,
    );
    path.lineTo(22.0 * scale, 9.0 * scale);
    path.arcToPoint(
      Offset(20.0 * scale, 7.0 * scale),
      radius: Radius.circular(2.0 * scale),
      clockwise: false,
    );
    path.lineTo(17.0 * scale, 7.0 * scale);
    path.close();

    canvas.drawPath(path, strokePaint);

    // Central circular camera lens
    canvas.drawCircle(
      Offset(12.0 * scale, 13.0 * scale),
      3.4 * scale,
      strokePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
`;

  const onboardingMicrophoneDartCode = `import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_dimensions.dart";
import "../../../core/theme/app_spacing.dart";

/// Screen 4 of Onboarding: Microphone Permission
/// Follows CRM Pro Flutter/Dart design system and architecture.
class OnboardingMicrophoneScreen extends StatefulWidget {
  final VoidCallback? onAllowMicrophone;
  final VoidCallback? onSkip;

  const OnboardingMicrophoneScreen({
    super.key,
    this.onAllowMicrophone,
    this.onSkip,
  });

  @override
  State<OnboardingMicrophoneScreen> createState() =>
      _OnboardingMicrophoneScreenState();
}

class _OnboardingMicrophoneScreenState
    extends State<OnboardingMicrophoneScreen> {
  bool _isRequesting = false;
  bool _isGranted = false;

  void _handleAllowMicrophone() async {
    if (_isRequesting || _isGranted) return;

    setState(() {
      _isRequesting = true;
    });

    // Simulate microphone permission latency
    await Future.delayed(const Duration(milliseconds: 700));

    if (mounted) {
      setState(() {
        _isRequesting = false;
        _isGranted = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Microphone permission granted successfully!"),
          backgroundColor: AppColors.primary,
          duration: Duration(seconds: 2),
        ),
      );

      if (widget.onAllowMicrophone != null) {
        widget.onAllowMicrophone!();
      } else {
        Navigator.of(context).pushNamed("/onboarding-step-5");
      }
    }
  }

  void _handleSkip() {
    if (widget.onSkip != null) {
      widget.onSkip!();
    } else {
      Navigator.of(context).pushNamed("/onboarding-step-5");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // 1. Top Progress Bar (Step 4 of Onboarding: ~60%)
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  height: 4.5,
                  width: double.infinity,
                  color: const Color(0xFFE5E7EB),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.60,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary, // #0F4C4C
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 2. Hero Graphic Card: Soft mint card with continuous audio waveform vector illustration
              Container(
                width: double.infinity,
                height: 210,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF9), // Soft mint tint
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: CustomPaint(
                  size: const Size(125, 105),
                  painter: _WaveformIllustrationPainter(),
                ),
              ),

              const SizedBox(height: 28),

              // 3. Title: "Enable Microphone"
              Text(
                "Enable Microphone",
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.6,
                  height: 1.15,
                ),
              ),

              const SizedBox(height: 10),

              // 4. Subtitle / Purpose Explanation
              Text(
                "Record voice notes during or after meetings instead of typing.",
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),

              const SizedBox(height: 24),

              // 5. Value Propositions List (3 key benefits with mint checkmark badges)
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: const [
                    _BenefitItem(
                      title: "Hands-free Minutes",
                      description:
                          "Dictate logs walking back to your car, converted instantly to text.",
                    ),
                    SizedBox(height: 20),
                    _BenefitItem(
                      title: "Quick Client Quotes",
                      description:
                          "Capture precise verbal requests with secure client agreement notes.",
                    ),
                    SizedBox(height: 20),
                    _BenefitItem(
                      title: "Smart Summary",
                      description:
                          "AI distills 5-minute recordings into actionable tasks.",
                    ),
                  ],
                ),
              ),

              // 6. Bottom Action Controls
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
                child: Column(
                  children: [
                    // Primary CTA: "Allow Microphone Access"
                    SizedBox(
                      width: double.infinity,
                      height: AppDimensions.buttonHeight,
                      child: ElevatedButton(
                        onPressed: _handleAllowMicrophone,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusButton,
                            ),
                          ),
                        ),
                        child: _isRequesting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                _isGranted
                                    ? "Microphone Access Granted"
                                    : "Allow Microphone Access",
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: -0.2,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Secondary Action: "Skip for now"
                    TextButton(
                      onPressed: _handleSkip,
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF6B7280),
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                      ),
                      child: Text(
                        "Skip for now",
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper widget to render each value proposition item with a mint checkmark badge
class _BenefitItem extends StatelessWidget {
  final String title;
  final String description;

  const _BenefitItem({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          margin: const EdgeInsets.only(top: 2),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFD1FADF),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.check,
            size: 14,
            color: Color(0xFF0F766E),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Custom painter for the continuous audio sound waveform illustration matching the reference image
class _WaveformIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const tealColor = Color(0xFF0F4C4C);

    final strokePaint = Paint()
      ..color = tealColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final scaleX = size.width / 100.0;
    final scaleY = size.height / 100.0;

    final path = Path();

    // Start of the left wave tail
    path.moveTo(16.0 * scaleX, 52.0 * scaleY);

    // Curve into the first vertical stem
    path.cubicTo(
      22.0 * scaleX, 51.0 * scaleY,
      26.0 * scaleX, 42.0 * scaleY,
      28.0 * scaleX, 32.0 * scaleY,
    );

    // Peak 1 top rounded dome with wider breathing room
    path.arcToPoint(
      Offset(44.0 * scaleX, 32.0 * scaleY),
      radius: Radius.circular(8.0 * scaleX),
      clockwise: true,
    );

    // Straight down to trough 1
    path.lineTo(44.0 * scaleX, 78.0 * scaleY);

    // Trough 1 bottom rounded curve (deepest drop) with wider space
    path.arcToPoint(
      Offset(60.0 * scaleX, 78.0 * scaleY),
      radius: Radius.circular(8.0 * scaleX),
      clockwise: false,
    );

    // Straight up to peak 2 (highest peak)
    path.lineTo(60.0 * scaleX, 22.0 * scaleY);

    // Peak 2 top rounded dome with wider space
    path.arcToPoint(
      Offset(76.0 * scaleX, 22.0 * scaleY),
      radius: Radius.circular(8.0 * scaleX),
      clockwise: true,
    );

    // Straight down to trough 2
    path.lineTo(76.0 * scaleX, 62.0 * scaleY);

    // Trough 2 bottom rounded curve with wider space
    path.arcToPoint(
      Offset(90.0 * scaleX, 62.0 * scaleY),
      radius: Radius.circular(7.0 * scaleX),
      clockwise: false,
    );

    // Curve out to the right ending tail
    path.cubicTo(
      91.0 * scaleX, 55.0 * scaleY,
      94.0 * scaleX, 48.0 * scaleY,
      98.0 * scaleX, 44.0 * scaleY,
    );

    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
`;

  const onboardingNotificationsDartCode = `import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_dimensions.dart";
import "../../../core/theme/app_spacing.dart";

/// Screen 5 of Onboarding: Notifications Permission
/// Follows CRM Pro Flutter/Dart design system and architecture.
class OnboardingNotificationsScreen extends StatefulWidget {
  final VoidCallback? onAllowNotifications;
  final VoidCallback? onSkip;

  const OnboardingNotificationsScreen({
    super.key,
    this.onAllowNotifications,
    this.onSkip,
  });

  @override
  State<OnboardingNotificationsScreen> createState() =>
      _OnboardingNotificationsScreenState();
}

class _OnboardingNotificationsScreenState
    extends State<OnboardingNotificationsScreen> {
  bool _isRequesting = false;
  bool _isGranted = false;

  void _handleAllowNotifications() async {
    if (_isRequesting || _isGranted) return;

    setState(() {
      _isRequesting = true;
    });

    // Simulate notification permission prompt latency
    await Future.delayed(const Duration(milliseconds: 700));

    if (mounted) {
      setState(() {
        _isRequesting = false;
        _isGranted = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Notifications enabled! Push channels calibrated for field sales."),
          backgroundColor: AppColors.primary,
          duration: Duration(seconds: 2),
        ),
      );

      if (widget.onAllowNotifications != null) {
        widget.onAllowNotifications!();
      } else {
        // Complete onboarding flow: navigate to biometric or sign in
        Navigator.of(context).pushReplacementNamed("/biometric-login");
      }
    }
  }

  void _handleSkip() {
    if (widget.onSkip != null) {
      widget.onSkip!();
    } else {
      Navigator.of(context).pushReplacementNamed("/biometric-login");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // 1. Top Progress Bar (Step 5 of Onboarding: ~78%)
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  height: 4.5,
                  width: double.infinity,
                  color: const Color(0xFFE5E7EB),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.78,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary, // #0F4C4C
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 2. Hero Graphic Card: Soft mint card with notification bell vector illustration
              Container(
                width: double.infinity,
                height: 210,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF9), // Soft mint tint
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: CustomPaint(
                  size: const Size(120, 110),
                  painter: _NotificationBellIllustrationPainter(),
                ),
              ),

              const SizedBox(height: 28),

              // 3. Title: "Enable Notifications"
              Text(
                "Enable Notifications",
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.6,
                  height: 1.15,
                ),
              ),

              const SizedBox(height: 10),

              // 4. Subtitle / Purpose Explanation
              Text(
                "Get reminders for visits, follow-ups, and new lead assignments.",
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),

              const SizedBox(height: 24),

              // 5. Value Propositions List (3 key benefits with mint checkmark badges)
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: const [
                    _BenefitItem(
                      title: "Real-time Lead Routing",
                      description:
                          "Instant alert the moment a manager scopes a hot lead into your zone.",
                    ),
                    SizedBox(height: 20),
                    _BenefitItem(
                      title: "Next Appointment Alerts",
                      description:
                          "Polite reminders 15 mins prior to keep you moving efficiently.",
                    ),
                    SizedBox(height: 20),
                    _BenefitItem(
                      title: "Daily Summary",
                      description:
                          "Morning heads-up summarizing critical actions for the day.",
                    ),
                  ],
                ),
              ),

              // 6. Bottom Action Controls
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
                child: Column(
                  children: [
                    // Primary CTA: "Allow Notifications"
                    SizedBox(
                      width: double.infinity,
                      height: AppDimensions.buttonHeight,
                      child: ElevatedButton(
                        onPressed: _handleAllowNotifications,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusButton,
                            ),
                          ),
                        ),
                        child: _isRequesting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                _isGranted
                                    ? "Notifications Enabled"
                                    : "Allow Notifications",
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: -0.2,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Secondary Action: "Skip for now"
                    TextButton(
                      onPressed: _handleSkip,
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF6B7280),
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                      ),
                      child: Text(
                        "Skip for now",
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper widget to render each value proposition item with a mint checkmark badge
class _BenefitItem extends StatelessWidget {
  final String title;
  final String description;

  const _BenefitItem({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          margin: const EdgeInsets.only(top: 2),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFD1FADF),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.check,
            size: 14,
            color: Color(0xFF0F766E),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Custom painter for the minimalist notification bell vector illustration matching the reference image
class _NotificationBellIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const tealColor = Color(0xFF0F4C4C);

    final strokePaint = Paint()
      ..color = tealColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final scaleX = size.width / 100.0;
    final scaleY = size.height / 100.0;

    // 1. Bell Body Outline with wide flare and notch for notification pip
    final bellPath = Path();

    // Start on upper curve just left of the alert circle
    bellPath.moveTo(47.0 * scaleX, 17.5 * scaleY);

    // Arch over top apex to the left shoulder
    bellPath.cubicTo(
      42.0 * scaleX, 17.0 * scaleY,
      37.5 * scaleX, 21.0 * scaleY,
      36.0 * scaleX, 28.0 * scaleY,
    );

    // Down through the left waist
    bellPath.cubicTo(
      35.0 * scaleX, 35.0 * scaleY,
      35.0 * scaleX, 41.0 * scaleY,
      33.5 * scaleX, 46.0 * scaleY,
    );

    // Graceful outward flare to bottom-left rim tip
    bellPath.cubicTo(
      31.5 * scaleX, 52.0 * scaleY,
      26.0 * scaleX, 55.0 * scaleY,
      24.0 * scaleX, 56.5 * scaleY,
    );

    // Rounded bottom-left corner
    bellPath.arcToPoint(
      Offset(27.0 * scaleX, 58.5 * scaleY),
      radius: Radius.circular(2.5 * scaleX),
      clockwise: false,
    );

    // Flat horizontal baseline
    bellPath.lineTo(71.0 * scaleX, 58.5 * scaleY);

    // Rounded bottom-right corner
    bellPath.arcToPoint(
      Offset(74.0 * scaleX, 56.5 * scaleY),
      radius: Radius.circular(2.5 * scaleX),
      clockwise: false,
    );

    // Graceful inward swoop from bottom-right flare tip through right waist
    bellPath.cubicTo(
      72.0 * scaleX, 55.0 * scaleY,
      66.5 * scaleX, 52.0 * scaleY,
      64.5 * scaleX, 46.0 * scaleY,
    );

    // Up through the right waist, terminating cleanly below the alert circle
    bellPath.cubicTo(
      63.0 * scaleX, 41.0 * scaleY,
      63.0 * scaleX, 36.0 * scaleY,
      59.5 * scaleX, 31.0 * scaleY,
    );

    canvas.drawPath(bellPath, strokePaint);

    // 2. Alert Notification Pip (circle on upper-right shoulder)
    final alertCenter = Offset(58.0 * scaleX, 20.0 * scaleY);
    final alertRadius = 7.5 * scaleX;
    canvas.drawCircle(alertCenter, alertRadius, strokePaint);

    // 3. Centered Bell Clapper (smile arc underneath the rim)
    final clapperPath = Path();
    clapperPath.moveTo(44.0 * scaleX, 64.0 * scaleY);
    clapperPath.quadraticBezierTo(
      49.0 * scaleX, 68.0 * scaleY,
      54.0 * scaleX, 64.0 * scaleY,
    );
    canvas.drawPath(clapperPath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
`;

  const onboardingOfflineSetupDartCode = `import "dart:async";
import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_dimensions.dart";
import "../../../core/theme/app_spacing.dart";

/// Screen 6 of Onboarding: Prepare for Offline Data Setup
/// Follows CRM Pro Flutter/Dart design system and architecture.
class OnboardingOfflineSetupScreen extends StatefulWidget {
  final VoidCallback? onDownloadComplete;
  final VoidCallback? onSkip;

  const OnboardingOfflineSetupScreen({
    super.key,
    this.onDownloadComplete,
    this.onSkip,
  });

  @override
  State<OnboardingOfflineSetupScreen> createState() =>
      _OnboardingOfflineSetupScreenState();
}

class _OnboardingOfflineSetupScreenState
    extends State<OnboardingOfflineSetupScreen> {
  bool _isDownloading = false;
  bool _isCompleted = false;
  double _progress = 0.60; // Initial 60% as seen in reference design
  int _downloadedCount = 72; // 72 of 120 leads
  final int _totalCount = 120;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startDownload() {
    if (_isDownloading || _isCompleted) return;

    setState(() {
      _isDownloading = true;
    });

    _timer = Timer.periodic(const Duration(milliseconds: 60), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_downloadedCount < _totalCount) {
          _downloadedCount += 2;
          if (_downloadedCount > _totalCount) {
            _downloadedCount = _totalCount;
          }
          _progress = _downloadedCount / _totalCount;
        } else {
          timer.cancel();
          _isDownloading = false;
          _isCompleted = true;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Offline cache ready! South Mumbai territory synced."),
              backgroundColor: AppColors.primary,
              duration: Duration(seconds: 2),
            ),
          );

          Future.delayed(const Duration(milliseconds: 1200), () {
            if (mounted) {
              if (widget.onDownloadComplete != null) {
                widget.onDownloadComplete!();
              } else {
                Navigator.of(context).pushReplacementNamed("/biometric-login");
              }
            }
          });
        }
      });
    });
  }

  void _handleSkip() {
    if (widget.onSkip != null) {
      widget.onSkip!();
    } else {
      Navigator.of(context).pushReplacementNamed("/biometric-login");
    }
  }

  @override
  Widget build(BuildContext context) {
    final percent = (_progress * 100).toInt();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // 1. Top Progress Bar (Step 6 of Onboarding: 100% full dark teal line)
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  height: 4.5,
                  width: double.infinity,
                  color: const Color(0xFFE5E7EB),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 1.0, // 100% full
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary, // #0F4C4C
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 2. Hero Graphic Card: Soft mint card with cloud download vector illustration
              Container(
                width: double.infinity,
                height: 210,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF9), // Soft mint tint
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: CustomPaint(
                  size: const Size(120, 110),
                  painter: _CloudDownloadIllustrationPainter(),
                ),
              ),

              const SizedBox(height: 28),

              // 3. Title: "Prepare for Offline"
              Text(
                "Prepare for Offline",
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.6,
                  height: 1.15,
                ),
              ),

              const SizedBox(height: 10),

              // 4. Subtitle / Purpose Explanation
              Text(
                "Download your leads and customer data so you can work without internet.",
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),

              const SizedBox(height: 22),

              // 5. Territory Payload Information Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFF3F4F6),
                    width: 1.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "SOUTH MUMBAI SYNC PAYLOAD",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF6B7280),
                            letterSpacing: 0.4,
                          ),
                        ),
                        Text(
                          "~45 MB",
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _PayloadBullet(text: "120 assigned leads"),
                    const SizedBox(height: 5),
                    _PayloadBullet(text: "85 customers in territory"),
                    const SizedBox(height: 5),
                    _PayloadBullet(text: "7 days offline visit logs"),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 6. Download Progress Indicator Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isCompleted
                            ? "Download complete"
                            : _isDownloading
                                ? "Downloading leads..."
                                : "Downloading leads...",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        "$_downloadedCount / $_totalCount ($percent%)",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      height: 5.5,
                      width: double.infinity,
                      color: const Color(0xFFE5E7EB),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _progress,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 60),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // 7. Bottom Action Controls
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: AppDimensions.buttonHeight,
                      child: ElevatedButton(
                        onPressed: _startDownload,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusButton,
                            ),
                          ),
                        ),
                        child: _isDownloading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "Downloading...",
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                _isCompleted
                                    ? "Sync Completed"
                                    : "Download Now",
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: -0.2,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextButton(
                      onPressed: _handleSkip,
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF6B7280),
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                      ),
                      child: Text(
                        "Skip — I'll sync later",
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PayloadBullet extends StatelessWidget {
  final String text;
  const _PayloadBullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 4.5,
          height: 4.5,
          margin: const EdgeInsets.only(right: 8, left: 2),
          decoration: const BoxDecoration(
            color: Color(0xFF374151),
            shape: BoxShape.circle,
          ),
        ),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF1F2937),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _CloudDownloadIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const tealColor = Color(0xFF0F4C4C);

    final strokePaint = Paint()
      ..color = tealColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final scaleX = size.width / 100.0;
    final scaleY = size.height / 100.0;

    final cloudPath = Path();
    cloudPath.moveTo(42.0 * scaleX, 66.0 * scaleY);
    cloudPath.cubicTo(
      36.0 * scaleX, 66.0 * scaleY,
      27.0 * scaleX, 61.0 * scaleY,
      26.0 * scaleX, 51.0 * scaleY,
    );
    cloudPath.cubicTo(
      25.0 * scaleX, 41.0 * scaleY,
      33.0 * scaleX, 33.0 * scaleY,
      43.0 * scaleX, 33.0 * scaleY,
    );
    cloudPath.cubicTo(
      47.0 * scaleX, 22.0 * scaleY,
      61.0 * scaleX, 22.0 * scaleY,
      67.0 * scaleX, 32.0 * scaleY,
    );
    cloudPath.cubicTo(
      77.0 * scaleX, 33.0 * scaleY,
      83.0 * scaleX, 42.0 * scaleY,
      82.0 * scaleX, 51.0 * scaleY,
    );
    cloudPath.cubicTo(
      81.0 * scaleX, 61.0 * scaleY,
      72.0 * scaleX, 66.0 * scaleY,
      58.0 * scaleX, 66.0 * scaleY,
    );
    canvas.drawPath(cloudPath, strokePaint);

    final arrowPath = Path();
    arrowPath.moveTo(50.0 * scaleX, 46.0 * scaleY);
    arrowPath.lineTo(50.0 * scaleX, 72.0 * scaleY);
    arrowPath.moveTo(43.0 * scaleX, 64.0 * scaleY);
    arrowPath.lineTo(50.0 * scaleX, 72.0 * scaleY);
    arrowPath.lineTo(57.0 * scaleX, 64.0 * scaleY);
    canvas.drawPath(arrowPath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
`;

  const introSlideTwoDartCode = `import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_spacing.dart";

/// Onboarding Screen 9: Intro Slide Two (Track Your Visits)
/// Authentic reproduction of the CRM Pro Field Sales walkthrough slide two.
/// Follows the CRM Pro Flutter/Dart master prompt and design system.
class IntroSlideTwoScreen extends StatelessWidget {
  final VoidCallback? onNext;
  final VoidCallback? onSkip;

  const IntroSlideTwoScreen({
    super.key,
    this.onNext,
    this.onSkip,
  });

  void _handleNext(BuildContext context) {
    if (onNext != null) {
      onNext!();
    } else {
      Navigator.of(context).pushReplacementNamed("/app-intro-walkthrough");
    }
  }

  void _handleSkip(BuildContext context) {
    if (onSkip != null) {
      onSkip!();
    } else {
      Navigator.of(context).pushReplacementNamed("/biometric-login");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Navigation Bar: Skip Button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
                vertical: 12,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => _handleSkip(context),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(48, 36),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    "Skip",
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF99F6E4),
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
            ),

            // 2. Main Content Area (Graphic card + Headline + Subtitle)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    // Center Graphic Card (280 x 280)
                    Center(
                      child: Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          color: const Color(0xFF135858),
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: const CustomPaint(
                          painter: TrackVisitsGraphicPainter(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Headline: "Track Your Visits"
                    Text(
                      "Track Your Visits",
                      style: GoogleFonts.inter(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.6,
                        height: 1.15,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Subtitle
                    Text(
                      "GPS-verified check-ins, real-time visit tracking, and automated meeting logs kept instantly in sync.",
                      style: GoogleFonts.inter(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFD1FAE5).withOpacity(0.85),
                        height: 1.45,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Bottom Control Row: Indicator Dots (2nd active) on Left, Next Button on Right
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
                vertical: 24,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 3-dot carousel indicator with second dot active
                  Row(
                    children: [
                      // Dot 1 (inactive)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.35),
                        ),
                      ),
                      // Dot 2 (active)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                      // Dot 3 (inactive)
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.35),
                        ),
                      ),
                    ],
                  ),

                  // Circular white Next button (56 x 56)
                  GestureDetector(
                    onTap: () => _handleNext(context),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.18),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for the Track Your Visits graphic
class TrackVisitsGraphicPainter extends CustomPainter {
  const TrackVisitsGraphicPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Subtle 4x4 coordinate grid lines
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 1; i < 4; i++) {
      final x = (w / 4) * i;
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridPaint);
      final y = (h / 4) * i;
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // Key Anchor Points
    final buildingCenter = Offset(w * 0.28, h * 0.70);
    final pinCenter = Offset(w * 0.495, h * 0.17);
    final checkmarkCenter = Offset(w * 0.715, h * 0.70);

    // 2. Dashed Trajectory Lines
    final dashPaint = Paint()
      ..color = const Color(0xFF6EE7B7).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    // Diagonal dashed line: Building -> Pin
    final pDiagStart = Offset(buildingCenter.dx + 4, buildingCenter.dy - 16);
    final pDiagEnd = Offset(pinCenter.dx - 1, pinCenter.dy + 23);
    _drawDashedLine(canvas, pDiagStart, pDiagEnd, dashPaint, dashLength: 6, dashSpace: 5);

    // Horizontal dashed line: Building -> Checkmark
    final pHorizStart = Offset(buildingCenter.dx + 16, buildingCenter.dy);
    final pHorizEnd = Offset(checkmarkCenter.dx - 22, checkmarkCenter.dy);
    _drawDashedLine(canvas, pHorizStart, pHorizEnd, dashPaint, dashLength: 6, dashSpace: 5);

    // 3. Draw Building Icon at bottom left
    _drawBuildingIcon(canvas, buildingCenter);

    // 4. Draw Location Pin Icon at top center
    _drawLocationPin(canvas, pinCenter);

    // 5. Draw White Checkmark Badge at bottom right
    _drawCheckmarkBadge(canvas, checkmarkCenter);
  }

  void _drawLocationPin(Canvas canvas, Offset center) {
    final pinPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final r = 13.5;
    final topCenter = Offset(center.dx, center.dy);
    path.addArc(
      Rect.fromCircle(center: topCenter, radius: r),
      3.14159 * 0.75,
      3.14159 * 1.5,
    );
    path.quadraticBezierTo(
      center.dx + r * 0.9,
      center.dy + r * 1.0,
      center.dx,
      center.dy + r * 1.7,
    );
    path.quadraticBezierTo(
      center.dx - r * 0.9,
      center.dy + r * 1.0,
      center.dx - r * 0.707,
      center.dy + r * 0.707,
    );
    canvas.drawPath(path, pinPaint);

    final holePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(topCenter, 4.5, holePaint);
  }

  void _drawBuildingIcon(Canvas canvas, Offset center) {
    final whiteStroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = 22.0;
    final h = 28.0;
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: w, height: h),
      const Radius.circular(5.0),
    );
    canvas.drawRRect(rect, whiteStroke);

    // Windows (2 columns, 3 rows of dots)
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final leftX = center.dx - 4.5;
    final rightX = center.dx + 4.5;
    final y1 = center.dy - 7.5;
    final y2 = center.dy - 2.5;
    final y3 = center.dy + 2.5;

    canvas.drawCircle(Offset(leftX, y1), 1.2, dotPaint);
    canvas.drawCircle(Offset(rightX, y1), 1.2, dotPaint);
    canvas.drawCircle(Offset(leftX, y2), 1.2, dotPaint);
    canvas.drawCircle(Offset(rightX, y2), 1.2, dotPaint);
    canvas.drawCircle(Offset(leftX, y3), 1.2, dotPaint);
    canvas.drawCircle(Offset(rightX, y3), 1.2, dotPaint);

    // Entrance door
    final doorPath = Path();
    doorPath.moveTo(center.dx - 3.5, center.dy + h / 2);
    doorPath.lineTo(center.dx - 3.5, center.dy + h / 2 - 5.5);
    doorPath.arcToPoint(
      Offset(center.dx + 3.5, center.dy + h / 2 - 5.5),
      radius: const Radius.circular(3.5),
    );
    doorPath.lineTo(center.dx + 3.5, center.dy + h / 2);
    canvas.drawPath(doorPath, whiteStroke..style = PaintingStyle.stroke);
  }

  void _drawCheckmarkBadge(Canvas canvas, Offset center) {
    final badgePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 19.0, badgePaint);

    final checkPaint = Paint()
      ..color = const Color(0xFF0F4C4C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final checkPath = Path();
    checkPath.moveTo(center.dx - 7.5, center.dy);
    checkPath.lineTo(center.dx - 2.0, center.dy + 5.5);
    checkPath.lineTo(center.dx + 7.5, center.dy - 4.5);
    canvas.drawPath(checkPath, checkPaint);
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint, {
    double dashLength = 6.0,
    double dashSpace = 4.0,
  }) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final totalDistance = (end - start).distance;
    if (totalDistance == 0) return;

    final normalizedDx = dx / totalDistance;
    final normalizedDy = dy / totalDistance;

    double currentDistance = 0.0;
    while (currentDistance < totalDistance) {
      final segmentLength = (currentDistance + dashLength > totalDistance)
          ? totalDistance - currentDistance
          : dashLength;

      final pStart = Offset(
        start.dx + normalizedDx * currentDistance,
        start.dy + normalizedDy * currentDistance,
      );
      final pEnd = Offset(
        start.dx + normalizedDx * (currentDistance + segmentLength),
        start.dy + normalizedDy * (currentDistance + segmentLength),
      );

      canvas.drawLine(pStart, pEnd, paint);
      currentDistance += dashLength + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
`;

  const dashboardDartCode = `import "dart:math" as math;
import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_spacing.dart";

/// Dashboard & Notification Screen 1: Screen-Dashboard
/// Authentic implementation for CRM Pro Field Sales mobile app.
/// Follows the CRM Pro Flutter/Dart master prompt and design system.
/// Features:
/// - Hidden scrollbars for smooth, pristine mobile presentation
/// - Top bar: Initials avatar "AM", "Good morning,...", "• Synced", Notification bell with "3" badge
/// - AI Daily Brief Card with highlighted action link
/// - Horizontal scrollable metric cards carousel (scrollbars hidden)
/// - Circular gauge Monthly Target progress card (68% completed)
/// - Today's Schedule section with status badges (completed, upcoming)
/// - Floating Action Button for quick field actions
/// - 5-Tab Bottom Navigation Bar with active 'Home' indicator
class DashboardScreen extends StatefulWidget {
  final VoidCallback? onNotificationTap;
  final VoidCallback? onViewAllMapTap;
  final VoidCallback? onFabTap;
  final ValueChanged<int>? onNavTap;
  final VoidCallback? onViewBriefTap;
  final ValueChanged<String>? onScheduleItemTap;

  const DashboardScreen({
    super.key,
    this.onNotificationTap,
    this.onViewAllMapTap,
    this.onFabTap,
    this.onNavTap,
    this.onViewBriefTap,
    this.onScheduleItemTap,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Static Top Bar + Main Content Area
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // 1. Static Top Bar (pinned, does not scroll): Avatar, Greeting, Synced Chip, Notification Bell
                _buildTopHeader(),

                const SizedBox(height: 10),

                // Main content area with scrollbars strictly hidden
                Expanded(
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 110),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 2. AI Daily Brief Card
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.screenHorizontal,
                            ),
                            child: _buildAiDailyBriefCard(),
                          ),

                          const SizedBox(height: 20),

                          // 3. Horizontal Metric Cards Carousel (hidden scrollbar)
                          _buildMetricsCarousel(),

                          const SizedBox(height: 20),

                          // 4. Monthly Target Progress Card
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.screenHorizontal,
                            ),
                            child: _buildMonthlyTargetCard(),
                          ),

                          const SizedBox(height: 24),

                          // 5. Section Header: "Today's Schedule" + "View All Map"
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.screenHorizontal,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Today's Schedule",
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: widget.onViewAllMapTap,
                                  child: Text(
                                    "View All Map",
                                    style: GoogleFonts.inter(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF0F4C4C),
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),

                          // 6. Schedule List Cards
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.screenHorizontal,
                            ),
                            child: Column(
                              children: [
                                _buildScheduleCard(
                                  time: "09:30 AM",
                                  status: "completed",
                                  company: "Acme Corp",
                                  contact: "John Doe (CTO)",
                                  location: "Nariman Point, South Mumbai",
                                  isCompleted: true,
                                ),
                                const SizedBox(height: 12),
                                _buildScheduleCard(
                                  time: "11:45 AM",
                                  status: "completed",
                                  company: "TechVista Ltd",
                                  contact: "Priya Sharma (HR)",
                                  location: "Lower Parel, Mumbai",
                                  isCompleted: true,
                                ),
                                const SizedBox(height: 12),
                                _buildScheduleCard(
                                  time: "02:30 PM",
                                  status: "upcoming",
                                  company: "DataFlow Systems",
                                  contact: "Karan Malhotra (MD)",
                                  location: "Andheri East, Mumbai",
                                  isCompleted: false,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Floating Action Button (placed above bottom navigation) - square with curved edges
            Positioned(
              right: 20,
              bottom: 84,
              child: GestureDetector(
                onTap: widget.onFabTap,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F4C4C),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F4C4C).withOpacity(0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Navigation Bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomNavigationBar(),
            ),
          ],
        ),
      ),
    );
  }

  /// 1. Top Header Row
  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFE0F2F1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              "AM",
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F4C4C),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Good morning,...",
                  style: GoogleFonts.inter(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.4,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  "Thursday, Aug 9",
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  "Synced",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF059669),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: widget.onNotificationTap,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.notifications_none_rounded,
                      color: Color(0xFF1F2937),
                      size: 22,
                    ),
                  ),
                ),
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "3",
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 2. AI Daily Brief Card
  Widget _buildAiDailyBriefCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F4C4C),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F4C4C).withOpacity(0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text("🤖", style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                "AI DAILY BRIEF",
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF99F6E4),
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "You have 6 visits planned today. 2 are high-priority. Start with Acme Corp they viewed your proposal yesterday.",
            style: GoogleFonts.inter(
              fontSize: 13.5,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.92),
              height: 1.45,
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: widget.onViewBriefTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "View Full Brief",
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  "→",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 3. Horizontally Scrollable Metric Cards Carousel with scrollbars hidden
  Widget _buildMetricsCarousel() {
    final metrics = [
      _MetricItem(
        title: "Today's Visits",
        value: "2/6",
        subtitle: "Goal: 6 visits",
      ),
      _MetricItem(
        title: "Check-ins",
        value: "2",
        subtitle: "Completed",
      ),
      _MetricItem(
        title: "Distance",
        value: "18 km",
        subtitle: "Estimated tra...",
      ),
      _MetricItem(
        title: "Revenue",
        value: "₹4.2L",
        subtitle: "Active leads",
      ),
    ];

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
        ),
        child: Row(
          children: metrics.map((item) {
            return Container(
              width: 124,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
                      letterSpacing: -0.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.value,
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F4C4C),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF9CA3AF),
                      letterSpacing: -0.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// 4. Monthly Target Card with circular progress
  Widget _buildMonthlyTargetCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 68,
            height: 68,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(68, 68),
                  painter: _CircularProgressPainter(
                    percentage: 0.68,
                    trackColor: const Color(0xFFF1F5F9),
                    progressColor: const Color(0xFF0F4C4C),
                    strokeWidth: 6.5,
                  ),
                ),
                Text(
                  "68%",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F4C4C),
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "MONTHLY TARGET",
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF6B7280),
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "₹6,80,000 / ₹10,00,000",
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "22 days remaining",
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFD97706),
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 5. Individual Schedule Item Card
  Widget _buildScheduleCard({
    required String time,
    required String status,
    required String company,
    required String contact,
    required String location,
    required bool isCompleted,
  }) {
    return GestureDetector(
      onTap: () {
        if (widget.onScheduleItemTap != null) {
          widget.onScheduleItemTap!(company);
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.015),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 90,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    time,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F4C4C),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? const Color(0xFF10B981)
                              : const Color(0xFF0F4C4C),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        status,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              height: 48,
              width: 1,
              color: const Color(0xFFF3F4F6),
              margin: const EdgeInsets.symmetric(horizontal: 10),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    company,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    contact,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF4B5563),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    location,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF9CA3AF),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 6. Bottom Navigation Bar with pill highlight for active tab
  Widget _buildBottomNavigationBar() {
    final navItems = [
      _BottomNavItemData(
        label: "Home",
        icon: Icons.home_rounded,
        outlinedIcon: Icons.home_outlined,
      ),
      _BottomNavItemData(
        label: "Leads",
        icon: Icons.folder_rounded,
        outlinedIcon: Icons.folder_outlined,
      ),
      _BottomNavItemData(
        label: "Visits",
        icon: Icons.share_location_rounded,
        outlinedIcon: Icons.share_location_outlined,
      ),
      _BottomNavItemData(
        label: "Tasks",
        icon: Icons.format_list_bulleted_rounded,
        outlinedIcon: Icons.format_list_bulleted_outlined,
      ),
      _BottomNavItemData(
        label: "Profile",
        icon: Icons.manage_accounts_rounded,
        outlinedIcon: Icons.manage_accounts_outlined,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.only(top: 8, bottom: 20, left: 8, right: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(navItems.length, (index) {
          final item = navItems[index];
          final isActive = _currentNavIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                _currentNavIndex = index;
              });
              if (widget.onNavTap != null) {
                widget.onNavTap!(index);
              }
            },
            behavior: HitTestBehavior.opaque,
            child: isActive
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F4F2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          size: 22,
                          color: const Color(0xFF0F4C4C),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F4C4C),
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.outlinedIcon,
                          size: 22,
                          color: const Color(0xFF9CA3AF),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
          );
        }),
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double percentage;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  _CircularProgressPainter({
    required this.percentage,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * percentage;
    const startAngle = -math.pi / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.percentage != percentage ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

class _MetricItem {
  final String title;
  final String value;
  final String subtitle;

  _MetricItem({
    required this.title,
    required this.value,
    required this.subtitle,
  });
}

class _BottomNavItemData {
  final String label;
  final IconData icon;
  final IconData outlinedIcon;

  _BottomNavItemData({
    required this.label,
    required this.icon,
    required this.outlinedIcon,
  });
}
`;

  const notificationsDartCode = `import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_spacing.dart";

/// Notification Item Data Model
class NotificationItem {
  final String id;
  final String title;
  final String time;
  final String category; // 'leads', 'visits', 'proposals', 'tasks', 'deals'
  final bool isUnread;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String? actionText;
  final VoidCallback? onAction;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.time,
    required this.category,
    required this.isUnread,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    this.actionText,
    this.onAction,
  });

  NotificationItem copyWith({bool? isUnread}) {
    return NotificationItem(
      id: id,
      title: title,
      time: time,
      category: category,
      isUnread: isUnread ?? this.isUnread,
      icon: icon,
      iconColor: iconColor,
      iconBgColor: iconBgColor,
      actionText: actionText,
      onAction: onAction,
    );
  }
}

/// Dashboard & Notification Screen 2 - Notifications (screen-notification)
/// Follows CRM Pro Flutter/Dart master prompt and design system:
/// - Pinned static top header with count badge & "Mark All Read"
/// - Filter chips: All, Unread 5, Leads, Visits
/// - Scrollbars strictly hidden (invisible per specification)
/// - Bottom navigation bar in floating rounded card style
class NotificationsScreen extends StatefulWidget {
  final VoidCallback? onHomeTap;
  final VoidCallback? onLeadsTap;
  final VoidCallback? onVisitsTap;
  final VoidCallback? onTasksTap;
  final VoidCallback? onProfileTap;

  const NotificationsScreen({
    super.key,
    this.onHomeTap,
    this.onLeadsTap,
    this.onVisitsTap,
    this.onTasksTap,
    this.onProfileTap,
  });

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = "All";
  int _selectedBottomNavIndex = 0;

  late List<NotificationItem> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = [
      NotificationItem(
        id: "1",
        title: "New lead assigned: Acme Corp",
        time: "2 hours ago",
        category: "leads",
        isUnread: true,
        icon: Icons.person_outline_rounded,
        iconColor: const Color(0xFF0F4C4C),
        iconBgColor: const Color(0xFFE0F2F1),
        actionText: "View Lead",
        onAction: () => _handleLeadTap("Acme Corp"),
      ),
      NotificationItem(
        id: "2",
        title: "Visit with TechVista in 30 min",
        time: "30 min ago",
        category: "visits",
        isUnread: true,
        icon: Icons.calendar_today_outlined,
        iconColor: const Color(0xFFD97706),
        iconBgColor: const Color(0xFFFEF3C7),
      ),
      NotificationItem(
        id: "3",
        title: "John at Acme opened your proposal",
        time: "1 hour ago",
        category: "leads",
        isUnread: true,
        icon: Icons.visibility_outlined,
        iconColor: const Color(0xFF2563EB),
        iconBgColor: const Color(0xFFDBEAFE),
      ),
      NotificationItem(
        id: "4",
        title: "Follow-up with DataFlow is due today",
        time: "3 hours ago",
        category: "tasks",
        isUnread: false,
        icon: Icons.error_outline_rounded,
        iconColor: const Color(0xFFD97706),
        iconBgColor: const Color(0xFFFEF3C7),
      ),
      NotificationItem(
        id: "5",
        title: "Deal moved to Negotiation",
        time: "Yesterday",
        category: "deals",
        isUnread: false,
        icon: Icons.handshake_outlined,
        iconColor: const Color(0xFF7C3AED),
        iconBgColor: const Color(0xFFEDE9FE),
      ),
    ];
  }

  int get _unreadCount => _notifications.where((item) => item.isUnread).length;

  void _markAllAsRead() {
    setState(() {
      _notifications = _notifications.map((n) => n.copyWith(isUnread: false)).toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "All notifications marked as read",
          style: GoogleFonts.inter(fontWeight: FontWeight.w500),
        ),
        backgroundColor: const Color(0xFF0F4C4C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleLeadTap(String company) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Opening lead details for $company",
          style: GoogleFonts.inter(fontWeight: FontWeight.w500),
        ),
        backgroundColor: const Color(0xFF0F4C4C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleReadStatus(String id) {
    setState(() {
      _notifications = _notifications.map((n) {
        if (n.id == id) {
          return n.copyWith(isUnread: !n.isUnread);
        }
        return n;
      }).toList();
    });
  }

  List<NotificationItem> get _filteredNotifications {
    if (_selectedFilter == "Unread") {
      return _notifications.where((n) => n.isUnread).toList();
    } else if (_selectedFilter == "Leads") {
      return _notifications.where((n) => n.category == "leads").toList();
    } else if (_selectedFilter == "Visits") {
      return _notifications.where((n) => n.category == "visits").toList();
    }
    return _notifications;
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _unreadCount;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // 1. Static Top Header (Title with Badge + "Mark All Read")
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Notifications",
                            style: GoogleFonts.inter(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          if (unreadCount > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7.5, vertical: 2),
                              decoration: const BoxDecoration(
                                color: Color(0xFFEF4444),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                "\$unreadCount",
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      GestureDetector(
                        onTap: _markAllAsRead,
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                          child: Text(
                            "Mark All Read",
                            style: GoogleFonts.inter(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0F4C4C),
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 2. Filter Chips (All, Unread 5, Leads, Visits) - Invisible Scrollbar
                SizedBox(
                  height: 38,
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
                      children: [
                        _buildFilterChip("All", isSelected: _selectedFilter == "All"),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          "Unread",
                          badgeCount: unreadCount,
                          isSelected: _selectedFilter == "Unread",
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip("Leads", isSelected: _selectedFilter == "Leads"),
                        const SizedBox(width: 8),
                        _buildFilterChip("Visits", isSelected: _selectedFilter == "Visits"),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 3. Notification List Items - Scrollbars strictly hidden per requirement
                Expanded(
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                    child: _filteredNotifications.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.notifications_none_outlined,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "No notifications in this tab",
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.only(
                              left: AppSpacing.screenHorizontal,
                              right: AppSpacing.screenHorizontal,
                              bottom: 110,
                            ),
                            itemCount: _filteredNotifications.length,
                            separatorBuilder: (context, index) => const Divider(
                              color: Color(0xFFF3F4F6),
                              thickness: 1,
                              height: 24,
                            ),
                            itemBuilder: (context, index) {
                              final item = _filteredNotifications[index];
                              return _buildNotificationRow(item);
                            },
                          ),
                  ),
                ),
              ],
            ),

            // Floating Bottom Navigation Bar (matches design system & screenshot)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: _buildFloatingBottomBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, {int? badgeCount, required bool isSelected}) {
    final bool isAllSelected = isSelected;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: badgeCount != null ? 14 : 18,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: isAllSelected
              ? const Color(0xFFCCFBF1) // light teal/mint background
              : const Color(0xFFF3F4F6), // neutral background
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: isAllSelected ? FontWeight.w700 : FontWeight.w500,
                color: isAllSelected ? const Color(0xFF0F4C4C) : const Color(0xFF4B5563),
              ),
            ),
            if (badgeCount != null && badgeCount > 0) ...[
              const SizedBox(width: 6),
              Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  "\$badgeCount",
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationRow(NotificationItem item) {
    return GestureDetector(
      onTap: () => _toggleReadStatus(item.id),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left Unread Dot Indicator (or aligned spacer)
            SizedBox(
              width: 14,
              child: item.isUnread
                  ? Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0F4C4C), // Teal dot
                        shape: BoxShape.circle,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            const SizedBox(width: 4),

            // Circular Icon Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: item.iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                item.icon,
                color: item.iconColor,
                size: 22,
              ),
            ),

            const SizedBox(width: 14),

            // Content: Title & Subtitle/Timestamp
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.time,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),

            // Optional Right Action Button (e.g. "View Lead")
            if (item.actionText != null) ...[
              const SizedBox(width: 10),
              GestureDetector(
                onTap: item.onAction,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F4C4C),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F4C4C).withOpacity(0.18),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    item.actionText!,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.home_outlined, "Home", onTap: widget.onHomeTap),
          _buildNavItem(1, Icons.folder_outlined, "Leads", onTap: widget.onLeadsTap),
          _buildNavItem(2, Icons.alt_route_rounded, "Visits", onTap: widget.onVisitsTap),
          _buildNavItem(3, Icons.format_list_bulleted_rounded, "Tasks", onTap: widget.onTasksTap),
          _buildNavItem(4, Icons.person_outline_rounded, "Profile", onTap: widget.onProfileTap),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, {VoidCallback? onTap}) {
    final isSelected = _selectedBottomNavIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBottomNavIndex = index;
        });
        if (onTap != null) {
          onTap();
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? const Color(0xFF0F4C4C) : const Color(0xFF6B7280),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? const Color(0xFF0F4C4C) : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
`;

  const introSlideThreeDartCode = `import "dart:math" as math;
import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_spacing.dart";

/// Onboarding Screen 10: Intro Slide Three (Win with AI Insights)
/// Authentic reproduction of the CRM Pro Field Sales walkthrough slide three.
/// Follows the CRM Pro Flutter/Dart master prompt and design system.
class IntroSlideThreeScreen extends StatelessWidget {
  final VoidCallback? onGetStarted;
  final VoidCallback? onSkip;

  const IntroSlideThreeScreen({
    super.key,
    this.onGetStarted,
    this.onSkip,
  });

  void _handleGetStarted(BuildContext context) {
    if (onGetStarted != null) {
      onGetStarted!();
    } else {
      Navigator.of(context).pushReplacementNamed("/biometric-login");
    }
  }

  void _handleSkip(BuildContext context) {
    if (onSkip != null) {
      onSkip!();
    } else {
      Navigator.of(context).pushReplacementNamed("/biometric-login");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Navigation Bar: Skip Button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
                vertical: 12,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => _handleSkip(context),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(48, 36),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    "Skip",
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF99F6E4),
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
            ),

            // 2. Main Content Area (Graphic card + Headline + Subtitle)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    // Center Graphic Card (280 x 280)
                    Center(
                      child: Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          color: const Color(0xFF135858),
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: const CustomPaint(
                          painter: AiInsightsGraphicPainter(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Headline: "Win with AI Insights"
                    Text(
                      "Win with AI Insights",
                      style: GoogleFonts.inter(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.6,
                        height: 1.15,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Subtitle
                    Text(
                      "Smart lead scoring, deal win probability, and personalized day-coaching to close deals faster.",
                      style: GoogleFonts.inter(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFD1FAE5).withOpacity(0.85),
                        height: 1.45,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Bottom Control Row: Indicator Dots on Left, "Get Started" Pill Button on Right
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
                vertical: 24,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 3-dot carousel indicator with third dot active
                  Row(
                    children: [
                      // Dot 1 (inactive)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.35),
                        ),
                      ),
                      // Dot 2 (inactive)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.35),
                        ),
                      ),
                      // Dot 3 (active)
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  // Pill-shaped "Get Started" Button
                  GestureDetector(
                    onTap: () => _handleGetStarted(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.18),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        "Get Started",
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F4C4C),
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for the Win with AI Insights graphic
class AiInsightsGraphicPainter extends CustomPainter {
  const AiInsightsGraphicPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Subtle 4x4 coordinate grid lines
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 1; i < 4; i++) {
      final x = (w / 4) * i;
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridPaint);
      final y = (h / 4) * i;
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    final yBase = h * 0.72;
    final barWidth = w * 0.062;

    // Bar 1 (Leftmost, shortest, muted gray-teal)
    final bar1Left = w * 0.245;
    final bar1Height = h * 0.26;
    final bar1Rect = RRect.fromRectAndCorners(
      Rect.fromLTWH(bar1Left, yBase - bar1Height, bar1Width, bar1Height),
      topLeft: const Radius.circular(5.5),
      topRight: const Radius.circular(5.5),
    );
    final bar1Paint = Paint()
      ..color = const Color(0xFF4D8080)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(bar1Rect, bar1Paint);

    // Bar 2 (Middle, medium height, brighter teal)
    final bar2Left = w * 0.368;
    final bar2Height = h * 0.46;
    final bar2Rect = RRect.fromRectAndCorners(
      Rect.fromLTWH(bar2Left, yBase - bar2Height, bar1Width, bar2Height),
      topLeft: const Radius.circular(5.5),
      topRight: const Radius.circular(5.5),
    );
    final bar2Paint = Paint()
      ..color = const Color(0xFF6BADA8)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(bar2Rect, bar2Paint);

    // Bar 3 (Rightmost, tallest, solid crisp white)
    final bar3Left = w * 0.493;
    final bar3Height = h * 0.62;
    final bar3Rect = RRect.fromRectAndCorners(
      Rect.fromLTWH(bar3Left, yBase - bar3Height, bar1Width, bar3Height),
      topLeft: const Radius.circular(5.5),
      topRight: const Radius.circular(5.5),
    );
    final bar3Paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRRect(bar3Rect, bar3Paint);

    // Outline Stars on the right of the tallest bar
    final starPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Small outline star
    final smallStarCenter = Offset(w * 0.65, h * 0.665);
    final smallStarPath = _createStarPath(smallStarCenter, 7.5, 3.8);
    canvas.drawPath(
      smallStarPath,
      starPaint
        ..strokeWidth = 1.7
        ..color = Colors.white.withOpacity(0.9),
    );

    // Large outline star
    final largeStarCenter = Offset(w * 0.79, h * 0.63);
    final largeStarPath = _createStarPath(largeStarCenter, 13.0, 6.2);
    canvas.drawPath(
      largeStarPath,
      starPaint
        ..strokeWidth = 2.1
        ..color = Colors.white,
    );
  }

  Path _createStarPath(Offset center, double outerRadius, double innerRadius) {
    final path = Path();
    const int numPoints = 5;
    final double step = math.pi / numPoints;
    double angle = -math.pi / 2;

    for (int i = 0; i < numPoints * 2; i++) {
      final r = (i % 2 == 0) ? outerRadius : innerRadius;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      angle += step;
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
`;

  const appIntroWalkthroughDartCode = `import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_spacing.dart";

/// Onboarding Screen 7: App Intro Walkthrough Screen
/// Direct, authentic reproduction of the CRM Pro Field Sales walkthrough intro screen.
/// Follows the CRM Pro Flutter/Dart master prompt and design system.
class AppIntroWalkthroughScreen extends StatefulWidget {
  final VoidCallback? onFinished;
  final VoidCallback? onSkip;

  const AppIntroWalkthroughScreen({
    super.key,
    this.onFinished,
    this.onSkip,
  });

  @override
  State<AppIntroWalkthroughScreen> createState() =>
      _AppIntroWalkthroughScreenState();
}

class _AppIntroWalkthroughScreenState extends State<AppIntroWalkthroughScreen>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  int _currentPage = 0;

  final List<_WalkthroughSlideData> _slides = const [
    _WalkthroughSlideData(
      title: "Plan Your Day",
      subtitle:
          "AI-optimized routes, smart scheduling, and morning briefings to maximize your visits.",
      type: _SlideGraphicType.mapRoute,
    ),
    _WalkthroughSlideData(
      title: "Close Deals Faster",
      subtitle:
          "Voice-to-text meeting logs, instant collateral access, and automatic CRM synchronization.",
      type: _SlideGraphicType.voiceNotes,
    ),
    _WalkthroughSlideData(
      title: "Work 100% Offline",
      subtitle:
          "Full catalog, customer history, and contract signing even with zero cellular signal.",
      type: _SlideGraphicType.offlineShield,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finishWalkthrough();
    }
  }

  void _handleSkip() {
    if (widget.onSkip != null) {
      widget.onSkip!();
    } else {
      _finishWalkthrough();
    }
  }

  void _finishWalkthrough() {
    if (widget.onFinished != null) {
      widget.onFinished!();
    } else {
      Navigator.of(context).pushReplacementNamed("/biometric-login");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar: Skip Button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
                vertical: 12,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: _handleSkip,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(48, 36),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    "Skip",
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF99F6E4),
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
            ),

            // Carousel Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontal,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),

                        // Center Graphic Card
                        Center(
                          child: Container(
                            width: 280,
                            height: 280,
                            decoration: BoxDecoration(
                              color: const Color(0xFF135858),
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: CustomPaint(
                              painter: _buildPainterForType(slide.type),
                            ),
                          ),
                        ),

                        const SizedBox(height: 48),

                        Text(
                          slide.title,
                          style: GoogleFonts.inter(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.6,
                            height: 1.15,
                          ),
                        ),

                        const SizedBox(height: 14),

                        Text(
                          slide.subtitle,
                          style: GoogleFonts.inter(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFFD1FAE5).withOpacity(0.85),
                            height: 1.45,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Control Row
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
                vertical: 24,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: List.generate(_slides.length, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(right: 8),
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive
                              ? Colors.white
                              : Colors.white.withOpacity(0.35),
                        ),
                      );
                    }),
                  ),

                  GestureDetector(
                    onTap: _handleNext,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.18),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  CustomPainter _buildPainterForType(_SlideGraphicType type) {
    switch (type) {
      case _SlideGraphicType.mapRoute:
        return const _MapRoutePainter();
      case _SlideGraphicType.voiceNotes:
        return const _VoiceNotesPainter();
      case _SlideGraphicType.offlineShield:
        return const _OfflineShieldPainter();
    }
  }
}

enum _SlideGraphicType { mapRoute, voiceNotes, offlineShield }

class _WalkthroughSlideData {
  final String title;
  final String subtitle;
  final _SlideGraphicType type;

  const _WalkthroughSlideData({
    required this.title,
    required this.subtitle,
    required this.type,
  });
}

class _MapRoutePainter extends CustomPainter {
  const _MapRoutePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 1; i < 4; i++) {
      final x = (w / 4) * i;
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridPaint);
      final y = (h / 4) * i;
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    final p1 = Offset(w * 0.28, h * 0.65);
    final p2 = Offset(w * 0.49, h * 0.38);
    final p3 = Offset(w * 0.74, h * 0.50);

    final dashPaint = Paint()
      ..color = const Color(0xFF6EE7B7).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    _drawDashedLine(canvas, p1, p2, dashPaint, dashLength: 6, dashSpace: 5);
    _drawDashedLine(canvas, p2, p3, dashPaint, dashLength: 6, dashSpace: 5);

    _drawWaypointNode(canvas, p1, 13.0);
    _drawWaypointNode(canvas, p2, 12.0);
    _drawWaypointNode(canvas, p3, 12.0);
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint, {
    double dashLength = 6.0,
    double dashSpace = 4.0,
  }) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final totalDistance = (end - start).distance;
    final normalizedDx = dx / totalDistance;
    final normalizedDy = dy / totalDistance;

    double currentDistance = 0.0;
    while (currentDistance < totalDistance) {
      final segmentLength = (currentDistance + dashLength > totalDistance)
          ? totalDistance - currentDistance
          : dashLength;

      final pStart = Offset(
        start.dx + normalizedDx * currentDistance,
        start.dy + normalizedDy * currentDistance,
      );
      final pEnd = Offset(
        start.dx + normalizedDx * (currentDistance + segmentLength),
        start.dy + normalizedDy * (currentDistance + segmentLength),
      );

      canvas.drawLine(pStart, pEnd, paint);
      currentDistance += dashLength + dashSpace;
    }
  }

  void _drawWaypointNode(Canvas canvas, Offset center, double radius) {
    final ringPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;
    canvas.drawCircle(center, radius, ringPaint);

    final fillPaint = Paint()
      ..color = const Color(0xFF0F4C4C).withOpacity(0.85)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - 1.2, fillPaint);

    final corePaint = Paint()
      ..color = const Color(0xFF99F6E4)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 3.2, corePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
`;

  const onboardingCompleteDartCode = `import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_dimensions.dart";
import "../../../core/theme/app_spacing.dart";

/// Screen 7 of Onboarding: Onboarding Complete ("You're All Set!")
/// Follows the CRM Pro Flutter/Dart master prompt and design system.
class OnboardingCompleteScreen extends StatefulWidget {
  final VoidCallback? onContinue;

  const OnboardingCompleteScreen({
    super.key,
    this.onContinue,
  });

  @override
  State<OnboardingCompleteScreen> createState() => _OnboardingCompleteScreenState();
}

class _OnboardingCompleteScreenState extends State<OnboardingCompleteScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    if (widget.onContinue != null) {
      widget.onContinue!();
    } else {
      Navigator.of(context).pushReplacementNamed("/biometric-login");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              // 1. Hero Graphic: Concentric Emerald Success Badge with Double Checkmark (identical to reset success)
              Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 196,
                      height: 196,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD1FADF),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        width: 128,
                        height: 128,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x1A10B981),
                              blurRadius: 16,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: CustomPaint(
                          size: const Size(56, 42),
                          painter: _DoubleCheckPainter(
                            color: Colors.white,
                            strokeWidth: 2.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // 2. Title: "You're All Set!"
              Text(
                "You're All Set!",
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.6,
                  height: 1.15,
                ),
              ),

              const SizedBox(height: 10),

              // 3. Subtitle: "Your field kit is ready. Time to hit the road."
              Text(
                "Your field kit is ready. Time to hit the road.",
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),

              const SizedBox(height: 26),

              // 4. Territory Prep Overview Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFF3F4F6),
                    width: 1.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "TERRITORY PREP OVERVIEW",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF6B7280),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Icon(
                          Icons.work_outline_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "120 leads parsed and mapped",
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF1F2937),
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "6 priority visits mapped out for today",
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF1F2937),
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_outline_rounded,
                          size: 18,
                          color: Color(0xFF10B981),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF10B981),
                                height: 1.35,
                              ),
                              children: const [
                                TextSpan(
                                  text: "Offline capability fully ready ",
                                ),
                                TextSpan(
                                  text: "(✓ Active)",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // 5. Bottom Action: "Continue" CTA
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0, top: 12.0),
                child: SizedBox(
                  width: double.infinity,
                  height: AppDimensions.buttonHeight,
                  child: ElevatedButton(
                    onPressed: _handleContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusButton,
                        ),
                      ),
                    ),
                    child: Text(
                      "Continue",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DoubleCheckPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _DoubleCheckPainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // First checkmark (left primary tick)
    final path1 = Path();
    path1.moveTo(w * 0.12, h * 0.54);
    path1.lineTo(w * 0.38, h * 0.82);
    path1.lineTo(w * 0.84, h * 0.28);
    canvas.drawPath(path1, paint);

    // Second checkmark (nested offset tick to the right)
    final path2 = Path();
    path2.moveTo(w * 0.50, h * 0.58);
    path2.lineTo(w * 0.66, h * 0.76);
    path2.lineTo(w * 0.98, h * 0.38);
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant _DoubleCheckPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}
`;

  const biometricLoginDartCode = `import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_typography.dart";
import "../../../core/theme/app_spacing.dart";

/// Screen: Biometric Login Screen (Face ID / Touch ID)
/// Authentic, pixel-accurate reproduction of the CRM Pro Field Sales Biometric Login screen.
/// Follows the CRM Pro Flutter/Dart master prompt and design system.
class BiometricLoginScreen extends StatefulWidget {
  final VoidCallback? onAuthenticated;
  final VoidCallback? onUsePasswordInstead;
  final String title;
  final String promptText;
  final String alternativeOptionText;

  const BiometricLoginScreen({
    super.key,
    this.onAuthenticated,
    this.onUsePasswordInstead,
    this.title = "CRM Pro Field Sales",
    this.promptText = "Use Face ID to sign in",
    this.alternativeOptionText = "Use password instead",
  });

  @override
  State<BiometricLoginScreen> createState() => _BiometricLoginScreenState();
}

class _BiometricLoginScreenState extends State<BiometricLoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  bool _isAuthenticating = false;
  bool _authSuccess = false;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _triggerBiometricScan() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
    });

    // Simulate authentic biometric sensor read
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    setState(() {
      _isAuthenticating = false;
      _authSuccess = true;
    });

    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    if (widget.onAuthenticated != null) {
      widget.onAuthenticated!();
    }
  }

  void _handleUsePassword() {
    if (widget.onUsePasswordInstead != null) {
      widget.onUsePasswordInstead!();
    } else {
      Navigator.of(context).pushReplacementNamed("/sign-in");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary, // Signature Deep Teal #0F4C4C
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
            child: Column(
              children: [
                const Spacer(flex: 3),

                // 1. App Logo Squircle ("LP")
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.16),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "LP",
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 2. App Title: "CRM Pro Field Sales"
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.4,
                    height: 1.25,
                  ),
                ),

                const Spacer(flex: 4),

                // 3. Face ID Scanning Disc
                GestureDetector(
                  onTap: _triggerBiometricScan,
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _isAuthenticating ? _pulseAnimation.value : 1.0,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF1E6060),
                            border: Border.all(
                              color: _authSuccess
                                  ? const Color(0xFF10B981)
                                  : Colors.white.withOpacity(0.15),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _authSuccess
                                    ? const Color(0x3310B981)
                                    : Colors.black.withOpacity(0.1),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: _authSuccess
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 52,
                                )
                              : _isAuthenticating
                                  ? const SizedBox(
                                      width: 48,
                                      height: 48,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.8,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const CustomPaint(
                                      size: Size(54, 54),
                                      painter: _FaceIdIconPainter(
                                        color: Colors.white,
                                        strokeWidth: 2.6,
                                      ),
                                    ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // 4. Prompt Text: "Use Face ID to sign in"
                GestureDetector(
                  onTap: _triggerBiometricScan,
                  child: Text(
                    _isAuthenticating
                        ? "Verifying Face ID..."
                        : _authSuccess
                            ? "Verified!"
                            : widget.promptText,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.95),
                      letterSpacing: -0.2,
                    ),
                  ),
                ),

                const Spacer(flex: 5),

                // 5. Alternative Option: "Use password instead"
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: TextButton(
                    onPressed: _handleUsePassword,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white.withOpacity(0.85),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: Text(
                      widget.alternativeOptionText,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.9),
                        letterSpacing: -0.1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FaceIdIconPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _FaceIdIconPainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    const bracketLen = 12.0;
    const cornerRadius = 4.0;

    // 1. Top-Left
    final pathTL = Path();
    pathTL.moveTo(0, bracketLen);
    pathTL.lineTo(0, cornerRadius);
    pathTL.arcToPoint(const Offset(cornerRadius, 0), radius: const Radius.circular(cornerRadius));
    pathTL.lineTo(bracketLen, 0);
    canvas.drawPath(pathTL, paint);

    // 2. Top-Right
    final pathTR = Path();
    pathTR.moveTo(w - bracketLen, 0);
    pathTR.lineTo(w - cornerRadius, 0);
    pathTR.arcToPoint(Offset(w, cornerRadius), radius: const Radius.circular(cornerRadius));
    pathTR.lineTo(w, bracketLen);
    canvas.drawPath(pathTR, paint);

    // 3. Bottom-Left
    final pathBL = Path();
    pathBL.moveTo(0, h - bracketLen);
    pathBL.lineTo(0, h - cornerRadius);
    pathBL.arcToPoint(Offset(cornerRadius, h), radius: const Radius.circular(cornerRadius));
    pathBL.lineTo(bracketLen, h);
    canvas.drawPath(pathBL, paint);

    // 4. Bottom-Right
    final pathBR = Path();
    pathBR.moveTo(w - bracketLen, h);
    pathBR.lineTo(w - cornerRadius, h);
    pathBR.arcToPoint(Offset(w, h - cornerRadius), radius: const Radius.circular(cornerRadius));
    pathBR.lineTo(w, h - bracketLen);
    canvas.drawPath(pathBR, paint);

    // Eyes
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(w * 0.36, h * 0.42),
          width: strokeWidth + 0.8,
          height: strokeWidth + 3.0,
        ),
        const Radius.circular(2),
      ),
      fillPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(w * 0.64, h * 0.42),
          width: strokeWidth + 0.8,
          height: strokeWidth + 3.0,
        ),
        const Radius.circular(2),
      ),
      fillPaint,
    );

    // Nose
    canvas.drawLine(
      Offset(w * 0.50, h * 0.48),
      Offset(w * 0.50, h * 0.55),
      paint,
    );

    // Smile
    final smilePath = Path();
    smilePath.moveTo(w * 0.35, h * 0.68);
    smilePath.quadraticBezierTo(
      w * 0.50,
      h * 0.78,
      w * 0.65,
      h * 0.68,
    );
    canvas.drawPath(smilePath, paint);
  }

  @override
  bool shouldRepaint(covariant _FaceIdIconPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}
`;

  const logoutConfirmationDartCode = `import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_dimensions.dart";
import "../../../core/theme/app_spacing.dart";
import "../../../core/theme/app_typography.dart";

/// Screen: Logout Confirmation Screen (\`screen-logout-confirmation\`)
/// Authentic, pixel-perfect reproduction of the CRM Pro Field Sales Logout Confirmation dialog/sheet.
class LogoutConfirmationScreen extends StatefulWidget {
  final VoidCallback? onSignOut;
  final VoidCallback? onCancel;

  const LogoutConfirmationScreen({
    super.key,
    this.onSignOut,
    this.onCancel,
  });

  @override
  State<LogoutConfirmationScreen> createState() => _LogoutConfirmationScreenState();
}

class _LogoutConfirmationScreenState extends State<LogoutConfirmationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Stack(
        children: [
          // Underlying Settings page (dimmed)
          // Modal bottom sheet with Marcus Vance avatar and Sign Out / Cancel buttons
          // Bottom Navigation bar with Profile active
        ],
      ),
    );
  }
}
`;

  const onboardingSkipConfirmationDartCode = `import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_dimensions.dart";
import "../../../core/theme/app_spacing.dart";
import "../../../core/theme/app_typography.dart";

/// Onboarding Screen: Skip Confirmation Screen (\`screen-onboarding-skip-confirmation\`)
///
/// Pixel-accurate implementation matching the CRM Pro Field Sales design system.
/// Features a dimmed background showing the Permissions setup screen, overlaid
/// by a modal bottom sheet warning reps about feature limitations when permissions are skipped.
class OnboardingSkipConfirmationScreen extends StatefulWidget {
  final String? skippedFromRoute;
  final VoidCallback? onGoBack;
  final VoidCallback? onSkipAnyway;
  final ValueChanged<int>? onBottomNavTap;

  const OnboardingSkipConfirmationScreen({
    super.key,
    this.skippedFromRoute,
    this.onGoBack,
    this.onSkipAnyway,
    this.onBottomNavTap,
  });

  /// Static helper to show the skip confirmation as a modal bottom sheet
  static Future<bool?> show(
    BuildContext context, {
    String? skippedFromRoute,
    VoidCallback? onGoBack,
    VoidCallback? onSkipAnyway,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => OnboardingSkipConfirmationSheet(
        onGoBack: () {
          Navigator.of(ctx).pop(false);
          onGoBack?.call();
        },
        onSkipAnyway: () {
          Navigator.of(ctx).pop(true);
          onSkipAnyway?.call();
        },
      ),
    );
  }

  @override
  State<OnboardingSkipConfirmationScreen> createState() =>
      _OnboardingSkipConfirmationScreenState();
}

class _OnboardingSkipConfirmationScreenState
    extends State<OnboardingSkipConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _slideAnimation = Tween<double>(begin: 40.0, end: 0.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleGoBack() {
    if (widget.onGoBack != null) {
      widget.onGoBack!();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else if (widget.skippedFromRoute != null) {
      Navigator.of(context).pushReplacementNamed(widget.skippedFromRoute!);
    } else {
      Navigator.of(context).pushReplacementNamed("/onboarding-offline-setup");
    }
  }

  void _handleSkipAnyway() {
    if (widget.onSkipAnyway != null) {
      widget.onSkipAnyway!();
    } else {
      Navigator.of(context).pushReplacementNamed("/onboarding-complete");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8E95A0),
      body: Stack(
        children: [
          // 1. Underlying Permissions Screen (Dimmed Context)
          Positioned.fill(
            child: Container(
              color: const Color(0xFF88929E),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 80),
                      // Rounded Square Permissions Placeholder Graphic
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6B7482).withOpacity(0.65),
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Title: Permissions
                      Text(
                        "Permissions",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1E293B),
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Subtitle
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 300),
                        child: Text(
                          "Enable the following permissions to ensure a smooth CRM field sales workflow.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF334155),
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 2. Dimmed Scrim Overlay (Greyed-out backdrop)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) => Container(
                color: Colors.black.withOpacity(0.20 * _fadeAnimation.value),
              ),
            ),
          ),

          // 3. Foreground Bottom Sheet Modal + Bottom Navigation
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: child,
                  ),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: AppDimensions.maxContentWidth,
                      ),
                      child: OnboardingSkipConfirmationSheet(
                        onGoBack: _handleGoBack,
                        onSkipAnyway: _handleSkipAnyway,
                      ),
                    ),
                  ),
                  _buildBottomNavigation(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE5E7EB), width: 1.0),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, "Home", Icons.home_outlined),
              _buildNavItem(1, "Leads", Icons.person_add_alt_outlined),
              _buildNavItem(2, "Visits", Icons.location_on_outlined),
              _buildNavItem(3, "Tasks", Icons.assignment_turned_in_outlined),
              _buildNavItem(4, "Profile", Icons.person_outline_rounded),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String label, IconData icon) {
    final navColor = const Color(0xFF0F4C4C);

    return InkWell(
      onTap: () {
        setState(() {
          _currentNavIndex = index;
        });
        widget.onBottomNavTap?.call(index);
      },
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: navColor,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: navColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Standalone Reusable Skip Confirmation Bottom Sheet
class OnboardingSkipConfirmationSheet extends StatelessWidget {
  final VoidCallback? onGoBack;
  final VoidCallback? onSkipAnyway;

  const OnboardingSkipConfirmationSheet({
    super.key,
    this.onGoBack,
    this.onSkipAnyway,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.only(
        top: 10,
        left: 20,
        right: 20,
        bottom: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle pill
          Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Title: "Skip Permissions?"
          Text(
            "Skip Permissions?",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF111827),
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle / Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              "Some features will be limited without these permissions. You can enable them later in Settings.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF4B5563),
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Feature Limitation Warning Box (Location, Camera, Notifications)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFF1F5F9),
                width: 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLimitationItem(
                  category: "Location",
                  description: "Nearby leads & check-in won't work",
                ),
                const SizedBox(height: 10),
                _buildLimitationItem(
                  category: "Camera",
                  description: "Can't capture visit photos",
                ),
                const SizedBox(height: 10),
                _buildLimitationItem(
                  category: "Notifications",
                  description: "You'll miss important updates",
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // Primary Button: "Go Back" (Deep Teal #0F4C4C)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onGoBack,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F4C4C),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Go Back",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Secondary Button: "Skip Anyway" (White Outlined)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: onSkipAnyway,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF374151),
                side: const BorderSide(
                  color: Color(0xFFE5E7EB),
                  width: 1.2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Skip Anyway",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF374151),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLimitationItem({
    required String category,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "•  ",
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF111827),
          ),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.inter(
                fontSize: 13.5,
                color: const Color(0xFF334155),
                height: 1.35,
              ),
              children: [
                TextSpan(
                  text: "$category: ",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                TextSpan(
                  text: description,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
`;

  const passwordResetSuccessDartCode = `import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_typography.dart";
import "../../../core/theme/app_dimensions.dart";
import "../../../core/theme/app_spacing.dart";

/// Screen 8: Password Reset Success Screen
/// Authentic, pixel-accurate reproduction of the CRM Pro Field Sales Password Reset Success screen.
/// Follows the CRM Pro Flutter/Dart master prompt and design system.
class PasswordResetSuccessScreen extends StatefulWidget {
  final VoidCallback? onBackToSignIn;
  final String title;
  final String message;
  final String buttonText;

  const PasswordResetSuccessScreen({
    super.key,
    this.onBackToSignIn,
    this.title = "Password Reset!",
    this.message = "Your password has been successfully reset. You can now sign in with your new password.",
    this.buttonText = "Back to Sign In",
  });

  @override
  State<PasswordResetSuccessScreen> createState() => _PasswordResetSuccessScreenState();
}

class _PasswordResetSuccessScreenState extends State<PasswordResetSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleBackToSignIn() {
    if (widget.onBackToSignIn != null) {
      widget.onBackToSignIn!();
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(
        "/sign-in",
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Spacer(flex: 3),

                      // 1. Success Concentric Circular Badge with Double Checkmark
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Center(
                          child: Container(
                            width: 196,
                            height: 196,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFD1FADF), // Soft mint outer glow circle
                            ),
                            alignment: Alignment.center,
                            child: Container(
                              width: 128,
                              height: 128,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF10B981), // Emerald green inner circle
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x1A10B981),
                                    blurRadius: 16,
                                    offset: Offset(0, 6),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: CustomPaint(
                                size: const Size(56, 42),
                                painter: _DoubleCheckPainter(
                                  color: Colors.white,
                                  strokeWidth: 2.4,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 36),

                      // 2. Headings & Message (Fade-in transition)
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            Text(
                              widget.title,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                                letterSpacing: -0.5,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                widget.message,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF4B5563),
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // 3. Primary Action Button: "Back to Sign In"
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SizedBox(
                          width: double.infinity,
                          height: AppDimensions.buttonHeight,
                          child: ElevatedButton(
                            onPressed: _handleBackToSignIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              widget.buttonText,
                              style: AppTypography.buttonPrimary.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const Spacer(flex: 3),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DoubleCheckPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _DoubleCheckPainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    final path1 = Path();
    path1.moveTo(w * 0.12, h * 0.54);
    path1.lineTo(w * 0.38, h * 0.82);
    path1.lineTo(w * 0.84, h * 0.28);
    canvas.drawPath(path1, paint);

    final path2 = Path();
    path2.moveTo(w * 0.50, h * 0.58);
    path2.lineTo(w * 0.66, h * 0.76);
    path2.lineTo(w * 0.98, h * 0.38);
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant _DoubleCheckPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}`;

  const formatCountdown = (totalSec: number) => {
    const mins = Math.floor(totalSec / 60);
    const secs = totalSec % 60;
    return `${String(mins).padStart(2, '0')}:${String(secs).padStart(2, '0')}`;
  };

  const handleResendEmail = () => {
    if (isResending) return;
    setIsResending(true);
    setTimeout(() => {
      setIsResending(false);
      setCountdown(45);
      setVerificationFeedback('New verification link sent to your inbox!');
      setTimeout(() => setVerificationFeedback(null), 3500);
    }, 600);
  };

  const handleOpenEmailApp = () => {
    setVerificationFeedback('Opening default email application...');
    setTimeout(() => setVerificationFeedback(null), 3000);
  };

  const maskedEmail = signUpEmail && signUpEmail.includes('@')
    ? `${signUpEmail.split('@')[0].charAt(0)}***@${signUpEmail.split('@')[1]}`
    : 'j***@company.com';

  // Forgot Password Validation and Submission
  const getForgotEmailError = () => {
    if (!forgotAttempted) return null;
    const trimmed = forgotEmail.trim();
    if (!trimmed) return 'Email address is required';
    const emailRegex = /^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$/;
    if (!emailRegex.test(trimmed)) return 'Email address is invalid';
    return null;
  };

  const forgotEmailError = getForgotEmailError();

  const handleForgotSubmit = (e?: React.FormEvent) => {
    if (e) e.preventDefault();
    setForgotAttempted(true);
    const trimmed = forgotEmail.trim();
    const emailRegex = /^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$/;
    if (!trimmed || !emailRegex.test(trimmed)) {
      return;
    }
    setForgotLoading(true);
    setTimeout(() => {
      setForgotLoading(false);
      setForgotSuccessMessage(`6-digit verification code sent to ${trimmed}`);
      setTimeout(() => {
        setForgotSuccessMessage(null);
        setSelectedScreen('otp');
      }, 1000);
    }, 700);
  };

  const otpVerificationDartCode = `import "dart:async";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_typography.dart";
import "../../../core/theme/app_dimensions.dart";
import "../../../core/theme/app_spacing.dart";

/// Screen 6: OTP Verification Screen ("Verify Your Identity")
/// Pixel-accurate reproduction of the CRM Pro Field Sales OTP Verification screen.
class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final VoidCallback? onBack;
  final ValueChanged<String>? onVerifySuccess;
  final VoidCallback? onResend;
  final VoidCallback? onSignInTap;
  final int initialCountdownSeconds;
  final String? initialError;

  const OtpVerificationScreen({
    super.key,
    this.email = "j***@company.com",
    this.onBack,
    this.onVerifySuccess,
    this.onResend,
    this.onSignInTap,
    this.initialCountdownSeconds = 45,
    this.initialError,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  static const int _otpLength = 6;
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  late int _secondsRemaining;
  Timer? _countdownTimer;
  bool _isLoading = false;
  bool _isResending = false;
  String? _errorMessage;
  bool _showSuccessToast = false;
  String _successToastMessage = "";

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_otpLength, (_) => TextEditingController());
    _focusNodes = List.generate(_otpLength, (_) => FocusNode());
    _secondsRemaining = widget.initialCountdownSeconds;
    _errorMessage = widget.initialError;

    _startTimer();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  String _formatTimer(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return "\${m.toString().padLeft(2, '0')}:\${s.toString().padLeft(2, '0')}";
  }

  String get _currentOtp =>
      _controllers.map((controller) => controller.text).join();

  bool get _isOtpComplete =>
      _controllers.every((c) => c.text.trim().isNotEmpty) &&
      _currentOtp.length == _otpLength;

  void _onDigitChanged(int index, String value) {
    setState(() {
      _errorMessage = null;
    });

    if (value.length > 1) {
      // Handle paste of multiple characters
      final clean = value.replaceAll(RegExp(r"[^0-9]"), "");
      for (int i = 0; i < _otpLength && i < clean.length; i++) {
        _controllers[i].text = clean[i];
      }
      final nextIndex = (clean.length < _otpLength) ? clean.length : _otpLength - 1;
      _focusNodes[nextIndex].requestFocus();
      return;
    }

    if (value.isNotEmpty) {
      if (index < _otpLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }
  }

  void _handleBackspace(int index) {
    setState(() {
      _errorMessage = null;
    });
    if (_controllers[index].text.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
    } else {
      _controllers[index].clear();
    }
  }

  void _handleResend() {
    if (_secondsRemaining > 0 || _isResending) return;

    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _isResending = false;
        _secondsRemaining = widget.initialCountdownSeconds;
        _showSuccessToast = true;
        _successToastMessage = "New 6-digit code sent to \${widget.email}";
      });
      _startTimer();
      widget.onResend?.call();

      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) {
          setState(() {
            _showSuccessToast = false;
          });
        }
      });
    });
  }

  void _handleVerify() {
    final otp = _currentOtp;
    if (otp.length < _otpLength) {
      setState(() {
        _errorMessage = "Invalid code. Please check and try again.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      // Verification logic: accept '123456' as valid or show invalid message
      if (otp == "123456") {
        setState(() {
          _showSuccessToast = true;
          _successToastMessage = "Identity verified successfully!";
        });
        widget.onVerifySuccess?.call(otp);
      } else {
        setState(() {
          _errorMessage = "Invalid code. Please check and try again.";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPaddingH,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Top Navigation Bar (Back Button)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: InkWell(
                            onTap: widget.onBack ??
                                () => Navigator.of(context).maybePop(),
                            borderRadius: BorderRadius.circular(20),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.chevron_left_rounded,
                                size: 28,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Optional Feedback Toast
                      if (_showSuccessToast)
                        Container(
                          margin: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14.0,
                            vertical: 10.0,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.successLight,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.success,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _successToastMessage,
                                  style: const TextStyle(
                                    fontFamily: "Inter",
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF065F46),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // 2. Graphic Badge (120x120 Mint Circle with Shield-Check)
                      Padding(
                        padding: const EdgeInsets.only(top: 24.0, bottom: 28.0),
                        child: Center(
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE8F5F3),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: CustomPaint(
                                size: const Size(38, 44),
                                painter: _ShieldCheckPainter(
                                  color: AppColors.primary,
                                  strokeWidth: 2.8,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // 3. Screen Headline
                      const Text(
                        "Verify Your Identity",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: "Inter",
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // 4. Subtitle with Masked Email
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: const TextStyle(
                              fontFamily: "Inter",
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF64748B),
                              height: 1.45,
                            ),
                            children: [
                              const TextSpan(text: "We sent a 6-digit code to "),
                              TextSpan(
                                text: widget.email,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),

                      // 5. 6-Digit OTP Input Row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(_otpLength, (index) {
                            final isFocused = _focusNodes[index].hasFocus;
                            final hasError = _errorMessage != null;

                            return Container(
                              width: 48,
                              height: 58,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: hasError
                                      ? AppColors.error
                                      : isFocused
                                          ? AppColors.primary
                                          : const Color(0xFFE2E8F0),
                                  width: isFocused || hasError ? 2.0 : 1.2,
                                ),
                                boxShadow: isFocused
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.12),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: RawKeyboardListener(
                                focusNode: FocusNode(),
                                onKey: (event) {
                                  if (event is RawKeyDownEvent &&
                                      event.logicalKey ==
                                          LogicalKeyboardKey.backspace) {
                                    _handleBackspace(index);
                                  }
                                },
                                child: TextField(
                                  controller: _controllers[index],
                                  focusNode: _focusNodes[index],
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(1),
                                  ],
                                  style: const TextStyle(
                                    fontFamily: "Inter",
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                  ),
                                  cursorColor: AppColors.primary,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    counterText: "",
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  onChanged: (value) =>
                                      _onDigitChanged(index, value),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),

                      // 6. Error Message (if any)
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.warning_rounded,
                              size: 14,
                              color: AppColors.error,
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  fontFamily: "Inter",
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 20),

                      // 7. Resend Code Countdown Row
                      Center(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontFamily: "Inter",
                              fontSize: 14,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w400,
                            ),
                            children: [
                              const TextSpan(text: "Didn't receive? "),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: GestureDetector(
                                  onTap: _secondsRemaining == 0
                                      ? _handleResend
                                      : null,
                                  child: Text(
                                    _secondsRemaining > 0
                                        ? "Resend (\${_formatTimer(_secondsRemaining)})"
                                        : "Resend Code",
                                    style: TextStyle(
                                      fontFamily: "Inter",
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                      decoration: _secondsRemaining == 0
                                          ? TextDecoration.underline
                                          : TextDecoration.none,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // 8. Primary CTA: Verify Code Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: (_isLoading || !_isOtpComplete)
                              ? null
                              : _handleVerify,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            disabledBackgroundColor:
                                AppColors.primary.withValues(alpha: 0.38),
                            foregroundColor: Colors.white,
                            disabledForegroundColor:
                                Colors.white.withValues(alpha: 0.7),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  "Verify Code",
                                  style: TextStyle(
                                    fontFamily: "Inter",
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                        ),
                      ),

                      const Spacer(),

                      // 9. Bottom Footer: Back to Sign In
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24.0, top: 20.0),
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              if (widget.onSignInTap != null) {
                                widget.onSignInTap!();
                              } else {
                                Navigator.of(context)
                                    .pushReplacementNamed("/sign-in");
                              }
                            },
                            child: RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                  fontFamily: "Inter",
                                  fontSize: 14,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                                children: [
                                  TextSpan(text: "Back to "),
                                  TextSpan(
                                    text: "Sign In",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Custom painter for the Shield with inner Checkmark
class _ShieldCheckPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _ShieldCheckPainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // Outer Shield Path
    final shieldPath = Path();
    shieldPath.moveTo(w * 0.5, 0);
    shieldPath.lineTo(w, h * 0.18);
    shieldPath.quadraticBezierTo(w, h * 0.65, w * 0.5, h);
    shieldPath.quadraticBezierTo(0, h * 0.65, 0, h * 0.18);
    shieldPath.close();

    canvas.drawPath(shieldPath, paint);

    // Inner Checkmark Path
    final checkPath = Path();
    checkPath.moveTo(w * 0.35, h * 0.48);
    checkPath.lineTo(w * 0.47, h * 0.60);
    checkPath.lineTo(w * 0.68, h * 0.38);

    canvas.drawPath(checkPath, paint);
  }

  @override
  bool shouldRepaint(covariant _ShieldCheckPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}
`;

  const forgotPasswordDartCode = `import "package:flutter/material.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_typography.dart";
import "../../../core/theme/app_dimensions.dart";
import "../../../core/theme/app_spacing.dart";

/// Screen 5: Forgot Password Screen
/// Authentic, pixel-accurate reproduction of the CRM Pro Field Sales Forgot Password screen.
class ForgotPasswordScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final ValueChanged<String>? onSendCode;
  final VoidCallback? onSignInTap;
  final String? initialEmail;

  const ForgotPasswordScreen({
    super.key,
    this.onBack,
    this.onSendCode,
    this.onSignInTap,
    this.initialEmail,
  });

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _hasAttemptedSubmit = false;
  String? _emailError;

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null && widget.initialEmail!.isNotEmpty) {
      _emailController.text = widget.initialEmail!;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_\`{|}~-]+@[a-zA-Z0-9-]+(?:\\.[a-zA-Z0-9-]+)+$");
    return emailRegex.hasMatch(email.trim());
  }

  void _validateField() {
    final text = _emailController.text.trim();
    if (text.isEmpty) {
      _emailError = "Email address is required";
    } else if (!_isValidEmail(text)) {
      _emailError = "Email address is invalid";
    } else {
      _emailError = null;
    }
  }

  void _handleSubmit() {
    setState(() {
      _hasAttemptedSubmit = true;
      _validateField();
    });

    if (_emailError != null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate sending 6-digit verification code
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      if (widget.onSendCode != null) {
        widget.onSendCode!(_emailController.text.trim());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.primary,
            content: Text(
              "Verification code sent to \${_emailController.text.trim()}",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),

                        // 1. Top Navigation Bar: Back Button
                        Align(
                          alignment: Alignment.centerLeft,
                          child: InkWell(
                            onTap: () {
                              if (widget.onBack != null) {
                                widget.onBack!();
                              } else {
                                Navigator.of(context).maybePop();
                              }
                            },
                            borderRadius: BorderRadius.circular(AppDimensions.radiusBackButton),
                            child: Container(
                              width: 44,
                              height: 44,
                              alignment: Alignment.centerLeft,
                              child: const Icon(
                                Icons.chevron_left_rounded,
                                size: 32,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // 2. Lock Graphic Badge
                        Center(
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE8F5F3),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: CustomPaint(
                                size: const Size(44, 48),
                                painter: _LockIconPainter(
                                  color: AppColors.primary,
                                  strokeWidth: 2.6,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // 3. Screen Title
                        Center(
                          child: Text(
                            "Forgot Password?",
                            textAlign: TextAlign.center,
                            style: AppTypography.h2.copyWith(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // 4. Instructions Subtitle
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              "Enter your registered email below. We'll send you a 6-digit verification code to reset your password.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: "Inter",
                                fontSize: 15,
                                height: 1.45,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // 5. Email Address Input Field
                        const Text(
                          "Email Address",
                          style: TextStyle(
                            fontFamily: "Inter",
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 8),

                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (val) {
                              if (_hasAttemptedSubmit) {
                                setState(() {
                                  _validateField();
                                });
                              }
                            },
                            style: const TextStyle(
                              fontFamily: "Inter",
                              fontSize: 15,
                              color: Color(0xFF0F172A),
                            ),
                            decoration: InputDecoration(
                              hintText: "john.sales@company.com",
                              hintStyle: const TextStyle(
                                fontFamily: "Inter",
                                color: Color(0xFF94A3B8),
                                fontSize: 15,
                              ),
                              prefixIcon: const Padding(
                                padding: EdgeInsets.only(left: 14, right: 12),
                                child: Icon(
                                  Icons.mail_outline_rounded,
                                  size: 22,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              prefixIconConstraints: const BoxConstraints(
                                minWidth: 46,
                                minHeight: 46,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 15,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: _emailError != null
                                      ? const Color(0xFFEF4444)
                                      : const Color(0xFFE2E8F0),
                                  width: _emailError != null ? 1.4 : 1.0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: _emailError != null
                                      ? const Color(0xFFEF4444)
                                      : AppColors.primary,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Error message
                        if (_emailError != null) ...[
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.only(left: 2),
                            child: Text(
                              _emailError!,
                              style: const TextStyle(
                                fontFamily: "Inter",
                                fontSize: 13,
                                color: Color(0xFFEF4444),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // 6. Action Button: Send Verification Code
                        SizedBox(
                          height: AppDimensions.buttonHeight,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.7),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    "Send Verification Code",
                                    style: TextStyle(
                                      fontFamily: "Inter",
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                          ),
                        ),

                        const Spacer(),

                        // 7. Footer: Remember your password? Sign In
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24.0, top: 20.0),
                          child: Center(
                            child: GestureDetector(
                              onTap: () {
                                if (widget.onSignInTap != null) {
                                  widget.onSignInTap!();
                                } else {
                                  Navigator.of(context).pushReplacementNamed("/sign-in");
                                }
                              },
                              child: RichText(
                                text: const TextSpan(
                                  style: TextStyle(
                                    fontFamily: "Inter",
                                    fontSize: 14,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  children: [
                                    TextSpan(text: "Remember your password? "),
                                    TextSpan(
                                      text: "Sign In",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LockIconPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _LockIconPainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    final shacklePath = Path();
    final shackleLeft = w * 0.22;
    final shackleRight = w * 0.78;
    final shackleTop = h * 0.04;
    final shackleBottom = h * 0.44;

    shacklePath.moveTo(shackleLeft, shackleBottom);
    shacklePath.lineTo(shackleLeft, shackleTop + (w * 0.28));
    shacklePath.arcToPoint(
      Offset(shackleRight, shackleTop + (w * 0.28)),
      radius: Radius.circular((shackleRight - shackleLeft) / 2),
      clockwise: true,
    );
    shacklePath.lineTo(shackleRight, shackleBottom);

    canvas.drawPath(shacklePath, paint);

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, h * 0.40, w, h * 0.58),
      const Radius.circular(9),
    );
    canvas.drawRRect(bodyRect, paint);

    final keyholeCenter = Offset(w * 0.5, h * 0.65);
    canvas.drawCircle(keyholeCenter, 3.2, fillPaint);

    final notchPath = Path();
    notchPath.moveTo(w * 0.46, h * 0.67);
    notchPath.lineTo(w * 0.54, h * 0.67);
    notchPath.lineTo(w * 0.53, h * 0.77);
    notchPath.lineTo(w * 0.47, h * 0.77);
    notchPath.close();
    canvas.drawPath(notchPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _LockIconPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}`;

  const emailVerificationDartCode = `import "dart:async";
import "package:flutter/material.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_typography.dart";
import "../../../core/theme/app_dimensions.dart";
import "../../../core/theme/app_spacing.dart";

/// Screen 4: Email Verification Screen
/// Authentic, pixel-accurate reproduction of the CRM Pro Field Sales Email Verification screen.
class EmailVerificationScreen extends StatefulWidget {
  final String email;
  final VoidCallback? onBack;
  final VoidCallback? onOpenEmailApp;
  final VoidCallback? onResendEmail;
  final VoidCallback? onSignInTap;
  final int initialCountdownSeconds;

  const EmailVerificationScreen({
    super.key,
    this.email = "j***@company.com",
    this.onBack,
    this.onOpenEmailApp,
    this.onResendEmail,
    this.onSignInTap,
    this.initialCountdownSeconds = 45,
  });

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  late int _secondsRemaining;
  Timer? _countdownTimer;
  bool _isResending = false;
  bool _showSuccessBanner = false;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.initialCountdownSeconds;
    _startTimer();
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _handleResend() {
    if (_secondsRemaining > 0 || _isResending) return;

    setState(() {
      _isResending = true;
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _isResending = false;
        _secondsRemaining = widget.initialCountdownSeconds;
        _showSuccessBanner = true;
      });
      _startTimer();
      widget.onResendEmail?.call();

      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) {
          setState(() {
            _showSuccessBanner = false;
          });
        }
      });
    });
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final minutesStr = minutes.toString().padLeft(2, "0");
    final secondsStr = seconds.toString().padLeft(2, "0");
    return "$minutesStr:$secondsStr";
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canResend = _secondsRemaining == 0;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),

                        // 1. Top Navigation Bar with Back Button
                        Align(
                          alignment: Alignment.centerLeft,
                          child: InkWell(
                            onTap: () {
                              if (widget.onBack != null) {
                                widget.onBack!();
                              } else {
                                Navigator.of(context).maybePop();
                              }
                            },
                            borderRadius: BorderRadius.circular(AppDimensions.radiusBackButton),
                            child: Container(
                              width: 44,
                              height: 44,
                              alignment: Alignment.centerLeft,
                              child: const Icon(
                                Icons.chevron_left_rounded,
                                size: 32,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ),
                        ),

                        const Spacer(flex: 2),

                        // 2. Verified Shield Graphic Badge
                        Center(
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE8F5F3),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: CustomPaint(
                                size: const Size(48, 52),
                                painter: _ShieldCheckPainter(
                                  color: AppColors.primary,
                                  strokeWidth: 2.6,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 36),

                        // 3. Screen Title
                        Center(
                          child: Text(
                            "Verify Your Email",
                            textAlign: TextAlign.center,
                            style: AppTypography.h2.copyWith(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // 4. Instructions & Masked Email
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: const TextStyle(
                                  fontFamily: "Inter",
                                  fontSize: 15,
                                  height: 1.5,
                                  color: Color(0xFF64748B),
                                ),
                                children: [
                                  const TextSpan(text: "We've sent a verification link to\\n"),
                                  TextSpan(
                                    text: widget.email,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const TextSpan(text: ". Please check your inbox."),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 38),

                        // 5. Primary Action: Open Email App
                        SizedBox(
                          height: AppDimensions.buttonHeight,
                          child: ElevatedButton(
                            onPressed: () {
                              widget.onOpenEmailApp?.call();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                              ),
                            ),
                            child: const Text(
                              "Open Email App",
                              style: TextStyle(
                                fontFamily: "Inter",
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // 6. Secondary Action: Resend Email
                        SizedBox(
                          height: AppDimensions.buttonHeight,
                          child: OutlinedButton(
                            onPressed: canResend && !_isResending ? _handleResend : null,
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primary,
                              disabledForegroundColor: const Color(0xFF94A3B8),
                              side: BorderSide(
                                color: canResend ? AppColors.primary : const Color(0xFFCBD5E1),
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                              ),
                            ),
                            child: _isResending
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: AppColors.primary,
                                    ),
                                  )
                                : const Text(
                                    "Resend Email",
                                    style: TextStyle(
                                      fontFamily: "Inter",
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // 7. Resend Link Countdown Notice
                        Center(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontFamily: "Inter",
                                fontSize: 14,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                              children: [
                                const TextSpan(text: "Resend link available in "),
                                TextSpan(
                                  text: _formatTime(_secondsRemaining),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const Spacer(flex: 3),

                        // 8. Bottom Footer: Back to Sign In
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24.0, top: 20.0),
                          child: Center(
                            child: GestureDetector(
                              onTap: () {
                                if (widget.onSignInTap != null) {
                                  widget.onSignInTap!();
                                } else {
                                  Navigator.of(context).pushReplacementNamed("/sign-in");
                                }
                              },
                              child: RichText(
                                text: const TextSpan(
                                  style: TextStyle(
                                    fontFamily: "Inter",
                                    fontSize: 14,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  children: [
                                    TextSpan(text: "Back to "),
                                    TextSpan(
                                      text: "Sign In",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ShieldCheckPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _ShieldCheckPainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    final shieldPath = Path();
    shieldPath.moveTo(w * 0.5, 0);
    shieldPath.lineTo(w, h * 0.18);
    shieldPath.quadraticBezierTo(w, h * 0.65, w * 0.5, h);
    shieldPath.quadraticBezierTo(0, h * 0.65, 0, h * 0.18);
    shieldPath.close();
    canvas.drawPath(shieldPath, paint);

    final checkPath = Path();
    checkPath.moveTo(w * 0.35, h * 0.48);
    checkPath.lineTo(w * 0.47, h * 0.60);
    checkPath.lineTo(w * 0.68, h * 0.38);
    canvas.drawPath(checkPath, paint);
  }

  @override
  bool shouldRepaint(covariant _ShieldCheckPainter oldDelegate) => false;
}`;

  const signUpDartCode = `import "package:flutter/material.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_typography.dart";
import "../../../core/theme/app_dimensions.dart";

/// Screen 3: Sign Up Screen (Create Account)

/// Authentic, pixel-accurate reproduction of the CRM Pro Field Sales Sign Up screen.
class SignUpScreen extends StatefulWidget {
  final VoidCallback? onSignUpSuccess;
  final VoidCallback? onSignInTap;
  final VoidCallback? onCompanySSO;

  const SignUpScreen({
    super.key,
    this.onSignUpSuccess,
    this.onSignInTap,
    this.onCompanySSO,
  });

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyController = TextEditingController();

  String _selectedCountryCode = "+91";
  String? _selectedDesignation;

  final List<String> _designationOptions = [
    "Field Sales Executive",
    "Area Sales Manager",
    "Senior Sales Representative",
    "Territory Lead",
    "Business Development Executive",
    "Sales Director",
  ];

  final List<String> _countryCodes = [
    "+91", "+1", "+44", "+65", "+971", "+61"
  ];

  bool _hasAttemptedSubmit = false;
  String? _fullNameError;
  String? _emailError;
  String? _phoneError;
  String? _companyError;
  String? _designationError;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  void _validateAndSubmit() {
    setState(() {
      _hasAttemptedSubmit = true;
      final name = _fullNameController.text.trim();
      final email = _emailController.text.trim();
      final phone = _phoneController.text.trim();
      final company = _companyController.text.trim();

      _fullNameError = name.isEmpty ? "Full name is required" : null;
      if (email.isEmpty) {
        _emailError = "Email address is required";
      } else if (!email.contains("@") || !email.contains(".")) {
        _emailError = "Invalid email format";
      } else {
        _emailError = null;
      }
      _phoneError = phone.isEmpty ? "Phone number is required" : null;
      _companyError = company.isEmpty ? "Company name is required" : null;
      _designationError = (_selectedDesignation == null || _selectedDesignation!.isEmpty)
          ? "Please select a designation"
          : null;
    });

    if (_fullNameError == null &&
        _emailError == null &&
        _phoneError == null &&
        _companyError == null &&
        _designationError == null) {
      widget.onSignUpSuccess?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top Logo Row: [LP Icon] + "CRM Pro"
                Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      "LP",
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "CRM Pro",
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // 2. Headings
              const Text(
                "Create Account",
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Register to join the field sales network.",
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 24),

              // 3. Full Name Field
              const Text("Full Name", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              _buildInputField(
                controller: _fullNameController,
                hintText: "e.g. John Doe",
                prefixIcon: Icons.person_outline_rounded,
                hasError: _hasAttemptedSubmit && _fullNameError != null,
              ),
              if (_hasAttemptedSubmit && _fullNameError != null) ...[
                const SizedBox(height: 5),
                Text(_fullNameError!, style: const TextStyle(fontSize: 12, color: AppColors.error)),
              ],

              const SizedBox(height: 16),

              // 4. Email Address Field
              const Text("Email Address", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              _buildInputField(
                controller: _emailController,
                hintText: "e.g. john@company.com",
                prefixIcon: Icons.mail_outline_rounded,
                hasError: _hasAttemptedSubmit && _emailError != null,
              ),
              if (_hasAttemptedSubmit && _emailError != null) ...[
                const SizedBox(height: 5),
                Text(_emailError!, style: const TextStyle(fontSize: 12, color: AppColors.error)),
              ],

              const SizedBox(height: 16),

              // 5. Phone Number Field
              const Text("Phone Number", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    height: 52,
                    width: 88,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _hasAttemptedSubmit && _phoneError != null ? const Color(0xFFEF4444) : AppColors.border,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCountryCode,
                        items: _countryCodes.map((code) => DropdownMenuItem(value: code, child: Text(code))).toList(),
                        onChanged: (val) => setState(() => _selectedCountryCode = val!),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildInputField(
                      controller: _phoneController,
                      hintText: "98765 43210",
                      keyboardType: TextInputType.phone,
                      hasError: _hasAttemptedSubmit && _phoneError != null,
                    ),
                  ),
                ],
              ),
              if (_hasAttemptedSubmit && _phoneError != null) ...[
                const SizedBox(height: 5),
                Text(_phoneError!, style: const TextStyle(fontSize: 12, color: AppColors.error)),
              ],

              const SizedBox(height: 16),

              // 6. Company Name Field
              const Text("Company Name", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              _buildInputField(
                controller: _companyController,
                hintText: "e.g. Acme Corp",
                prefixIcon: Icons.business_center_outlined,
                hasError: _hasAttemptedSubmit && _companyError != null,
              ),
              if (_hasAttemptedSubmit && _companyError != null) ...[
                const SizedBox(height: 5),
                Text(_companyError!, style: const TextStyle(fontSize: 12, color: AppColors.error)),
              ],

              const SizedBox(height: 16),

              // 7. Designation Selector
              const Text("Designation", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _hasAttemptedSubmit && _designationError != null ? const Color(0xFFEF4444) : AppColors.border,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedDesignation,
                    isExpanded: true,
                    hint: const Text("Select Designation"),
                    items: _designationOptions.map((desig) => DropdownMenuItem(value: desig, child: Text(desig))).toList(),
                    onChanged: (val) => setState(() => _selectedDesignation = val),
                  ),
                ),
              ),
              if (_hasAttemptedSubmit && _designationError != null) ...[
                const SizedBox(height: 5),
                Text(_designationError!, style: const TextStyle(fontSize: 12, color: AppColors.error)),
              ],

              const SizedBox(height: 24),

              // 8. CTA Button
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: ElevatedButton(
                  onPressed: _validateAndSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Create Account"),
                ),
              ),

              const SizedBox(height: 26),

              // 9. OR SIGN UP WITH
              Row(
                children: const [
                  Expanded(child: Divider(color: AppColors.border)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14.0),
                    child: Text("OR SIGN UP WITH", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  ),
                  Expanded(child: Divider(color: AppColors.border)),
                ],
              ),

              const SizedBox(height: 20),

              // 10. Company SSO
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: OutlinedButton.icon(
                  onPressed: widget.onCompanySSO,
                  icon: const Icon(Icons.apartment_rounded, color: AppColors.primary),
                  label: const Text("Company SSO"),
                ),
              ),

              const SizedBox(height: 28),

              // 11. Footer: Already have an account? Sign In
              Center(
                child: InkWell(
                  onTap: widget.onSignInTap,
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary),
                      children: [
                        TextSpan(text: "Already have an account? "),
                        TextSpan(text: "Sign In", style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}`;

  const currentDartCode =
    selectedScreen === 'leads-list'
      ? leadsListDartCode
      : selectedScreen === 'nearby-leads'
      ? nearbyLeadsDartCode
      : selectedScreen === 'dashboard'
      ? dashboardDartCode
      : selectedScreen === 'notifications'
      ? notificationsDartCode
      : selectedScreen === 'intro-slide-three'
      ? introSlideThreeDartCode
      : selectedScreen === 'intro-slide-two'
      ? introSlideTwoDartCode
      : selectedScreen === 'app-intro-walkthrough'
      ? appIntroWalkthroughDartCode
      : selectedScreen === 'onboarding-complete'
      ? onboardingCompleteDartCode
      : selectedScreen === 'onboarding-offline-setup'
      ? onboardingOfflineSetupDartCode
      : selectedScreen === 'onboarding-notifications'
      ? onboardingNotificationsDartCode
      : selectedScreen === 'onboarding-microphone'
      ? onboardingMicrophoneDartCode
      : selectedScreen === 'onboarding-camera'
      ? onboardingCameraDartCode
      : selectedScreen === 'onboarding-location'
      ? onboardingLocationDartCode
      : selectedScreen === 'onboarding-welcome'
      ? onboardingWelcomeDartCode
      : selectedScreen === 'biometric'
      ? biometricLoginDartCode
      : selectedScreen === 'biometric-fail'
      ? `// Authentication Biometric Fail Screen (screen-biometric-fail)
// Reuses the BiometricLoginScreen component with isFailed: true
import 'package:flutter/material.dart';
import 'biometric_login_screen.dart';

class BiometricFailScreen extends StatelessWidget {
  final VoidCallback? onUsePasswordInstead;
  final VoidCallback? onTryAgain;
  final VoidCallback? onAuthenticated;

  const BiometricFailScreen({
    super.key,
    this.onUsePasswordInstead,
    this.onTryAgain,
    this.onAuthenticated,
  });

  @override
  Widget build(BuildContext context) {
    return BiometricLoginScreen(
      isFailed: true,
      onUsePasswordInstead: onUsePasswordInstead,
      onTryAgain: onTryAgain,
      onAuthenticated: onAuthenticated,
    );
  }
}`
      : selectedScreen === 'logout-confirmation'
      ? logoutConfirmationDartCode
      : selectedScreen === 'onboarding-skip-confirmation'
      ? onboardingSkipConfirmationDartCode
      : selectedScreen === 'success'
      ? passwordResetSuccessDartCode
      : selectedScreen === 'reset'
      ? resetPasswordDartCode
      : selectedScreen === 'otp'
      ? otpVerificationDartCode
      : selectedScreen === 'forgot'
      ? forgotPasswordDartCode
      : selectedScreen === 'verification'
      ? emailVerificationDartCode
      : selectedScreen === 'signup'
      ? signUpDartCode
      : selectedScreen === 'signin'
      ? `// Refer to lib/features/authentication/screens/sign_in_screen.dart`
      : `// Refer to lib/features/authentication/screens/splash_screen.dart`;

  const copyCode = () => {
    navigator.clipboard.writeText(currentDartCode);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div className="min-h-screen bg-[#EBF0F0] text-[#111827] flex flex-col font-['Inter',sans-serif]">
      {/* Top Application Header */}
      <header className="bg-white border-b border-[#E5E7EB] px-6 py-3 flex items-center justify-between sticky top-0 z-50">
        <div className="flex items-center space-x-3">
          <div className="w-9 h-9 rounded-xl bg-[#0F4C4C] text-white flex items-center justify-center font-extrabold text-sm shadow-xs">
            LP
          </div>
          <div>
            <div className="flex items-center space-x-2">
              <h1 className="text-base font-extrabold text-[#111827]">CRM Pro Field Sales</h1>
              <span className="bg-[#ECFDF5] text-[#10B981] text-[11px] font-semibold px-2 py-0.5 rounded-md border border-[#A7F3D0]">
                {selectedScreen === 'leads-list'
                  ? 'Leads (Screen 1)'
                  : selectedScreen === 'nearby-leads'
                  ? 'Nearby Leads (Screen 2)'
                  : selectedScreen === 'dashboard'
                  ? 'Dashboard (Screen 1)'
                  : selectedScreen === 'notifications'
                  ? 'Notifications (Screen 2)'
                  : selectedScreen === 'empty-notifications'
                  ? 'Empty Notifications (Screen 3)'
                  : selectedScreen === 'intro-slide-three'
                  ? 'Intro 3: Win with AI Insights'
                  : selectedScreen === 'intro-slide-two'
                  ? 'Intro 2: Track Your Visits'
                  : selectedScreen === 'app-intro-walkthrough'
                  ? 'Walkthrough: Plan Your Day'
                  : selectedScreen === 'onboarding-complete'
                  ? 'Onboarding 7: All Set!'
                  : selectedScreen === 'onboarding-offline-setup'
                  ? 'Onboarding 6: Offline Setup'
                  : selectedScreen === 'onboarding-notifications'
                  ? 'Onboarding 5: Notifications'
                  : selectedScreen === 'onboarding-microphone'
                  ? 'Onboarding 4: Microphone'
                  : selectedScreen === 'onboarding-camera'
                  ? 'Onboarding 3: Camera'
                  : selectedScreen === 'onboarding-location'
                  ? 'Onboarding 2: Location'
                  : selectedScreen === 'onboarding-welcome'
                  ? 'Onboarding 1: Welcome'
                  : selectedScreen === 'biometric'
                  ? 'Screen 8: Biometric Login'
                  : selectedScreen === 'biometric-fail'
                  ? 'Screen: Biometric Fail'
                  : selectedScreen === 'logout-confirmation'
                  ? 'Logout Confirmation (Modal Sheet)'
                  : selectedScreen === 'onboarding-skip-confirmation'
                  ? 'Onboarding: Skip Confirmation'
                  : selectedScreen === 'success'
                  ? 'Password Reset Success'
                  : selectedScreen === 'reset'
                  ? 'Screen 7: Set New Password'
                  : selectedScreen === 'otp'
                  ? 'Screen 6: OTP Verification'
                  : selectedScreen === 'forgot'
                  ? 'Screen 5: Forgot Password'
                  : selectedScreen === 'verification'
                  ? 'Screen 4: Email Verification'
                  : selectedScreen === 'signup'
                  ? 'Screen 3: Sign Up'
                  : selectedScreen === 'signin'
                  ? 'Screen 2: Sign In'
                  : 'Screen 1: Splash'}
              </span>
            </div>
            <p className="text-xs text-[#4B5563]">
              {selectedScreen === 'leads-list'
                ? 'Leads Flow • lib/features/leads/screens/leads_list_screen.dart (screen-leads-list)'
                : selectedScreen === 'nearby-leads'
                ? 'Leads Flow • lib/features/leads/screens/nearby_leads_screen.dart (screen-nearby-leads)'
                : selectedScreen === 'dashboard'
                ? 'Main Flow • lib/features/dashboard/screens/dashboard_screen.dart (screen-dashboard)'
                : selectedScreen === 'notifications'
                ? 'Dashboard & Notification • lib/features/dashboard/screens/notifications_screen.dart (screen-notification)'
                : selectedScreen === 'empty-notifications'
                ? 'Dashboard & Notification 3 • lib/features/dashboard/screens/screen_empty_notification.dart (screen-empty-notification)'
                : selectedScreen === 'intro-slide-three'
                ? 'Onboarding Flow • lib/features/onboarding/screens/intro_slide_three_screen.dart'
                : selectedScreen === 'intro-slide-two'

                ? 'Onboarding Flow • lib/features/onboarding/screens/intro_slide_two_screen.dart'
                : selectedScreen === 'app-intro-walkthrough'
                ? 'Onboarding Flow • lib/features/onboarding/screens/app_intro_walkthrough_screen.dart'
                : selectedScreen === 'onboarding-complete'
                ? 'Onboarding Flow • lib/features/onboarding/screens/onboarding_complete_screen.dart'
                : selectedScreen === 'onboarding-offline-setup'
                ? 'Onboarding Flow • lib/features/onboarding/screens/onboarding_offline_setup_screen.dart'
                : selectedScreen === 'onboarding-notifications'
                ? 'Onboarding Flow • lib/features/onboarding/screens/onboarding_notifications_screen.dart'
                : selectedScreen === 'onboarding-microphone'
                ? 'Onboarding Flow • lib/features/onboarding/screens/onboarding_microphone_screen.dart'
                : selectedScreen === 'onboarding-camera'
                ? 'Onboarding Flow • lib/features/onboarding/screens/onboarding_camera_screen.dart'
                : selectedScreen === 'onboarding-location'
                ? 'Onboarding Flow • lib/features/onboarding/screens/onboarding_location_screen.dart'
                : selectedScreen === 'onboarding-skip-confirmation'
                ? 'Onboarding Flow • lib/features/onboarding/screens/onboarding_skip_confirmation_screen.dart (screen-onboarding-skip-confirmation)'
                : selectedScreen === 'onboarding-welcome'
                ? 'Onboarding Flow • lib/features/onboarding/screens/onboarding_welcome_screen.dart'
                : `Authentication Flow • lib/features/authentication/screens/${
                    selectedScreen === 'biometric'
                      ? 'biometric_login_screen.dart'
                      : selectedScreen === 'biometric-fail'
                      ? 'biometric_fail_screen.dart (reusing biometric_login_screen.dart)'
                      : selectedScreen === 'logout-confirmation'
                      ? 'logout_confirmation_screen.dart (screen-logout-confirmation)'
                      : selectedScreen === 'success'
                      ? 'password_reset_success_screen.dart'
                      : selectedScreen === 'reset'
                      ? 'reset_password_screen.dart'
                      : selectedScreen === 'otp'
                      ? 'otp_verification_screen.dart'
                      : selectedScreen === 'forgot'
                      ? 'forgot_password_screen.dart'
                      : selectedScreen === 'verification'
                      ? 'email_verification_screen.dart'
                      : selectedScreen === 'signup'
                      ? 'sign_up_screen.dart'
                      : selectedScreen === 'signin'
                      ? 'sign_in_screen.dart'
                      : 'splash_screen.dart'
                  }`}
            </p>
          </div>
        </div>

        {/* Screen Switcher & View Switcher */}
        <div className="flex items-center space-x-3">
          {/* Switch Between Screens */}
          <div className="flex bg-[#F3F4F6] p-1 rounded-xl border border-[#E5E7EB] text-xs font-medium overflow-x-auto max-w-[650px] no-scrollbar">
            <button
              onClick={() => setSelectedScreen('leads-list')}
              className={`px-3 py-1.5 rounded-lg transition-all cursor-pointer whitespace-nowrap ${
                selectedScreen === 'leads-list'
                  ? 'bg-[#0F4C4C] text-white font-bold shadow-xs'
                  : 'text-[#4B5563] hover:text-[#111827]'
              }`}
            >
              Leads (Screen 1)
            </button>
            <button
              onClick={() => setSelectedScreen('nearby-leads')}
              className={`px-3 py-1.5 rounded-lg transition-all cursor-pointer whitespace-nowrap ${
                selectedScreen === 'nearby-leads'
                  ? 'bg-[#0F4C4C] text-white font-bold shadow-xs'
                  : 'text-[#4B5563] hover:text-[#111827]'
              }`}
            >
              Nearby Leads (Screen 2)
            </button>
            <button
              onClick={() => setSelectedScreen('dashboard')}
              className={`px-3 py-1.5 rounded-lg transition-all cursor-pointer whitespace-nowrap ${
                selectedScreen === 'dashboard'
                  ? 'bg-[#0F4C4C] text-white font-bold shadow-xs'
                  : 'text-[#4B5563] hover:text-[#111827]'
              }`}
            >
              Dashboard (Home)
            </button>
            <button
              onClick={() => setSelectedScreen('notifications')}
              className={`px-3 py-1.5 rounded-lg transition-all cursor-pointer whitespace-nowrap ${
                selectedScreen === 'notifications'
                  ? 'bg-[#0F4C4C] text-white font-bold shadow-xs'
                  : 'text-[#4B5563] hover:text-[#111827]'
              }`}
            >
              Notifications (Screen 2)
            </button>
            <button
              onClick={() => setSelectedScreen('empty-notifications')}
              className={`px-3 py-1.5 rounded-lg transition-all cursor-pointer whitespace-nowrap ${
                selectedScreen === 'empty-notifications'
                  ? 'bg-[#0F4C4C] text-white font-bold shadow-xs'
                  : 'text-[#4B5563] hover:text-[#111827]'
              }`}
            >
              Empty Alerts (Screen 3)
            </button>
            <button
              onClick={() => setSelectedScreen('intro-slide-three')}
              className={`px-3 py-1.5 rounded-lg transition-all cursor-pointer whitespace-nowrap ${
                selectedScreen === 'intro-slide-three'
                  ? 'bg-[#0F4C4C] text-white font-bold shadow-xs'
                  : 'text-[#4B5563] hover:text-[#111827]'
              }`}
            >
              Intro 3 (AI Insights)
            </button>

            <button
              onClick={() => setSelectedScreen('intro-slide-two')}
              className={`px-3 py-1.5 rounded-lg transition-all cursor-pointer ${
                selectedScreen === 'intro-slide-two'
                  ? 'bg-[#0F4C4C] text-white font-bold shadow-xs'
                  : 'text-[#4B5563] hover:text-[#111827]'
              }`}
            >
              Intro 2 (Track Visits)
            </button>
            <button
              onClick={() => {
                setSelectedScreen('app-intro-walkthrough');
                setWalkthroughPage(0);
              }}
              className={`px-3 py-1.5 rounded-lg transition-all cursor-pointer ${
                selectedScreen === 'app-intro-walkthrough'
                  ? 'bg-[#0F4C4C] text-white font-bold shadow-xs'
                  : 'text-[#4B5563] hover:text-[#111827]'
              }`}
            >
              Walkthrough (Intro)
            </button>
            <button
              onClick={() => setSelectedScreen('onboarding-complete')}
              className={`px-3 py-1.5 rounded-lg transition-all cursor-pointer ${
                selectedScreen === 'onboarding-complete'
                  ? 'bg-[#0F4C4C] text-white font-bold shadow-xs'
                  : 'text-[#4B5563] hover:text-[#111827]'
              }`}
            >
              Onboarding 7 (Done)
            </button>
            <button
              onClick={() => setSelectedScreen('onboarding-offline-setup')}
              className={`px-3 py-1.5 rounded-lg transition-all cursor-pointer ${
                selectedScreen === 'onboarding-offline-setup'
                  ? 'bg-[#0F4C4C] text-white font-bold shadow-xs'
                  : 'text-[#4B5563] hover:text-[#111827]'
              }`}
            >
              Onboarding 6 (Offline)
            </button>
            <button
              onClick={() => setSelectedScreen('onboarding-notifications')}
              className={`px-3 py-1.5 rounded-lg transition-all cursor-pointer ${
                selectedScreen === 'onboarding-notifications'
                  ? 'bg-[#0F4C4C] text-white font-bold shadow-xs'
                  : 'text-[#4B5563] hover:text-[#111827]'
              }`}
            >
              Onboarding 5 (Alerts)
            </button>
            <button
              onClick={() => setSelectedScreen('onboarding-microphone')}
              className={`px-3 py-1.5 rounded-lg transition-all ${
                selectedScreen === 'onboarding-microphone'
                  ? 'bg-[#0F4C4C] text-white font-bold shadow-xs'
                  : 'text-[#4B5563] hover:text-[#111827]'
              }`}
            >
              Onboarding 4 (Mic)
            </button>
            <button
              onClick={() => setSelectedScreen('onboarding-camera')}
              className={`px-3 py-1.5 rounded-lg transition-all ${
                selectedScreen === 'onboarding-camera'
                  ? 'bg-[#0F4C4C] text-white font-bold shadow-xs'
                  : 'text-[#4B5563] hover:text-[#111827]'
              }`}
            >
              Onboarding 3 (Camera)
            </button>
            <button
              onClick={() => setSelectedScreen('onboarding-location')}
              className={`px-3 py-1.5 rounded-lg transition-all ${
                selectedScreen === 'onboarding-location'
                  ? 'bg-[#0F4C4C] text-white font-bold shadow-xs'
                  : 'text-[#4B5563] hover:text-[#111827]'
              }`}
            >
              Onboarding 2 (Location)
            </button>
            <button
              onClick={() => setSelectedScreen('onboarding-welcome')}
              className={`px-3 py-1.5 rounded-lg transition-all ${
                selectedScreen === 'onboarding-welcome'
                  ? 'bg-[#0F4C4C] text-white font-bold shadow-xs'
                  : 'text-[#4B5563] hover:text-[#111827]'
              }`}
            >
              Onboarding 1 (Welcome)
            </button>
            <button
              onClick={() => {
                setSelectedScreen('biometric');
                setBiometricSuccess(false);
                setBiometricScanning(false);
              }}
              className={`px-3 py-1.5 rounded-lg transition-all ${
                selectedScreen === 'biometric'
                  ? 'bg-[#0F4C4C] text-white font-bold shadow-xs'
                  : 'text-[#4B5563] hover:text-[#111827]'
              }`}
            >
              Biometric
            </button>
            <button
              onClick={() => {
                setSelectedScreen('biometric-fail');
                setBiometricSuccess(false);
                setBiometricScanning(false);
              }}
              className={`px-3 py-1.5 rounded-lg transition-all whitespace-nowrap ${
                selectedScreen === 'biometric-fail'
                  ? 'bg-[#0F4C4C] text-white font-bold shadow-xs'
                  : 'text-[#4B5563] hover:text-[#111827]'
              }`}
            >
              Biometric Fail
            </button>
            <button
              onClick={() => setSelectedScreen('logout-confirmation')}
              className={`px-3 py-1.5 rounded-lg transition-all whitespace-nowrap cursor-pointer ${
                selectedScreen === 'logout-confirmation'
                  ? 'bg-[#0F4C4C] text-white font-bold shadow-xs'
                  : 'text-[#4B5563] hover:text-[#111827]'
              }`}
            >
              Logout Confirmation
            </button>
            <button
              onClick={() => setSelectedScreen('onboarding-skip-confirmation')}
              className={`px-3 py-1.5 rounded-lg transition-all whitespace-nowrap cursor-pointer ${
                selectedScreen === 'onboarding-skip-confirmation'
                  ? 'bg-[#0F4C4C] text-white font-bold shadow-xs'
                  : 'text-[#4B5563] hover:text-[#111827]'
              }`}
            >
              Onboarding Skip Confirm
            </button>
            <button
              onClick={() => setSelectedScreen('success')}
              className={`px-3 py-1.5 rounded-lg transition-all ${
                selectedScreen === 'success'
                  ? 'bg-[#0F4C4C] text-white font-bold shadow-xs'
                  : 'text-[#4B5563] hover:text-[#111827]'
              }`}
            >
              Reset Success
            </button>
            <button
              onClick={() => setSelectedScreen('reset')}
              className={`px-3 py-1.5 rounded-lg transition-all ${
                selectedScreen === 'reset'
                  ? 'bg-[#0F4C4C] text-white font-bold shadow-xs'
                  : 'text-[#4B5563] hover:text-[#111827]'
              }`}
            >
              Set Password
            </button>
            <button
              onClick={() => setSelectedScreen('otp')}
              className={`px-3 py-1.5 rounded-lg transition-all ${
                selectedScreen === 'otp'
                  ? 'bg-[#0F4C4C] text-white font-bold shadow-xs'
                  : 'text-[#4B5563] hover:text-[#111827]'
              }`}
            >
              OTP Verify
            </button>
            <button
              onClick={() => setSelectedScreen('forgot')}
              className={`px-3 py-1.5 rounded-lg transition-all ${
                selectedScreen === 'forgot'
                  ? 'bg-[#0F4C4C] text-white font-bold shadow-xs'
                  : 'text-[#4B5563] hover:text-[#111827]'
              }`}
            >
              Forgot Pwd
            </button>
            <button
              onClick={() => setSelectedScreen('verification')}
              className={`px-3 py-1.5 rounded-lg transition-all ${
                selectedScreen === 'verification'
                  ? 'bg-[#0F4C4C] text-white font-bold shadow-xs'
                  : 'text-[#4B5563] hover:text-[#111827]'
              }`}
            >
              Verify Email
            </button>
            <button
              onClick={() => setSelectedScreen('signup')}
              className={`px-3 py-1.5 rounded-lg transition-all ${
                selectedScreen === 'signup'
                  ? 'bg-[#0F4C4C] text-white font-bold shadow-xs'
                  : 'text-[#4B5563] hover:text-[#111827]'
              }`}
            >
              Sign Up
            </button>
            <button
              onClick={() => setSelectedScreen('signin')}
              className={`px-3 py-1.5 rounded-lg transition-all ${
                selectedScreen === 'signin'
                  ? 'bg-[#0F4C4C] text-white font-bold shadow-xs'
                  : 'text-[#4B5563] hover:text-[#111827]'
              }`}
            >
              Sign In
            </button>
            <button
              onClick={() => setSelectedScreen('splash')}
              className={`px-3 py-1.5 rounded-lg transition-all ${
                selectedScreen === 'splash'
                  ? 'bg-[#0F4C4C] text-white font-bold shadow-xs'
                  : 'text-[#4B5563] hover:text-[#111827]'
              }`}
            >
              Splash
            </button>
          </div>

          {/* View Mode */}
          <div className="flex bg-[#F3F4F6] p-1 rounded-xl border border-[#E5E7EB] text-xs font-medium">
            <button
              onClick={() => setActiveTab('preview')}
              className={`flex items-center space-x-1.5 px-3 py-1.5 rounded-lg transition-all ${
                activeTab === 'preview'
                  ? 'bg-white text-[#0F4C4C] shadow-xs font-bold'
                  : 'text-[#4B5563] hover:text-[#111827]'
              }`}
            >
              <Smartphone className="w-3.5 h-3.5" />
              <span>Canvas (390&times;844)</span>
            </button>
            <button
              onClick={() => setActiveTab('code')}
              className={`flex items-center space-x-1.5 px-3 py-1.5 rounded-lg transition-all ${
                activeTab === 'code'
                  ? 'bg-white text-[#0F4C4C] shadow-xs font-bold'
                  : 'text-[#4B5563] hover:text-[#111827]'
              }`}
            >
              <FileCode className="w-3.5 h-3.5" />
              <span>Flutter Dart</span>
            </button>
            <button
              onClick={() => setActiveTab('instructions')}
              className={`flex items-center space-x-1.5 px-3 py-1.5 rounded-lg transition-all ${
                activeTab === 'instructions'
                  ? 'bg-white text-[#0F4C4C] shadow-xs font-bold'
                  : 'text-[#4B5563] hover:text-[#111827]'
              }`}
            >
              <Terminal className="w-3.5 h-3.5" />
              <span>Android Guide</span>
            </button>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="flex-1 p-6 flex justify-center items-start overflow-y-auto">
        {activeTab === 'preview' && (
          <div className="flex flex-col items-center">
            {/* Viewport Meta Details */}
            <div className="w-[390px] mb-3 flex items-center justify-between text-xs text-[#4B5563] px-1">
              <span className="font-semibold text-[#0F4C4C]">
                Clean Canvas &bull; 390 &times; 844 px
              </span>
              <span className="text-[11px] text-[#6B7280]">
                {selectedScreen === 'leads-list'
                  ? 'Leads (Screen 1) • AI Score Cards, Filter Chips, Swipe Call & Log Visit, Bottom Nav'
                  : selectedScreen === 'dashboard'
                  ? 'Dashboard (Screen 1) • Hidden scrollbars, AI Daily Brief, Monthly Target Gauge, Schedule'
                  : selectedScreen === 'notifications'
                  ? 'Notifications (Screen 2) • Static Header, Filter Chips, Interactive List, Hidden Scrollbars'
                  : selectedScreen === 'app-intro-walkthrough'
                  ? 'App Intro Walkthrough • Plan Your Day, Close Deals Faster, Work 100% Offline'
                  : selectedScreen === 'onboarding-complete'
                  ? 'Onboarding Complete • Tap "Continue" to proceed to Biometric Security'
                  : selectedScreen === 'intro-slide-two'
                  ? 'Intro Slide 2 (Track Your Visits) • GPS Check-in & Real-time Visit Tracking'
                  : selectedScreen === 'onboarding-offline-setup'
                  ? 'Onboarding Offline Setup • Tap "Download Now" to test animated sync'
                  : selectedScreen === 'onboarding-notifications'
                  ? 'Onboarding Notifications Screen • Tap "Allow Notifications" or "Skip for now"'
                  : selectedScreen === 'onboarding-microphone'
                  ? 'Onboarding Microphone Screen • Tap "Allow Microphone Access" or "Skip for now"'
                  : selectedScreen === 'onboarding-camera'
                  ? 'Onboarding Camera Screen • Tap "Allow Camera Access" or "Skip for now"'
                  : selectedScreen === 'onboarding-location'
                  ? 'Onboarding Location Screen • Tap "Allow Location Access" or "Skip for now"'
                  : selectedScreen === 'onboarding-welcome'
                  ? 'Onboarding Welcome Screen • Tap checklist items or "Let\'s Go"'
                  : selectedScreen === 'biometric'
                  ? 'Biometric Login (Face ID) • Tap circle to simulate biometric scan'
                  : selectedScreen === 'biometric-fail'
                  ? 'Biometric Fail Screen • Too many attempts warning & action buttons'
                  : selectedScreen === 'logout-confirmation'
                  ? 'Logout Confirmation (Modal Sheet) • Replicating exact Marcus Vance sign-out sheet'
                  : selectedScreen === 'onboarding-skip-confirmation'
                  ? 'Onboarding Skip Confirmation • Bottom sheet warning reps about feature limits'
                  : selectedScreen === 'success'
                  ? 'Password Reset Success • Pixel-accurate Screen 8 layout'
                  : selectedScreen === 'reset'
                  ? 'Set New Password &bull; Test real-time validation & strength meter'
                  : selectedScreen === 'otp'
                  ? 'Enter all 6 digits to enable verify (test 123456 for success)'
                  : selectedScreen === 'forgot'
                  ? 'Tap "Send Verification Code" to test validation'
                  : selectedScreen === 'verification'
                  ? 'Email Verification Flow &bull; Timer & Resend'
                  : selectedScreen === 'signup'
                  ? 'Tap "Create Account" to test empty validation'
                  : 'Tap "Sign In" to test empty validation'}
              </span>
            </div>

            {/* Mobile Screen Canvas */}
            <div
              className={`w-[390px] h-[844px] rounded-[32px] shadow-2xl border-[6px] border-[#1F2937] flex flex-col overflow-hidden relative select-none ${
                selectedScreen === 'biometric' || selectedScreen === 'app-intro-walkthrough' || selectedScreen === 'intro-slide-two' || selectedScreen === 'intro-slide-three'
                  ? 'bg-[#0F4C4C]'
                  : 'bg-white'
              }`}
              style={{ boxShadow: '0 25px 60px -15px rgba(15, 76, 76, 0.35)' }}
            >
              {selectedScreen === 'leads-list' ? (
                /* LEADS SCREEN 1 (LEADS-LIST) */
                <LeadsListSimulator
                  onNavigateToDashboard={() => setSelectedScreen('dashboard')}
                  onNavigateToNotifications={() => setSelectedScreen('notifications')}
                  onNavigateToNearbyLeads={() => setSelectedScreen('nearby-leads')}
                />
              ) : selectedScreen === 'nearby-leads' ? (
                /* LEADS SCREEN 2 (NEARBY-LEADS) */
                <NearbyLeadsSimulator
                  onBackToLeadsList={() => setSelectedScreen('leads-list')}
                  onNavigateToDashboard={() => setSelectedScreen('dashboard')}
                  onNavigateToNotifications={() => setSelectedScreen('notifications')}
                />
              ) : selectedScreen === 'dashboard' ? (
                /* DASHBOARD AND NOTIFICATION SCREEN 1 (SCREEN-DASHBOARD) */
                <div className="flex-1 flex flex-col bg-white relative select-none h-full overflow-hidden font-['Inter',sans-serif]">
                  {/* Toast Feedback Notification */}
                  {dashboardToast && (
                    <div className="absolute top-4 left-4 right-4 z-40 bg-[#0F4C4C] text-white px-3.5 py-2.5 rounded-xl shadow-lg flex items-center justify-between text-xs animate-in fade-in slide-in-from-top-2 duration-200">
                      <div className="flex items-center space-x-2">
                        <Sparkles className="w-4 h-4 text-[#99F6E4] shrink-0" />
                        <span className="font-medium">{dashboardToast}</span>
                      </div>
                      <button
                        onClick={() => setDashboardToast(null)}
                        className="text-white/70 hover:text-white text-xs font-bold px-1"
                      >
                        ✕
                      </button>
                    </div>
                  )}

                  {/* Static Top Bar (pinned, does not scroll): Avatar, Greeting, Synced Chip, Notification Bell */}
                  <div className="px-5 pt-4 pb-3 flex items-center justify-between bg-white shrink-0 z-20">
                    <div className="flex items-center space-x-3">
                      {/* Avatar */}
                      <div className="w-11 h-11 rounded-full bg-[#E0F2F1] text-[#0F4C4C] font-bold text-base flex items-center justify-center border border-[#B2DFDB]">
                        AM
                      </div>
                      <div>
                        <h2 className="text-[18px] font-extrabold text-[#111827] tracking-tight leading-tight">
                          Good morning,...
                        </h2>
                        <p className="text-[12.5px] font-medium text-[#6B7280]">
                          Thursday, Aug 9
                        </p>
                      </div>
                    </div>

                    <div className="flex items-center space-x-2.5">
                      {/* Synced Badge */}
                      <div className="flex items-center space-x-1.5 bg-[#D1FAE5] text-[#059669] px-2.5 py-1 rounded-full text-[12px] font-semibold">
                        <span className="w-1.5 h-1.5 rounded-full bg-[#10B981]"></span>
                        <span>Synced</span>
                      </div>

                      {/* Notification Bell */}
                      <button
                        onClick={() => {
                          setSelectedScreen('notifications');
                          triggerNotificationToast('Switched to Notifications (Screen 2)');
                        }}
                        className="relative w-10 h-10 rounded-full border border-[#E5E7EB] bg-white flex items-center justify-center shadow-2xs hover:bg-[#F9FAFB] transition-colors cursor-pointer"
                        title="View Notifications (Screen 2)"
                      >
                        <Bell className="w-5 h-5 text-[#1F2937]" />
                        <span className="absolute -top-1 -right-1 w-4 h-4 bg-[#EF4444] text-white text-[10px] font-bold rounded-full flex items-center justify-center border-2 border-white">
                          {notificationsList.filter(n => n.isUnread).length}
                        </span>
                      </button>
                    </div>
                  </div>

                  {/* Main Scrollable Content Area - Hidden scrollbars per constraint */}
                  <div className="flex-1 overflow-y-auto pb-24 pt-1 [scrollbar-width:none] [-ms-overflow-style:none] [&::-webkit-scrollbar]:hidden">
                    {/* AI Daily Brief Card */}
                    <div className="px-5 mt-1">
                      <div className="bg-[#0F4C4C] text-white rounded-2xl p-4.5 shadow-md border border-[#0D4444]">
                        <div className="flex items-center space-x-2 text-[#99F6E4] text-[12px] font-extrabold tracking-wider">
                          <Bot className="w-4 h-4 text-[#99F6E4]" />
                          <span>AI DAILY BRIEF</span>
                        </div>
                        <p className="mt-2.5 text-[13.5px] text-white/90 leading-relaxed font-normal">
                          You have 6 visits planned today. 2 are high-priority. Start with <span className="font-semibold text-white">Acme Corp</span> they viewed your proposal yesterday.
                        </p>
                        <div className="mt-3.5">
                          <button
                            onClick={() => triggerDashboardToast('Opening full AI brief for today...')}
                            className="text-white text-[13px] font-bold flex items-center space-x-1 underline hover:text-[#99F6E4] transition-colors cursor-pointer"
                          >
                            <span>View Full Brief</span>
                            <ArrowRight className="w-3.5 h-3.5" />
                          </button>
                        </div>
                      </div>
                    </div>

                    {/* Metric Cards Carousel - Horizontal scroll with scrollbars strictly hidden */}
                    <div className="mt-4">
                      <div className="flex space-x-3 px-5 overflow-x-auto py-1 [scrollbar-width:none] [-ms-overflow-style:none] [&::-webkit-scrollbar]:hidden">
                        {/* Metric 1 */}
                        <div className="shrink-0 w-[122px] bg-white rounded-2xl p-3.5 border border-[#E5E7EB] shadow-2xs">
                          <p className="text-[12px] font-medium text-[#6B7280] truncate">Today's Visits</p>
                          <p className="text-[22px] font-extrabold text-[#0F4C4C] mt-1 tracking-tight">2/6</p>
                          <p className="text-[11px] text-[#9CA3AF] mt-1 truncate">Goal: 6 visits</p>
                        </div>

                        {/* Metric 2 */}
                        <div className="shrink-0 w-[122px] bg-white rounded-2xl p-3.5 border border-[#E5E7EB] shadow-2xs">
                          <p className="text-[12px] font-medium text-[#6B7280] truncate">Check-ins</p>
                          <p className="text-[22px] font-extrabold text-[#0F4C4C] mt-1 tracking-tight">2</p>
                          <p className="text-[11px] text-[#9CA3AF] mt-1 truncate">Completed</p>
                        </div>

                        {/* Metric 3 */}
                        <div className="shrink-0 w-[122px] bg-white rounded-2xl p-3.5 border border-[#E5E7EB] shadow-2xs">
                          <p className="text-[12px] font-medium text-[#6B7280] truncate">Distance</p>
                          <p className="text-[22px] font-extrabold text-[#0F4C4C] mt-1 tracking-tight">18 km</p>
                          <p className="text-[11px] text-[#9CA3AF] mt-1 truncate">Estimated tra...</p>
                        </div>

                        {/* Metric 4 */}
                        <div className="shrink-0 w-[122px] bg-white rounded-2xl p-3.5 border border-[#E5E7EB] shadow-2xs">
                          <p className="text-[12px] font-medium text-[#6B7280] truncate">Revenue</p>
                          <p className="text-[22px] font-extrabold text-[#0F4C4C] mt-1 tracking-tight">₹4.2L</p>
                          <p className="text-[11px] text-[#9CA3AF] mt-1 truncate">Active leads</p>
                        </div>
                      </div>
                    </div>

                    {/* Monthly Target Card */}
                    <div className="px-5 mt-4">
                      <div className="bg-white rounded-2xl p-4 border border-[#E5E7EB] shadow-2xs flex items-center space-x-4">
                        {/* Circular Progress Gauge */}
                        <div className="relative w-[68px] h-[68px] shrink-0 flex items-center justify-center">
                          <svg className="w-full h-full -rotate-90" viewBox="0 0 36 36">
                            <circle
                              cx="18"
                              cy="18"
                              r="15"
                              fill="none"
                              stroke="#F1F5F9"
                              strokeWidth="3.4"
                            />
                            <circle
                              cx="18"
                              cy="18"
                              r="15"
                              fill="none"
                              stroke="#0F4C4C"
                              strokeWidth="3.4"
                              strokeDasharray="94.24"
                              strokeDashoffset={94.24 * (1 - 0.68)}
                              strokeLinecap="round"
                            />
                          </svg>
                          <span className="absolute text-[13.5px] font-extrabold text-[#0F4C4C]">
                            68%
                          </span>
                        </div>

                        {/* Details */}
                        <div className="flex-1">
                          <p className="text-[11px] font-bold text-[#6B7280] tracking-wide uppercase">
                            MONTHLY TARGET
                          </p>
                          <p className="text-[16.5px] font-extrabold text-[#111827] mt-0.5 tracking-tight">
                            ₹6,80,000 / ₹10,00,000
                          </p>
                          <p className="text-[12px] font-semibold text-[#D97706] mt-0.5">
                            22 days remaining
                          </p>
                        </div>
                      </div>
                    </div>

                    {/* Today's Schedule Section */}
                    <div className="px-5 mt-5">
                      <div className="flex items-center justify-between mb-3">
                        <h3 className="text-[17.5px] font-extrabold text-[#111827] tracking-tight">
                          Today's Schedule
                        </h3>
                        <button
                          onClick={() => triggerDashboardToast('Opening full map view with 6 visit pins...')}
                          className="text-[13px] font-bold text-[#0F4C4C] hover:underline cursor-pointer"
                        >
                          View All Map
                        </button>
                      </div>

                      {/* Schedule Cards */}
                      <div className="space-y-2.5">
                        {dashboardScheduleItems.map((item) => (
                          <div
                            key={item.id}
                            onClick={() => triggerDashboardToast(`Selected ${item.company} (${item.contact})`)}
                            className="bg-white rounded-2xl p-3.5 border border-[#E5E7EB] shadow-2xs hover:border-[#0F4C4C]/40 transition-all cursor-pointer flex items-center"
                          >
                            {/* Left Time Block */}
                            <div className="w-[88px] shrink-0 pr-3 border-r border-[#F3F4F6]">
                              <p className="text-[13px] font-bold text-[#0F4C4C]">{item.time}</p>
                              <div className="flex items-center space-x-1.5 mt-1">
                                <span
                                  className={`w-2 h-2 rounded-full ${
                                    item.isCompleted ? 'bg-[#10B981]' : 'bg-[#0F4C4C]'
                                  }`}
                                ></span>
                                <span className="text-[11px] font-medium text-[#6B7280]">
                                  {item.status}
                                </span>
                              </div>
                            </div>

                            {/* Right Client Info */}
                            <div className="pl-3.5 flex-1 min-w-0">
                              <p className="text-[14.5px] font-bold text-[#111827] truncate">
                                {item.company}
                              </p>
                              <p className="text-[12.5px] font-medium text-[#4B5563] truncate">
                                {item.contact}
                              </p>
                              <p className="text-[11.5px] text-[#9CA3AF] truncate mt-0.5">
                                {item.location}
                              </p>
                            </div>
                          </div>
                        ))}
                      </div>
                    </div>
                  </div>

                  {/* Floating Action Button - square with curved edges */}
                  <button
                    onClick={() => triggerDashboardToast('Quick Action: Add Visit / Lead initiated')}
                    className="absolute right-5 bottom-[82px] w-14 h-14 rounded-2xl bg-[#0F4C4C] text-white shadow-xl hover:bg-[#0D4444] active:scale-95 transition-all flex items-center justify-center z-30 cursor-pointer"
                    style={{ boxShadow: '0 8px 24px -4px rgba(15, 76, 76, 0.45)' }}
                    title="Add new action"
                  >
                    <Plus className="w-7 h-7" />
                  </button>

                  {/* 5-Tab Bottom Navigation Bar */}
                  <div className="absolute left-0 right-0 bottom-0 bg-white border-t border-[#E5E7EB] px-3 py-2 flex justify-around items-center z-30">
                    {/* Home Tab (Active) */}
                    <button
                      onClick={() => setDashboardNavIndex(0)}
                      className={`flex flex-col items-center py-1 px-3.5 rounded-full transition-all cursor-pointer ${
                        dashboardNavIndex === 0
                          ? 'bg-[#E6F4F2] text-[#0F4C4C]'
                          : 'text-[#9CA3AF] hover:text-[#4B5563]'
                      }`}
                    >
                      <Home className="w-5 h-5" />
                      <span className="text-[10.5px] font-bold mt-0.5">Home</span>
                    </button>

                    {/* Leads Tab */}
                    <button
                      onClick={() => {
                        setSelectedScreen('leads-list');
                      }}
                      className={`flex flex-col items-center py-1 rounded-full transition-all cursor-pointer ${
                        dashboardNavIndex === 1
                          ? 'bg-[#E6F4F2] text-[#0F4C4C] px-3.5'
                          : 'text-[#9CA3AF] hover:text-[#4B5563] px-2.5'
                      }`}
                    >
                      <Folder className="w-5 h-5" />
                      <span className={`text-[10.5px] mt-0.5 ${dashboardNavIndex === 1 ? 'font-bold' : 'font-medium'}`}>
                        Leads
                      </span>
                    </button>

                    {/* Visits Tab */}
                    <button
                      onClick={() => {
                        setDashboardNavIndex(2);
                        triggerDashboardToast('Navigating to Visits route map');
                      }}
                      className={`flex flex-col items-center py-1 px-2.5 rounded-full transition-all cursor-pointer ${
                        dashboardNavIndex === 2
                          ? 'bg-[#E6F4F2] text-[#0F4C4C]'
                          : 'text-[#9CA3AF] hover:text-[#4B5563]'
                      }`}
                    >
                      <Route className="w-5 h-5" />
                      <span className="text-[10.5px] font-medium mt-0.5">Visits</span>
                    </button>

                    {/* Tasks Tab */}
                    <button
                      onClick={() => {
                        setDashboardNavIndex(3);
                        triggerDashboardToast('Navigating to Tasks checklist');
                      }}
                      className={`flex flex-col items-center py-1 px-2.5 rounded-full transition-all cursor-pointer ${
                        dashboardNavIndex === 3
                          ? 'bg-[#E6F4F2] text-[#0F4C4C]'
                          : 'text-[#9CA3AF] hover:text-[#4B5563]'
                      }`}
                    >
                      <ListTodo className="w-5 h-5" />
                      <span className="text-[10.5px] font-medium mt-0.5">Tasks</span>
                    </button>

                    {/* Profile Tab */}
                    <button
                      onClick={() => {
                        setDashboardNavIndex(4);
                        triggerDashboardToast('Navigating to Rep Profile & Settings');
                      }}
                      className={`flex flex-col items-center py-1 px-2.5 rounded-full transition-all cursor-pointer ${
                        dashboardNavIndex === 4
                          ? 'bg-[#E6F4F2] text-[#0F4C4C]'
                          : 'text-[#9CA3AF] hover:text-[#4B5563]'
                      }`}
                    >
                      <User className="w-5 h-5" />
                      <span className="text-[10.5px] font-medium mt-0.5">Profile</span>
                    </button>
                  </div>
                </div>
              ) : (selectedScreen === 'notifications' || selectedScreen === 'empty-notifications') ? (
                /* DASHBOARD AND NOTIFICATION SCREEN 2 (NOTIFICATIONS) & SCREEN 3 (EMPTY-NOTIFICATION) */
                <div className="flex-1 flex flex-col bg-white relative select-none h-full overflow-hidden font-['Inter',sans-serif]">
                  {/* Toast Feedback Notification */}
                  {notificationToast && (
                    <div className="absolute top-4 left-4 right-4 z-50 bg-[#0F4C4C] text-white px-3.5 py-2.5 rounded-xl shadow-lg flex items-center justify-between text-xs animate-in fade-in slide-in-from-top-2 duration-200">
                      <div className="flex items-center space-x-2">
                        <Sparkles className="w-4 h-4 text-[#99F6E4] shrink-0" />
                        <span className="font-medium">{notificationToast}</span>
                      </div>
                      <button
                        onClick={() => setNotificationToast(null)}
                        className="text-white/70 hover:text-white text-xs font-bold px-1"
                      >
                        ✕
                      </button>
                    </div>
                  )}

                  {/* Static Top Bar (pinned, does not scroll): Title with Badge & Actions */}
                  <div className="px-5 pt-5 pb-3 flex items-center justify-between bg-white shrink-0 z-20 border-b border-[#F9FAFB]">
                    <div className="flex items-center space-x-2.5">
                      <h2 className="text-[26px] font-extrabold text-[#111827] tracking-tight leading-none">
                        Notifications
                      </h2>
                      {selectedScreen !== 'empty-notifications' && notificationsList.filter((n) => n.isUnread).length > 0 && (
                        <span className="w-5 h-5 bg-[#EF4444] text-white text-[12px] font-bold rounded-full flex items-center justify-center">
                          {notificationsList.filter((n) => n.isUnread).length}
                        </span>
                      )}
                    </div>
                    
                    <div className="flex items-center space-x-2">
                      {selectedScreen === 'empty-notifications' || notificationsList.length === 0 ? (
                        <button
                          onClick={() => {
                            handleRestoreNotifications();
                            if (selectedScreen === 'empty-notifications') {
                              setSelectedScreen('notifications');
                            }
                          }}
                          className="bg-[#E6F4F2] text-[#0F4C4C] text-[13px] font-bold px-3 py-1.5 rounded-lg hover:bg-[#CCECE8] cursor-pointer transition-colors"
                        >
                          Load Demo
                        </button>
                      ) : (
                        <>
                          <button
                            onClick={handleMarkAllNotificationsRead}
                            className="text-[#0F4C4C] text-[13.5px] font-semibold hover:text-[#0D4444] cursor-pointer transition-colors"
                          >
                            Mark All Read
                          </button>
                          <span className="text-[#D1D5DB]">•</span>
                          <button
                            onClick={handleClearAllNotifications}
                            className="text-[#6B7280] text-[13px] font-medium hover:text-[#EF4444] cursor-pointer transition-colors"
                            title="Clear all to see empty state"
                          >
                            Clear
                          </button>
                        </>
                      )}
                    </div>
                  </div>

                  {/* Filter Chips - Only show when items exist */}
                  {(selectedScreen !== 'empty-notifications' && notificationsList.length > 0) && (
                    <div className="px-5 py-2.5 shrink-0 overflow-x-auto [scrollbar-width:none] [-ms-overflow-style:none] [&::-webkit-scrollbar]:hidden flex items-center space-x-2">
                      <button
                        onClick={() => setNotificationFilter('All')}
                        className={`px-4 py-1.5 rounded-xl text-[13.5px] transition-all cursor-pointer whitespace-nowrap ${
                          notificationFilter === 'All'
                            ? 'bg-[#CCFBF1] text-[#0F4C4C] font-bold'
                            : 'bg-[#F3F4F6] text-[#4B5563] font-medium hover:bg-[#E5E7EB]'
                        }`}
                      >
                        All
                      </button>
                      <button
                        onClick={() => setNotificationFilter('Unread')}
                        className={`px-3.5 py-1.5 rounded-xl text-[13.5px] transition-all cursor-pointer whitespace-nowrap flex items-center space-x-1.5 ${
                          notificationFilter === 'Unread'
                            ? 'bg-[#CCFBF1] text-[#0F4C4C] font-bold'
                            : 'bg-[#F3F4F6] text-[#4B5563] font-medium hover:bg-[#E5E7EB]'
                        }`}
                      >
                        <span>Unread</span>
                        {notificationsList.filter((n) => n.isUnread).length > 0 && (
                          <span className="w-4 h-4 bg-[#EF4444] text-white text-[10px] font-bold rounded-full flex items-center justify-center">
                            {notificationsList.filter((n) => n.isUnread).length}
                          </span>
                        )}
                      </button>
                      <button
                        onClick={() => setNotificationFilter('Leads')}
                        className={`px-4 py-1.5 rounded-xl text-[13.5px] transition-all cursor-pointer whitespace-nowrap ${
                          notificationFilter === 'Leads'
                            ? 'bg-[#CCFBF1] text-[#0F4C4C] font-bold'
                            : 'bg-[#F3F4F6] text-[#4B5563] font-medium hover:bg-[#E5E7EB]'
                        }`}
                      >
                        Leads
                      </button>
                      <button
                        onClick={() => setNotificationFilter('Visits')}
                        className={`px-4 py-1.5 rounded-xl text-[13.5px] transition-all cursor-pointer whitespace-nowrap ${
                          notificationFilter === 'Visits'
                            ? 'bg-[#CCFBF1] text-[#0F4C4C] font-bold'
                            : 'bg-[#F3F4F6] text-[#4B5563] font-medium hover:bg-[#E5E7EB]'
                        }`}
                      >
                        Visits
                      </button>
                    </div>
                  )}

                  {/* Main Content Area: Empty State or Notification Items */}
                  {selectedScreen === 'empty-notifications' ||
                  notificationsList.length === 0 ||
                  notificationsList.filter((n) => {
                    if (notificationFilter === 'Unread') return n.isUnread;
                    if (notificationFilter === 'Leads') return n.category === 'leads';
                    if (notificationFilter === 'Visits') return n.category === 'visits';
                    return true;
                  }).length === 0 ? (
                    /* SCREEN 3: EMPTY NOTIFICATION STATE (Exact design from image.png) */
                    <div className="flex-1 flex flex-col items-center justify-center px-6 pb-24 text-center animate-in fade-in duration-300">
                      {/* Pale Mint Circular Container */}
                      <div className="w-[140px] h-[140px] rounded-full bg-[#E8F6F4] flex items-center justify-center mb-6">
                        <Bell className="w-14 h-14 text-[#0F4C4C]" strokeWidth={1.75} />
                      </div>

                      {/* Headline */}
                      <h3 className="text-[24px] font-extrabold text-[#111827] tracking-tight">
                        All Caught Up!
                      </h3>

                      {/* Subtitle */}
                      <p className="text-[14.5px] text-[#6B7280] font-normal max-w-[280px] mt-2.5 leading-relaxed">
                        You have no new notifications. We'll alert you when something needs your attention.
                      </p>

                      {/* Action Link with Arrow */}
                      <button
                        onClick={() => setShowNotificationSettingsModal(true)}
                        className="mt-7 text-[#0F4C4C] hover:text-[#0D4444] text-[15px] font-semibold flex items-center justify-center space-x-1.5 cursor-pointer group transition-colors"
                      >
                        <span className="group-hover:underline">View notification settings</span>
                        <ArrowRight className="w-4 h-4 transition-transform group-hover:translate-x-0.5" />
                      </button>
                    </div>
                  ) : (
                    /* Notifications List */
                    <div className="flex-1 overflow-y-auto px-5 pt-2 pb-24 [scrollbar-width:none] [-ms-overflow-style:none] [&::-webkit-scrollbar]:hidden divide-y divide-[#F3F4F6]">
                      {notificationsList
                        .filter((n) => {
                          if (notificationFilter === 'Unread') return n.isUnread;
                          if (notificationFilter === 'Leads') return n.category === 'leads';
                          if (notificationFilter === 'Visits') return n.category === 'visits';
                          return true;
                        })
                        .map((item) => (
                          <div
                            key={item.id}
                            onClick={() => toggleNotificationItemRead(item.id)}
                            className="py-3.5 flex items-center space-x-3 cursor-pointer hover:bg-gray-50/60 rounded-xl transition-colors px-1"
                          >
                            {/* Unread dot */}
                            <div className="w-2.5 flex justify-center shrink-0">
                              {item.isUnread && (
                                <span className="w-2 h-2 rounded-full bg-[#0F4C4C]" />
                              )}
                            </div>

                            {/* Avatar icon */}
                            <div
                              className="w-11 h-11 rounded-full flex items-center justify-center shrink-0"
                              style={{ backgroundColor: item.iconBg, color: item.iconColor }}
                            >
                              {item.iconType === 'user' && <User className="w-5 h-5" />}
                              {item.iconType === 'calendar' && <Calendar className="w-5 h-5" />}
                              {item.iconType === 'eye' && <Eye className="w-5 h-5" />}
                              {item.iconType === 'alert' && <AlertCircle className="w-5 h-5" />}
                              {item.iconType === 'handshake' && <Handshake className="w-5 h-5" />}
                            </div>

                            {/* Text content */}
                            <div className="flex-1 min-w-0 pr-1">
                              <p className="text-[14px] font-bold text-[#111827] leading-tight">
                                {item.title}
                              </p>
                              <p className="text-[12.5px] text-[#6B7280] font-normal mt-1">
                                {item.time}
                              </p>
                            </div>

                            {/* Action button if any */}
                            {item.actionText && (
                              <button
                                onClick={(e) => {
                                  e.stopPropagation();
                                  triggerNotificationToast('Opening Acme Corp lead record');
                                }}
                                className="bg-[#0F4C4C] hover:bg-[#0D4444] text-white text-[12px] font-bold px-3 py-1.5 rounded-lg shadow-xs transition-colors shrink-0 cursor-pointer"
                              >
                                {item.actionText}
                              </button>
                            )}
                          </div>
                        ))}
                    </div>
                  )}

                  {/* Floating Bottom Navigation Bar */}
                  <div className="absolute bottom-3 left-4 right-4 bg-white rounded-3xl border border-[#E5E7EB] shadow-lg py-2 px-3 flex justify-around items-center z-30">
                    {/* Home Tab */}
                    <button
                      onClick={() => {
                        setSelectedScreen('dashboard');
                        triggerDashboardToast('Switched to Dashboard');
                      }}
                      className="flex flex-col items-center py-1 px-3.5 rounded-full transition-all cursor-pointer text-[#9CA3AF] hover:text-[#4B5563]"
                    >
                      <Home className="w-5 h-5" />
                      <span className="text-[10.5px] font-medium mt-0.5">Home</span>
                    </button>

                    {/* Leads Tab */}
                    <button
                      onClick={() => triggerNotificationToast('Navigating to Leads screen')}
                      className="flex flex-col items-center py-1 px-2.5 rounded-full transition-all cursor-pointer text-[#9CA3AF] hover:text-[#4B5563]"
                    >
                      <Folder className="w-5 h-5" />
                      <span className="text-[10.5px] font-medium mt-0.5">Leads</span>
                    </button>

                    {/* Visits Tab */}
                    <button
                      onClick={() => triggerNotificationToast('Navigating to Visits route map')}
                      className="flex flex-col items-center py-1 px-2.5 rounded-full transition-all cursor-pointer text-[#9CA3AF] hover:text-[#4B5563]"
                    >
                      <Route className="w-5 h-5" />
                      <span className="text-[10.5px] font-medium mt-0.5">Visits</span>
                    </button>

                    {/* Tasks Tab */}
                    <button
                      onClick={() => triggerNotificationToast('Navigating to Tasks checklist')}
                      className="flex flex-col items-center py-1 px-2.5 rounded-full transition-all cursor-pointer text-[#9CA3AF] hover:text-[#4B5563]"
                    >
                      <ListTodo className="w-5 h-5" />
                      <span className="text-[10.5px] font-medium mt-0.5">Tasks</span>
                    </button>

                    {/* Profile Tab */}
                    <button
                      onClick={() => triggerNotificationToast('Navigating to Rep Profile & Settings')}
                      className="flex flex-col items-center py-1 px-2.5 rounded-full transition-all cursor-pointer text-[#9CA3AF] hover:text-[#4B5563]"
                    >
                      <User className="w-5 h-5" />
                      <span className="text-[10.5px] font-medium mt-0.5">Profile</span>
                    </button>
                  </div>

                  {/* Notification Settings Bottom Sheet Modal */}
                  {showNotificationSettingsModal && (
                    <div className="absolute inset-0 z-50 bg-black/50 backdrop-blur-xs flex flex-col justify-end animate-in fade-in duration-200">
                      <div
                        onClick={(e) => e.stopPropagation()}
                        className="bg-white rounded-t-3xl p-6 shadow-2xl border-t border-[#E5E7EB] animate-in slide-in-from-bottom duration-250"
                      >
                        {/* Drag handle */}
                        <div className="w-10 h-1.5 bg-[#E5E7EB] rounded-full mx-auto mb-4" />

                        {/* Title and Close */}
                        <div className="flex items-center justify-between mb-5">
                          <div>
                            <h4 className="text-[18px] font-extrabold text-[#111827] tracking-tight">
                              Notification Preferences
                            </h4>
                            <p className="text-[12.5px] text-[#6B7280] mt-0.5">
                              Customize alerts for your field sales workflow
                            </p>
                          </div>
                          <button
                            onClick={() => setShowNotificationSettingsModal(false)}
                            className="w-8 h-8 rounded-full bg-[#F3F4F6] text-[#4B5563] hover:text-[#111827] flex items-center justify-center text-sm font-bold cursor-pointer"
                          >
                            ✕
                          </button>
                        </div>

                        {/* Toggles */}
                        <div className="space-y-4">
                          {/* Item 1 */}
                          <div className="flex items-center justify-between py-1">
                            <div>
                              <p className="text-[14px] font-bold text-[#111827]">Lead Assignments</p>
                              <p className="text-[12px] text-[#6B7280]">Instant alerts when new leads are allocated</p>
                            </div>
                            <button
                              onClick={() =>
                                setNotificationSettings((prev) => ({
                                  ...prev,
                                  leads: !prev.leads,
                                }))
                              }
                              className={`w-12 h-6.5 rounded-full transition-colors relative cursor-pointer ${
                                notificationSettings.leads ? 'bg-[#0F4C4C]' : 'bg-[#E5E7EB]'
                              }`}
                            >
                              <span
                                className={`absolute top-0.5 w-5.5 h-5.5 rounded-full bg-white transition-transform ${
                                  notificationSettings.leads ? 'right-0.5' : 'left-0.5'
                                } shadow-sm`}
                              />
                            </button>
                          </div>

                          {/* Item 2 */}
                          <div className="flex items-center justify-between py-1">
                            <div>
                              <p className="text-[14px] font-bold text-[#111827]">Visit Reminders</p>
                              <p className="text-[12px] text-[#6B7280]">30-minute advance warnings for scheduled visits</p>
                            </div>
                            <button
                              onClick={() =>
                                setNotificationSettings((prev) => ({
                                  ...prev,
                                  visits: !prev.visits,
                                }))
                              }
                              className={`w-12 h-6.5 rounded-full transition-colors relative cursor-pointer ${
                                notificationSettings.visits ? 'bg-[#0F4C4C]' : 'bg-[#E5E7EB]'
                              }`}
                            >
                              <span
                                className={`absolute top-0.5 w-5.5 h-5.5 rounded-full bg-white transition-transform ${
                                  notificationSettings.visits ? 'right-0.5' : 'left-0.5'
                                } shadow-sm`}
                              />
                            </button>
                          </div>

                          {/* Item 3 */}
                          <div className="flex items-center justify-between py-1">
                            <div>
                              <p className="text-[14px] font-bold text-[#111827]">Proposal Activity</p>
                              <p className="text-[12px] text-[#6B7280]">When clients open, view, or sign proposals</p>
                            </div>
                            <button
                              onClick={() =>
                                setNotificationSettings((prev) => ({
                                  ...prev,
                                  proposals: !prev.proposals,
                                }))
                              }
                              className={`w-12 h-6.5 rounded-full transition-colors relative cursor-pointer ${
                                notificationSettings.proposals ? 'bg-[#0F4C4C]' : 'bg-[#E5E7EB]'
                              }`}
                            >
                              <span
                                className={`absolute top-0.5 w-5.5 h-5.5 rounded-full bg-white transition-transform ${
                                  notificationSettings.proposals ? 'right-0.5' : 'left-0.5'
                                } shadow-sm`}
                              />
                            </button>
                          </div>

                          {/* Item 4 */}
                          <div className="flex items-center justify-between py-1">
                            <div>
                              <p className="text-[14px] font-bold text-[#111827]">Deal Stage Milestones</p>
                              <p className="text-[12px] text-[#6B7280]">Pipeline stage changes and closing updates</p>
                            </div>
                            <button
                              onClick={() =>
                                setNotificationSettings((prev) => ({
                                  ...prev,
                                  deals: !prev.deals,
                                }))
                              }
                              className={`w-12 h-6.5 rounded-full transition-colors relative cursor-pointer ${
                                notificationSettings.deals ? 'bg-[#0F4C4C]' : 'bg-[#E5E7EB]'
                              }`}
                            >
                              <span
                                className={`absolute top-0.5 w-5.5 h-5.5 rounded-full bg-white transition-transform ${
                                  notificationSettings.deals ? 'right-0.5' : 'left-0.5'
                                } shadow-sm`}
                              />
                            </button>
                          </div>
                        </div>

                        {/* Done button */}
                        <button
                          onClick={() => {
                            setShowNotificationSettingsModal(false);
                            triggerNotificationToast('Preferences saved');
                          }}
                          className="w-full mt-6 bg-[#0F4C4C] hover:bg-[#0D4444] text-white font-bold py-3.5 rounded-xl shadow-sm transition-all cursor-pointer text-sm"
                        >
                          Save & Close
                        </button>
                      </div>
                    </div>
                  )}
                </div>
              ) : selectedScreen === 'intro-slide-three' ? (
                /* ONBOARDING SCREEN 10: INTRO SLIDE THREE (WIN WITH AI INSIGHTS) */
                <div className="flex-1 flex flex-col justify-between bg-[#0F4C4C] relative select-none">
                  {/* Top Bar: Skip button */}
                  <div className="px-6 pt-4 pb-2 flex items-center justify-between">
                    <button
                      type="button"
                      onClick={handleSkipIntroSlideThree}
                      className="text-[#99F6E4] hover:text-white font-medium text-[15px] cursor-pointer transition-colors"
                    >
                      Skip
                    </button>
                    <span className="text-white/40 text-[12px] font-semibold">
                      3 of 3
                    </span>
                  </div>

                  {/* Feedback Toast */}
                  {introSlideThreeToast && (
                    <div className="mx-6 mt-1 p-2.5 bg-emerald-500/20 border border-emerald-400/40 rounded-xl flex items-center space-x-2 text-xs text-emerald-200 animate-fade-in">
                      <CheckCircle2 className="w-4 h-4 text-emerald-300 shrink-0" />
                      <span className="font-semibold">{introSlideThreeToast}</span>
                    </div>
                  )}


                  {/* Main Card & Text Content */}
                  <div className="flex-1 flex flex-col justify-center px-6 py-2">
                    {/* Center Graphic Card (280x280) */}
                    <div className="mx-auto w-[280px] h-[280px] rounded-[32px] bg-[#135858] relative overflow-hidden shadow-xl shadow-black/20 flex items-center justify-center">
                      {/* 4x4 Grid Coordinate Lines */}
                      <svg className="absolute inset-0 w-full h-full pointer-events-none">
                        <line x1="25%" y1="0" x2="25%" y2="100%" stroke="rgba(255,255,255,0.08)" strokeWidth="1" />
                        <line x1="50%" y1="0" x2="50%" y2="100%" stroke="rgba(255,255,255,0.08)" strokeWidth="1" />
                        <line x1="75%" y1="0" x2="75%" y2="100%" stroke="rgba(255,255,255,0.08)" strokeWidth="1" />
                        <line x1="0" y1="25%" x2="100%" y2="25%" stroke="rgba(255,255,255,0.08)" strokeWidth="1" />
                        <line x1="0" y1="50%" x2="100%" y2="50%" stroke="rgba(255,255,255,0.08)" strokeWidth="1" />
                        <line x1="0" y1="75%" x2="100%" y2="75%" stroke="rgba(255,255,255,0.08)" strokeWidth="1" />

                        {/* Bar 1 (Left, muted teal) */}
                        <rect x="24.5%" y="46%" width="6.2%" height="26%" rx="5.5" fill="#4D8080" />
                        {/* Bar 2 (Middle, medium teal) */}
                        <rect x="36.8%" y="26%" width="6.2%" height="46%" rx="5.5" fill="#6BADA8" />
                        {/* Bar 3 (Right, tallest white) */}
                        <rect x="49.3%" y="10%" width="6.2%" height="62%" rx="5.5" fill="#FFFFFF" />

                        {/* Small Star Outline (Center 65%, 66.5% -> x=182, y=186.2) */}
                        <path
                          d="M 182 178.7 L 184.3 183.3 L 189.5 184.1 L 185.7 187.8 L 186.6 193 L 182 190.5 L 177.4 193 L 178.3 187.8 L 174.5 184.1 L 179.7 183.3 Z"
                          fill="none"
                          stroke="rgba(255,255,255,0.9)"
                          strokeWidth="1.7"
                          strokeLinecap="round"
                          strokeLinejoin="round"
                        />

                        {/* Large Star Outline (Center 79%, 63% -> x=221.2, y=176.4) */}
                        <path
                          d="M 221.2 163.4 L 225.1 171.3 L 233.8 172.6 L 227.5 178.8 L 229 187.5 L 221.2 183.4 L 213.4 187.5 L 214.9 178.8 L 208.6 172.6 L 217.3 171.3 Z"
                          fill="none"
                          stroke="#FFFFFF"
                          strokeWidth="2.1"
                          strokeLinecap="round"
                          strokeLinejoin="round"
                        />
                      </svg>
                    </div>

                    {/* Title */}
                    <h2 className="text-[32px] font-extrabold text-white tracking-tight leading-[1.15] mt-10">
                      Win with AI Insights
                    </h2>

                    {/* Subtitle */}
                    <p className="text-[15.5px] text-[#D1FAE5]/85 font-normal mt-3.5 leading-relaxed">
                      Smart lead scoring, deal win probability, and personalized day-coaching to close deals faster.
                    </p>
                  </div>

                  {/* Bottom Navigation Control Row */}
                  <div className="px-6 py-6 flex items-center justify-between mt-auto">
                    {/* Dots indicator with 3rd dot active */}
                    <div className="flex items-center space-x-2">
                      <button
                        type="button"
                        onClick={() => {
                          setSelectedScreen('app-intro-walkthrough');
                          setWalkthroughPage(0);
                        }}
                        className="w-2 h-2 rounded-full bg-white/35 hover:bg-white/60 transition-all cursor-pointer"
                        aria-label="Go to slide 1"
                      />
                      <button
                        type="button"
                        onClick={() => setSelectedScreen('intro-slide-two')}
                        className="w-2 h-2 rounded-full bg-white/35 hover:bg-white/60 transition-all cursor-pointer"
                        aria-label="Go to slide 2"
                      />
                      <div
                        className="w-2.5 h-2.5 rounded-full bg-white scale-110 shadow-sm"
                        aria-label="Slide 3 (Current)"
                      />
                    </div>

                    {/* Get Started Pill Button */}
                    <button
                      type="button"
                      onClick={handleGetStartedIntroSlideThree}
                      className="px-7 py-3.5 rounded-full bg-white text-[#0F4C4C] font-bold text-[15px] shadow-xl shadow-black/20 hover:scale-105 active:scale-95 transition-all cursor-pointer"
                    >
                      Get Started
                    </button>
                  </div>
                </div>
              ) : selectedScreen === 'intro-slide-two' ? (
                /* ONBOARDING SCREEN 9: INTRO SLIDE TWO (TRACK YOUR VISITS) */
                <div className="flex-1 flex flex-col justify-between bg-[#0F4C4C] relative select-none">
                  {/* Top Bar: Skip button */}
                  <div className="px-6 pt-4 pb-2 flex items-center justify-between">
                    <button
                      type="button"
                      onClick={handleSkipIntroSlideTwo}
                      className="text-[#99F6E4] hover:text-white font-medium text-[15px] cursor-pointer transition-colors"
                    >
                      Skip
                    </button>
                    <span className="text-white/40 text-[12px] font-semibold">
                      2 of 3
                    </span>
                  </div>

                  {/* Feedback Toast */}
                  {introSlideTwoToast && (
                    <div className="mx-6 mt-1 p-2.5 bg-emerald-500/20 border border-emerald-400/40 rounded-xl flex items-center space-x-2 text-xs text-emerald-200 animate-fade-in">
                      <CheckCircle2 className="w-4 h-4 text-emerald-300 shrink-0" />
                      <span className="font-semibold">{introSlideTwoToast}</span>
                    </div>
                  )}

                  {/* Main Card & Text Content */}
                  <div className="flex-1 flex flex-col justify-center px-6 py-2">
                    {/* Center Graphic Card (280x280) */}
                    <div className="mx-auto w-[280px] h-[280px] rounded-[32px] bg-[#135858] relative overflow-hidden shadow-xl shadow-black/20 flex items-center justify-center">
                      {/* 4x4 Grid Coordinate Lines */}
                      <svg className="absolute inset-0 w-full h-full pointer-events-none">
                        <line x1="25%" y1="0" x2="25%" y2="100%" stroke="rgba(255,255,255,0.08)" strokeWidth="1" />
                        <line x1="50%" y1="0" x2="50%" y2="100%" stroke="rgba(255,255,255,0.08)" strokeWidth="1" />
                        <line x1="75%" y1="0" x2="75%" y2="100%" stroke="rgba(255,255,255,0.08)" strokeWidth="1" />
                        <line x1="0" y1="25%" x2="100%" y2="25%" stroke="rgba(255,255,255,0.08)" strokeWidth="1" />
                        <line x1="0" y1="50%" x2="100%" y2="50%" stroke="rgba(255,255,255,0.08)" strokeWidth="1" />
                        <line x1="0" y1="75%" x2="100%" y2="75%" stroke="rgba(255,255,255,0.08)" strokeWidth="1" />

                        {/* Dashed Connecting Line 1: Building to Pin */}
                        <line
                          x1="30%"
                          y1="64%"
                          x2="49.5%"
                          y2="25%"
                          stroke="#6EE7B7"
                          strokeOpacity="0.6"
                          strokeWidth="2.2"
                          strokeDasharray="6,5"
                          strokeLinecap="round"
                        />
                        {/* Dashed Connecting Line 2: Building to Checkmark Badge */}
                        <line
                          x1="34%"
                          y1="70%"
                          x2="63%"
                          y2="70%"
                          stroke="#6EE7B7"
                          strokeOpacity="0.6"
                          strokeWidth="2.2"
                          strokeDasharray="6,5"
                          strokeLinecap="round"
                        />
                      </svg>

                      {/* Top Location Pin Node (Center ~49.5%, ~17%) */}
                      <div className="absolute left-1/2 -translate-x-1/2 top-[38px] flex flex-col items-center">
                        <MapPin className="w-9 h-9 text-white stroke-[2.1]" />
                      </div>

                      {/* Bottom-Left Building Node (Center ~28%, ~70%) */}
                      <div className="absolute left-[62px] top-[182px] flex items-center justify-center">
                        <Building2 className="w-8 h-8 text-white stroke-[2.1]" />
                      </div>

                      {/* Bottom-Right Verified Checkmark Badge (Center ~71.5%, ~70%) */}
                      <div className="absolute right-[56px] top-[180px] w-10 h-10 rounded-full bg-white flex items-center justify-center shadow-lg">
                        <Check className="w-5 h-5 text-[#0F4C4C] stroke-[3]" />
                      </div>
                    </div>

                    {/* Title */}
                    <h2 className="text-[32px] font-extrabold text-white tracking-tight leading-[1.15] mt-10">
                      Track Your Visits
                    </h2>

                    {/* Subtitle */}
                    <p className="text-[15.5px] text-[#D1FAE5]/85 font-normal mt-3.5 leading-relaxed">
                      GPS-verified check-ins, real-time visit tracking, and automated meeting logs kept instantly in sync.
                    </p>
                  </div>

                  {/* Bottom Navigation Control Row */}
                  <div className="px-6 py-6 flex items-center justify-between mt-auto">
                    {/* Dots indicator with 2nd dot active */}
                    <div className="flex items-center space-x-2">
                      <button
                        type="button"
                        onClick={() => {
                          setSelectedScreen('app-intro-walkthrough');
                          setWalkthroughPage(0);
                        }}
                        className="w-2 h-2 rounded-full bg-white/35 hover:bg-white/60 transition-all cursor-pointer"
                        aria-label="Go to slide 1"
                      />
                      <div
                        className="w-2.5 h-2.5 rounded-full bg-white scale-110 shadow-sm"
                        aria-label="Slide 2 (Current)"
                      />
                      <button
                        type="button"
                        onClick={() => {
                          setSelectedScreen('app-intro-walkthrough');
                          setWalkthroughPage(2);
                        }}
                        className="w-2 h-2 rounded-full bg-white/35 hover:bg-white/60 transition-all cursor-pointer"
                        aria-label="Go to slide 3"
                      />
                    </div>

                    {/* Next Button (56x56 white circle with dark teal arrow) */}
                    <button
                      type="button"
                      onClick={handleNextIntroSlideTwo}
                      className="w-[56px] h-[56px] rounded-full bg-white shadow-xl shadow-black/20 flex items-center justify-center hover:scale-105 active:scale-95 transition-all cursor-pointer"
                      title="Next Slide"
                    >
                      <ArrowRight className="w-6 h-6 text-[#0F4C4C] stroke-[2.4]" />
                    </button>
                  </div>
                </div>
              ) : selectedScreen === 'app-intro-walkthrough' ? (
                /* ONBOARDING SCREEN 7: APP INTRO WALKTHROUGH */
                <div className="flex-1 flex flex-col justify-between bg-[#0F4C4C] relative select-none">
                  {/* Top Bar: Skip button */}
                  <div className="px-6 pt-4 pb-2 flex items-center justify-between">
                    <button
                      type="button"
                      onClick={handleSkipWalkthrough}
                      className="text-[#99F6E4] hover:text-white font-medium text-[15px] cursor-pointer transition-colors"
                    >
                      Skip
                    </button>
                    {/* Slide counter indicator */}
                    <span className="text-white/40 text-[12px] font-semibold">
                      {walkthroughPage + 1} of {walkthroughSlides.length}
                    </span>
                  </div>

                  {/* Feedback Toast */}
                  {walkthroughToast && (
                    <div className="mx-6 mt-1 p-2.5 bg-emerald-500/20 border border-emerald-400/40 rounded-xl flex items-center space-x-2 text-xs text-emerald-200 animate-fade-in">
                      <CheckCircle2 className="w-4 h-4 text-emerald-300 shrink-0" />
                      <span className="font-semibold">{walkthroughToast}</span>
                    </div>
                  )}

                  {/* Main Carousel Card & Text Content */}
                  <div className="flex-1 flex flex-col justify-center px-6 py-2">
                    {/* Center Graphic Card (280x280) */}
                    <div className="mx-auto w-[280px] h-[280px] rounded-[32px] bg-[#135858] relative overflow-hidden shadow-xl shadow-black/20 flex items-center justify-center">
                      {walkthroughSlides[walkthroughPage].type === 'map' ? (
                        /* Map Route Graphic */
                        <div className="w-full h-full relative">
                          {/* 4x4 Grid Coordinate Lines */}
                          <svg className="absolute inset-0 w-full h-full pointer-events-none">
                            <line x1="25%" y1="0" x2="25%" y2="100%" stroke="rgba(255,255,255,0.08)" strokeWidth="1" />
                            <line x1="50%" y1="0" x2="50%" y2="100%" stroke="rgba(255,255,255,0.08)" strokeWidth="1" />
                            <line x1="75%" y1="0" x2="75%" y2="100%" stroke="rgba(255,255,255,0.08)" strokeWidth="1" />
                            <line x1="0" y1="25%" x2="100%" y2="25%" stroke="rgba(255,255,255,0.08)" strokeWidth="1" />
                            <line x1="0" y1="50%" x2="100%" y2="50%" stroke="rgba(255,255,255,0.08)" strokeWidth="1" />
                            <line x1="0" y1="75%" x2="100%" y2="75%" stroke="rgba(255,255,255,0.08)" strokeWidth="1" />

                            {/* Dashed Connecting Line */}
                            <line
                              x1="28%"
                              y1="65%"
                              x2="49%"
                              y2="38%"
                              stroke="#6EE7B7"
                              strokeOpacity="0.6"
                              strokeWidth="2.2"
                              strokeDasharray="6,5"
                              strokeLinecap="round"
                            />
                            <line
                              x1="49%"
                              y1="38%"
                              x2="74%"
                              y2="50%"
                              stroke="#6EE7B7"
                              strokeOpacity="0.6"
                              strokeWidth="2.2"
                              strokeDasharray="6,5"
                              strokeLinecap="round"
                            />

                            {/* Waypoint Nodes */}
                            {/* P1: 28%, 65% */}
                            <circle cx="28%" cy="65%" r="13" fill="#0F4C4C" fillOpacity="0.85" stroke="white" strokeWidth="2.4" />
                            <circle cx="28%" cy="65%" r="3.5" fill="#99F6E4" />

                            {/* P2: 49%, 38% */}
                            <circle cx="49%" cy="38%" r="12" fill="#0F4C4C" fillOpacity="0.85" stroke="white" strokeWidth="2.4" />
                            <circle cx="49%" cy="38%" r="3.2" fill="#99F6E4" />

                            {/* P3: 74%, 50% */}
                            <circle cx="74%" cy="50%" r="12" fill="#0F4C4C" fillOpacity="0.85" stroke="white" strokeWidth="2.4" />
                            <circle cx="74%" cy="50%" r="3.2" fill="#99F6E4" />
                          </svg>
                        </div>
                      ) : walkthroughSlides[walkthroughPage].type === 'track-visits' ? (
                        /* Track Your Visits Graphic (GPS + Visits + Verified) */
                        <div className="w-full h-full relative">
                          {/* 4x4 Grid Coordinate Lines */}
                          <svg className="absolute inset-0 w-full h-full pointer-events-none">
                            <line x1="25%" y1="0" x2="25%" y2="100%" stroke="rgba(255,255,255,0.08)" strokeWidth="1" />
                            <line x1="50%" y1="0" x2="50%" y2="100%" stroke="rgba(255,255,255,0.08)" strokeWidth="1" />
                            <line x1="75%" y1="0" x2="75%" y2="100%" stroke="rgba(255,255,255,0.08)" strokeWidth="1" />
                            <line x1="0" y1="25%" x2="100%" y2="25%" stroke="rgba(255,255,255,0.08)" strokeWidth="1" />
                            <line x1="0" y1="50%" x2="100%" y2="50%" stroke="rgba(255,255,255,0.08)" strokeWidth="1" />
                            <line x1="0" y1="75%" x2="100%" y2="75%" stroke="rgba(255,255,255,0.08)" strokeWidth="1" />

                            {/* Dashed Connecting Line 1: Building to Pin */}
                            <line
                              x1="30%"
                              y1="64%"
                              x2="49.5%"
                              y2="25%"
                              stroke="#6EE7B7"
                              strokeOpacity="0.6"
                              strokeWidth="2.2"
                              strokeDasharray="6,5"
                              strokeLinecap="round"
                            />
                            {/* Dashed Connecting Line 2: Building to Checkmark Badge */}
                            <line
                              x1="34%"
                              y1="70%"
                              x2="63%"
                              y2="70%"
                              stroke="#6EE7B7"
                              strokeOpacity="0.6"
                              strokeWidth="2.2"
                              strokeDasharray="6,5"
                              strokeLinecap="round"
                            />
                          </svg>

                          {/* Top Location Pin Node (Center ~49.5%, ~17%) */}
                          <div className="absolute left-1/2 -translate-x-1/2 top-[38px] flex flex-col items-center">
                            <MapPin className="w-9 h-9 text-white stroke-[2.1]" />
                          </div>

                          {/* Bottom-Left Building Node (Center ~28%, ~70%) */}
                          <div className="absolute left-[62px] top-[182px] flex items-center justify-center">
                            <Building2 className="w-8 h-8 text-white stroke-[2.1]" />
                          </div>

                          {/* Bottom-Right Verified Checkmark Badge (Center ~71.5%, ~70%) */}
                          <div className="absolute right-[56px] top-[180px] w-10 h-10 rounded-full bg-white flex items-center justify-center shadow-lg">
                            <Check className="w-5 h-5 text-[#0F4C4C] stroke-[3]" />
                          </div>
                        </div>
                      ) : walkthroughSlides[walkthroughPage].type === 'ai-insights' ? (
                        /* AI Insights Graphic */
                        <div className="w-full h-full relative">
                          <svg className="absolute inset-0 w-full h-full pointer-events-none">
                            <line x1="25%" y1="0" x2="25%" y2="100%" stroke="rgba(255,255,255,0.08)" strokeWidth="1" />
                            <line x1="50%" y1="0" x2="50%" y2="100%" stroke="rgba(255,255,255,0.08)" strokeWidth="1" />
                            <line x1="75%" y1="0" x2="75%" y2="100%" stroke="rgba(255,255,255,0.08)" strokeWidth="1" />
                            <line x1="0" y1="25%" x2="100%" y2="25%" stroke="rgba(255,255,255,0.08)" strokeWidth="1" />
                            <line x1="0" y1="50%" x2="100%" y2="50%" stroke="rgba(255,255,255,0.08)" strokeWidth="1" />
                            <line x1="0" y1="75%" x2="100%" y2="75%" stroke="rgba(255,255,255,0.08)" strokeWidth="1" />

                            <rect x="24.5%" y="46%" width="6.2%" height="26%" rx="5.5" fill="#4D8080" />
                            <rect x="36.8%" y="26%" width="6.2%" height="46%" rx="5.5" fill="#6BADA8" />
                            <rect x="49.3%" y="10%" width="6.2%" height="62%" rx="5.5" fill="#FFFFFF" />

                            <path
                              d="M 182 178.7 L 184.3 183.3 L 189.5 184.1 L 185.7 187.8 L 186.6 193 L 182 190.5 L 177.4 193 L 178.3 187.8 L 174.5 184.1 L 179.7 183.3 Z"
                              fill="none"
                              stroke="rgba(255,255,255,0.9)"
                              strokeWidth="1.7"
                              strokeLinecap="round"
                              strokeLinejoin="round"
                            />
                            <path
                              d="M 221.2 163.4 L 225.1 171.3 L 233.8 172.6 L 227.5 178.8 L 229 187.5 L 221.2 183.4 L 213.4 187.5 L 214.9 178.8 L 208.6 172.6 L 217.3 171.3 Z"
                              fill="none"
                              stroke="#FFFFFF"
                              strokeWidth="2.1"
                              strokeLinecap="round"
                              strokeLinejoin="round"
                            />
                          </svg>
                        </div>
                      ) : (
                        /* Fallback */
                        <div className="w-full h-full relative flex items-center justify-center">
                          <div className="w-[100px] h-[110px] rounded-2xl bg-[#0F4C4C] border-2 border-white flex items-center justify-center shadow-lg">
                            <Shield className="w-12 h-12 text-[#99F6E4]" />
                          </div>
                        </div>
                      )}
                    </div>

                    {/* Title */}
                    <h2 className="text-[32px] font-extrabold text-white tracking-tight leading-[1.15] mt-10">
                      {walkthroughSlides[walkthroughPage].title}
                    </h2>

                    {/* Subtitle */}
                    <p className="text-[15.5px] text-[#D1FAE5]/85 font-normal mt-3.5 leading-relaxed">
                      {walkthroughSlides[walkthroughPage].subtitle}
                    </p>
                  </div>

                  {/* Bottom Navigation Control Row */}
                  <div className="px-6 py-6 flex items-center justify-between mt-auto">
                    {/* Dots indicator */}
                    <div className="flex items-center space-x-2">
                      {walkthroughSlides.map((_, idx) => {
                        const isActive = idx === walkthroughPage;
                        return (
                          <button
                            key={idx}
                            type="button"
                            onClick={() => setWalkthroughPage(idx)}
                            className={`transition-all rounded-full cursor-pointer ${
                              isActive
                                ? 'w-2.5 h-2.5 bg-white scale-110'
                                : 'w-2 h-2 bg-white/35 hover:bg-white/60'
                            }`}
                            aria-label={`Go to slide ${idx + 1}`}
                          />
                        );
                      })}
                    </div>

                    {/* Action Button: Pill "Get Started" on slide 3, or circular arrow on slides 1 & 2 */}
                    {walkthroughPage === walkthroughSlides.length - 1 ? (
                      <button
                        type="button"
                        onClick={handleNextWalkthrough}
                        className="px-7 py-3.5 rounded-full bg-white text-[#0F4C4C] font-bold text-[15px] shadow-xl shadow-black/20 hover:scale-105 active:scale-95 transition-all cursor-pointer"
                      >
                        Get Started
                      </button>
                    ) : (
                      <button
                        type="button"
                        onClick={handleNextWalkthrough}
                        className="w-[56px] h-[56px] rounded-full bg-white shadow-xl shadow-black/20 flex items-center justify-center hover:scale-105 active:scale-95 transition-all cursor-pointer"
                        title="Next Slide"
                      >
                        <ArrowRight className="w-6 h-6 text-[#0F4C4C] stroke-[2.4]" />
                      </button>
                    )}
                  </div>
                </div>
              ) : selectedScreen === 'onboarding-complete' ? (
                /* ONBOARDING SCREEN 7: ONBOARDING COMPLETE ("YOU'RE ALL SET!") */
                <div className="flex-1 flex flex-col justify-between px-6 pt-8 pb-6 overflow-y-auto no-scrollbar scroll-smooth bg-white relative">
                  <div>
                    {/* 1. Hero Graphic: Concentric Emerald Success Badge with Double Checkmark (identical to reset success) */}
                    <div className="flex justify-center mt-4">
                      <div className="flex items-center justify-center w-[196px] h-[196px] rounded-full bg-[#D1FADF] animate-fade-in transition-all">
                        <div className="flex items-center justify-center w-[128px] h-[128px] rounded-full bg-[#10B981] shadow-lg shadow-[#10B981]/25">
                          <CheckCheck className="w-14 h-14 text-white stroke-[1.25]" />
                        </div>
                      </div>
                    </div>

                    {/* 2. Title: "You're All Set!" */}
                    <h2 className="text-[28px] font-extrabold text-[#111827] mt-9 tracking-tight leading-tight">
                      You're All Set!
                    </h2>

                    {/* 3. Subtitle: "Your field kit is ready. Time to hit the road." */}
                    <p className="text-[15px] text-[#4B5563] mt-2.5 leading-relaxed">
                      Your field kit is ready. Time to hit the road.
                    </p>

                    {/* 4. Territory Prep Overview Card */}
                    <div className="mt-7 p-4.5 bg-[#F9FAFB] rounded-2xl border border-[#F3F4F6] space-y-3.5">
                      <p className="text-[11px] font-bold text-[#6B7280] tracking-wider uppercase">
                        TERRITORY PREP OVERVIEW
                      </p>

                      <div className="flex items-center space-x-2.5">
                        <Briefcase className="w-4.5 h-4.5 text-[#0F4C4C] shrink-0" />
                        <span className="text-[13.5px] font-medium text-[#1F2937]">
                          120 leads parsed and mapped
                        </span>
                      </div>

                      <div className="flex items-center space-x-2.5">
                        <Calendar className="w-4.5 h-4.5 text-[#0F4C4C] shrink-0" />
                        <span className="text-[13.5px] font-medium text-[#1F2937]">
                          6 priority visits mapped out for today
                        </span>
                      </div>

                      <div className="flex items-center space-x-2.5">
                        <CheckCircle2 className="w-4.5 h-4.5 text-[#10B981] shrink-0" />
                        <span className="text-[13.5px] font-medium text-[#10B981]">
                          Offline capability fully ready{' '}
                          <strong className="font-bold text-[#059669]">(✓ Active)</strong>
                        </span>
                      </div>
                    </div>
                  </div>

                  {/* 5. Bottom Action: "Continue" CTA */}
                  <div className="mt-8 pb-2 space-y-3">
                    <button
                      onClick={handleOnboardingFinish}
                      className="w-full h-[52px] bg-[#0F4C4C] hover:bg-[#0c3c3c] active:scale-[0.99] text-white font-bold text-[15px] rounded-xl transition-all shadow-md flex items-center justify-center cursor-pointer tracking-tight"
                    >
                      Continue
                    </button>
                  </div>

                  {/* Toast Feedback */}
                  {completeToast && (
                    <div className="absolute top-5 left-6 right-6 z-50 bg-[#111827] text-white text-xs font-semibold py-3 px-4 rounded-xl shadow-xl flex items-center space-x-2 border border-gray-700 animate-fade-in">
                      <CheckCircle2 className="w-4 h-4 text-[#10B981] shrink-0" />
                      <span>{completeToast}</span>
                    </div>
                  )}
                </div>
              ) : selectedScreen === 'onboarding-offline-setup' ? (
                /* ONBOARDING SCREEN 6: PREPARE FOR OFFLINE DATA SETUP SCREEN */
                <div className="flex-1 flex flex-col justify-between px-6 pt-5 pb-6 overflow-y-auto no-scrollbar scroll-smooth bg-white">
                  <div>
                    {/* 1. Top Progress Bar: 100% filled dark teal (Final step) */}
                    <div className="w-full h-[4.5px] bg-[#E5E7EB] rounded-full overflow-hidden mt-1">
                      <div className="h-full w-full bg-[#0F4C4C] rounded-full transition-all duration-500" />
                    </div>

                    {/* 2. Hero Graphic Card: Soft mint card with cloud download vector illustration */}
                    <div className="mt-5 w-full h-[210px] rounded-[24px] bg-[#F0FDF9] flex items-center justify-center relative overflow-hidden group">
                      <svg
                        width="130"
                        height="115"
                        viewBox="0 0 100 100"
                        fill="none"
                        stroke="#0F4C4C"
                        strokeWidth="2.2"
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        className="transition-transform duration-300 group-hover:scale-105"
                      >
                        {/* Cloud Outline */}
                        <path d="M 42 66 C 36 66 27 61 26 51 C 25 41 33 33 43 33 C 47 22 61 22 67 32 C 77 33 83 42 82 51 C 81 61 72 66 58 66" />
                        {/* Downward Arrow */}
                        <path d="M 50 46 L 50 72" />
                        <path d="M 43 64 L 50 72 L 57 64" />
                      </svg>
                    </div>

                    {/* 3. Title: "Prepare for Offline" */}
                    <h2 className="mt-6 text-[#111827] text-[28px] font-extrabold tracking-tight leading-tight">
                      Prepare for Offline
                    </h2>

                    {/* 4. Subtitle */}
                    <p className="mt-2 text-[#4B5563] text-[15px] font-normal leading-[1.45]">
                      Download your leads and customer data so you can work without internet.
                    </p>

                    {/* Feedback Toast if active */}
                    {offlineToast && (
                      <div className="mt-3 p-3 bg-[#ECFDF5] border border-[#A7F3D0] rounded-xl flex items-center space-x-2 text-xs text-[#065F46] animate-fade-in">
                        <CheckCircle2 className="w-4 h-4 text-[#10B981] shrink-0" />
                        <span className="font-semibold">{offlineToast}</span>
                      </div>
                    )}

                    {/* 5. Territory Payload Information Box */}
                    <div className="mt-5 w-full bg-[#F9FAFB] rounded-[16px] p-4 border border-[#F3F4F6]">
                      <div className="flex items-center justify-between">
                        <span className="text-[12px] font-bold text-[#6B7280] tracking-wider uppercase">
                          SOUTH MUMBAI SYNC PAYLOAD
                        </span>
                        <span className="text-[13px] font-extrabold text-[#0F4C4C]">
                          ~45 MB
                        </span>
                      </div>
                      <div className="mt-2.5 space-y-1.5">
                        <div className="flex items-center text-[14px] text-[#1F2937]">
                          <span className="w-1.5 h-1.5 rounded-full bg-[#374151] mr-2.5 ml-1" />
                          <span>120 assigned leads</span>
                        </div>
                        <div className="flex items-center text-[14px] text-[#1F2937]">
                          <span className="w-1.5 h-1.5 rounded-full bg-[#374151] mr-2.5 ml-1" />
                          <span>85 customers in territory</span>
                        </div>
                        <div className="flex items-center text-[14px] text-[#1F2937]">
                          <span className="w-1.5 h-1.5 rounded-full bg-[#374151] mr-2.5 ml-1" />
                          <span>7 days offline visit logs</span>
                        </div>
                      </div>
                    </div>

                    {/* 6. Download Progress Indicator Section */}
                    <div className="mt-5 w-full">
                      <div className="flex items-center justify-between text-sm">
                        <span className="font-semibold text-[#1F2937]">
                          {isDownloadCompleted ? 'Download complete' : isDownloading ? 'Downloading leads...' : 'Downloading leads...'}
                        </span>
                        <span className="font-extrabold text-[#0F4C4C]">
                          {downloadedLeads} / 120 ({downloadProgress}%)
                        </span>
                      </div>
                      <div className="w-full h-[5.5px] bg-[#E5E7EB] rounded-full overflow-hidden mt-2">
                        <div
                          className="h-full bg-[#0F4C4C] rounded-full transition-all duration-100"
                          style={{ width: `${downloadProgress}%` }}
                        />
                      </div>
                    </div>
                  </div>

                  {/* 7. Bottom Action Controls */}
                  <div className="pt-4 pb-2 flex flex-col space-y-3">
                    <button
                      onClick={handleStartDownload}
                      disabled={isDownloading || isDownloadCompleted}
                      className="w-full h-[52px] rounded-[12px] bg-[#0F4C4C] hover:bg-[#0C3E3E] active:scale-[0.99] text-white font-bold text-base transition-all flex items-center justify-center space-x-2 shadow-xs cursor-pointer disabled:opacity-90"
                    >
                      {isDownloading ? (
                        <>
                          <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin mr-2" />
                          <span>Downloading...</span>
                        </>
                      ) : isDownloadCompleted ? (
                        <span>Sync Completed</span>
                      ) : (
                        <span>Download Now</span>
                      )}
                    </button>
                    <button
                      onClick={handleSkipOffline}
                      className="w-full text-[#6B7280] hover:text-[#111827] font-medium text-sm py-1 transition-colors cursor-pointer"
                    >
                      Skip — I'll sync later
                    </button>
                  </div>
                </div>
              ) : selectedScreen === 'onboarding-notifications' ? (
                /* ONBOARDING SCREEN 5: ONBOARDING NOTIFICATIONS PERMISSION SCREEN */
                <div className="flex-1 flex flex-col justify-between px-6 pt-5 pb-6 overflow-y-auto no-scrollbar scroll-smooth bg-white">
                  <div>
                    {/* 1. Top Progress Bar: ~78% filled dark teal */}
                    <div className="w-full h-[4.5px] bg-[#E5E7EB] rounded-full overflow-hidden mt-1">
                      <div className="h-full w-[78%] bg-[#0F4C4C] rounded-full transition-all duration-500" />
                    </div>

                    {/* 2. Hero Graphic Card: Soft mint card with notification bell vector illustration */}
                    <div className="mt-5 w-full h-[210px] rounded-[24px] bg-[#F0FDF9] flex items-center justify-center relative overflow-hidden group">
                      <svg
                        width="130"
                        height="115"
                        viewBox="0 0 100 100"
                        fill="none"
                        stroke="#0F4C4C"
                        strokeWidth="2.2"
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        className="transition-transform duration-300 group-hover:scale-105"
                      >
                        {/* Bell Body */}
                        <path d="M 47 17.5 C 42 17 37.5 21 36 28 C 35 35 35 41 33.5 46 C 31.5 52 26 55 24 56.5 A 2.5 2.5 0 0 0 27 58.5 L 71 58.5 A 2.5 2.5 0 0 0 74 56.5 C 72 55 66.5 52 64.5 46 C 63 41 63 36 59.5 31" />
                        {/* Notification Alert Pip */}
                        <circle cx="58" cy="20" r="7.5" />
                        {/* Clapper */}
                        <path d="M 44 64 Q 49 68 54 64" />
                      </svg>
                    </div>

                    {/* 3. Title: "Enable Notifications" */}
                    <h2 className="mt-6 text-[#111827] text-[28px] font-extrabold tracking-tight leading-tight">
                      Enable Notifications
                    </h2>

                    {/* 4. Subtitle */}
                    <p className="mt-2 text-[#4B5563] text-[15px] font-normal leading-[1.45]">
                      Get reminders for visits, follow-ups, and new lead assignments.
                    </p>

                    {/* Toast / Feedback Banner if active */}
                    {notificationsToast && (
                      <div className="mt-4 p-3 bg-[#ECFDF5] border border-[#A7F3D0] rounded-xl flex items-center space-x-2 text-xs text-[#065F46] animate-fade-in">
                        <CheckCircle2 className="w-4 h-4 text-[#10B981] shrink-0" />
                        <span className="font-semibold">{notificationsToast}</span>
                      </div>
                    )}

                    {/* 5. Benefits List (3 items with mint check badges) */}
                    <div className="mt-5 space-y-4">
                      {/* Benefit 1 */}
                      <div className="flex items-start space-x-3">
                        <div className="w-[22px] h-[22px] rounded-full bg-[#D1FADF] flex items-center justify-center shrink-0 mt-0.5">
                          <Check className="w-3.5 h-3.5 text-[#0F766E] stroke-[2.8]" />
                        </div>
                        <div className="flex-1 min-w-0">
                          <h4 className="text-[15px] font-bold text-[#111827] leading-snug">
                            Real-time Lead Routing
                          </h4>
                          <p className="text-[13.5px] text-[#4B5563] leading-[1.4] mt-0.5">
                            Instant alert the moment a manager scopes a hot lead into your zone.
                          </p>
                        </div>
                      </div>

                      {/* Benefit 2 */}
                      <div className="flex items-start space-x-3">
                        <div className="w-[22px] h-[22px] rounded-full bg-[#D1FADF] flex items-center justify-center shrink-0 mt-0.5">
                          <Check className="w-3.5 h-3.5 text-[#0F766E] stroke-[2.8]" />
                        </div>
                        <div className="flex-1 min-w-0">
                          <h4 className="text-[15px] font-bold text-[#111827] leading-snug">
                            Next Appointment Alerts
                          </h4>
                          <p className="text-[13.5px] text-[#4B5563] leading-[1.4] mt-0.5">
                            Polite reminders 15 mins prior to keep you moving efficiently.
                          </p>
                        </div>
                      </div>

                      {/* Benefit 3 */}
                      <div className="flex items-start space-x-3">
                        <div className="w-[22px] h-[22px] rounded-full bg-[#D1FADF] flex items-center justify-center shrink-0 mt-0.5">
                          <Check className="w-3.5 h-3.5 text-[#0F766E] stroke-[2.8]" />
                        </div>
                        <div className="flex-1 min-w-0">
                          <h4 className="text-[15px] font-bold text-[#111827] leading-snug">
                            Daily Summary
                          </h4>
                          <p className="text-[13.5px] text-[#4B5563] leading-[1.4] mt-0.5">
                            Morning heads-up summarizing critical actions for the day.
                          </p>
                        </div>
                      </div>
                    </div>
                  </div>

                  {/* 6. Bottom Action Controls */}
                  <div className="pt-6 pb-2 space-y-3">
                    <button
                      onClick={handleAllowNotifications}
                      disabled={notificationsStatus === 'requesting'}
                      className="w-full h-[52px] bg-[#0F4C4C] hover:bg-[#0c3c3c] active:scale-[0.99] text-white font-bold text-[16px] rounded-xl flex items-center justify-center transition-all shadow-sm"
                    >
                      {notificationsStatus === 'requesting' ? (
                        <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                      ) : notificationsStatus === 'granted' ? (
                        <span className="flex items-center space-x-2">
                          <Check className="w-5 h-5 stroke-[2.5]" />
                          <span>Notifications Enabled</span>
                        </span>
                      ) : (
                        'Allow Notifications'
                      )}
                    </button>

                    <button
                      onClick={handleSkipNotifications}
                      className="w-full text-center text-[#6B7280] hover:text-[#111827] text-[15px] font-medium py-1 transition-colors"
                    >
                      Skip for now
                    </button>
                  </div>
                </div>
              ) : selectedScreen === 'onboarding-microphone' ? (
                /* ONBOARDING SCREEN 4: ONBOARDING MICROPHONE PERMISSION SCREEN */
                <div className="flex-1 flex flex-col justify-between px-6 pt-5 pb-6 overflow-y-auto no-scrollbar scroll-smooth bg-white">
                  <div>
                    {/* 1. Top Progress Bar: ~60% filled dark teal */}
                    <div className="w-full h-[4.5px] bg-[#E5E7EB] rounded-full overflow-hidden mt-1">
                      <div className="h-full w-[60%] bg-[#0F4C4C] rounded-full transition-all duration-500" />
                    </div>

                    {/* 2. Hero Graphic Card: Soft mint card with continuous audio waveform illustration */}
                    <div className="mt-5 w-full h-[210px] rounded-[24px] bg-[#F0FDF9] flex items-center justify-center relative overflow-hidden group">
                      <svg
                        width="125"
                        height="105"
                        viewBox="0 0 100 100"
                        fill="none"
                        stroke="#0F4C4C"
                        strokeWidth="2.0"
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        className="transition-transform duration-300 group-hover:scale-105"
                      >
                        <path d="M 16 52 C 22 51 26 42 28 32 A 8 8 0 0 1 44 32 L 44 78 A 8 8 0 0 0 60 78 L 60 22 A 8 8 0 0 1 76 22 L 76 62 A 7 7 0 0 0 90 62 C 91 55 94 48 98 44" />
                      </svg>
                    </div>

                    {/* 3. Title: "Enable Microphone" */}
                    <h2 className="mt-6 text-[#111827] text-[28px] font-extrabold tracking-tight leading-tight">
                      Enable Microphone
                    </h2>

                    {/* 4. Subtitle */}
                    <p className="mt-2 text-[#4B5563] text-[15px] font-normal leading-[1.45]">
                      Record voice notes during or after meetings instead of typing.
                    </p>

                    {/* Toast / Feedback Banner if active */}
                    {microphoneToast && (
                      <div className="mt-4 p-3 bg-[#ECFDF5] border border-[#A7F3D0] rounded-xl flex items-center space-x-2 text-xs text-[#065F46] animate-fade-in">
                        <CheckCircle2 className="w-4 h-4 text-[#10B981] shrink-0" />
                        <span className="font-semibold">{microphoneToast}</span>
                      </div>
                    )}

                    {/* 5. Benefits List (3 items with mint check badges) */}
                    <div className="mt-5 space-y-4">
                      {/* Benefit 1 */}
                      <div className="flex items-start space-x-3">
                        <div className="w-[22px] h-[22px] rounded-full bg-[#D1FADF] flex items-center justify-center shrink-0 mt-0.5">
                          <Check className="w-3.5 h-3.5 text-[#0F766E] stroke-[2.8]" />
                        </div>
                        <div className="flex-1 min-w-0">
                          <h4 className="text-[15px] font-bold text-[#111827] leading-snug">
                            Hands-free Minutes
                          </h4>
                          <p className="text-[13.5px] text-[#4B5563] leading-[1.4] mt-0.5">
                            Dictate logs walking back to your car, converted instantly to text.
                          </p>
                        </div>
                      </div>

                      {/* Benefit 2 */}
                      <div className="flex items-start space-x-3">
                        <div className="w-[22px] h-[22px] rounded-full bg-[#D1FADF] flex items-center justify-center shrink-0 mt-0.5">
                          <Check className="w-3.5 h-3.5 text-[#0F766E] stroke-[2.8]" />
                        </div>
                        <div className="flex-1 min-w-0">
                          <h4 className="text-[15px] font-bold text-[#111827] leading-snug">
                            Quick Client Quotes
                          </h4>
                          <p className="text-[13.5px] text-[#4B5563] leading-[1.4] mt-0.5">
                            Capture precise verbal requests with secure client agreement notes.
                          </p>
                        </div>
                      </div>

                      {/* Benefit 3 */}
                      <div className="flex items-start space-x-3">
                        <div className="w-[22px] h-[22px] rounded-full bg-[#D1FADF] flex items-center justify-center shrink-0 mt-0.5">
                          <Check className="w-3.5 h-3.5 text-[#0F766E] stroke-[2.8]" />
                        </div>
                        <div className="flex-1 min-w-0">
                          <h4 className="text-[15px] font-bold text-[#111827] leading-snug">
                            Smart Summary
                          </h4>
                          <p className="text-[13.5px] text-[#4B5563] leading-[1.4] mt-0.5">
                            AI distills 5-minute recordings into actionable tasks.
                          </p>
                        </div>
                      </div>
                    </div>
                  </div>

                  {/* 6. Bottom Action Controls */}
                  <div className="pt-6 pb-2 space-y-3">
                    <button
                      onClick={handleAllowMicrophone}
                      disabled={microphoneStatus === 'requesting'}
                      className="w-full h-[52px] bg-[#0F4C4C] hover:bg-[#0c3c3c] active:scale-[0.99] text-white font-bold text-[16px] rounded-xl flex items-center justify-center transition-all shadow-sm"
                    >
                      {microphoneStatus === 'requesting' ? (
                        <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                      ) : microphoneStatus === 'granted' ? (
                        <span className="flex items-center space-x-2">
                          <Check className="w-5 h-5 stroke-[2.5]" />
                          <span>Microphone Access Granted</span>
                        </span>
                      ) : (
                        'Allow Microphone Access'
                      )}
                    </button>

                    <button
                      onClick={handleSkipMicrophone}
                      className="w-full text-center text-[#6B7280] hover:text-[#111827] text-[15px] font-medium py-1 transition-colors"
                    >
                      Skip for now
                    </button>
                  </div>
                </div>
              ) : selectedScreen === 'onboarding-camera' ? (
                /* ONBOARDING SCREEN 3: ONBOARDING CAMERA PERMISSION SCREEN */
                <div className="flex-1 flex flex-col justify-between px-6 pt-5 pb-6 overflow-y-auto no-scrollbar scroll-smooth bg-white">
                  <div>
                    {/* 1. Top Progress Bar: ~42% filled dark teal */}
                    <div className="w-full h-[4.5px] bg-[#E5E7EB] rounded-full overflow-hidden mt-1">
                      <div className="h-full w-[42%] bg-[#0F4C4C] rounded-full transition-all duration-500" />
                    </div>

                    {/* 2. Hero Graphic Card: Soft mint card with camera vector illustration */}
                    <div className="mt-5 w-full h-[210px] rounded-[24px] bg-[#F0FDF9] flex items-center justify-center relative overflow-hidden group">
                      <svg
                        width="106"
                        height="106"
                        viewBox="0 0 24 24"
                        fill="none"
                        stroke="#0F4C4C"
                        strokeWidth="0.65"
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        className="transition-transform duration-300 group-hover:scale-105"
                      >
                        <path d="M14.5 4h-5L7 7H4a2 2 0 0 0-2 2v9a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V9a2 2 0 0 0-2-2h-3l-2.5-3z" />
                        <circle cx="12" cy="13" r="3.4" />
                      </svg>
                    </div>

                    {/* 3. Title: "Enable Camera" */}
                    <h2 className="mt-6 text-[#111827] text-[28px] font-extrabold tracking-tight leading-tight">
                      Enable Camera
                    </h2>

                    {/* 4. Subtitle */}
                    <p className="mt-2 text-[#4B5563] text-[15px] font-normal leading-[1.45]">
                      Capture visiting cards, customer photos, and documents during visits.
                    </p>

                    {/* Toast / Feedback Banner if active */}
                    {cameraToast && (
                      <div className="mt-4 p-3 bg-[#ECFDF5] border border-[#A7F3D0] rounded-xl flex items-center space-x-2 text-xs text-[#065F46] animate-fade-in">
                        <CheckCircle2 className="w-4 h-4 text-[#10B981] shrink-0" />
                        <span className="font-semibold">{cameraToast}</span>
                      </div>
                    )}

                    {/* 5. Benefits List (3 items with mint check badges) */}
                    <div className="mt-5 space-y-4">
                      {/* Benefit 1 */}
                      <div className="flex items-start space-x-3">
                        <div className="w-[22px] h-[22px] rounded-full bg-[#D1FADF] flex items-center justify-center shrink-0 mt-0.5">
                          <Check className="w-3.5 h-3.5 text-[#0F766E] stroke-[2.8]" />
                        </div>
                        <div className="flex-1 min-w-0">
                          <h4 className="text-[15px] font-bold text-[#111827] leading-snug">
                            Business Card OCR
                          </h4>
                          <p className="text-[13.5px] text-[#4B5563] leading-[1.4] mt-0.5">
                            Instant lead translation from physical cards directly to the CRM.
                          </p>
                        </div>
                      </div>

                      {/* Benefit 2 */}
                      <div className="flex items-start space-x-3">
                        <div className="w-[22px] h-[22px] rounded-full bg-[#D1FADF] flex items-center justify-center shrink-0 mt-0.5">
                          <Check className="w-3.5 h-3.5 text-[#0F766E] stroke-[2.8]" />
                        </div>
                        <div className="flex-1 min-w-0">
                          <h4 className="text-[15px] font-bold text-[#111827] leading-snug">
                            Site Verification
                          </h4>
                          <p className="text-[13.5px] text-[#4B5563] leading-[1.4] mt-0.5">
                            Upload physical storefront images as meeting proof for compliance.
                          </p>
                        </div>
                      </div>

                      {/* Benefit 3 */}
                      <div className="flex items-start space-x-3">
                        <div className="w-[22px] h-[22px] rounded-full bg-[#D1FADF] flex items-center justify-center shrink-0 mt-0.5">
                          <Check className="w-3.5 h-3.5 text-[#0F766E] stroke-[2.8]" />
                        </div>
                        <div className="flex-1 min-w-0">
                          <h4 className="text-[15px] font-bold text-[#111827] leading-snug">
                            Receipt Scans
                          </h4>
                          <p className="text-[13.5px] text-[#4B5563] leading-[1.4] mt-0.5">
                            Instantly log client lunch bills to expenses on the fly.
                          </p>
                        </div>
                      </div>
                    </div>
                  </div>

                  {/* 6. Bottom Action Controls */}
                  <div className="mt-auto pt-4 pb-2 flex flex-col items-center space-y-3">
                    <button
                      type="button"
                      onClick={handleAllowCamera}
                      disabled={cameraStatus === 'requesting'}
                      className="w-full h-[52px] bg-[#0F4C4C] hover:bg-[#0C3E3E] active:scale-[0.99] text-white font-bold text-[16px] rounded-xl flex items-center justify-center transition-all shadow-xs cursor-pointer disabled:opacity-80"
                    >
                      {cameraStatus === 'requesting' ? (
                        <RotateCcw className="w-5 h-5 animate-spin" />
                      ) : cameraStatus === 'granted' ? (
                        <span className="flex items-center space-x-2">
                          <Check className="w-5 h-5 stroke-[2.8]" />
                          <span>Camera Access Granted</span>
                        </span>
                      ) : (
                        'Allow Camera Access'
                      )}
                    </button>

                    <button
                      type="button"
                      onClick={handleSkipCamera}
                      className="text-[15px] font-medium text-[#6B7280] hover:text-[#111827] transition-colors py-1 cursor-pointer"
                    >
                      Skip for now
                    </button>
                  </div>
                </div>
              ) : selectedScreen === 'onboarding-location' ? (
                /* ONBOARDING SCREEN 2: ONBOARDING LOCATION PERMISSION SCREEN */
                <div className="flex-1 flex flex-col justify-between px-6 pt-5 pb-6 overflow-y-auto no-scrollbar scroll-smooth bg-white">
                  <div>
                    {/* 1. Top Progress Bar: 25% filled dark teal */}
                    <div className="w-full h-[4.5px] bg-[#E5E7EB] rounded-full overflow-hidden mt-1">
                      <div className="h-full w-[25%] bg-[#0F4C4C] rounded-full transition-all duration-500" />
                    </div>

                    {/* 2. Hero Graphic Card: Soft mint card with route nodes vector */}
                    <div className="mt-5 w-full h-[210px] rounded-[24px] bg-[#F0FDF9] flex items-center justify-center relative overflow-hidden group">
                      <svg
                        width="140"
                        height="140"
                        viewBox="0 0 140 140"
                        fill="none"
                        className="transition-transform duration-300 group-hover:scale-105"
                      >
                        {/* Outer boundary L-bracket frame */}
                        <path
                          d="M 28 25 L 28 108 Q 28 122 42 122 L 122 122"
                          stroke="#0F4C4C"
                          strokeWidth="2.6"
                          strokeLinecap="round"
                          strokeLinejoin="round"
                        />
                        {/* Lead-in line from top-right into upper node */}
                        <line
                          x1="116"
                          y1="32"
                          x2="78"
                          y2="42"
                          stroke="#0F4C4C"
                          strokeWidth="2.6"
                          strokeLinecap="round"
                        />
                        {/* Connecting segment: Node A to Node B */}
                        <line
                          x1="78"
                          y1="42"
                          x2="100"
                          y2="72"
                          stroke="#0F4C4C"
                          strokeWidth="2.6"
                          strokeLinecap="round"
                        />
                        {/* Connecting segment: Node B to Node C */}
                        <line
                          x1="100"
                          y1="72"
                          x2="62"
                          y2="98"
                          stroke="#0F4C4C"
                          strokeWidth="2.6"
                          strokeLinecap="round"
                        />
                        {/* Node A: Upper waypoint */}
                        <circle
                          cx="78"
                          cy="42"
                          r="9"
                          fill="#F0FDF9"
                          stroke="#0F4C4C"
                          strokeWidth="2.6"
                        />
                        {/* Node B: Middle-right waypoint */}
                        <circle
                          cx="100"
                          cy="72"
                          r="9"
                          fill="#F0FDF9"
                          stroke="#0F4C4C"
                          strokeWidth="2.6"
                        />
                        {/* Node C: Lower-left waypoint */}
                        <circle
                          cx="62"
                          cy="98"
                          r="9"
                          fill="#F0FDF9"
                          stroke="#0F4C4C"
                          strokeWidth="2.6"
                        />
                      </svg>
                    </div>

                    {/* 3. Title: "Enable Location" */}
                    <h2 className="mt-6 text-[#111827] text-[28px] font-extrabold tracking-tight leading-tight">
                      Enable Location
                    </h2>

                    {/* 4. Subtitle */}
                    <p className="mt-2 text-[#4B5563] text-[15px] font-normal leading-[1.45]">
                      We use GPS to verify your check-ins, optimize your routes, and show nearby leads.
                    </p>

                    {/* Toast / Feedback Banner if active */}
                    {locationToast && (
                      <div className="mt-4 p-3 bg-[#ECFDF5] border border-[#A7F3D0] rounded-xl flex items-center space-x-2 text-xs text-[#065F46] animate-fade-in">
                        <CheckCircle2 className="w-4 h-4 text-[#10B981] shrink-0" />
                        <span className="font-semibold">{locationToast}</span>
                      </div>
                    )}

                    {/* 5. Benefits List (3 items with mint check badges) */}
                    <div className="mt-5 space-y-4">
                      {/* Benefit 1 */}
                      <div className="flex items-start space-x-3">
                        <div className="w-[22px] h-[22px] rounded-full bg-[#D1FADF] flex items-center justify-center shrink-0 mt-0.5">
                          <Check className="w-3.5 h-3.5 text-[#0F766E] stroke-[2.8]" />
                        </div>
                        <div className="flex-1 min-w-0">
                          <h4 className="text-[15px] font-bold text-[#111827] leading-snug">
                            Accurate Check-ins
                          </h4>
                          <p className="text-[13.5px] text-[#4B5563] leading-[1.4] mt-0.5">
                            Geofenced visits automatically logs meetings at the client's office.
                          </p>
                        </div>
                      </div>

                      {/* Benefit 2 */}
                      <div className="flex items-start space-x-3">
                        <div className="w-[22px] h-[22px] rounded-full bg-[#D1FADF] flex items-center justify-center shrink-0 mt-0.5">
                          <Check className="w-3.5 h-3.5 text-[#0F766E] stroke-[2.8]" />
                        </div>
                        <div className="flex-1 min-w-0">
                          <h4 className="text-[15px] font-bold text-[#111827] leading-snug">
                            Smart Route Optimization
                          </h4>
                          <p className="text-[13.5px] text-[#4B5563] leading-[1.4] mt-0.5">
                            Minimize commute fatigue with dynamic sequence plans.
                          </p>
                        </div>
                      </div>

                      {/* Benefit 3 */}
                      <div className="flex items-start space-x-3">
                        <div className="w-[22px] h-[22px] rounded-full bg-[#D1FADF] flex items-center justify-center shrink-0 mt-0.5">
                          <Check className="w-3.5 h-3.5 text-[#0F766E] stroke-[2.8]" />
                        </div>
                        <div className="flex-1 min-w-0">
                          <h4 className="text-[15px] font-bold text-[#111827] leading-snug">
                            Nearby Client Alerts
                          </h4>
                          <p className="text-[13.5px] text-[#4B5563] leading-[1.4] mt-0.5">
                            Discover unassigned hot prospects within 1 km of your current site.
                          </p>
                        </div>
                      </div>
                    </div>
                  </div>

                  {/* 6. Bottom Action Controls */}
                  <div className="mt-auto pt-4 pb-2 flex flex-col items-center space-y-3">
                    <button
                      type="button"
                      onClick={handleAllowLocation}
                      disabled={locationStatus === 'requesting'}
                      className="w-full h-[52px] bg-[#0F4C4C] hover:bg-[#0C3E3E] active:scale-[0.99] text-white font-bold text-[16px] rounded-xl flex items-center justify-center transition-all shadow-xs cursor-pointer disabled:opacity-80"
                    >
                      {locationStatus === 'requesting' ? (
                        <RotateCcw className="w-5 h-5 animate-spin" />
                      ) : locationStatus === 'granted' ? (
                        <span className="flex items-center space-x-2">
                          <Check className="w-5 h-5 stroke-[2.8]" />
                          <span>Location Access Granted</span>
                        </span>
                      ) : (
                        'Allow Location Access'
                      )}
                    </button>

                    <button
                      type="button"
                      onClick={handleSkipLocation}
                      className="text-[15px] font-medium text-[#6B7280] hover:text-[#111827] transition-colors py-1 cursor-pointer"
                    >
                      Skip for now
                    </button>
                  </div>
                </div>
              ) : selectedScreen === 'onboarding-welcome' ? (
                /* ONBOARDING SCREEN 1: ONBOARDING WELCOME SCREEN */
                <div className="flex-1 flex flex-col justify-between px-6 pt-11 pb-6 overflow-y-auto no-scrollbar scroll-smooth bg-white">
                  <div>
                    {/* 1. Top Avatar Badge: Centered dark teal squircle with white initials */}
                    <div className="flex justify-center">
                      <div className="w-[72px] h-[72px] rounded-[22px] bg-[#0F4C4C] text-white flex items-center justify-center font-extrabold text-[24px] tracking-tight shadow-md shadow-[#0F4C4C]/25">
                        AM
                      </div>
                    </div>

                    {/* 2. Greeting Headline */}
                    <h2 className="mt-6 text-[#111827] text-[28px] font-extrabold tracking-tight leading-tight">
                      Hi Arjun!
                    </h2>

                    {/* 3. Subtitle / Description */}
                    <p className="mt-2 text-[#4B5563] text-[14.5px] font-normal leading-[1.45]">
                      Let's set up your field kit in under a minute to prepare for South Mumbai territory operations.
                    </p>

                    {/* 4. Company & Territory Info Card */}
                    <div className="mt-5 bg-[#F3F4F6] rounded-xl p-3.5 flex items-center space-x-3.5 border border-[#E5E7EB]">
                      <div className="w-11 h-11 rounded-full bg-[#D1FADF] flex items-center justify-center shrink-0">
                        <Briefcase className="w-5 h-5 text-[#0F766E] stroke-[2]" />
                      </div>
                      <div className="flex-1 min-w-0">
                        <h4 className="text-[15px] font-bold text-[#111827] leading-snug">
                          Acme Industries
                        </h4>
                        <p className="text-[13px] text-[#4B5563] font-normal leading-snug mt-0.5 truncate">
                          Assigned Territory: South Mumbai
                        </p>
                      </div>
                    </div>

                    {/* Feedback Toast */}
                    {onboardingSuccessMessage && (
                      <div className="mt-4 p-3 bg-[#ECFDF5] border border-[#A7F3D0] rounded-xl flex items-center space-x-2 text-xs text-[#065F46] animate-fade-in">
                        <CheckCircle2 className="w-4 h-4 text-[#10B981] shrink-0" />
                        <span className="font-semibold">{onboardingSuccessMessage}</span>
                      </div>
                    )}

                    {/* 5. Section Header */}
                    <div className="mt-6 mb-2">
                      <span className="text-[12px] font-semibold text-[#6B7280] tracking-wider uppercase">
                        REQUIRED SETUP PROGRESS
                      </span>
                    </div>

                    {/* 6. Checklist Items */}
                    <div className="space-y-1">
                      {[
                        { id: 'location', title: 'Location Access', icon: MapPin },
                        { id: 'camera', title: 'Camera Access', icon: Camera },
                        { id: 'microphone', title: 'Microphone Access', icon: Mic },
                        { id: 'notifications', title: 'Notifications', icon: Bell },
                        { id: 'offline_data', title: 'Offline Data Setup', icon: Database },
                      ].map((step) => {
                        const isCompleted = completedSteps.includes(step.id);
                        const IconComponent = step.icon;

                        return (
                          <div
                            key={step.id}
                            onClick={() => toggleOnboardingStep(step.id)}
                            className="flex items-center justify-between py-3 px-1 rounded-lg hover:bg-gray-50/80 active:bg-gray-100 transition-colors cursor-pointer group select-none"
                          >
                            <div className="flex items-center space-x-3.5">
                              <IconComponent
                                className={`w-[22px] h-[22px] transition-colors ${
                                  isCompleted ? 'text-[#0F4C4C]' : 'text-[#4B5563] group-hover:text-[#111827]'
                                }`}
                                strokeWidth={1.8}
                              />
                              <span className="text-[15px] font-medium text-[#111827] group-hover:text-[#0F4C4C] transition-colors">
                                {step.title}
                              </span>
                            </div>

                            {/* Circular status indicator */}
                            <div
                              className={`w-[22px] h-[22px] rounded-full flex items-center justify-center transition-all duration-200 ${
                                isCompleted
                                  ? 'bg-[#10B981] border-[1.8px] border-[#10B981] text-white shadow-xs'
                                  : 'border-[1.8px] border-[#D1D5DB] bg-transparent group-hover:border-[#9CA3AF]'
                              }`}
                            >
                              {isCompleted && <Check className="w-3.5 h-3.5 stroke-[2.8]" />}
                            </div>
                          </div>
                        );
                      })}
                    </div>
                  </div>

                  {/* 7. Bottom Action Button: "Let's Go" */}
                  <div className="pt-4 mt-auto">
                    <button
                      type="button"
                      onClick={handleLetsGo}
                      className="w-full h-[52px] bg-[#0F4C4C] hover:bg-[#0C3E3E] active:scale-[0.99] text-white font-bold text-[16px] rounded-xl flex items-center justify-center transition-all shadow-xs cursor-pointer"
                    >
                      Let's Go
                    </button>
                  </div>
                </div>
              ) : selectedScreen === 'biometric' || selectedScreen === 'biometric-fail' ? (
                /* SCREEN 8 & BIOMETRIC FAIL SCREEN: REUSED BIOMETRIC LOGIN COMPONENT */
                <div className="flex-1 flex flex-col justify-between items-center px-6 pt-14 pb-6 text-white overflow-y-auto no-scrollbar scroll-smooth">
                  {/* 1. App Logo & Title */}
                  <div className="flex flex-col items-center animate-fade-in">
                    <div className="w-[88px] h-[88px] rounded-[22px] bg-white shadow-xl flex items-center justify-center">
                      <span className="text-[#0F4C4C] font-extrabold text-[32px] tracking-tight">LP</span>
                    </div>
                    <h2 className="mt-5 text-white text-[23px] font-extrabold tracking-tight text-center">
                      CRM Pro Field Sales
                    </h2>
                  </div>

                  {/* 2. Biometric Scan Disc & Prompt */}
                  <div className="flex flex-col items-center my-auto w-full max-w-[320px]">
                    {selectedScreen === 'biometric-fail' ? (
                      /* FAILED STATE BIOMETRIC COMPONENT: Coral Red Circle with Corner Brackets */
                      <div className="flex flex-col items-center">
                        <div
                          className="relative flex items-center justify-center w-[124px] h-[124px] rounded-full bg-[#133B3B] border-[1.8px] border-[#EF4444] shadow-lg shadow-[#EF4444]/20 animate-fade-in"
                        >
                          {/* Face ID Icon in Coral Red */}
                          <svg
                            className="w-[58px] h-[58px] text-[#EF4444]"
                            viewBox="0 0 54 54"
                            fill="none"
                            xmlns="http://www.w3.org/2000/svg"
                          >
                            {/* Top Left Bracket */}
                            <path d="M4 14V8C4 5.79086 5.79086 4 8 4H14" stroke="#EF4444" strokeWidth="2.8" strokeLinecap="round" strokeLinejoin="round"/>
                            {/* Top Right Bracket */}
                            <path d="M40 4H46C48.2091 4 50 5.79086 50 8V14" stroke="#EF4444" strokeWidth="2.8" strokeLinecap="round" strokeLinejoin="round"/>
                            {/* Bottom Left Bracket */}
                            <path d="M4 40V46C4 48.2091 5.79086 50 8 50H14" stroke="#EF4444" strokeWidth="2.8" strokeLinecap="round" strokeLinejoin="round"/>
                            {/* Bottom Right Bracket */}
                            <path d="M40 50H46C48.2091 50 50 48.2091 50 46V40" stroke="#EF4444" strokeWidth="2.8" strokeLinecap="round" strokeLinejoin="round"/>
                            {/* Eye Slits */}
                            <path d="M19 20V23" stroke="#EF4444" strokeWidth="3" strokeLinecap="round"/>
                            <path d="M35 20V23" stroke="#EF4444" strokeWidth="3" strokeLinecap="round"/>
                            {/* Nose */}
                            <path d="M27 24V30" stroke="#EF4444" strokeWidth="2.6" strokeLinecap="round"/>
                            {/* Smile */}
                            <path d="M19 36C21.5 39 32.5 39 35 36" stroke="#EF4444" strokeWidth="2.6" strokeLinecap="round"/>
                          </svg>
                        </div>

                        {/* Title */}
                        <h3 className="text-white text-[22px] font-extrabold tracking-tight text-center mt-5">
                          Face ID Failed
                        </h3>

                        {/* Subtitle */}
                        <p className="text-white/75 text-[14px] leading-relaxed text-center px-2 mt-2">
                          We couldn't verify your identity. Please try again or use your password.
                        </p>
                      </div>
                    ) : (
                      /* NORMAL BIOMETRIC STATE */
                      <div className="flex flex-col items-center">
                        <button
                          type="button"
                          onClick={handleTriggerBiometric}
                          className={`relative group flex items-center justify-center w-[124px] h-[124px] rounded-full transition-all duration-300 cursor-pointer ${
                            biometricSuccess
                              ? 'bg-[#10B981] shadow-xl shadow-[#10B981]/30 ring-4 ring-[#10B981]/40'
                              : biometricScanning
                              ? 'bg-[#1E6060] ring-4 ring-white/30 animate-pulse'
                              : 'bg-[#1E6060] hover:bg-[#246f6f] border border-white/20 active:scale-95 shadow-lg shadow-black/20'
                          }`}
                          title="Tap to scan Face ID"
                        >
                          {biometricSuccess ? (
                            <Check className="w-14 h-14 text-white stroke-[2.8] animate-fade-in" />
                          ) : biometricScanning ? (
                            <RotateCcw className="w-10 h-10 text-white animate-spin stroke-[2.2]" />
                          ) : (
                            <ScanFace className="w-16 h-16 text-white stroke-[2] transition-transform group-hover:scale-105" />
                          )}
                        </button>

                        {/* Prompt Text */}
                        <button
                          type="button"
                          onClick={handleTriggerBiometric}
                          className="mt-5 text-white/95 hover:text-white text-[16px] font-medium tracking-tight cursor-pointer transition-colors"
                        >
                          {biometricScanning
                            ? 'Verifying Face ID...'
                            : biometricSuccess
                            ? 'Face ID Verified!'
                            : 'Use Face ID to sign in'}
                        </button>

                        <p className="text-[12px] text-white/60 mt-1.5">
                          {biometricSuccess
                            ? 'Authenticated successfully'
                            : 'Tap circle to simulate biometric scan'}
                        </p>
                      </div>
                    )}
                  </div>

                  {/* 3. Bottom Actions */}
                  <div className="w-full max-w-[340px] pt-4 pb-2">
                    {selectedScreen === 'biometric-fail' ? (
                      /* Actions for Biometric Failure */
                      <div className="flex flex-col items-center w-full">
                        {/* Error warning text */}
                        <div className="text-[#EF4444] text-[12.5px] font-bold tracking-wider text-center uppercase mb-4">
                          TOO MANY ATTEMPTS. PLEASE USE PASSWORD.
                        </div>

                        {/* Try Again Button */}
                        <button
                          type="button"
                          onClick={() => {
                            setSelectedScreen('biometric');
                            handleTriggerBiometric();
                          }}
                          className="w-full h-[52px] bg-[#5E8585] hover:bg-[#527777] active:scale-[0.99] text-[#1B3B3B] rounded-xl font-bold text-[16px] transition-all flex items-center justify-center cursor-pointer mb-3 shadow-xs"
                        >
                          Try Again
                        </button>

                        {/* Use Password Instead Button */}
                        <button
                          type="button"
                          onClick={() => setSelectedScreen('signin')}
                          className="w-full h-[52px] bg-transparent border-[1.5px] border-white hover:bg-white/10 active:scale-[0.99] text-white rounded-xl font-bold text-[16px] transition-all flex items-center justify-center cursor-pointer"
                        >
                          Use Password Instead
                        </button>
                      </div>
                    ) : (
                      /* Normal Action: "Use password instead" link */
                      <div className="text-center w-full">
                        <button
                          type="button"
                          onClick={() => setSelectedScreen('signin')}
                          className="text-white/90 hover:text-white hover:underline text-[15px] font-medium cursor-pointer transition-all"
                        >
                          Use password instead
                        </button>
                      </div>
                    )}
                  </div>
                </div>
              ) : selectedScreen === 'logout-confirmation' ? (
                /* AUTHENTICATION: LOGOUT CONFIRMATION SCREEN (screen-logout-confirmation) */
                <div className="flex-1 flex flex-col bg-[#F9FAFB] relative select-none h-full overflow-hidden font-['Inter',sans-serif]">
                  {/* Toast Notification */}
                  {logoutToast && (
                    <div className="absolute top-4 left-4 right-4 z-50 bg-[#111827] text-white px-4 py-2.5 rounded-xl shadow-xl flex items-center justify-between text-xs animate-in fade-in slide-in-from-top duration-200">
                      <div className="flex items-center space-x-2">
                        <Check className="w-4 h-4 text-[#10B981] shrink-0" />
                        <span className="font-medium">{logoutToast}</span>
                      </div>
                      <button
                        onClick={() => setLogoutToast(null)}
                        className="text-white/70 hover:text-white text-xs font-bold ml-2 cursor-pointer"
                      >
                        ✕
                      </button>
                    </div>
                  )}

                  {/* 1. Underlying Settings Page */}
                  <div className="flex-1 flex flex-col overflow-y-auto no-scrollbar">
                    {/* Top Status Bar & App Header */}
                    <div className="px-5 pt-3 pb-3 flex items-center justify-between">
                      <h2 className="text-[26px] font-extrabold text-[#111827] tracking-tight">
                        Settings
                      </h2>
                      <button
                        type="button"
                        onClick={() => {
                          setLogoutToast('Settings options');
                          setTimeout(() => setLogoutToast(null), 2500);
                        }}
                        className="w-10 h-10 rounded-xl flex items-center justify-center hover:bg-gray-100 transition-colors text-[#111827]"
                      >
                        <Settings className="w-6 h-6 stroke-[1.8]" />
                      </button>
                    </div>

                    {/* Section Header: ACCOUNT */}
                    <div className="px-5 mt-3">
                      <p className="text-[12px] font-bold text-[#6B7280] tracking-wider uppercase">
                        ACCOUNT
                      </p>

                      {/* Account Options List */}
                      <div className="mt-3 space-y-2.5">
                        {/* Option 1: Personal Information */}
                        <div
                          onClick={() => {
                            setLogoutToast('Opening Personal Information');
                            setTimeout(() => setLogoutToast(null), 2000);
                          }}
                          className="bg-white rounded-xl border border-[#E5E7EB] p-4 flex items-center justify-between shadow-2xs hover:border-[#D1D5DB] transition-all cursor-pointer group"
                        >
                          <div className="flex items-center space-x-3.5">
                            <User className="w-5 h-5 text-[#4B5563] group-hover:text-[#111827] transition-colors" strokeWidth={1.8} />
                            <span className="text-[15px] font-medium text-[#111827]">
                              Personal Information
                            </span>
                          </div>
                          <ChevronRight className="w-5 h-5 text-[#9CA3AF] group-hover:text-[#4B5563] transition-colors" />
                        </div>

                        {/* Option 2: Change Password */}
                        <div
                          onClick={() => {
                            setLogoutToast('Opening Change Password');
                            setTimeout(() => setLogoutToast(null), 2000);
                          }}
                          className="bg-white rounded-xl border border-[#E5E7EB] p-4 flex items-center justify-between shadow-2xs hover:border-[#D1D5DB] transition-all cursor-pointer group"
                        >
                          <div className="flex items-center space-x-3.5">
                            <Lock className="w-5 h-5 text-[#4B5563] group-hover:text-[#111827] transition-colors" strokeWidth={1.8} />
                            <span className="text-[15px] font-medium text-[#111827]">
                              Change Password
                            </span>
                          </div>
                          <ChevronRight className="w-5 h-5 text-[#9CA3AF] group-hover:text-[#4B5563] transition-colors" />
                        </div>

                        {/* Option 3: Notification Preferences */}
                        <div
                          onClick={() => {
                            setLogoutToast('Opening Notification Preferences');
                            setTimeout(() => setLogoutToast(null), 2000);
                          }}
                          className="bg-white rounded-xl border border-[#E5E7EB] p-4 flex items-center justify-between shadow-2xs hover:border-[#D1D5DB] transition-all cursor-pointer group"
                        >
                          <div className="flex items-center space-x-3.5">
                            <Bell className="w-5 h-5 text-[#4B5563] group-hover:text-[#111827] transition-colors" strokeWidth={1.8} />
                            <span className="text-[15px] font-medium text-[#111827]">
                              Notification Preferences
                            </span>
                          </div>
                          <ChevronRight className="w-5 h-5 text-[#9CA3AF] group-hover:text-[#4B5563] transition-colors" />
                        </div>

                        {/* Option 4: Re-open sign out modal if dismissed */}
                        {!isLogoutModalOpen && (
                          <div
                            onClick={() => setIsLogoutModalOpen(true)}
                            className="bg-red-50/60 rounded-xl border border-red-200 p-4 flex items-center justify-between hover:bg-red-50 transition-all cursor-pointer mt-4"
                          >
                            <span className="text-[15px] font-bold text-[#EF4444]">
                              Sign Out of Account
                            </span>
                            <span className="text-xs bg-[#EF4444] text-white font-semibold px-2 py-1 rounded-md">
                              Open Sheet
                            </span>
                          </div>
                        )}
                      </div>
                    </div>
                  </div>

                  {/* 2. Dimmed Scrim / Overlay */}
                  {isLogoutModalOpen && (
                    <div
                      onClick={() => setIsLogoutModalOpen(false)}
                      className="absolute inset-0 bg-black/45 z-30 transition-opacity duration-300"
                    />
                  )}

                  {/* 3. Modal Bottom Sheet */}
                  {isLogoutModalOpen && (
                    <div className="absolute left-0 right-0 bottom-0 z-40 bg-white rounded-t-[28px] shadow-2xl animate-in slide-in-from-bottom duration-300 border-t border-[#F3F4F6] flex flex-col">
                      <div className="px-6 pt-3 pb-5 flex flex-col items-center">
                        {/* Drag Handle Bar */}
                        <div className="w-9 h-1 bg-[#E5E7EB] rounded-full mb-4" />

                        {/* Marcus Vance Avatar Photo */}
                        <div className="relative">
                          <img
                            src="https://images.unsplash.com/photo-1560250097-0b93528c311a?w=256&auto=format&fit=crop&q=80"
                            alt="Marcus Vance"
                            className="w-[72px] h-[72px] rounded-full object-cover ring-2 ring-white shadow-md"
                          />
                        </div>

                        {/* Marcus Vance Profile Title & Subtitle */}
                        <h3 className="mt-3 text-[19px] font-extrabold text-[#111827] tracking-tight">
                          Marcus Vance
                        </h3>
                        <p className="mt-0.5 text-[13.5px] text-[#64748B] font-normal">
                          Pacific Northwest Territory
                        </p>

                        {/* Dialog Heading: Sign Out? */}
                        <h4 className="mt-4 text-[22px] font-extrabold text-[#111827] tracking-tight">
                          Sign Out?
                        </h4>

                        {/* Body description */}
                        <p className="mt-1.5 text-[14px] text-[#4B5563] text-center max-w-[290px] leading-relaxed">
                          Are you sure you want to sign out? You will need to sign in again to access your account.
                        </p>

                        {/* Action 1: Primary Sign Out Button (Coral Red) */}
                        <button
                          type="button"
                          disabled={logoutSigningOut}
                          onClick={() => {
                            setLogoutSigningOut(true);
                            setLogoutToast('Signing out...');
                            setTimeout(() => {
                              setLogoutSigningOut(false);
                              setLogoutToast('Signed out successfully');
                              setSelectedScreen('signin');
                            }, 800);
                          }}
                          className="w-full h-[50px] bg-[#EF4444] hover:bg-[#DC2626] active:scale-[0.99] text-white font-bold text-[16px] rounded-xl flex items-center justify-center transition-all mt-6 shadow-xs cursor-pointer disabled:opacity-75"
                        >
                          {logoutSigningOut ? (
                            <span className="flex items-center space-x-2">
                              <span className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin" />
                              <span>Signing out...</span>
                            </span>
                          ) : (
                            'Sign Out'
                          )}
                        </button>

                        {/* Action 2: Secondary Cancel Button (White Outlined) */}
                        <button
                          type="button"
                          onClick={() => {
                            setIsLogoutModalOpen(false);
                            setLogoutToast('Sign out cancelled');
                            setTimeout(() => setLogoutToast(null), 2000);
                          }}
                          className="w-full h-[50px] bg-white hover:bg-gray-50 active:scale-[0.99] border border-[#E5E7EB] text-[#374151] font-bold text-[16px] rounded-xl flex items-center justify-center transition-all mt-3 cursor-pointer"
                        >
                          Cancel
                        </button>
                      </div>

                      {/* Bottom Navigation Bar pinned beneath sheet */}
                      <div className="bg-white border-t border-[#E5E7EB] px-3 pt-2 pb-2">
                        <div className="flex items-center justify-around">
                          {/* Home */}
                          <div
                            onClick={() => setSelectedScreen('dashboard')}
                            className="flex flex-col items-center cursor-pointer group py-1"
                          >
                            <Home className="w-5 h-5 text-[#6B7280] group-hover:text-[#111827]" strokeWidth={1.8} />
                            <span className="text-[11px] font-medium text-[#6B7280] mt-1 group-hover:text-[#111827]">
                              Home
                            </span>
                          </div>

                          {/* Leads */}
                          <div
                            onClick={() => {
                              setLogoutToast('Navigating to Leads');
                              setTimeout(() => setLogoutToast(null), 1500);
                            }}
                            className="flex flex-col items-center cursor-pointer group py-1"
                          >
                            <UserPlus className="w-5 h-5 text-[#6B7280] group-hover:text-[#111827]" strokeWidth={1.8} />
                            <span className="text-[11px] font-medium text-[#6B7280] mt-1 group-hover:text-[#111827]">
                              Leads
                            </span>
                          </div>

                          {/* Visits */}
                          <div
                            onClick={() => {
                              setLogoutToast('Navigating to Visits');
                              setTimeout(() => setLogoutToast(null), 1500);
                            }}
                            className="flex flex-col items-center cursor-pointer group py-1"
                          >
                            <MapPin className="w-5 h-5 text-[#6B7280] group-hover:text-[#111827]" strokeWidth={1.8} />
                            <span className="text-[11px] font-medium text-[#6B7280] mt-1 group-hover:text-[#111827]">
                              Visits
                            </span>
                          </div>

                          {/* Tasks */}
                          <div
                            onClick={() => {
                              setLogoutToast('Navigating to Tasks');
                              setTimeout(() => setLogoutToast(null), 1500);
                            }}
                            className="flex flex-col items-center cursor-pointer group py-1"
                          >
                            <ListTodo className="w-5 h-5 text-[#6B7280] group-hover:text-[#111827]" strokeWidth={1.8} />
                            <span className="text-[11px] font-medium text-[#6B7280] mt-1 group-hover:text-[#111827]">
                              Tasks
                            </span>
                          </div>

                          {/* Profile (Active) */}
                          <div className="flex flex-col items-center cursor-pointer py-1">
                            <User className="w-5 h-5 text-[#0F4C4C]" strokeWidth={2.2} />
                            <span className="text-[11px] font-bold text-[#0F4C4C] mt-1">
                              Profile
                            </span>
                          </div>
                        </div>
                      </div>
                    </div>
                  )}

                  {/* When modal is closed: standard bottom navigation bar */}
                  {!isLogoutModalOpen && (
                    <div className="bg-white border-t border-[#E5E7EB] px-3 pt-2 pb-2 mt-auto">
                      <div className="flex items-center justify-around">
                        <div onClick={() => setSelectedScreen('dashboard')} className="flex flex-col items-center cursor-pointer py-1">
                          <Home className="w-5 h-5 text-[#6B7280]" strokeWidth={1.8} />
                          <span className="text-[11px] font-medium text-[#6B7280] mt-1">Home</span>
                        </div>
                        <div className="flex flex-col items-center cursor-pointer py-1">
                          <UserPlus className="w-5 h-5 text-[#6B7280]" strokeWidth={1.8} />
                          <span className="text-[11px] font-medium text-[#6B7280] mt-1">Leads</span>
                        </div>
                        <div className="flex flex-col items-center cursor-pointer py-1">
                          <MapPin className="w-5 h-5 text-[#6B7280]" strokeWidth={1.8} />
                          <span className="text-[11px] font-medium text-[#6B7280] mt-1">Visits</span>
                        </div>
                        <div className="flex flex-col items-center cursor-pointer py-1">
                          <ListTodo className="w-5 h-5 text-[#6B7280]" strokeWidth={1.8} />
                          <span className="text-[11px] font-medium text-[#6B7280] mt-1">Tasks</span>
                        </div>
                        <div className="flex flex-col items-center cursor-pointer py-1">
                          <User className="w-5 h-5 text-[#0F4C4C]" strokeWidth={2.2} />
                          <span className="text-[11px] font-bold text-[#0F4C4C] mt-1">Profile</span>
                        </div>
                      </div>
                    </div>
                  )}
                </div>
              ) : selectedScreen === 'onboarding-skip-confirmation' ? (
                /* ONBOARDING: SKIP CONFIRMATION SCREEN (screen-onboarding-skip-confirmation) */
                <div className="flex-1 flex flex-col bg-[#88929E] relative select-none h-full overflow-hidden font-['Inter',sans-serif]">
                  {/* Toast Notification */}
                  {skipConfirmationToast && (
                    <div className="absolute top-4 left-4 right-4 z-50 bg-[#111827] text-white px-4 py-2.5 rounded-xl shadow-xl flex items-center justify-between text-xs animate-in fade-in slide-in-from-top duration-200">
                      <div className="flex items-center space-x-2">
                        <Check className="w-4 h-4 text-[#10B981] shrink-0" />
                        <span className="font-medium">{skipConfirmationToast}</span>
                      </div>
                      <button
                        onClick={() => setSkipConfirmationToast(null)}
                        className="text-white/70 hover:text-white text-xs font-bold ml-2 cursor-pointer"
                      >
                        ✕
                      </button>
                    </div>
                  )}

                  {/* 1. Underlying Screen (Dimmed Context - dynamically reflects which screen was skipped) */}
                  <div className="flex-1 flex flex-col items-center justify-center px-6 text-center pb-28">
                    {/* Context switcher chips for simulator testing */}
                    <div className="mb-6 flex flex-wrap items-center justify-center gap-1.5 opacity-85">
                      <span className="text-[11px] font-bold text-[#1E293B] mr-1">Skipped From:</span>
                      {[
                        { id: 'onboarding-offline-setup', label: 'Offline Setup' },
                        { id: 'onboarding-location', label: 'Location' },
                        { id: 'onboarding-camera', label: 'Camera' },
                        { id: 'onboarding-microphone', label: 'Mic' },
                        { id: 'onboarding-notifications', label: 'Notifications' },
                      ].map((item) => (
                        <button
                          key={item.id}
                          type="button"
                          onClick={() => {
                            setSkippedFromScreen(item.id as any);
                            setIsSkipModalOpen(true);
                          }}
                          className={`px-2 py-0.5 text-[10px] rounded-md font-semibold transition-all cursor-pointer ${
                            skippedFromScreen === item.id
                              ? 'bg-[#0F4C4C] text-white shadow-xs'
                              : 'bg-white/40 text-[#1E293B] hover:bg-white/60'
                          }`}
                        >
                          {item.label}
                        </button>
                      ))}
                    </div>

                    {/* Contextual Graphic */}
                    <div className="w-[84px] h-[84px] bg-[#6B7482]/60 rounded-[22px] mb-5 shadow-inner flex items-center justify-center">
                      {skippedFromScreen === 'onboarding-offline-setup' ? (
                        <Cloud className="w-10 h-10 text-white/70" strokeWidth={1.7} />
                      ) : skippedFromScreen === 'onboarding-location' ? (
                        <MapPin className="w-10 h-10 text-white/70" strokeWidth={1.7} />
                      ) : skippedFromScreen === 'onboarding-camera' ? (
                        <Camera className="w-10 h-10 text-white/70" strokeWidth={1.7} />
                      ) : skippedFromScreen === 'onboarding-microphone' ? (
                        <Mic className="w-10 h-10 text-white/70" strokeWidth={1.7} />
                      ) : (
                        <Bell className="w-10 h-10 text-white/70" strokeWidth={1.7} />
                      )}
                    </div>

                    {/* Title */}
                    <h2 className="text-[24px] font-extrabold text-[#1E293B] tracking-tight mb-2">
                      {skippedFromScreen === 'onboarding-offline-setup'
                        ? 'Prepare for Offline'
                        : skippedFromScreen === 'onboarding-location'
                        ? 'Location Access'
                        : skippedFromScreen === 'onboarding-camera'
                        ? 'Camera Access'
                        : skippedFromScreen === 'onboarding-microphone'
                        ? 'Microphone Access'
                        : 'Notifications'}
                    </h2>

                    {/* Subtitle */}
                    <p className="text-[13.5px] text-[#334155] max-w-[290px] leading-relaxed font-normal">
                      {skippedFromScreen === 'onboarding-offline-setup'
                        ? 'Download your assigned territory data for seamless offline CRM access in field operations.'
                        : skippedFromScreen === 'onboarding-location'
                        ? 'GPS coordinates are used for automated client check-in and calculating fastest travel routes.'
                        : skippedFromScreen === 'onboarding-camera'
                        ? 'Required to scan visiting cards, perform OCR data extraction, and verify site audits.'
                        : skippedFromScreen === 'onboarding-microphone'
                        ? 'Voice notes transcribe customer meeting discussions into structured deal summaries.'
                        : 'Receive real-time push alerts for new hot inbound leads, priority tasks, and scheduled visits.'}
                    </p>

                    {/* If modal is dismissed, show button to re-trigger skip modal */}
                    {!isSkipModalOpen && (
                      <button
                        onClick={() => setIsSkipModalOpen(true)}
                        className="mt-6 px-5 py-2.5 bg-[#0F4C4C] text-white rounded-xl font-bold text-xs shadow-md hover:bg-[#0C3B3B] transition-all cursor-pointer"
                      >
                        Open Skip Confirmation
                      </button>
                    )}
                  </div>

                  {/* 2. Dimmed Scrim Overlay */}
                  {isSkipModalOpen && (
                    <div
                      onClick={() => setIsSkipModalOpen(false)}
                      className="absolute inset-0 bg-black/25 z-20 backdrop-blur-[0.5px] transition-opacity"
                    />
                  )}

                  {/* 3. Foreground Modal Bottom Sheet + Bottom Navigation */}
                  {isSkipModalOpen && (
                    <div className="absolute inset-x-0 bottom-0 z-30 flex flex-col justify-end animate-in slide-in-from-bottom duration-300">
                      {/* Modal Sheet Content */}
                      <div className="bg-white rounded-t-[28px] px-6 pt-3 pb-5 shadow-2xl">
                        {/* Drag Handle Bar */}
                        <div className="w-10 h-1 bg-[#E2E8F0] rounded-full mx-auto my-2" />

                        {/* Title: Skip Permissions? */}
                        <h3 className="text-[22px] font-extrabold text-[#0F172A] tracking-tight text-center mt-3">
                          Skip Permissions?
                        </h3>

                        {/* Subtitle */}
                        <p className="text-[14px] text-[#4B5563] text-center mt-2 leading-snug px-1">
                          Some features will be limited without these permissions. You can enable them later in Settings.
                        </p>

                        {/* Limitations Warning Card */}
                        <div className="bg-[#F9FAFB] rounded-2xl p-4 mt-4 border border-[#F1F5F9] space-y-2.5">
                          {/* Location */}
                          <div className="flex items-start text-[13.5px] text-[#334155]">
                            <span className="font-extrabold text-[#111827] mr-2 leading-tight">•</span>
                            <span className="leading-snug">
                              <strong className="text-[#0F172A] font-bold">Location</strong>: Nearby leads &amp; check-in won't work
                            </span>
                          </div>

                          {/* Camera */}
                          <div className="flex items-start text-[13.5px] text-[#334155]">
                            <span className="font-extrabold text-[#111827] mr-2 leading-tight">•</span>
                            <span className="leading-snug">
                              <strong className="text-[#0F172A] font-bold">Camera</strong>: Can't capture visit photos
                            </span>
                          </div>

                          {/* Notifications */}
                          <div className="flex items-start text-[13.5px] text-[#334155]">
                            <span className="font-extrabold text-[#111827] mr-2 leading-tight">•</span>
                            <span className="leading-snug">
                              <strong className="text-[#0F172A] font-bold">Notifications</strong>: You'll miss important updates
                            </span>
                          </div>

                          {/* Offline Sync */}
                          <div className="flex items-start text-[13.5px] text-[#334155]">
                            <span className="font-extrabold text-[#111827] mr-2 leading-tight">•</span>
                            <span className="leading-snug">
                              <strong className="text-[#0F172A] font-bold">Offline Sync</strong>: Data won't be available without internet
                            </span>
                          </div>
                        </div>

                        {/* Action Buttons */}
                        <div className="mt-5 space-y-3">
                          {/* Primary: Go Back - navigates back to the skipped screen */}
                          <button
                            type="button"
                            onClick={() => {
                              setIsSkipModalOpen(false);
                              const target = skippedFromScreen;
                              const screenName =
                                target === 'onboarding-offline-setup'
                                  ? 'Offline Setup'
                                  : target === 'onboarding-location'
                                  ? 'Location Access'
                                  : target === 'onboarding-camera'
                                  ? 'Camera Access'
                                  : target === 'onboarding-microphone'
                                  ? 'Microphone Access'
                                  : 'Notifications';
                              setSkipConfirmationToast(`Returning to ${screenName}...`);
                              setTimeout(() => {
                                setSkipConfirmationToast(null);
                                setSelectedScreen(target);
                              }, 220);
                            }}
                            className="w-full h-[52px] bg-[#0F4C4C] hover:bg-[#0C3B3B] active:scale-[0.99] text-white rounded-xl font-bold text-[16px] transition-all flex items-center justify-center cursor-pointer shadow-xs"
                          >
                            Go Back
                          </button>

                          {/* Secondary: Skip Anyway - proceeds to onboarding-complete */}
                          <button
                            type="button"
                            onClick={() => {
                              setSkipConfirmationToast('Permissions skipped. Proceeding to Onboarding Complete...');
                              setTimeout(() => {
                                setSkipConfirmationToast(null);
                                setSelectedScreen('onboarding-complete');
                              }, 400);
                            }}
                            className="w-full h-[52px] bg-white border border-[#E5E7EB] hover:bg-gray-50 active:scale-[0.99] text-[#374151] rounded-xl font-bold text-[16px] transition-all flex items-center justify-center cursor-pointer"
                          >
                            Skip Anyway
                          </button>
                        </div>
                      </div>

                      {/* Pinned Bottom Navigation Bar (No bottom line) */}
                      <div className="bg-white border-t border-[#E5E7EB] px-3 py-2">
                        <div className="flex items-center justify-around">
                          {/* Home */}
                          <div
                            onClick={() => setSelectedScreen('dashboard')}
                            className="flex flex-col items-center cursor-pointer py-1 group"
                          >
                            <Home className="w-5 h-5 text-[#0F4C4C]" strokeWidth={1.8} />
                            <span className="text-[11px] font-semibold text-[#0F4C4C] mt-1">
                              Home
                            </span>
                          </div>

                          {/* Leads */}
                          <div className="flex flex-col items-center cursor-pointer py-1 group">
                            <UserPlus className="w-5 h-5 text-[#0F4C4C]" strokeWidth={1.8} />
                            <span className="text-[11px] font-semibold text-[#0F4C4C] mt-1">
                              Leads
                            </span>
                          </div>

                          {/* Visits */}
                          <div className="flex flex-col items-center cursor-pointer py-1 group">
                            <MapPin className="w-5 h-5 text-[#0F4C4C]" strokeWidth={1.8} />
                            <span className="text-[11px] font-semibold text-[#0F4C4C] mt-1">
                              Visits
                            </span>
                          </div>

                          {/* Tasks */}
                          <div className="flex flex-col items-center cursor-pointer py-1 group">
                            <ListTodo className="w-5 h-5 text-[#0F4C4C]" strokeWidth={1.8} />
                            <span className="text-[11px] font-semibold text-[#0F4C4C] mt-1">
                              Tasks
                            </span>
                          </div>

                          {/* Profile */}
                          <div className="flex flex-col items-center cursor-pointer py-1 group">
                            <User className="w-5 h-5 text-[#0F4C4C]" strokeWidth={1.8} />
                            <span className="text-[11px] font-semibold text-[#0F4C4C] mt-1">
                              Profile
                            </span>
                          </div>
                        </div>
                      </div>
                    </div>
                  )}

                  {/* If modal is closed, still show bottom nav */}
                  {!isSkipModalOpen && (
                    <div className="bg-white border-t border-[#E5E7EB] px-3 py-2 mt-auto">
                      <div className="flex items-center justify-around">
                        <div onClick={() => setSelectedScreen('dashboard')} className="flex flex-col items-center cursor-pointer py-1">
                          <Home className="w-5 h-5 text-[#0F4C4C]" strokeWidth={1.8} />
                          <span className="text-[11px] font-semibold text-[#0F4C4C] mt-1">Home</span>
                        </div>
                        <div className="flex flex-col items-center cursor-pointer py-1">
                          <UserPlus className="w-5 h-5 text-[#0F4C4C]" strokeWidth={1.8} />
                          <span className="text-[11px] font-semibold text-[#0F4C4C] mt-1">Leads</span>
                        </div>
                        <div className="flex flex-col items-center cursor-pointer py-1">
                          <MapPin className="w-5 h-5 text-[#0F4C4C]" strokeWidth={1.8} />
                          <span className="text-[11px] font-semibold text-[#0F4C4C] mt-1">Visits</span>
                        </div>
                        <div className="flex flex-col items-center cursor-pointer py-1">
                          <ListTodo className="w-5 h-5 text-[#0F4C4C]" strokeWidth={1.8} />
                          <span className="text-[11px] font-semibold text-[#0F4C4C] mt-1">Tasks</span>
                        </div>
                        <div className="flex flex-col items-center cursor-pointer py-1">
                          <User className="w-5 h-5 text-[#0F4C4C]" strokeWidth={1.8} />
                          <span className="text-[11px] font-semibold text-[#0F4C4C] mt-1">Profile</span>
                        </div>
                      </div>
                    </div>
                  )}
                </div>
              ) : selectedScreen === 'success' ? (
                /* SCREEN 8: PASSWORD RESET SUCCESS */
                <div className="flex-1 flex flex-col justify-between px-6 pt-12 pb-8 overflow-y-auto no-scrollbar scroll-smooth">
                  <div className="flex-1 flex flex-col items-center justify-center">
                    {/* Concentric Circular Badge with Crisp White Double Checkmark */}
                    <div className="flex items-center justify-center w-[196px] h-[196px] rounded-full bg-[#D1FADF] animate-fade-in transition-all">
                      <div className="flex items-center justify-center w-[128px] h-[128px] rounded-full bg-[#10B981] shadow-lg shadow-[#10B981]/25">
                        <CheckCheck className="w-14 h-14 text-white stroke-[1.25]" />
                      </div>
                    </div>

                    {/* Title */}
                    <h2 className="mt-9 text-[#0F172A] text-[26px] font-extrabold tracking-tight text-center leading-tight">
                      Password Reset!
                    </h2>

                    {/* Subtitle / Description */}
                    <p className="mt-3 text-[#4B5563] text-[15px] font-normal leading-relaxed text-center px-4 max-w-[320px]">
                      Your password has been successfully reset. You can now sign in with your new password.
                    </p>

                    {/* Primary Action Button: Back to Sign In */}
                    <div className="w-full mt-10">
                      <button
                        type="button"
                        onClick={() => setSelectedScreen('signin')}
                        className="w-full h-[52px] bg-[#0F4C4C] hover:bg-[#0C3E3E] active:scale-[0.99] text-white rounded-xl font-bold text-[16px] transition-all flex items-center justify-center shadow-xs cursor-pointer"
                      >
                        Back to Sign In
                      </button>
                    </div>
                  </div>
                </div>
              ) : selectedScreen === 'reset' ? (
                /* SCREEN 7: RESET PASSWORD SCREEN ("Set New Password") */
                <div className="flex-1 flex flex-col justify-between px-6 pt-5 pb-6 overflow-y-auto no-scrollbar scroll-smooth">
                  <div>
                    {/* Top Bar: Back Button */}
                    <div className="flex items-center justify-between">
                      <button
                        type="button"
                        onClick={() => setSelectedScreen('otp')}
                        className="w-10 h-10 -ml-2 rounded-full flex items-center justify-center text-[#0F172A] hover:bg-gray-100 transition-colors cursor-pointer"
                        title="Back to OTP Verification"
                      >
                        <ChevronLeft className="w-7 h-7" />
                      </button>
                    </div>

                    {/* Feedback Toast */}
                    {resetSuccessMessage && (
                      <div className="mt-3 p-2.5 bg-[#ECFDF5] border border-[#A7F3D0] rounded-xl flex items-center space-x-2 text-xs text-[#065F46] animate-fade-in">
                        <CheckCircle2 className="w-4 h-4 text-[#10B981] shrink-0" />
                        <span className="font-semibold">{resetSuccessMessage}</span>
                      </div>
                    )}

                    {/* Screen Title & Subtitle */}
                    <div className="mt-5">
                      <h2 className="text-[#0F172A] text-[26px] font-extrabold tracking-tight leading-tight">
                        Set New Password
                      </h2>
                      <p className="text-[#64748B] text-[14px] font-normal mt-2 leading-relaxed">
                        Your new password must be different from previous used passwords.
                      </p>
                    </div>

                    {/* Field 1: New Password */}
                    <div className="mt-7">
                      <label className="block text-[13.5px] font-semibold text-[#0F172A] mb-2">
                        New Password
                      </label>
                      <div
                        className={`h-[52px] rounded-xl px-4 flex items-center transition-all border ${
                          resetNewError
                            ? 'bg-[#FDE8E8] border-[#F87171] focus-within:ring-2 focus-within:ring-[#F87171]/20'
                            : 'bg-white border-[#E2E8F0] focus-within:border-[#0F4C4C] focus-within:ring-2 focus-within:ring-[#0F4C4C]/10'
                        }`}
                      >
                        <input
                          type={resetObscureNew ? 'password' : 'text'}
                          value={resetNewPassword}
                          onChange={(e) => {
                            const val = e.target.value;
                            setResetNewPassword(val);
                            if (val.length > 0) {
                              setResetNewTouched(true);
                            } else if (!resetAttempted) {
                              setResetNewTouched(false);
                            }
                          }}
                          placeholder="Enter new password"
                          className="flex-1 bg-transparent text-[#0F172A] text-[15px] font-medium outline-none placeholder-[#94A3B8]"
                        />
                        <button
                          type="button"
                          onClick={() => setResetObscureNew(!resetObscureNew)}
                          className="p-1 text-[#64748B] hover:text-[#0F172A] transition-colors cursor-pointer"
                        >
                          {resetObscureNew ? (
                            <EyeOff className="w-5 h-5" />
                          ) : (
                            <Eye className="w-5 h-5" />
                          )}
                        </button>
                      </div>
                      {resetNewError && (
                        <p className="text-[12px] text-[#EF4444] mt-1.5 font-medium">
                          {resetNewError}
                        </p>
                      )}
                    </div>

                    {/* Password Strength Section */}
                    {resetNewPassword.length > 0 && (
                      <div className="mt-4">
                        <div className="flex items-center justify-between mb-1.5">
                          <span className="text-[13px] font-semibold text-[#334155]">
                            Password Strength
                          </span>
                          <span
                            className="text-[13px] font-bold"
                            style={{ color: resetStrengthColor }}
                          >
                            {resetStrengthLabel}
                          </span>
                        </div>
                        <div className="w-full h-1 bg-[#E2E8F0] rounded-full overflow-hidden">
                          <div
                            className="h-full rounded-full transition-all duration-300"
                            style={{
                              width: `${resetStrengthPercent}%`,
                              backgroundColor: resetStrengthColor,
                            }}
                          />
                        </div>
                      </div>
                    )}

                    {/* Field 2: Confirm New Password */}
                    <div className="mt-4">
                      <label className="block text-[13.5px] font-semibold text-[#0F172A] mb-2">
                        Confirm New Password
                      </label>
                      <div
                        className={`h-[52px] rounded-xl px-4 flex items-center transition-all border ${
                          resetConfirmError
                            ? 'bg-[#FDE8E8] border-[#F87171] focus-within:ring-2 focus-within:ring-[#F87171]/20'
                            : 'bg-white border-[#E2E8F0] focus-within:border-[#0F4C4C] focus-within:ring-2 focus-within:ring-[#0F4C4C]/10'
                        }`}
                      >
                        <input
                          type={resetObscureConfirm ? 'password' : 'text'}
                          value={resetConfirmPassword}
                          onChange={(e) => {
                            const val = e.target.value;
                            setResetConfirmPassword(val);
                            if (val.length > 0) {
                              setResetConfirmTouched(true);
                            } else if (!resetAttempted) {
                              setResetConfirmTouched(false);
                            }
                          }}
                          placeholder="Confirm new password"
                          className="flex-1 bg-transparent text-[#0F172A] text-[15px] font-medium outline-none placeholder-[#94A3B8]"
                        />
                        <button
                          type="button"
                          onClick={() => setResetObscureConfirm(!resetObscureConfirm)}
                          className="p-1 text-[#64748B] hover:text-[#0F172A] transition-colors cursor-pointer"
                        >
                          {resetObscureConfirm ? (
                            <EyeOff className="w-5 h-5" />
                          ) : (
                            <Eye className="w-5 h-5" />
                          )}
                        </button>
                      </div>
                      {resetConfirmError && (
                        <p className="text-[12px] text-[#EF4444] mt-1.5 font-medium">
                          {resetConfirmError}
                        </p>
                      )}
                    </div>

                    {/* Requirements Checklist */}
                    <div className="mt-5 space-y-2.5">
                      <div className="flex items-center space-x-2.5">
                        {resetRuleLength ? (
                          <Check className="w-4 h-4 text-[#10B981] stroke-[2.5]" />
                        ) : (
                          <div className="w-4 h-4 rounded-full border border-[#94A3B8]" />
                        )}
                        <span
                          className={`text-[13.5px] ${
                            resetRuleLength ? 'text-[#334155] font-medium' : 'text-[#64748B]'
                          }`}
                        >
                          At least 8 characters long
                        </span>
                      </div>

                      <div className="flex items-center space-x-2.5">
                        {resetRuleUpperLower ? (
                          <Check className="w-4 h-4 text-[#10B981] stroke-[2.5]" />
                        ) : (
                          <div className="w-4 h-4 rounded-full border border-[#94A3B8]" />
                        )}
                        <span
                          className={`text-[13.5px] ${
                            resetRuleUpperLower ? 'text-[#334155] font-medium' : 'text-[#64748B]'
                          }`}
                        >
                          Includes uppercase & lowercase
                        </span>
                      </div>

                      <div className="flex items-center space-x-2.5">
                        {resetRuleNumber ? (
                          <Check className="w-4 h-4 text-[#10B981] stroke-[2.5]" />
                        ) : (
                          <div className="w-4 h-4 rounded-full border border-[#94A3B8]" />
                        )}
                        <span
                          className={`text-[13.5px] ${
                            resetRuleNumber ? 'text-[#334155] font-medium' : 'text-[#64748B]'
                          }`}
                        >
                          Includes a number
                        </span>
                      </div>

                      <div className="flex items-center space-x-2.5">
                        {resetRuleSpecial ? (
                          <Check className="w-4 h-4 text-[#10B981] stroke-[2.5]" />
                        ) : (
                          <div className="w-4 h-4 rounded-full border border-[#94A3B8]" />
                        )}
                        <span
                          className={`text-[13.5px] ${
                            resetRuleSpecial ? 'text-[#334155] font-medium' : 'text-[#64748B]'
                          }`}
                        >
                          Includes a special character
                        </span>
                      </div>
                    </div>

                    {/* Primary CTA Button: Reset Password */}
                    <div className="mt-8">
                      <button
                        type="button"
                        onClick={handleResetPasswordSubmit}
                        disabled={!isResetFormValid || resetLoading}
                        className={`w-full h-[52px] rounded-xl font-bold text-[16px] transition-all flex items-center justify-center shadow-xs ${
                          !isResetFormValid || resetLoading
                            ? 'bg-[#0F4C4C]/40 text-white/70 cursor-not-allowed'
                            : 'bg-[#0F4C4C] hover:bg-[#0C3E3E] active:scale-[0.99] text-white cursor-pointer'
                        }`}
                      >
                        {resetLoading ? (
                          <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin" />
                        ) : (
                          'Reset Password'
                        )}
                      </button>
                    </div>
                  </div>
                </div>
              ) : selectedScreen === 'otp' ? (
                /* SCREEN 6: OTP VERIFICATION SCREEN */
                <div className="flex-1 flex flex-col justify-between px-6 pt-5 pb-6 overflow-y-auto no-scrollbar scroll-smooth">
                  <div>
                    {/* Back Button */}
                    <div>
                      <button
                        type="button"
                        onClick={() => setSelectedScreen('forgot')}
                        className="w-10 h-10 -ml-2 rounded-full flex items-center justify-center text-[#1E293B] hover:bg-gray-100 transition-colors cursor-pointer"
                        title="Back to Forgot Password"
                      >
                        <ChevronLeft className="w-7 h-7" />
                      </button>
                    </div>

                    {/* Feedback Toast */}
                    {otpSuccessMessage && (
                      <div className="mt-2 p-2.5 bg-[#ECFDF5] border border-[#A7F3D0] rounded-xl flex items-center space-x-2 text-xs text-[#065F46] animate-fade-in">
                        <CheckCircle2 className="w-4 h-4 text-[#10B981] shrink-0" />
                        <span className="font-semibold">{otpSuccessMessage}</span>
                      </div>
                    )}

                    {/* Graphic Badge: 120x120 Mint Circle with Shield-Check */}
                    <div className="flex justify-center pt-6 pb-7">
                      <div className="w-[120px] h-[120px] rounded-full bg-[#E8F5F3] flex items-center justify-center shadow-xs">
                        <svg
                          className="w-12 h-14 text-[#0F4C4C]"
                          viewBox="0 0 38 44"
                          fill="none"
                          stroke="currentColor"
                          strokeWidth="2.8"
                          strokeLinecap="round"
                          strokeLinejoin="round"
                        >
                          <path d="M19 2L36 7.5V23C36 32.5 28 39 19 42C10 39 2 32.5 2 23V7.5L19 2Z" />
                          <path d="M13 22L17.5 26.5L25.5 16.5" />
                        </svg>
                      </div>
                    </div>

                    {/* Screen Headline */}
                    <div className="text-center px-2">
                      <h2 className="text-[#0F172A] text-[26px] font-extrabold tracking-tight">
                        Verify Your Identity
                      </h2>
                      <p className="text-[#64748B] text-[15px] font-normal mt-2.5 leading-relaxed">
                        We sent a 6-digit code to{' '}
                        <strong className="text-[#0F172A] font-bold">
                          {forgotEmail.trim() ? forgotEmail.trim() : 'j***@company.com'}
                        </strong>
                      </p>
                    </div>

                    {/* 6-Digit OTP Input Row */}
                    <div className="mt-8">
                      <div className="flex justify-between items-center px-1">
                        {otpDigits.map((digit, index) => {
                          const isFocused = focusedIndex === index;
                          const hasError = otpError !== null;
                          return (
                            <input
                              key={index}
                              ref={(el) => {
                                otpInputRefs.current[index] = el;
                              }}
                              type="text"
                              inputMode="numeric"
                              pattern="[0-9]*"
                              maxLength={1}
                              value={digit}
                              onFocus={() => {
                                setFocusedIndex(index);
                                setActiveOtpIndex(index);
                              }}
                              onBlur={() => setFocusedIndex(null)}
                              onChange={(e) => handleOtpChange(index, e.target.value)}
                              onKeyDown={(e) => handleOtpKeyDown(index, e)}
                              className={`w-[48px] h-[58px] text-center text-[22px] font-extrabold rounded-xl border transition-all outline-none ${
                                hasError
                                  ? 'border-[#EF4444] text-[#0F172A] bg-white focus:border-[#EF4444] focus:ring-2 focus:ring-[#EF4444]/20'
                                  : isFocused
                                  ? 'border-[#0F4C4C] text-[#0F172A] bg-white ring-2 ring-[#0F4C4C]/20 shadow-xs'
                                  : digit
                                  ? 'border-[#CBD5E1] text-[#0F172A] bg-white'
                                  : 'border-[#E2E8F0] text-[#0F172A] bg-white'
                              }`}
                            />
                          );
                        })}
                      </div>

                      {/* Validation Error Message */}
                      {otpError && (
                        <div className="mt-3.5 flex items-center justify-center space-x-1.5 text-xs text-[#EF4444]">
                          <AlertTriangle className="w-3.5 h-3.5 shrink-0" />
                          <span className="font-medium">{otpError}</span>
                        </div>
                      )}

                      {/* Resend Code Row */}
                      <div className="mt-5 text-center">
                        <span className="text-xs text-[#64748B]">Didn&apos;t receive? </span>
                        <button
                          type="button"
                          onClick={handleOtpResend}
                          disabled={otpCountdown > 0 || otpLoading}
                          className={`text-xs font-bold transition-colors cursor-pointer ${
                            otpCountdown > 0
                              ? 'text-[#0F4C4C] cursor-not-allowed opacity-90'
                              : 'text-[#0F4C4C] underline hover:text-[#0C3E3E]'
                          }`}
                        >
                          {otpCountdown > 0
                            ? `Resend (${formatCountdown(otpCountdown)})`
                            : 'Resend Code'}
                        </button>
                      </div>

                      {/* Primary CTA: Verify Code Button */}
                      <div className="mt-7">
                        <button
                          type="button"
                          onClick={handleVerifyOtp}
                          disabled={isVerifyDisabled}
                          className={`w-full h-[52px] rounded-xl font-bold text-[16px] transition-all flex items-center justify-center shadow-xs ${
                            isVerifyDisabled
                              ? 'bg-[#0F4C4C]/40 text-white/70 cursor-not-allowed'
                              : 'bg-[#0F4C4C] hover:bg-[#0C3E3E] active:scale-[0.99] text-white cursor-pointer'
                          }`}
                        >
                          {otpLoading ? (
                            <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin" />
                          ) : (
                            'Verify Code'
                          )}
                        </button>
                      </div>
                    </div>
                  </div>

                  {/* Bottom Footer: Back to Sign In */}
                  <div className="text-center pt-5 pb-2">
                    <p className="text-xs text-[#64748B] font-medium">
                      Back to{' '}
                      <button
                        type="button"
                        onClick={() => setSelectedScreen('signin')}
                        className="font-bold text-[#0F4C4C] hover:underline cursor-pointer"
                      >
                        Sign In
                      </button>
                    </p>
                  </div>
                </div>
              ) : selectedScreen === 'forgot' ? (
                /* SCREEN 5: FORGOT PASSWORD SCREEN */
                <div className="flex-1 flex flex-col justify-between px-6 pt-5 pb-6 overflow-y-auto no-scrollbar scroll-smooth">
                  <div>
                    {/* Back Button */}
                    <div>
                      <button
                        type="button"
                        onClick={() => setSelectedScreen('signin')}
                        className="w-10 h-10 -ml-2 rounded-full flex items-center justify-center text-[#1E293B] hover:bg-gray-100 transition-colors cursor-pointer"
                        title="Back to Sign In"
                      >
                        <ChevronLeft className="w-7 h-7" />
                      </button>
                    </div>

                    {/* Feedback Toast */}
                    {forgotSuccessMessage && (
                      <div className="mt-2 p-2.5 bg-[#ECFDF5] border border-[#A7F3D0] rounded-xl flex items-center space-x-2 text-xs text-[#065F46] animate-fade-in">
                        <CheckCircle2 className="w-4 h-4 text-[#10B981] shrink-0" />
                        <span className="font-medium">{forgotSuccessMessage}</span>
                      </div>
                    )}

                    {/* Lock Graphic Badge */}
                    <div className="flex justify-center pt-8 pb-7">
                      <div className="w-[120px] h-[120px] rounded-full bg-[#E8F5F3] flex items-center justify-center shadow-xs">
                        <svg
                          className="w-12 h-14 text-[#0F4C4C]"
                          viewBox="0 0 28 32"
                          fill="none"
                          stroke="currentColor"
                          strokeWidth="2.5"
                          strokeLinecap="round"
                          strokeLinejoin="round"
                        >
                          {/* Arched Shackle */}
                          <path d="M7 13V8.5a7 7 0 0 1 14 0V13" />
                          {/* Rounded Body */}
                          <rect x="3" y="13" width="22" height="16" rx="5" />
                          {/* Keyhole */}
                          <circle cx="14" cy="20" r="1.8" fill="currentColor" />
                          <path d="M14 21.8v2.6" strokeWidth="2.4" />
                        </svg>
                      </div>
                    </div>

                    {/* Screen Headline */}
                    <div className="text-center px-2">
                      <h2 className="text-[#0F172A] text-[26px] font-extrabold tracking-tight">
                        Forgot Password?
                      </h2>
                      <p className="text-[#64748B] text-[15px] font-normal mt-3 leading-relaxed max-w-[310px] mx-auto">
                        Enter your registered email below. We&apos;ll send you a 6-digit verification code to reset your password.
                      </p>
                    </div>

                    {/* Form Section */}
                    <form onSubmit={handleForgotSubmit} className="mt-8">
                      <div>
                        <label className="block text-sm font-semibold text-[#334155] mb-2">
                          Email Address
                        </label>

                        <div
                          className={`h-[52px] rounded-xl border flex items-center px-3.5 bg-white transition-all ${
                            forgotEmailError
                              ? 'border-[#EF4444] ring-1 ring-[#EF4444]'
                              : 'border-[#E2E8F0] focus-within:border-[#0F4C4C]'
                          }`}
                        >
                          <Mail className="w-5 h-5 text-[#64748B] shrink-0 mr-3" />
                          <input
                            type="email"
                            value={forgotEmail}
                            onChange={(e) => setForgotEmail(e.target.value)}
                            placeholder="john.sales@company.com"
                            className="w-full text-[15px] text-[#0F172A] placeholder-[#94A3B8] outline-hidden bg-transparent"
                          />
                        </div>

                        {forgotEmailError && (
                          <p className="text-[13px] text-[#EF4444] mt-1.5 font-normal">
                            {forgotEmailError}
                          </p>
                        )}
                      </div>

                      {/* Send Verification Code CTA */}
                      <div className="pt-6">
                        <button
                          type="submit"
                          disabled={forgotLoading}
                          className="w-full h-[52px] bg-[#0F4C4C] hover:bg-[#0C3E3E] active:scale-[0.99] text-white rounded-xl font-bold text-[16px] transition-all flex items-center justify-center shadow-xs cursor-pointer disabled:opacity-75"
                        >
                          {forgotLoading ? (
                            <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin" />
                          ) : (
                            'Send Verification Code'
                          )}
                        </button>
                      </div>
                    </form>
                  </div>

                  {/* Bottom Footer Section */}
                  <div className="pt-6 pb-2">
                    <div className="text-center">
                      <p className="text-[14px] text-[#64748B]">
                        Remember your password?{' '}
                        <button
                          type="button"
                          onClick={() => setSelectedScreen('signin')}
                          className="font-bold text-[#0F4C4C] hover:underline cursor-pointer"
                        >
                          Sign In
                        </button>
                      </p>
                    </div>
                  </div>
                </div>
              ) : selectedScreen === 'verification' ? (
                /* SCREEN 4: EMAIL VERIFICATION SCREEN */
                <div className="flex-1 flex flex-col justify-between px-6 pt-5 pb-6 overflow-y-auto no-scrollbar scroll-smooth">
                  <div>
                    {/* Back Button */}
                    <div>
                      <button
                        type="button"
                        onClick={() => setSelectedScreen('signup')}
                        className="w-10 h-10 -ml-2 rounded-full flex items-center justify-center text-[#1E293B] hover:bg-gray-100 transition-colors cursor-pointer"
                        title="Back to Sign Up"
                      >
                        <ChevronLeft className="w-7 h-7" />
                      </button>
                    </div>

                    {/* Feedback Toast */}
                    {verificationFeedback && (
                      <div className="mt-2 p-2.5 bg-[#ECFDF5] border border-[#A7F3D0] rounded-xl flex items-center space-x-2 text-xs text-[#065F46] animate-fade-in">
                        <CheckCircle2 className="w-4 h-4 text-[#10B981] shrink-0" />
                        <span className="font-medium">{verificationFeedback}</span>
                      </div>
                    )}

                    {/* Verified Shield Graphic Badge */}
                    <div className="flex justify-center pt-8 pb-7">
                      <div className="w-[120px] h-[120px] rounded-full bg-[#E8F5F3] flex items-center justify-center shadow-xs">
                        <svg
                          className="w-12 h-14 text-[#0F4C4C]"
                          viewBox="0 0 24 26"
                          fill="none"
                          stroke="currentColor"
                          strokeWidth="2.4"
                          strokeLinecap="round"
                          strokeLinejoin="round"
                        >
                          <path d="M12 2L21 5.5V13C21 18.5 16.5 22.5 12 24C7.5 22.5 3 18.5 3 13V5.5L12 2Z" />
                          <path d="M8.5 13L11 15.5L16 10" />
                        </svg>
                      </div>
                    </div>

                    {/* Screen Headline */}
                    <div className="text-center px-2">
                      <h2 className="text-[#0F172A] text-[26px] font-extrabold tracking-tight">
                        Verify Your Email
                      </h2>
                      <p className="text-[#64748B] text-[15px] font-normal mt-3 leading-relaxed">
                        We&apos;ve sent a verification link to<br />
                        <strong className="text-[#0F172A] font-bold">{maskedEmail}</strong>. Please check your inbox.
                      </p>
                    </div>

                    {/* Buttons */}
                    <div className="mt-9 space-y-3.5">
                      {/* Open Email App */}
                      <button
                        type="button"
                        onClick={handleOpenEmailApp}
                        className="w-full h-[52px] bg-[#0F4C4C] hover:bg-[#0C3E3E] active:scale-[0.99] text-white rounded-xl font-bold text-[16px] transition-all flex items-center justify-center shadow-xs cursor-pointer"
                      >
                        Open Email App
                      </button>

                      {/* Resend Email */}
                      <button
                        type="button"
                        onClick={handleResendEmail}
                        disabled={countdown > 0 && !isResending}
                        className={`w-full h-[52px] rounded-xl font-bold text-[16px] transition-all flex items-center justify-center cursor-pointer ${
                          countdown === 0 || isResending
                            ? 'bg-white border-1.5 border-[#0F4C4C] text-[#0F4C4C] hover:bg-[#F9FAFB] active:scale-[0.99]'
                            : 'bg-white border-1.5 border-[#CBD5E1] text-[#94A3B8] cursor-not-allowed opacity-90'
                        }`}
                      >
                        {isResending ? (
                          <div className="flex items-center space-x-2">
                            <RotateCcw className="w-4 h-4 animate-spin text-[#0F4C4C]" />
                            <span className="text-[#0F4C4C]">Sending...</span>
                          </div>
                        ) : (
                          'Resend Email'
                        )}
                      </button>
                    </div>

                    {/* Countdown indicator */}
                    <div className="mt-4 text-center">
                      <p className="text-[14px] text-[#64748B]">
                        Resend link available in{' '}
                        <strong className="text-[#0F4C4C] font-bold">
                          {formatCountdown(countdown)}
                        </strong>
                      </p>
                    </div>
                  </div>

                  {/* Bottom Footer Section */}
                  <div className="pt-6 pb-2">
                    <div className="text-center">
                      <p className="text-[14px] text-[#64748B]">
                        Back to{' '}
                        <button
                          type="button"
                          onClick={() => setSelectedScreen('signin')}
                          className="font-bold text-[#0F4C4C] hover:underline cursor-pointer"
                        >
                          Sign In
                        </button>
                      </p>
                    </div>
                  </div>
                </div>
              ) : selectedScreen === 'signup' ? (
                /* SCREEN 3: SIGN UP SCREEN */
                <div className="flex-1 flex flex-col px-6 py-6 overflow-y-auto no-scrollbar scroll-smooth">
                  {/* 1. Top Logo Row */}
                  <div className="flex items-center space-x-3 pt-1">
                    <div className="w-11 h-11 rounded-[14px] bg-[#0F4C4C] text-white flex items-center justify-center font-extrabold text-lg tracking-tight shadow-xs">
                      LP
                    </div>
                    <span className="text-[#0F4C4C] font-extrabold text-[19px] tracking-tight">
                      CRM Pro
                    </span>
                  </div>

                  {/* 2. Headings */}
                  <div className="mt-7">
                    <h2 className="text-[#111827] text-[28px] font-extrabold tracking-tight leading-tight">
                      Create Account
                    </h2>
                    <p className="text-[#4B5563] text-[15px] font-normal mt-1">
                      Register to join the field sales network.
                    </p>
                  </div>

                  {/* 3. Form */}
                  <form onSubmit={handleSignUpSubmit} className="mt-6 space-y-3.5">
                    {/* Full Name */}
                    <div>
                      <label className="block text-sm font-semibold text-[#111827] mb-1.5">
                        Full Name
                      </label>
                      <div
                        className={`h-[52px] rounded-xl border flex items-center px-3.5 bg-white transition-all ${
                          fullNameError
                            ? 'border-[#EF4444] ring-1 ring-[#EF4444]'
                            : 'border-[#E5E7EB] focus-within:border-[#0F4C4C]'
                        }`}
                      >
                        <User className="w-5 h-5 text-[#9CA3AF] shrink-0 mr-2.5" />
                        <input
                          type="text"
                          value={fullName}
                          onChange={(e) => setFullName(e.target.value)}
                          placeholder="e.g. John Doe"
                          className="w-full text-sm text-[#111827] placeholder-[#9CA3AF] outline-hidden bg-transparent"
                        />
                      </div>
                      {fullNameError && (
                        <p className="text-[12px] text-[#EF4444] mt-1 font-normal">
                          {fullNameError}
                        </p>
                      )}
                    </div>

                    {/* Email Address */}
                    <div>
                      <label className="block text-sm font-semibold text-[#111827] mb-1.5">
                        Email Address
                      </label>
                      <div
                        className={`h-[52px] rounded-xl border flex items-center px-3.5 bg-white transition-all ${
                          signUpEmailError
                            ? 'border-[#EF4444] ring-1 ring-[#EF4444]'
                            : 'border-[#E5E7EB] focus-within:border-[#0F4C4C]'
                        }`}
                      >
                        <Mail className="w-5 h-5 text-[#9CA3AF] shrink-0 mr-2.5" />
                        <input
                          type="text"
                          value={signUpEmail}
                          onChange={(e) => setSignUpEmail(e.target.value)}
                          placeholder="e.g. john@company.com"
                          className="w-full text-sm text-[#111827] placeholder-[#9CA3AF] outline-hidden bg-transparent"
                        />
                      </div>
                      {signUpEmailError && (
                        <p className="text-[12px] text-[#EF4444] mt-1 font-normal">
                          {signUpEmailError}
                        </p>
                      )}
                    </div>

                    {/* Phone Number (Country code + input) */}
                    <div>
                      <label className="block text-sm font-semibold text-[#111827] mb-1.5">
                        Phone Number
                      </label>
                      <div className="flex space-x-2.5">
                        {/* Country code picker */}
                        <div className="relative">
                          <button
                            type="button"
                            onClick={() => setShowCountryDropdown(!showCountryDropdown)}
                            className={`h-[52px] w-[86px] rounded-xl border flex items-center justify-between px-3 bg-white transition-all ${
                              phoneError ? 'border-[#EF4444] ring-1 ring-[#EF4444]' : 'border-[#E5E7EB]'
                            }`}
                          >
                            <span className="text-sm font-bold text-[#111827]">{countryCode}</span>
                            <ChevronDown className="w-4 h-4 text-[#6B7280]" />
                          </button>
                          {showCountryDropdown && (
                            <div className="absolute top-14 left-0 w-24 bg-white border border-[#E5E7EB] rounded-xl shadow-lg z-20 py-1">
                              {countryCodes.map((code) => (
                                <button
                                  key={code}
                                  type="button"
                                  onClick={() => {
                                    setCountryCode(code);
                                    setShowCountryDropdown(false);
                                  }}
                                  className="w-full px-3 py-1.5 text-left text-xs font-semibold hover:bg-[#F3F4F6]"
                                >
                                  {code}
                                </button>
                              ))}
                            </div>
                          )}
                        </div>

                        {/* Phone text input */}
                        <div
                          className={`flex-1 h-[52px] rounded-xl border flex items-center px-3.5 bg-white transition-all ${
                            phoneError
                              ? 'border-[#EF4444] ring-1 ring-[#EF4444]'
                              : 'border-[#E5E7EB] focus-within:border-[#0F4C4C]'
                          }`}
                        >
                          <input
                            type="tel"
                            value={phone}
                            onChange={(e) => setPhone(e.target.value)}
                            placeholder="98765 43210"
                            className="w-full text-sm text-[#111827] placeholder-[#9CA3AF] outline-hidden bg-transparent"
                          />
                        </div>
                      </div>
                      {phoneError && (
                        <p className="text-[12px] text-[#EF4444] mt-1 font-normal">
                          {phoneError}
                        </p>
                      )}
                    </div>

                    {/* Company Name */}
                    <div>
                      <label className="block text-sm font-semibold text-[#111827] mb-1.5">
                        Company Name
                      </label>
                      <div
                        className={`h-[52px] rounded-xl border flex items-center px-3.5 bg-white transition-all ${
                          companyError
                            ? 'border-[#EF4444] ring-1 ring-[#EF4444]'
                            : 'border-[#E5E7EB] focus-within:border-[#0F4C4C]'
                        }`}
                      >
                        <Briefcase className="w-5 h-5 text-[#9CA3AF] shrink-0 mr-2.5" />
                        <input
                          type="text"
                          value={companyName}
                          onChange={(e) => setCompanyName(e.target.value)}
                          placeholder="e.g. Acme Corp"
                          className="w-full text-sm text-[#111827] placeholder-[#9CA3AF] outline-hidden bg-transparent"
                        />
                      </div>
                      {companyError && (
                        <p className="text-[12px] text-[#EF4444] mt-1 font-normal">
                          {companyError}
                        </p>
                      )}
                    </div>

                    {/* Designation Dropdown */}
                    <div className="relative">
                      <label className="block text-sm font-semibold text-[#111827] mb-1.5">
                        Designation
                      </label>
                      <button
                        type="button"
                        onClick={() => setShowDesignationDropdown(!showDesignationDropdown)}
                        className={`w-full h-[52px] rounded-xl border flex items-center justify-between px-3.5 bg-white transition-all text-left ${
                          designationError
                            ? 'border-[#EF4444] ring-1 ring-[#EF4444]'
                            : 'border-[#E5E7EB]'
                        }`}
                      >
                        <div className="flex items-center space-x-2.5">
                          <Award className="w-5 h-5 text-[#9CA3AF] shrink-0" />
                          <span
                            className={`text-sm ${
                              designation ? 'text-[#111827] font-medium' : 'text-[#9CA3AF]'
                            }`}
                          >
                            {designation || 'Select Designation'}
                          </span>
                        </div>
                        <ChevronDown className="w-4 h-4 text-[#6B7280]" />
                      </button>
                      {showDesignationDropdown && (
                        <div className="absolute top-[80px] left-0 right-0 bg-white border border-[#E5E7EB] rounded-xl shadow-xl z-30 py-1.5 max-h-48 overflow-y-auto">
                          {designations.map((desig) => (
                            <button
                              key={desig}
                              type="button"
                              onClick={() => {
                                setDesignation(desig);
                                setShowDesignationDropdown(false);
                              }}
                              className="w-full px-4 py-2.5 text-left text-sm text-[#111827] hover:bg-[#F3F4F6] flex items-center justify-between"
                            >
                              <span>{desig}</span>
                              {designation === desig && (
                                <Check className="w-4 h-4 text-[#0F4C4C]" />
                              )}
                            </button>
                          ))}
                        </div>
                      )}
                      {designationError && (
                        <p className="text-[12px] text-[#EF4444] mt-1 font-normal">
                          {designationError}
                        </p>
                      )}
                    </div>

                    {/* Primary CTA Button: Create Account */}
                    <div className="pt-2">
                      <button
                        type="submit"
                        className="w-full h-[52px] bg-[#0F4C4C] hover:bg-[#0C3E3E] active:scale-[0.99] text-white rounded-xl font-bold text-[16px] transition-all flex items-center justify-center shadow-xs"
                      >
                        Create Account
                      </button>
                    </div>
                  </form>

                  {/* Divider: OR SIGN UP WITH */}
                  <div className="flex items-center my-5">
                    <div className="flex-1 border-t border-[#E5E7EB]" />
                    <span className="px-3 text-[11px] font-semibold text-[#6B7280] tracking-wider uppercase">
                      OR SIGN UP WITH
                    </span>
                    <div className="flex-1 border-t border-[#E5E7EB]" />
                  </div>

                  {/* Secondary Outlined CTA: Company SSO */}
                  <button
                    type="button"
                    className="w-full h-[52px] bg-white border border-[#E5E7EB] hover:bg-[#F9FAFB] active:scale-[0.99] text-[#111827] rounded-xl font-bold text-[15px] transition-all flex items-center justify-center space-x-2.5 shadow-2xs"
                  >
                    <Building2 className="w-5 h-5 text-[#0F4C4C]" />
                    <span>Company SSO</span>
                  </button>

                  {/* Bottom Footer: Already have an account? Sign In */}
                  <div className="pt-6 pb-4 text-center">
                    <p className="text-[13.5px] text-[#4B5563]">
                      Already have an account?{' '}
                      <button
                        type="button"
                        onClick={() => setSelectedScreen('signin')}
                        className="font-bold text-[#0F4C4C] hover:underline cursor-pointer"
                      >
                        Sign In
                      </button>
                    </p>
                  </div>
                </div>
              ) : selectedScreen === 'signin' ? (
                /* SCREEN 2: SIGN IN SCREEN */
                <div className="flex-1 flex flex-col justify-between px-6 py-7 overflow-y-auto no-scrollbar scroll-smooth">
                  <div>
                    {/* Top Logo Row */}
                    <div className="flex items-center space-x-3 pt-2">
                      <div className="w-11 h-11 rounded-[14px] bg-[#0F4C4C] text-white flex items-center justify-center font-extrabold text-lg tracking-tight shadow-xs">
                        LP
                      </div>
                      <span className="text-[#0F4C4C] font-extrabold text-[19px] tracking-tight">
                        CRM Pro
                      </span>
                    </div>

                    {/* Headings */}
                    <div className="mt-8">
                      <h2 className="text-[#111827] text-[28px] font-extrabold tracking-tight leading-tight">
                        Welcome Back
                      </h2>
                      <p className="text-[#4B5563] text-[15px] font-normal mt-1.5">
                        Sign in to continue your field work.
                      </p>
                    </div>

                    {/* Form */}
                    <form onSubmit={handleSignInSubmit} className="mt-7 space-y-4">
                      {/* Email Address */}
                      <div>
                        <label className="block text-sm font-semibold text-[#111827] mb-2">
                          Email Address
                        </label>
                        <div
                          className={`h-[52px] rounded-xl border flex items-center px-3.5 bg-white transition-all ${
                            signInEmailError
                              ? 'border-[#EF4444] ring-1 ring-[#EF4444]'
                              : 'border-[#E5E7EB] focus-within:border-[#0F4C4C]'
                          }`}
                        >
                          <Mail className="w-5 h-5 text-[#9CA3AF] shrink-0 mr-2.5" />
                          <input
                            type="text"
                            value={signInEmail}
                            onChange={(e) => setSignInEmail(e.target.value)}
                            placeholder="e.g. john@company.com"
                            className="w-full text-sm text-[#111827] placeholder-[#9CA3AF] outline-hidden bg-transparent"
                          />
                        </div>
                        {signInEmailError && (
                          <p className="text-[12px] text-[#EF4444] mt-1.5 font-normal">
                            {signInEmailError}
                          </p>
                        )}
                      </div>

                      {/* Password */}
                      <div>
                        <label className="block text-sm font-semibold text-[#111827] mb-2">
                          Password
                        </label>
                        <div
                          className={`h-[52px] rounded-xl border flex items-center px-3.5 bg-white transition-all ${
                            signInPasswordError
                              ? 'border-[#EF4444] ring-1 ring-[#EF4444]'
                              : 'border-[#E5E7EB] focus-within:border-[#0F4C4C]'
                          }`}
                        >
                          <Lock className="w-5 h-5 text-[#9CA3AF] shrink-0 mr-2.5" />
                          <input
                            type={showSignInPassword ? 'text' : 'password'}
                            value={signInPassword}
                            onChange={(e) => setSignInPassword(e.target.value)}
                            placeholder="Enter your password"
                            className="w-full text-sm text-[#111827] placeholder-[#9CA3AF] outline-hidden bg-transparent"
                          />
                          <button
                            type="button"
                            onClick={() => setShowSignInPassword(!showSignInPassword)}
                            className="text-[#9CA3AF] hover:text-[#4B5563] ml-2 focus:outline-hidden"
                          >
                            {showSignInPassword ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
                          </button>
                        </div>
                        {signInPasswordError && (
                          <p className="text-[12px] text-[#EF4444] mt-1.5 font-normal">
                            {signInPasswordError}
                          </p>
                        )}
                      </div>

                      {/* Forgot Password */}
                      <div className="flex justify-end pt-0.5">
                        <button
                          type="button"
                          onClick={() => setSelectedScreen('forgot')}
                          className="text-sm font-bold text-[#0F4C4C] hover:underline cursor-pointer"
                        >
                          Forgot Password?
                        </button>
                      </div>

                      {/* Primary CTA */}
                      <div className="pt-2">
                        <button
                          type="submit"
                          className="w-full h-[52px] bg-[#0F4C4C] hover:bg-[#0C3E3E] active:scale-[0.99] text-white rounded-xl font-bold text-[16px] transition-all flex items-center justify-center shadow-xs"
                        >
                          Sign In
                        </button>
                      </div>
                    </form>

                    {/* Divider */}
                    <div className="flex items-center my-6">
                      <div className="flex-1 border-t border-[#E5E7EB]" />
                      <span className="px-3 text-[11px] font-semibold text-[#6B7280] tracking-wider uppercase">
                        OR SIGN IN WITH
                      </span>
                      <div className="flex-1 border-t border-[#E5E7EB]" />
                    </div>

                    {/* Secondary Auth Options */}
                    <div className="space-y-2.5">
                      <button
                        type="button"
                        onClick={() => {
                          setSelectedScreen('biometric');
                          setBiometricSuccess(false);
                          setBiometricScanning(false);
                        }}
                        className="w-full h-[52px] bg-white border border-[#E5E7EB] hover:bg-[#F9FAFB] active:scale-[0.99] text-[#111827] rounded-xl font-bold text-[15px] transition-all flex items-center justify-center space-x-2.5 shadow-2xs cursor-pointer"
                      >
                        <ScanFace className="w-5 h-5 text-[#0F4C4C]" />
                        <span>Sign in with Face ID</span>
                      </button>

                      <button
                        type="button"
                        className="w-full h-[52px] bg-white border border-[#E5E7EB] hover:bg-[#F9FAFB] active:scale-[0.99] text-[#111827] rounded-xl font-bold text-[15px] transition-all flex items-center justify-center space-x-2.5 shadow-2xs"
                      >
                        <Building2 className="w-5 h-5 text-[#0F4C4C]" />
                        <span>Company SSO</span>
                      </button>
                    </div>
                  </div>

                  {/* Footer */}
                  <div className="pt-8 pb-3 text-center">
                    <p className="text-[13.5px] text-[#4B5563]">
                      Don&apos;t have an account?{' '}
                      <button
                        type="button"
                        onClick={() => setSelectedScreen('signup')}
                        className="font-bold text-[#0F4C4C] hover:underline cursor-pointer"
                      >
                        Create Account
                      </button>
                    </p>
                  </div>
                </div>
              ) : (
                /* SCREEN 1: SPLASH SCREEN */
                <div className="flex-1 bg-[#0F4C4C] flex flex-col justify-between relative overflow-hidden">
                  <svg className="absolute inset-0 w-full h-full pointer-events-none" xmlns="http://www.w3.org/2000/svg">
                    <line x1="0" y1="380" x2="390" y2="380" stroke="rgba(255,255,255,0.04)" strokeWidth="1" />
                    <line x1="195" y1="0" x2="195" y2="844" stroke="rgba(255,255,255,0.04)" strokeWidth="1" />
                    <circle cx="195" cy="380" r="140" fill="none" stroke="rgba(255,255,255,0.04)" strokeWidth="1" />
                    <circle cx="195" cy="380" r="235" fill="none" stroke="rgba(255,255,255,0.04)" strokeWidth="1" />
                    <circle cx="195" cy="380" r="340" fill="none" stroke="rgba(255,255,255,0.035)" strokeWidth="1" />
                  </svg>

                  <div className="flex-1 flex flex-col items-center justify-center relative z-10 px-6">
                    <div className="w-[96px] h-[96px] bg-white rounded-[26px] flex items-center justify-center shadow-2xl">
                      <span className="text-[#0F4C4C] font-extrabold text-[36px] tracking-tight leading-none">
                        LP
                      </span>
                    </div>
                    <h2 className="text-white text-[28px] font-extrabold tracking-tight text-center mt-7 leading-tight">
                      CRM Pro Field Sales
                    </h2>
                    <p className="text-[#D3E4E4] text-[16px] font-normal text-center mt-2 tracking-normal">
                      Your field. Your leads. Your wins.
                    </p>
                  </div>

                  <div className="pb-10 flex flex-col items-center justify-center relative z-10">
                    <span className="text-[#8BA7A7] text-[12px] font-normal tracking-wide">
                      v1.0.0
                    </span>
                  </div>
                </div>
              )}
            </div>
          </div>
        )}

        {activeTab === 'code' && (
          <div className="w-full max-w-4xl bg-white rounded-2xl border border-[#E5E7EB] shadow-xs overflow-hidden">
            <div className="bg-[#1F2937] px-6 py-4 flex items-center justify-between">
              <div className="flex items-center space-x-2">
                <FileCode className="w-4 h-4 text-[#10B981]" />
                <span className="font-mono text-xs text-gray-200 font-semibold">
                  {selectedScreen === 'leads-list'
                    ? 'lib/features/leads/screens/leads_list_screen.dart (screen-leads-list)'
                    : selectedScreen === 'nearby-leads'
                    ? 'lib/features/leads/screens/nearby_leads_screen.dart (screen-nearby-leads)'
                    : selectedScreen === 'dashboard'
                    ? 'lib/features/dashboard/screens/dashboard_screen.dart (screen-dashboard)'
                    : selectedScreen === 'notifications'
                    ? 'lib/features/dashboard/screens/notifications_screen.dart (screen-notification)'
                    : selectedScreen === 'intro-slide-three'
                    ? 'lib/features/onboarding/screens/intro_slide_three_screen.dart'
                    : selectedScreen === 'intro-slide-two'

                    ? 'lib/features/onboarding/screens/intro_slide_two_screen.dart'
                    : selectedScreen === 'app-intro-walkthrough'
                    ? 'lib/features/onboarding/screens/app_intro_walkthrough_screen.dart'
                    : selectedScreen === 'onboarding-complete'
                    ? 'lib/features/onboarding/screens/onboarding_complete_screen.dart'
                    : selectedScreen === 'onboarding-offline-setup'
                    ? 'lib/features/onboarding/screens/onboarding_offline_setup_screen.dart'
                    : selectedScreen === 'onboarding-notifications'
                    ? 'lib/features/onboarding/screens/onboarding_notifications_screen.dart'
                    : selectedScreen === 'onboarding-microphone'
                    ? 'lib/features/onboarding/screens/onboarding_microphone_screen.dart'
                    : selectedScreen === 'onboarding-camera'
                    ? 'lib/features/onboarding/screens/onboarding_camera_screen.dart'
                    : selectedScreen === 'onboarding-location'
                    ? 'lib/features/onboarding/screens/onboarding_location_screen.dart'
                    : selectedScreen === 'onboarding-welcome'
                    ? 'lib/features/onboarding/screens/onboarding_welcome_screen.dart'
                    : `lib/features/authentication/screens/${
                        selectedScreen === 'biometric'
                          ? 'biometric_login_screen.dart'
                          : selectedScreen === 'success'
                          ? 'password_reset_success_screen.dart'
                          : selectedScreen === 'reset'
                          ? 'reset_password_screen.dart'
                          : selectedScreen === 'otp'
                          ? 'otp_verification_screen.dart'
                          : selectedScreen === 'forgot'
                          ? 'forgot_password_screen.dart'
                          : selectedScreen === 'verification'
                          ? 'email_verification_screen.dart'
                          : selectedScreen === 'signup'
                          ? 'sign_up_screen.dart'
                          : selectedScreen === 'signin'
                          ? 'sign_in_screen.dart'
                          : 'splash_screen.dart'
                      }`}
                </span>
              </div>
              <button
                onClick={copyCode}
                className="flex items-center space-x-1.5 px-3 py-1.5 rounded-lg bg-gray-700 hover:bg-gray-600 text-xs text-white font-medium transition-all cursor-pointer"
              >
                {copied ? <Check className="w-3.5 h-3.5 text-[#10B981]" /> : <Copy className="w-3.5 h-3.5" />}
                <span>{copied ? 'Copied' : 'Copy Dart Code'}</span>
              </button>
            </div>
            <pre className="p-6 bg-[#111827] text-gray-200 font-mono text-xs overflow-x-auto leading-relaxed max-h-[700px]">
              <code>{currentDartCode}</code>
            </pre>
          </div>
        )}

        {activeTab === 'instructions' && (
          <div className="w-full max-w-3xl bg-white rounded-2xl border border-[#E5E7EB] p-8 shadow-xs space-y-6">
            <div className="flex items-start space-x-3">
              <div className="w-10 h-10 rounded-xl bg-[#E6F0F0] text-[#0F4C4C] flex items-center justify-center shrink-0">
                <Terminal className="w-5 h-5" />
              </div>
              <div>
                <h2 className="text-lg font-extrabold text-[#111827]">Running in Android Studio</h2>
                <p className="text-xs text-[#4B5563] mt-0.5">
                  Execute the Sign Up flow locally on Android emulator or physical device.
                </p>
              </div>
            </div>

            <div className="space-y-4 text-xs text-[#111827]">
              <div className="p-4 bg-[#F9FAFB] rounded-xl border border-[#E5E7EB]">
                <p className="font-bold text-[#0F4C4C] mb-1">Step 1: Open in Android Studio</p>
                <p className="text-[#4B5563]">
                  Select <strong>File &rarr; Open</strong> and choose this repository directory.
                </p>
              </div>

              <div className="p-4 bg-[#F9FAFB] rounded-xl border border-[#E5E7EB]">
                <p className="font-bold text-[#0F4C4C] mb-1">Step 2: Fetch Packages</p>
                <code className="block bg-[#111827] text-green-400 p-2.5 rounded-lg font-mono">
                  flutter pub get
                </code>
              </div>

              <div className="p-4 bg-[#F9FAFB] rounded-xl border border-[#E5E7EB]">
                <p className="font-bold text-[#0F4C4C] mb-1">Step 3: Run Flutter App</p>
                <code className="block bg-[#111827] text-green-400 p-2.5 rounded-lg font-mono">
                  flutter run
                </code>
              </div>
            </div>
          </div>
        )}
      </main>
    </div>
  );
}
