import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizationsEn();
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get appLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @russian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get russian;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @driver.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get driver;

  /// No description provided for @signedIn.
  ///
  /// In en, this message translates to:
  /// **'Signed in'**
  String get signedIn;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @vehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get vehicle;

  /// No description provided for @allNotifications.
  ///
  /// In en, this message translates to:
  /// **'All notifications'**
  String get allNotifications;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @garage.
  ///
  /// In en, this message translates to:
  /// **'Garage'**
  String get garage;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @brandName.
  ///
  /// In en, this message translates to:
  /// **'My Talking Shaha'**
  String get brandName;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @openGarage.
  ///
  /// In en, this message translates to:
  /// **'Open garage'**
  String get openGarage;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @enterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmail;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get enterValidEmail;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least {count} characters'**
  String passwordMinLength(int count);

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get passwordHint;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logIn;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'No account?'**
  String get noAccount;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @registration.
  ///
  /// In en, this message translates to:
  /// **'Registration'**
  String get registration;

  /// No description provided for @createYourProfile.
  ///
  /// In en, this message translates to:
  /// **'Create your profile'**
  String get createYourProfile;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @enterYourFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterYourFullName;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'John Smith'**
  String get fullNameHint;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @repeatPassword.
  ///
  /// In en, this message translates to:
  /// **'Repeat password'**
  String get repeatPassword;

  /// No description provided for @confirmYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get confirmYourPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again later'**
  String get somethingWentWrong;

  /// No description provided for @couldNotLogOut.
  ///
  /// In en, this message translates to:
  /// **'Could not log out. Please try again'**
  String get couldNotLogOut;

  /// No description provided for @deleteVehicleQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete vehicle?'**
  String get deleteVehicleQuestion;

  /// No description provided for @deleteVehicleConfirmation.
  ///
  /// In en, this message translates to:
  /// **'{vehicleName} will be removed from the garage.'**
  String deleteVehicleConfirmation(Object vehicleName);

  /// No description provided for @garageEmpty.
  ///
  /// In en, this message translates to:
  /// **'Garage is empty'**
  String get garageEmpty;

  /// No description provided for @garageEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Add your first car to create its digital twin.'**
  String get garageEmptyDescription;

  /// No description provided for @garageEmptyCompactDescription.
  ///
  /// In en, this message translates to:
  /// **'Add your first car to open its digital twin.'**
  String get garageEmptyCompactDescription;

  /// No description provided for @addVehicle.
  ///
  /// In en, this message translates to:
  /// **'Add vehicle'**
  String get addVehicle;

  /// No description provided for @addCar.
  ///
  /// In en, this message translates to:
  /// **'Add car'**
  String get addCar;

  /// No description provided for @yourFleet.
  ///
  /// In en, this message translates to:
  /// **'YOUR FLEET'**
  String get yourFleet;

  /// No description provided for @couldNotLoadGarage.
  ///
  /// In en, this message translates to:
  /// **'Could not load garage'**
  String get couldNotLoadGarage;

  /// No description provided for @openCockpit.
  ///
  /// In en, this message translates to:
  /// **'Open cockpit'**
  String get openCockpit;

  /// No description provided for @mileage.
  ///
  /// In en, this message translates to:
  /// **'MILEAGE'**
  String get mileage;

  /// No description provided for @service.
  ///
  /// In en, this message translates to:
  /// **'SERVICE'**
  String get service;

  /// No description provided for @fuel.
  ///
  /// In en, this message translates to:
  /// **'FUEL'**
  String get fuel;

  /// No description provided for @noIssues.
  ///
  /// In en, this message translates to:
  /// **'No issues'**
  String get noIssues;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @warningsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} warnings'**
  String warningsCount(int count);

  /// No description provided for @editCar.
  ///
  /// In en, this message translates to:
  /// **'Edit car'**
  String get editCar;

  /// No description provided for @carSpecifications.
  ///
  /// In en, this message translates to:
  /// **'Car Specifications'**
  String get carSpecifications;

  /// No description provided for @vehicleNotFound.
  ///
  /// In en, this message translates to:
  /// **'Vehicle was not found'**
  String get vehicleNotFound;

  /// No description provided for @brand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get brand;

  /// No description provided for @model.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get model;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @currentMileage.
  ///
  /// In en, this message translates to:
  /// **'Current mileage'**
  String get currentMileage;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @vinOptional.
  ///
  /// In en, this message translates to:
  /// **'VIN number (optional)'**
  String get vinOptional;

  /// No description provided for @engineType.
  ///
  /// In en, this message translates to:
  /// **'Engine type'**
  String get engineType;

  /// No description provided for @selectEngineType.
  ///
  /// In en, this message translates to:
  /// **'Select engine type'**
  String get selectEngineType;

  /// No description provided for @gasoline.
  ///
  /// In en, this message translates to:
  /// **'Gasoline'**
  String get gasoline;

  /// No description provided for @diesel.
  ///
  /// In en, this message translates to:
  /// **'Diesel'**
  String get diesel;

  /// No description provided for @hybrid.
  ///
  /// In en, this message translates to:
  /// **'Hybrid'**
  String get hybrid;

  /// No description provided for @electric.
  ///
  /// In en, this message translates to:
  /// **'Electric'**
  String get electric;

  /// No description provided for @powerOutputHp.
  ///
  /// In en, this message translates to:
  /// **'Power output (hp)'**
  String get powerOutputHp;

  /// No description provided for @engineVolumeL.
  ///
  /// In en, this message translates to:
  /// **'Engine volume (L)'**
  String get engineVolumeL;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @startNewShaha.
  ///
  /// In en, this message translates to:
  /// **'Start new shaha!'**
  String get startNewShaha;

  /// No description provided for @vehicleUpdated.
  ///
  /// In en, this message translates to:
  /// **'Vehicle updated'**
  String get vehicleUpdated;

  /// No description provided for @vehicleAdded.
  ///
  /// In en, this message translates to:
  /// **'Vehicle added'**
  String get vehicleAdded;

  /// No description provided for @checkVehicleDetails.
  ///
  /// In en, this message translates to:
  /// **'Check the vehicle details'**
  String get checkVehicleDetails;

  /// No description provided for @couldNotUpdateVehicle.
  ///
  /// In en, this message translates to:
  /// **'Could not update the vehicle'**
  String get couldNotUpdateVehicle;

  /// No description provided for @couldNotSaveVehicle.
  ///
  /// In en, this message translates to:
  /// **'Could not save the vehicle'**
  String get couldNotSaveVehicle;

  /// No description provided for @enterBrand.
  ///
  /// In en, this message translates to:
  /// **'Enter a brand'**
  String get enterBrand;

  /// No description provided for @enterModel.
  ///
  /// In en, this message translates to:
  /// **'Enter a model'**
  String get enterModel;

  /// No description provided for @enterProductionYear.
  ///
  /// In en, this message translates to:
  /// **'Enter a production year'**
  String get enterProductionYear;

  /// No description provided for @enterProductionYearRange.
  ///
  /// In en, this message translates to:
  /// **'Enter a production year from 1900 to {year}'**
  String enterProductionYearRange(int year);

  /// No description provided for @mileageCannotBeNegative.
  ///
  /// In en, this message translates to:
  /// **'Mileage cannot be negative'**
  String get mileageCannotBeNegative;

  /// No description provided for @enterCurrentMileage.
  ///
  /// In en, this message translates to:
  /// **'Enter current mileage'**
  String get enterCurrentMileage;

  /// No description provided for @enterPowerOutput.
  ///
  /// In en, this message translates to:
  /// **'Enter power output'**
  String get enterPowerOutput;

  /// No description provided for @enterEngineVolume.
  ///
  /// In en, this message translates to:
  /// **'Enter engine volume'**
  String get enterEngineVolume;

  /// No description provided for @enterEngineSpecification.
  ///
  /// In en, this message translates to:
  /// **'Enter either engine volume or power output'**
  String get enterEngineSpecification;

  /// No description provided for @powerOutputPositive.
  ///
  /// In en, this message translates to:
  /// **'Power output must be greater than zero'**
  String get powerOutputPositive;

  /// No description provided for @engineVolumePositive.
  ///
  /// In en, this message translates to:
  /// **'Engine volume must be greater than zero'**
  String get engineVolumePositive;

  /// No description provided for @vinLengthError.
  ///
  /// In en, this message translates to:
  /// **'VIN must contain exactly 17 characters'**
  String get vinLengthError;

  /// No description provided for @myShaha.
  ///
  /// In en, this message translates to:
  /// **'My Shaha'**
  String get myShaha;

  /// No description provided for @couldNotLoadDashboard.
  ///
  /// In en, this message translates to:
  /// **'Could not load the dashboard'**
  String get couldNotLoadDashboard;

  /// No description provided for @currentOdometer.
  ///
  /// In en, this message translates to:
  /// **'Current odometer'**
  String get currentOdometer;

  /// No description provided for @engine.
  ///
  /// In en, this message translates to:
  /// **'ENGINE'**
  String get engine;

  /// No description provided for @vinNumber.
  ///
  /// In en, this message translates to:
  /// **'VIN NUMBER'**
  String get vinNumber;

  /// No description provided for @vinUnavailable.
  ///
  /// In en, this message translates to:
  /// **'VIN unavailable'**
  String get vinUnavailable;

  /// No description provided for @copyVin.
  ///
  /// In en, this message translates to:
  /// **'Copy VIN'**
  String get copyVin;

  /// No description provided for @vinCopied.
  ///
  /// In en, this message translates to:
  /// **'VIN copied'**
  String get vinCopied;

  /// No description provided for @latestEvents.
  ///
  /// In en, this message translates to:
  /// **'LATEST EVENTS'**
  String get latestEvents;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @noEventsYet.
  ///
  /// In en, this message translates to:
  /// **'No events yet'**
  String get noEventsYet;

  /// No description provided for @maintenanceHistory.
  ///
  /// In en, this message translates to:
  /// **'Maintenance History'**
  String get maintenanceHistory;

  /// No description provided for @addEvent.
  ///
  /// In en, this message translates to:
  /// **'Add event'**
  String get addEvent;

  /// No description provided for @searchHistory.
  ///
  /// In en, this message translates to:
  /// **'Search history…'**
  String get searchHistory;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'ALL'**
  String get all;

  /// No description provided for @repairs.
  ///
  /// In en, this message translates to:
  /// **'REPAIRS'**
  String get repairs;

  /// No description provided for @trips.
  ///
  /// In en, this message translates to:
  /// **'TRIPS'**
  String get trips;

  /// No description provided for @noEventsFound.
  ///
  /// In en, this message translates to:
  /// **'No events found'**
  String get noEventsFound;

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'History is empty'**
  String get historyEmpty;

  /// No description provided for @tryAnotherSearch.
  ///
  /// In en, this message translates to:
  /// **'Try another search or event type.'**
  String get tryAnotherSearch;

  /// No description provided for @historyEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Trips, refueling, and repairs will appear here.'**
  String get historyEmptyDescription;

  /// No description provided for @couldNotLoadHistory.
  ///
  /// In en, this message translates to:
  /// **'Could not load history'**
  String get couldNotLoadHistory;

  /// No description provided for @newRefueling.
  ///
  /// In en, this message translates to:
  /// **'New refueling'**
  String get newRefueling;

  /// No description provided for @newMaintenance.
  ///
  /// In en, this message translates to:
  /// **'New maintenance'**
  String get newMaintenance;

  /// No description provided for @newTrip.
  ///
  /// In en, this message translates to:
  /// **'New trip'**
  String get newTrip;

  /// No description provided for @eventType.
  ///
  /// In en, this message translates to:
  /// **'EVENT TYPE'**
  String get eventType;

  /// No description provided for @dateAndTime.
  ///
  /// In en, this message translates to:
  /// **'DATE AND TIME'**
  String get dateAndTime;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'TITLE'**
  String get title;

  /// No description provided for @enterEventTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter event title...'**
  String get enterEventTitle;

  /// No description provided for @currentMileageLabel.
  ///
  /// In en, this message translates to:
  /// **'CURRENT MILEAGE'**
  String get currentMileageLabel;

  /// No description provided for @refuelingDetails.
  ///
  /// In en, this message translates to:
  /// **'REFUELING DETAILS'**
  String get refuelingDetails;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'AMOUNT'**
  String get amount;

  /// No description provided for @cost.
  ///
  /// In en, this message translates to:
  /// **'COST'**
  String get cost;

  /// No description provided for @fuelType.
  ///
  /// In en, this message translates to:
  /// **'FUEL TYPE'**
  String get fuelType;

  /// No description provided for @mileageForecastInfo.
  ///
  /// In en, this message translates to:
  /// **'Mileage data will be used to update service intervals and forecasts.'**
  String get mileageForecastInfo;

  /// No description provided for @workDescription.
  ///
  /// In en, this message translates to:
  /// **'WORK DESCRIPTION'**
  String get workDescription;

  /// No description provided for @describeWorkPerformed.
  ///
  /// In en, this message translates to:
  /// **'Describe the work performed...'**
  String get describeWorkPerformed;

  /// No description provided for @replacedParts.
  ///
  /// In en, this message translates to:
  /// **'REPLACED PARTS'**
  String get replacedParts;

  /// No description provided for @enterPartsSeparated.
  ///
  /// In en, this message translates to:
  /// **'Enter parts separated by commas...'**
  String get enterPartsSeparated;

  /// No description provided for @route.
  ///
  /// In en, this message translates to:
  /// **'ROUTE'**
  String get route;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'DURATION'**
  String get duration;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'START'**
  String get start;

  /// No description provided for @end.
  ///
  /// In en, this message translates to:
  /// **'END'**
  String get end;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'optional'**
  String get optional;

  /// No description provided for @partPhoto.
  ///
  /// In en, this message translates to:
  /// **'PART PHOTO'**
  String get partPhoto;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get addPhoto;

  /// No description provided for @openingGallery.
  ///
  /// In en, this message translates to:
  /// **'Opening gallery...'**
  String get openingGallery;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removePhoto;

  /// No description provided for @chooseAnotherPhoto.
  ///
  /// In en, this message translates to:
  /// **'Choose another photo'**
  String get chooseAnotherPhoto;

  /// No description provided for @couldNotSaveEvent.
  ///
  /// In en, this message translates to:
  /// **'Could not save the event. Try again.'**
  String get couldNotSaveEvent;

  /// No description provided for @couldNotAccessPhotoLibrary.
  ///
  /// In en, this message translates to:
  /// **'Could not access the photo library.'**
  String get couldNotAccessPhotoLibrary;

  /// No description provided for @couldNotSelectPhoto.
  ///
  /// In en, this message translates to:
  /// **'Could not select the photo.'**
  String get couldNotSelectPhoto;

  /// No description provided for @couldNotRestorePhoto.
  ///
  /// In en, this message translates to:
  /// **'Could not restore the selected photo.'**
  String get couldNotRestorePhoto;

  /// No description provided for @fuelEvent.
  ///
  /// In en, this message translates to:
  /// **'Fuel'**
  String get fuelEvent;

  /// No description provided for @maintenanceEvent.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get maintenanceEvent;

  /// No description provided for @tripEvent.
  ///
  /// In en, this message translates to:
  /// **'Trip'**
  String get tripEvent;

  /// No description provided for @fieldMustBePositive.
  ///
  /// In en, this message translates to:
  /// **'{field} must be positive'**
  String fieldMustBePositive(Object field);

  /// No description provided for @fieldIsRequired.
  ///
  /// In en, this message translates to:
  /// **'{field} is required'**
  String fieldIsRequired(Object field);

  /// No description provided for @mileageAtLeastKm.
  ///
  /// In en, this message translates to:
  /// **'Must be at least {km} km'**
  String mileageAtLeastKm(int km);

  /// No description provided for @atLeastKm.
  ///
  /// In en, this message translates to:
  /// **'At least {km} km'**
  String atLeastKm(int km);

  /// No description provided for @mustExceedStart.
  ///
  /// In en, this message translates to:
  /// **'Must exceed start'**
  String get mustExceedStart;

  /// No description provided for @replaced.
  ///
  /// In en, this message translates to:
  /// **'Replaced: {parts}'**
  String replaced(Object parts);

  /// No description provided for @partPhotoLabel.
  ///
  /// In en, this message translates to:
  /// **'Part photo:'**
  String get partPhotoLabel;

  /// No description provided for @chatWithShaha.
  ///
  /// In en, this message translates to:
  /// **'Chat with Shaha'**
  String get chatWithShaha;

  /// No description provided for @vehicleAiAssistant.
  ///
  /// In en, this message translates to:
  /// **'Vehicle AI assistant'**
  String get vehicleAiAssistant;

  /// No description provided for @shahaOnline.
  ///
  /// In en, this message translates to:
  /// **'Shaha is online'**
  String get shahaOnline;

  /// No description provided for @chatEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Ask about vehicle condition, expenses, or maintenance.'**
  String get chatEmptyDescription;

  /// No description provided for @quickQuestionVehicleStatus.
  ///
  /// In en, this message translates to:
  /// **'Vehicle status'**
  String get quickQuestionVehicleStatus;

  /// No description provided for @quickQuestionOil.
  ///
  /// In en, this message translates to:
  /// **'When should I change oil?'**
  String get quickQuestionOil;

  /// No description provided for @quickQuestionBreakSoon.
  ///
  /// In en, this message translates to:
  /// **'What can break soon?'**
  String get quickQuestionBreakSoon;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send message'**
  String get sendMessage;

  /// No description provided for @assistantThinking.
  ///
  /// In en, this message translates to:
  /// **'Assistant is thinking'**
  String get assistantThinking;

  /// No description provided for @shahaThinking.
  ///
  /// In en, this message translates to:
  /// **'Shaha is thinking'**
  String get shahaThinking;

  /// No description provided for @connectingToShaha.
  ///
  /// In en, this message translates to:
  /// **'Connecting to Shaha'**
  String get connectingToShaha;

  /// No description provided for @preparingChat.
  ///
  /// In en, this message translates to:
  /// **'Preparing history and quick questions.'**
  String get preparingChat;

  /// No description provided for @chatDidNotLoad.
  ///
  /// In en, this message translates to:
  /// **'Chat did not load'**
  String get chatDidNotLoad;

  /// No description provided for @checkConnectionTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Check the connection and try again.'**
  String get checkConnectionTryAgain;

  /// No description provided for @couldNotGetReply.
  ///
  /// In en, this message translates to:
  /// **'Could not get a reply. Check the backend and try again.'**
  String get couldNotGetReply;

  /// No description provided for @openAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Open analytics'**
  String get openAnalytics;

  /// No description provided for @openForecast.
  ///
  /// In en, this message translates to:
  /// **'Open forecast'**
  String get openForecast;

  /// No description provided for @openDashboard.
  ///
  /// In en, this message translates to:
  /// **'Open dashboard'**
  String get openDashboard;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @addRefuel.
  ///
  /// In en, this message translates to:
  /// **'Add refueling'**
  String get addRefuel;

  /// No description provided for @addTrip.
  ///
  /// In en, this message translates to:
  /// **'Add trip'**
  String get addTrip;

  /// No description provided for @addPartRecord.
  ///
  /// In en, this message translates to:
  /// **'Add part record'**
  String get addPartRecord;

  /// No description provided for @addMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Add maintenance'**
  String get addMaintenance;

  /// No description provided for @openForm.
  ///
  /// In en, this message translates to:
  /// **'Open form'**
  String get openForm;

  /// No description provided for @intelligence.
  ///
  /// In en, this message translates to:
  /// **'Intelligence'**
  String get intelligence;

  /// No description provided for @performanceOverview.
  ///
  /// In en, this message translates to:
  /// **'Performance and spending overview'**
  String get performanceOverview;

  /// No description provided for @seasonalExpenses.
  ///
  /// In en, this message translates to:
  /// **'SEASONAL EXPENSES'**
  String get seasonalExpenses;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'TOTAL: {amount}'**
  String totalAmount(Object amount);

  /// No description provided for @monthlyExpenseTrend.
  ///
  /// In en, this message translates to:
  /// **'Monthly expense trend'**
  String get monthlyExpenseTrend;

  /// No description provided for @historyAnalysis.
  ///
  /// In en, this message translates to:
  /// **'HISTORY ANALYSIS'**
  String get historyAnalysis;

  /// No description provided for @expensesLabel.
  ///
  /// In en, this message translates to:
  /// **'{period} EXPENSES'**
  String expensesLabel(Object period);

  /// No description provided for @costPerKm.
  ///
  /// In en, this message translates to:
  /// **'COST PER KM'**
  String get costPerKm;

  /// No description provided for @averageLabel.
  ///
  /// In en, this message translates to:
  /// **'Avg: {value}'**
  String averageLabel(Object value);

  /// No description provided for @performanceTrendOverTime.
  ///
  /// In en, this message translates to:
  /// **'PERFORMANCE TREND OVER TIME'**
  String get performanceTrendOverTime;

  /// No description provided for @companyMetricsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Company metrics are not available'**
  String get companyMetricsUnavailable;

  /// No description provided for @countsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Counts are not available'**
  String get countsUnavailable;

  /// No description provided for @companyMetrics.
  ///
  /// In en, this message translates to:
  /// **'COMPANY METRICS'**
  String get companyMetrics;

  /// No description provided for @keyCounts.
  ///
  /// In en, this message translates to:
  /// **'KEY COUNTS'**
  String get keyCounts;

  /// No description provided for @subscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscription;

  /// No description provided for @electronics.
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get electronics;

  /// No description provided for @notEnoughAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Not enough data for analytics'**
  String get notEnoughAnalytics;

  /// No description provided for @analyticsEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Add trips, refueling, repairs, or maintenance records.'**
  String get analyticsEmptyDescription;

  /// No description provided for @addRepair.
  ///
  /// In en, this message translates to:
  /// **'Add repair'**
  String get addRepair;

  /// No description provided for @couldNotLoadAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Could not load analytics'**
  String get couldNotLoadAnalytics;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'MONTH'**
  String get month;

  /// No description provided for @yearPeriod.
  ///
  /// In en, this message translates to:
  /// **'YEAR'**
  String get yearPeriod;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'ALL TIME'**
  String get allTime;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'MONTHLY'**
  String get monthly;

  /// No description provided for @annual.
  ///
  /// In en, this message translates to:
  /// **'ANNUAL'**
  String get annual;

  /// No description provided for @allTimeAdjective.
  ///
  /// In en, this message translates to:
  /// **'ALL-TIME'**
  String get allTimeAdjective;

  /// No description provided for @fuelCategory.
  ///
  /// In en, this message translates to:
  /// **'Fuel'**
  String get fuelCategory;

  /// No description provided for @maintenanceCategory.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get maintenanceCategory;

  /// No description provided for @partsCategory.
  ///
  /// In en, this message translates to:
  /// **'Parts'**
  String get partsCategory;

  /// No description provided for @otherCategory.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get otherCategory;

  /// No description provided for @maintenanceForecast.
  ///
  /// In en, this message translates to:
  /// **'Maintenance forecast'**
  String get maintenanceForecast;

  /// No description provided for @noPartsAdded.
  ///
  /// In en, this message translates to:
  /// **'No parts added'**
  String get noPartsAdded;

  /// No description provided for @partsEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'When part lifetime data appears, the maintenance forecast will be shown here.'**
  String get partsEmptyDescription;

  /// No description provided for @couldNotLoadParts.
  ///
  /// In en, this message translates to:
  /// **'Could not load parts lifetime'**
  String get couldNotLoadParts;

  /// No description provided for @partsRetryDescription.
  ///
  /// In en, this message translates to:
  /// **'Try again to refresh the maintenance forecast.'**
  String get partsRetryDescription;

  /// No description provided for @lifetimeNotSet.
  ///
  /// In en, this message translates to:
  /// **'Lifetime not set'**
  String get lifetimeNotSet;

  /// No description provided for @resource.
  ///
  /// In en, this message translates to:
  /// **'RESOURCE'**
  String get resource;

  /// No description provided for @updatedTwoHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'UPDATED 2 HOURS AGO'**
  String get updatedTwoHoursAgo;

  /// No description provided for @maintenanceForecastCaps.
  ///
  /// In en, this message translates to:
  /// **'MAINTENANCE FORECAST'**
  String get maintenanceForecastCaps;

  /// No description provided for @serviceNeededNow.
  ///
  /// In en, this message translates to:
  /// **'Service needed now'**
  String get serviceNeededNow;

  /// No description provided for @inKm.
  ///
  /// In en, this message translates to:
  /// **'In {km} km'**
  String inKm(Object km);

  /// No description provided for @notEnoughData.
  ///
  /// In en, this message translates to:
  /// **'Not enough data'**
  String get notEnoughData;

  /// No description provided for @addLifetimeData.
  ///
  /// In en, this message translates to:
  /// **'Add lifetime data to forecast'**
  String get addLifetimeData;

  /// No description provided for @nextService.
  ///
  /// In en, this message translates to:
  /// **'NEXT SERVICE'**
  String get nextService;

  /// No description provided for @approxDateInDays.
  ///
  /// In en, this message translates to:
  /// **'Approx. date: in {days} days'**
  String approxDateInDays(int days);

  /// No description provided for @replacePartNow.
  ///
  /// In en, this message translates to:
  /// **'Replace {part} now'**
  String replacePartNow(Object part);

  /// No description provided for @replaceCriticalPartsNow.
  ///
  /// In en, this message translates to:
  /// **'Replace {count} critical parts now'**
  String replaceCriticalPartsNow(int count);

  /// No description provided for @noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotificationsYet;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error'**
  String get networkError;

  /// No description provided for @notificationsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Notifications could not be loaded. Check the connection and try again.'**
  String get notificationsLoadError;

  /// No description provided for @notificationDetails.
  ///
  /// In en, this message translates to:
  /// **'Notification details'**
  String get notificationDetails;

  /// No description provided for @notificationNotFound.
  ///
  /// In en, this message translates to:
  /// **'Notification was not found'**
  String get notificationNotFound;

  /// No description provided for @remainingResource.
  ///
  /// In en, this message translates to:
  /// **'Remaining resource'**
  String get remainingResource;

  /// No description provided for @recommendedAction.
  ///
  /// In en, this message translates to:
  /// **'Recommended action'**
  String get recommendedAction;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
