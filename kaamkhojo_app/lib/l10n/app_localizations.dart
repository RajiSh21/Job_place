import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ne'),
  ];

  bool get isNepali => locale.languageCode == 'ne';

  String _t(String en, String ne) => isNepali ? ne : en;

  // App name
  String get appName => 'KaamKhojo';
  String get appTagline => _t('Find Local Workers', 'स्थानीय कामदार खोज्नुहोस्');

  // Navigation
  String get navHome => _t('Home', 'होम');
  String get navSearch => _t('Search', 'खोज्नुहोस्');
  String get navBookings => _t('Bookings', 'बुकिङहरू');
  String get navProfile => _t('Profile', 'प्रोफाइल');
  String get navDashboard => _t('Dashboard', 'ड्यासबोर्ड');
  String get navJobs => _t('Jobs', 'कामहरू');
  String get navChat => _t('Chat', 'च्याट');

  // Auth
  String get enterPhone => _t('Enter your phone number', 'फोन नम्बर प्रविष्ट गर्नुहोस्');
  String get phoneHint => _t('98XXXXXXXX', '98XXXXXXXX');
  String get sendOtp => _t('Send OTP', 'OTP पठाउनुहोस्');
  String get enterOtp => _t('Enter OTP', 'OTP प्रविष्ट गर्नुहोस्');
  String get otpSentTo => _t('OTP sent to', 'OTP पठाइयो');
  String get verifyOtp => _t('Verify OTP', 'OTP प्रमाणित गर्नुहोस्');
  String get resendOtp => _t('Resend OTP', 'OTP पुनः पठाउनुहोस्');
  String get resendIn => _t('Resend in', 'पुनः पठाउन');
  String get iAmCustomer => _t("I'm looking for workers\n(Customer)", 'म कामदार खोजिरहेको छु\n(घरवाला)');
  String get iAmWorker => _t("I'm a service provider\n(Worker)", 'म काम गर्छु\n(कामदार)');
  String get selectRole => _t('Who are you?', 'तपाईं को हुनुहुन्छ?');

  // Home screen
  String get searchPlaceholder => _t('What service do you need?', 'कस्तो सेवा चाहिन्छ?');
  String get nearbyWorkers => _t('Nearby Workers', 'नजिकका कामदारहरू');
  String get topRated => _t('Top Rated in Your Area', 'तपाईंको क्षेत्रमा शीर्ष रेटेड');
  String get recentBookings => _t('Recent Bookings', 'हालका बुकिङहरू');
  String get selectLocation => _t('Select Location', 'स्थान छान्नुहोस्');
  String get seeAll => _t('See All', 'सबै हेर्नुहोस्');

  // Categories
  String get plumber => _t('Plumber', 'प्लम्बर');
  String get electrician => _t('Electrician', 'इलेक्ट्रिशियन');
  String get tutor => _t('Tutor', 'ट्युटर');
  String get carpenter => _t('Carpenter', 'काठ मिस्त्री');
  String get painter => _t('Painter', 'रंगकर्मी');
  String get tailor => _t('Tailor', 'दर्जी');
  String get cleaner => _t('Cleaner', 'सफाइकर्मी');
  String get driver => _t('Driver', 'चालक');
  String get cook => _t('Cook', 'भान्से');
  String get mason => _t('Mason', 'डकर्मी');
  String get mechanic => _t('Mechanic', 'मेकानिक');
  String get gardener => _t('Gardener', 'माली');
  String get other => _t('Other', 'अन्य');

  // Worker profile
  String get bookNow => _t('Book Now', 'अहिले बुक गर्नुहोस्');
  String get perHour => _t('/hr', '/घण्टा');
  String get perJob => _t('/job', '/काम');
  String get verified => _t('Verified', 'प्रमाणित');
  String get featured => _t('Featured', 'विशेष');
  String get memberSince => _t('Member since', 'सदस्य भएको');
  String get totalJobs => _t('Total jobs', 'जम्मा काम');
  String get availability => _t('Availability', 'उपलब्धता');
  String get workGallery => _t('Work Gallery', 'काम ग्यालरी');
  String get reviews => _t('Reviews', 'समीक्षाहरू');
  String get noReviews => _t('No reviews yet', 'अहिलेसम्म कुनै समीक्षा छैन');
  String get rating => _t('Rating', 'रेटिङ');
  String get punctuality => _t('Punctuality', 'समयपालन');
  String get quality => _t('Quality', 'गुणस्तर');
  String get behavior => _t('Behavior', 'व्यवहार');

  // Booking flow
  String get describeJob => _t('Describe the job', 'काम विवरण लेख्नुहोस्');
  String get addPhotos => _t('Add photos (optional)', 'फोटोहरू थप्नुहोस् (ऐच्छिक)');
  String get selectDate => _t('Select date', 'मिति छान्नुहोस्');
  String get selectTime => _t('Select time', 'समय छान्नुहोस्');
  String get yourAddress => _t('Your address', 'तपाईंको ठेगाना');
  String get useMyLocation => _t('Use my location', 'मेरो स्थान प्रयोग गर्नुहोस्');
  String get bookingConfirm => _t('Confirm Booking', 'बुकिङ पुष्टि गर्नुहोस्');
  String get paymentMethod => _t('Payment Method', 'भुक्तानी विधि');
  String get cashOnCompletion => _t('Cash on Completion', 'काम पूरा भएपछि नगद');
  String get comingSoon => _t('Coming Soon', 'चाँडै आउँदैछ');
  String get bookingSuccess => _t('Booking Confirmed!', 'बुकिङ पुष्टि भयो!');
  String get bookingId => _t('Booking ID', 'बुकिङ ID');
  String get workerContact => _t('Worker Contact', 'कामदारको सम्पर्क');
  String get openChat => _t('Open Chat', 'च्याट खोल्नुहोस्');
  String get trackBooking => _t('Track Booking', 'बुकिङ ट्र्याक गर्नुहोस्');
  String get priceEstimate => _t('Price Estimate', 'मूल्य अनुमान');

  // Booking statuses
  String get statusPending => _t('Pending', 'पर्खिरहेको');
  String get statusAccepted => _t('Accepted', 'स्वीकृत');
  String get statusInProgress => _t('In Progress', 'भइरहेको');
  String get statusCompleted => _t('Completed', 'सम्पन्न');
  String get statusCancelled => _t('Cancelled', 'रद्द');
  String get statusDeclined => _t('Declined', 'अस्वीकृत');

  // Worker dashboard
  String get todayJobs => _t("Today's Jobs", 'आजका कामहरू');
  String get incomingRequests => _t('Incoming Requests', 'आएका अनुरोधहरू');
  String get thisWeek => _t('This Week', 'यो हप्ता');
  String get thisMonth => _t('This Month', 'यो महिना');
  String get earnings => _t('Earnings', 'आम्दानी');
  String get profileViews => _t('Profile Views', 'प्रोफाइल हेरिएको');
  String get accept => _t('Accept', 'स्वीकार');
  String get decline => _t('Decline', 'अस्वीकार');
  String get counterOffer => _t('Counter Offer', 'नयाँ प्रस्ताव');
  String get markComplete => _t('Mark Complete', 'सम्पन्न मार्क गर्नुहोस्');

  // Worker registration
  String get registerAsWorker => _t('Register as Worker', 'कामदारको रूपमा दर्ता गर्नुहोस्');
  String get selectSkills => _t('Select your skills', 'आफ्नो सिपहरू छान्नुहोस्');
  String get setLocation => _t('Set your location', 'आफ्नो स्थान तोक्नुहोस्');
  String get setRates => _t('Set your rates', 'आफ्नो मूल्य तोक्नुहोस्');
  String get hourlyRate => _t('Hourly rate (NPR)', 'प्रति घण्टा मूल्य (रू)');
  String get fixedRate => _t('Fixed rate per job (NPR)', 'प्रति काम मूल्य (रू)');
  String get enterNid => _t('Citizenship / NID number', 'नागरिकता / राष्ट्रिय परिचय पत्र नम्बर');
  String get shortBio => _t('Short bio', 'छोटो परिचय');
  String get uploadProfilePhoto => _t('Upload profile photo', 'प्रोफाइल फोटो अपलोड गर्नुहोस्');
  String get submit => _t('Submit', 'पेश गर्नुहोस्');
  String get next => _t('Next', 'अर्को');
  String get back => _t('Back', 'पछाडि');
  String get finish => _t('Finish', 'समाप्त');

  // Chat
  String get typeMessage => _t('Type a message...', 'सन्देश टाइप गर्नुहोस्...');
  String get send => _t('Send', 'पठाउनुहोस्');
  String get typing => _t('typing...', 'टाइप गर्दैछ...');

  // Settings
  String get settings => _t('Settings', 'सेटिङ');
  String get language => _t('Language', 'भाषा');
  String get english => _t('English', 'अंग्रेजी');
  String get nepali => _t('Nepali', 'नेपाली');
  String get logout => _t('Log Out', 'लगआउट');
  String get logoutConfirm => _t('Are you sure you want to log out?', 'के तपाईं साँच्चै लगआउट गर्न चाहनुहुन्छ?');
  String get cancel => _t('Cancel', 'रद्द गर्नुहोस्');
  String get confirm => _t('Confirm', 'पुष्टि गर्नुहोस्');

  // Errors
  String get errNoInternet => _t('No internet connection', 'इन्टरनेट जडान छैन');
  String get errServerDown => _t('Server error. Please try again later.', 'सर्भरमा समस्या। पछि पुनः प्रयास गर्नुहोस्।');
  String get errInvalidPhone => _t('Enter a valid Nepal phone number', 'वैध नेपाली फोन नम्बर प्रविष्ट गर्नुहोस्');
  String get errInvalidOtp => _t('Invalid or expired OTP', 'OTP गलत छ वा म्याद सकिएको छ');
  String get errRequired => _t('This field is required', 'यो क्षेत्र आवश्यक छ');
  String get errSelectSkill => _t('Select at least one skill', 'कम्तिमा एउटा सिप छान्नुहोस्');

  // Misc
  String get npr => 'रू';
  String get km => _t('km', 'कि.मी.');
  String get loading => _t('Loading...', 'लोड हुँदैछ...');
  String get noData => _t('No data found', 'डेटा फेला परेन');
  String get retry => _t('Retry', 'पुनः प्रयास');
  String get saveChanges => _t('Save Changes', 'परिवर्तन सुरक्षित गर्नुहोस्');
  String get district => _t('District', 'जिल्ला');
  String get municipality => _t('Municipality', 'नगरपालिका');
  String get ward => _t('Ward No.', 'वडा नं.');
  String get selectDistrict => _t('Select district', 'जिल्ला छान्नुहोस्');
  String get filterAndSort => _t('Filter & Sort', 'फिल्टर र क्रम');
  String get priceRange => _t('Price Range (NPR)', 'मूल्य दायरा (रू)');
  String get minRating => _t('Minimum Rating', 'न्यूनतम रेटिङ');
  String get availableToday => _t('Available Today', 'आज उपलब्ध');
  String get applyFilters => _t('Apply Filters', 'फिल्टर लागू गर्नुहोस्');
  String get clearFilters => _t('Clear Filters', 'फिल्टर हटाउनुहोस्');
  String get sortNearest => _t('Nearest', 'नजिकको');
  String get sortHighestRated => _t('Highest Rated', 'सर्वोच्च रेटेड');
  String get sortLowestPrice => _t('Lowest Price', 'सबभन्दा सस्तो');
  String get sortMostBooked => _t('Most Booked', 'सबभन्दा बढी बुक');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ne'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
