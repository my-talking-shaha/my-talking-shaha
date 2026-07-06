// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appLanguage => 'App language';

  @override
  String get english => 'English';

  @override
  String get russian => 'Russian';

  @override
  String get profile => 'Profile';

  @override
  String get driver => 'Driver';

  @override
  String get signedIn => 'Signed in';

  @override
  String get theme => 'Theme';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get general => 'General';

  @override
  String get notifications => 'Notifications';

  @override
  String get vehicle => 'Vehicle';

  @override
  String get allNotifications => 'All notifications';

  @override
  String get logOut => 'Log out';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get garage => 'Garage';

  @override
  String get history => 'History';

  @override
  String get chat => 'Chat';

  @override
  String get analytics => 'Analytics';

  @override
  String get settings => 'Settings';

  @override
  String get brandName => 'My Talking Shaha';

  @override
  String get retry => 'Retry';

  @override
  String get tryAgain => 'Try again';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get save => 'Save';

  @override
  String get openGarage => 'Open garage';

  @override
  String get email => 'Email';

  @override
  String get enterYourEmail => 'Enter your email';

  @override
  String get enterValidEmail => 'Enter a valid email';

  @override
  String get password => 'Password';

  @override
  String get enterYourPassword => 'Enter your password';

  @override
  String passwordMinLength(int count) {
    return 'Password must be at least $count characters';
  }

  @override
  String get passwordHint => 'At least 6 characters';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get logIn => 'Log in';

  @override
  String get noAccount => 'No account?';

  @override
  String get register => 'Register';

  @override
  String get registration => 'Registration';

  @override
  String get createYourProfile => 'Create your profile';

  @override
  String get fullName => 'Full name';

  @override
  String get enterYourFullName => 'Enter your full name';

  @override
  String get fullNameHint => 'John Smith';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get repeatPassword => 'Repeat password';

  @override
  String get confirmYourPassword => 'Confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get somethingWentWrong =>
      'Something went wrong. Please try again later';

  @override
  String get couldNotLogOut => 'Could not log out. Please try again';

  @override
  String get deleteVehicleQuestion => 'Delete vehicle?';

  @override
  String deleteVehicleConfirmation(Object vehicleName) {
    return '$vehicleName will be removed from the garage.';
  }

  @override
  String get garageEmpty => 'Garage is empty';

  @override
  String get garageEmptyDescription =>
      'Add your first car to create its digital twin.';

  @override
  String get garageEmptyCompactDescription =>
      'Add your first car to open its digital twin.';

  @override
  String get addVehicle => 'Add vehicle';

  @override
  String get addCar => 'Add car';

  @override
  String get yourFleet => 'YOUR FLEET';

  @override
  String get couldNotLoadGarage => 'Could not load garage';

  @override
  String get openCockpit => 'Open cockpit';

  @override
  String get mileage => 'MILEAGE';

  @override
  String get service => 'SERVICE';

  @override
  String get fuel => 'FUEL';

  @override
  String get noIssues => 'No issues';

  @override
  String get noData => 'No data';

  @override
  String warningsCount(int count) {
    return '$count warnings';
  }

  @override
  String get editCar => 'Edit car';

  @override
  String get carSpecifications => 'Car Specifications';

  @override
  String get vehicleNotFound => 'Vehicle was not found';

  @override
  String get brand => 'Brand';

  @override
  String get model => 'Model';

  @override
  String get year => 'Year';

  @override
  String get currentMileage => 'Current mileage';

  @override
  String get color => 'Color';

  @override
  String get selectColor => 'Select color';

  @override
  String get customColor => 'Custom color';

  @override
  String get vehicleColorWhite => 'White';

  @override
  String get vehicleColorBlack => 'Black';

  @override
  String get vehicleColorSilver => 'Silver';

  @override
  String get vehicleColorGrey => 'Grey';

  @override
  String get vehicleColorRed => 'Red';

  @override
  String get vehicleColorBlue => 'Blue';

  @override
  String get vehicleColorGreen => 'Green';

  @override
  String get vehicleColorYellow => 'Yellow';

  @override
  String get vehicleColorOrange => 'Orange';

  @override
  String get vehicleColorBrown => 'Brown';

  @override
  String get vehicleColorBeige => 'Beige';

  @override
  String get vehicleColorGold => 'Gold';

  @override
  String get vehicleColorPurple => 'Purple';

  @override
  String get vehicleColorOther => 'Other';

  @override
  String get vinOptional => 'VIN number (optional)';

  @override
  String get engineType => 'Engine type';

  @override
  String get selectEngineType => 'Select engine type';

  @override
  String get gasoline => 'Gasoline';

  @override
  String get diesel => 'Diesel';

  @override
  String get hybrid => 'Hybrid';

  @override
  String get electric => 'Electric';

  @override
  String get powerOutputHp => 'Power output (hp)';

  @override
  String get engineVolumeL => 'Engine volume (L)';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get startNewShaha => 'Start new shaha!';

  @override
  String get vehicleUpdated => 'Vehicle updated';

  @override
  String get vehicleAdded => 'Vehicle added';

  @override
  String get checkVehicleDetails => 'Check the vehicle details';

  @override
  String get couldNotUpdateVehicle => 'Could not update the vehicle';

  @override
  String get couldNotSaveVehicle => 'Could not save the vehicle';

  @override
  String get enterBrand => 'Enter a brand';

  @override
  String get enterModel => 'Enter a model';

  @override
  String get enterProductionYear => 'Enter a production year';

  @override
  String enterProductionYearRange(int year) {
    return 'Enter a production year from 1900 to $year';
  }

  @override
  String get mileageCannotBeNegative => 'Mileage cannot be negative';

  @override
  String get enterCurrentMileage => 'Enter current mileage';

  @override
  String get enterPowerOutput => 'Enter power output';

  @override
  String get enterEngineVolume => 'Enter engine volume';

  @override
  String get enterEngineSpecification =>
      'Enter either engine volume or power output';

  @override
  String get powerOutputPositive => 'Power output must be greater than zero';

  @override
  String get engineVolumePositive => 'Engine volume must be greater than zero';

  @override
  String get vinLengthError => 'VIN must contain exactly 17 characters';

  @override
  String get myShaha => 'My Shaha';

  @override
  String get couldNotLoadDashboard => 'Could not load the dashboard';

  @override
  String get currentOdometer => 'Current odometer';

  @override
  String get engine => 'ENGINE';

  @override
  String get vinNumber => 'VIN NUMBER';

  @override
  String get vinUnavailable => 'VIN unavailable';

  @override
  String get copyVin => 'Copy VIN';

  @override
  String get vinCopied => 'VIN copied';

  @override
  String get latestEvents => 'LATEST EVENTS';

  @override
  String get viewAll => 'View all';

  @override
  String get noEventsYet => 'No events yet';

  @override
  String get maintenanceHistory => 'Maintenance History';

  @override
  String get addEvent => 'Add event';

  @override
  String get searchHistory => 'Search history…';

  @override
  String get all => 'ALL';

  @override
  String get repairs => 'REPAIRS';

  @override
  String get trips => 'TRIPS';

  @override
  String get noEventsFound => 'No events found';

  @override
  String get historyEmpty => 'History is empty';

  @override
  String get tryAnotherSearch => 'Try another search or event type.';

  @override
  String get historyEmptyDescription =>
      'Trips, refueling, and repairs will appear here.';

  @override
  String get couldNotLoadHistory => 'Could not load history';

  @override
  String get newRefueling => 'New refueling';

  @override
  String get newMaintenance => 'New maintenance';

  @override
  String get newTrip => 'New trip';

  @override
  String get eventType => 'EVENT TYPE';

  @override
  String get dateAndTime => 'DATE AND TIME';

  @override
  String get title => 'TITLE';

  @override
  String get enterEventTitle => 'Enter event title...';

  @override
  String get currentMileageLabel => 'CURRENT MILEAGE';

  @override
  String get refuelingDetails => 'REFUELING DETAILS';

  @override
  String get amount => 'AMOUNT';

  @override
  String get fuelLitersInvalidNumber => 'Enter amount';

  @override
  String get fuelLitersMustBePositive => 'Must be > 0 L';

  @override
  String fuelLitersMax(int max) {
    return 'Max $max L';
  }

  @override
  String get cost => 'COST';

  @override
  String get fuelType => 'FUEL TYPE';

  @override
  String get mileageForecastInfo =>
      'Mileage data will be used to update service intervals and forecasts.';

  @override
  String get workDescription => 'WORK DESCRIPTION';

  @override
  String get describeWorkPerformed => 'Describe the work performed...';

  @override
  String get replacedParts => 'REPLACED PARTS';

  @override
  String get enterPartsSeparated => 'Enter parts separated by commas...';

  @override
  String get route => 'ROUTE';

  @override
  String get duration => 'DURATION';

  @override
  String get start => 'START';

  @override
  String get end => 'END';

  @override
  String get optional => 'optional';

  @override
  String get partPhoto => 'PART PHOTO';

  @override
  String get addPhoto => 'Add photo';

  @override
  String get openingGallery => 'Opening gallery...';

  @override
  String get removePhoto => 'Remove photo';

  @override
  String get chooseAnotherPhoto => 'Choose another photo';

  @override
  String get couldNotSaveEvent => 'Could not save the event. Try again.';

  @override
  String get couldNotAccessPhotoLibrary =>
      'Could not access the photo library.';

  @override
  String get couldNotSelectPhoto => 'Could not select the photo.';

  @override
  String get couldNotRestorePhoto => 'Could not restore the selected photo.';

  @override
  String get fuelEvent => 'Fuel';

  @override
  String get maintenanceEvent => 'Maintenance';

  @override
  String get tripEvent => 'Trip';

  @override
  String fieldMustBePositive(Object field) {
    return '$field must be positive';
  }

  @override
  String fieldIsRequired(Object field) {
    return '$field is required';
  }

  @override
  String mileageAtLeastKm(int km) {
    return 'Must be at least $km km';
  }

  @override
  String atLeastKm(int km) {
    return 'At least $km km';
  }

  @override
  String get mustExceedStart => 'Must exceed start';

  @override
  String replaced(Object parts) {
    return 'Replaced: $parts';
  }

  @override
  String get partPhotoLabel => 'Part photo:';

  @override
  String get chatWithShaha => 'Chat with Shaha';

  @override
  String get vehicleAiAssistant => 'Vehicle AI assistant';

  @override
  String get shahaOnline => 'Shaha is online';

  @override
  String get chatEmptyDescription =>
      'Ask about vehicle condition, expenses, or maintenance.';

  @override
  String get chatGreetingReady => 'Hi! I am your car, and I am ready to chat.';

  @override
  String get quickQuestionVehicleStatus => 'Vehicle status';

  @override
  String get quickQuestionTotalExpenses => 'What are my total expenses?';

  @override
  String get quickQuestionOil => 'When should I change oil?';

  @override
  String get quickQuestionBreakSoon => 'What can break soon?';

  @override
  String get message => 'Message';

  @override
  String get sendMessage => 'Send message';

  @override
  String get assistantThinking => 'Assistant is thinking';

  @override
  String get shahaThinking => 'Shaha is thinking';

  @override
  String get connectingToShaha => 'Connecting to Shaha';

  @override
  String get preparingChat => 'Preparing history and quick questions.';

  @override
  String get chatDidNotLoad => 'Chat did not load';

  @override
  String get checkConnectionTryAgain => 'Check the connection and try again.';

  @override
  String get couldNotGetReply =>
      'Could not get a reply. Check the backend and try again.';

  @override
  String get openAnalytics => 'Open analytics';

  @override
  String get openForecast => 'Open forecast';

  @override
  String get openDashboard => 'Open dashboard';

  @override
  String get open => 'Open';

  @override
  String get addRefuel => 'Add refueling';

  @override
  String get addTrip => 'Add trip';

  @override
  String get addPartRecord => 'Add part record';

  @override
  String get addMaintenance => 'Add maintenance';

  @override
  String get openForm => 'Open form';

  @override
  String get intelligence => 'Intelligence';

  @override
  String get performanceOverview => 'Performance and spending overview';

  @override
  String get seasonalExpenses => 'SEASONAL EXPENSES';

  @override
  String get mileageTrend => 'MILEAGE TREND';

  @override
  String get customRange => 'Custom range';

  @override
  String get clearCustomRange => 'Clear custom range';

  @override
  String totalAmount(Object amount) {
    return 'TOTAL: $amount';
  }

  @override
  String get monthlyExpenseTrend => 'Monthly expense trend';

  @override
  String get allMonths => 'All months';

  @override
  String get january => 'January';

  @override
  String get february => 'February';

  @override
  String get march => 'March';

  @override
  String get april => 'April';

  @override
  String get may => 'May';

  @override
  String get june => 'June';

  @override
  String get july => 'July';

  @override
  String get august => 'August';

  @override
  String get september => 'September';

  @override
  String get october => 'October';

  @override
  String get november => 'November';

  @override
  String get december => 'December';

  @override
  String get winter => 'Winter';

  @override
  String get spring => 'Spring';

  @override
  String get summer => 'Summer';

  @override
  String get autumn => 'Autumn';

  @override
  String get mileageDataUnavailableForFilter =>
      'Mileage data is not available for this filter';

  @override
  String get accumulatedMileageByMonth => 'Accumulated mileage by month';

  @override
  String get accumulatedMileageByDay => 'Accumulated mileage by day';

  @override
  String get couldNotLoadMileageTrend => 'Could not load mileage trend';

  @override
  String get historyAnalysis => 'HISTORY ANALYSIS';

  @override
  String expensesLabel(Object period) {
    return '$period EXPENSES';
  }

  @override
  String get costPerKm => 'COST PER KM';

  @override
  String averageLabel(Object value) {
    return 'Avg: $value';
  }

  @override
  String get performanceTrendOverTime => 'PERFORMANCE TREND OVER TIME';

  @override
  String get companyMetricsUnavailable => 'Company metrics are not available';

  @override
  String get countsUnavailable => 'Counts are not available';

  @override
  String get companyMetrics => 'COMPANY METRICS';

  @override
  String get keyCounts => 'KEY COUNTS';

  @override
  String get eventsMetric => 'Events';

  @override
  String get tripKmMetric => 'Trip km';

  @override
  String get reliabilityMetric => 'Reliability';

  @override
  String get efficiencyMetric => 'Efficiency';

  @override
  String get maintenanceLoadMetric => 'Maintenance load';

  @override
  String get subscription => 'Subscription';

  @override
  String get electronics => 'Electronics';

  @override
  String get notEnoughAnalytics => 'Not enough data for analytics';

  @override
  String get analyticsEmptyDescription =>
      'Add trips, refueling, repairs, or maintenance records.';

  @override
  String get addRepair => 'Add repair';

  @override
  String get couldNotLoadAnalytics => 'Could not load analytics';

  @override
  String get month => 'MONTH';

  @override
  String get yearPeriod => 'YEAR';

  @override
  String get allTime => 'ALL TIME';

  @override
  String get monthly => 'MONTHLY';

  @override
  String get annual => 'ANNUAL';

  @override
  String get allTimeAdjective => 'ALL-TIME';

  @override
  String get fuelCategory => 'Fuel';

  @override
  String get maintenanceCategory => 'Maintenance';

  @override
  String get partsCategory => 'Parts';

  @override
  String get otherCategory => 'Other';

  @override
  String get maintenanceForecast => 'Maintenance forecast';

  @override
  String get noPartsAdded => 'No parts added';

  @override
  String get partsEmptyDescription =>
      'When part lifetime data appears, the maintenance forecast will be shown here.';

  @override
  String get couldNotLoadParts => 'Could not load parts lifetime';

  @override
  String get partsRetryDescription =>
      'Try again to refresh the maintenance forecast.';

  @override
  String get lifetimeNotSet => 'Lifetime not set';

  @override
  String get resource => 'RESOURCE';

  @override
  String get updatedTwoHoursAgo => 'UPDATED 2 HOURS AGO';

  @override
  String get maintenanceForecastCaps => 'MAINTENANCE FORECAST';

  @override
  String get serviceNeededNow => 'Service needed now';

  @override
  String inKm(Object km) {
    return 'In $km km';
  }

  @override
  String get notEnoughData => 'Not enough data';

  @override
  String get addLifetimeData => 'Add lifetime data to forecast';

  @override
  String get nextService => 'NEXT SERVICE';

  @override
  String approxDateInDays(int days) {
    return 'Approx. date: in $days days';
  }

  @override
  String replacePartNow(Object part) {
    return 'Replace $part now';
  }

  @override
  String replaceCriticalPartsNow(int count) {
    return 'Replace $count critical parts now';
  }

  @override
  String get noNotificationsYet => 'No notifications yet';

  @override
  String get networkError => 'Network error';

  @override
  String get notificationsLoadError =>
      'Notifications could not be loaded. Check the connection and try again.';

  @override
  String get notificationDetails => 'Notification details';

  @override
  String get notificationNotFound => 'Notification was not found';

  @override
  String get remainingResource => 'Remaining resource';

  @override
  String get recommendedAction => 'Recommended action';
}
