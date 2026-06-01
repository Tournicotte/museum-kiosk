import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_et.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('de'),
    Locale('en'),
    Locale('et')
  ];

  /// Museum display name on attract screen
  ///
  /// In et, this message translates to:
  /// **'Eppingi torn'**
  String get museumDisplayName;

  /// Attract screen call to action
  ///
  /// In et, this message translates to:
  /// **'Puuduta ekraani piletite ostmiseks'**
  String get touchToStart;

  /// No description provided for @orderSummary.
  ///
  /// In et, this message translates to:
  /// **'Tellimuse kokkuvõte'**
  String get orderSummary;

  /// No description provided for @total.
  ///
  /// In et, this message translates to:
  /// **'Kokku'**
  String get total;

  /// No description provided for @payByCard.
  ///
  /// In et, this message translates to:
  /// **'Maksa kaardiga'**
  String get payByCard;

  /// No description provided for @cancel.
  ///
  /// In et, this message translates to:
  /// **'Tühista'**
  String get cancel;

  /// No description provided for @processingPayment.
  ///
  /// In et, this message translates to:
  /// **'Makse töötlemisel…'**
  String get processingPayment;

  /// No description provided for @doNotRemoveCard.
  ///
  /// In et, this message translates to:
  /// **'Ärge eemaldage kaarti'**
  String get doNotRemoveCard;

  /// No description provided for @paymentSuccessful.
  ///
  /// In et, this message translates to:
  /// **'Makse õnnestus!'**
  String get paymentSuccessful;

  /// No description provided for @receiptSent.
  ///
  /// In et, this message translates to:
  /// **'Kviitung on saadetud.'**
  String get receiptSent;

  /// No description provided for @returningIn.
  ///
  /// In et, this message translates to:
  /// **'Tagasi {seconds} sekundi pärast…'**
  String returningIn(int seconds);

  /// No description provided for @done.
  ///
  /// In et, this message translates to:
  /// **'Valmis'**
  String get done;

  /// No description provided for @paymentFailed.
  ///
  /// In et, this message translates to:
  /// **'Makse ebaõnnestus'**
  String get paymentFailed;

  /// No description provided for @tryAgain.
  ///
  /// In et, this message translates to:
  /// **'Proovi uuesti'**
  String get tryAgain;

  /// No description provided for @startAgain.
  ///
  /// In et, this message translates to:
  /// **'Alusta uuesti'**
  String get startAgain;

  /// No description provided for @adminTitle.
  ///
  /// In et, this message translates to:
  /// **'Haldus'**
  String get adminTitle;

  /// No description provided for @enterPin.
  ///
  /// In et, this message translates to:
  /// **'Sisesta PIN-kood'**
  String get enterPin;

  /// No description provided for @unlock.
  ///
  /// In et, this message translates to:
  /// **'Ava'**
  String get unlock;

  /// No description provided for @incorrectPin.
  ///
  /// In et, this message translates to:
  /// **'Vale PIN-kood'**
  String get incorrectPin;

  /// No description provided for @todaySales.
  ///
  /// In et, this message translates to:
  /// **'Tänased müügid'**
  String get todaySales;

  /// No description provided for @syncCatalog.
  ///
  /// In et, this message translates to:
  /// **'Uuenda piletikataloog'**
  String get syncCatalog;

  /// No description provided for @lastSynced.
  ///
  /// In et, this message translates to:
  /// **'Sünkroniseeritud: {time}'**
  String lastSynced(String time);

  /// No description provided for @neverSynced.
  ///
  /// In et, this message translates to:
  /// **'Sünkroniseerimine puudub'**
  String get neverSynced;

  /// No description provided for @syncingNow.
  ///
  /// In et, this message translates to:
  /// **'Sünkroniseerimisel…'**
  String get syncingNow;

  /// No description provided for @syncStale.
  ///
  /// In et, this message translates to:
  /// **'Andmed võivad olla aegunud (>24h)'**
  String get syncStale;

  /// No description provided for @quantity.
  ///
  /// In et, this message translates to:
  /// **'Kogus'**
  String get quantity;

  /// Single ticket type name
  ///
  /// In et, this message translates to:
  /// **'Muuseumi pilet'**
  String get ticketSingle;

  /// Single ticket type description
  ///
  /// In et, this message translates to:
  /// **'Sissepääs'**
  String get ticketSingleDesc;

  /// Label for the ticket price in admin
  ///
  /// In et, this message translates to:
  /// **'Piletihind'**
  String get ticketPrice;

  /// Button to change the ticket price
  ///
  /// In et, this message translates to:
  /// **'Muuda hinda'**
  String get changePrice;

  /// Dialog title for price entry
  ///
  /// In et, this message translates to:
  /// **'Uus hind (€)'**
  String get newPriceEuros;

  /// No description provided for @ticketAdult.
  ///
  /// In et, this message translates to:
  /// **'Täiskasvanu'**
  String get ticketAdult;

  /// No description provided for @ticketAdultDesc.
  ///
  /// In et, this message translates to:
  /// **'Täishind, 18+'**
  String get ticketAdultDesc;

  /// No description provided for @ticketChild.
  ///
  /// In et, this message translates to:
  /// **'Laps'**
  String get ticketChild;

  /// No description provided for @ticketChildDesc.
  ///
  /// In et, this message translates to:
  /// **'Soodushind, 7–17'**
  String get ticketChildDesc;

  /// No description provided for @ticketFamily.
  ///
  /// In et, this message translates to:
  /// **'Pere'**
  String get ticketFamily;

  /// No description provided for @ticketFamilyDesc.
  ///
  /// In et, this message translates to:
  /// **'2 täiskasvanut + kuni 3 last'**
  String get ticketFamilyDesc;

  /// No description provided for @ticketSenior.
  ///
  /// In et, this message translates to:
  /// **'Senior / Üliõpilane'**
  String get ticketSenior;

  /// No description provided for @ticketSeniorDesc.
  ///
  /// In et, this message translates to:
  /// **'65+ või kehtiv üliõpilaspilet'**
  String get ticketSeniorDesc;
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
      <String>['de', 'en', 'et'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'et':
      return AppLocalizationsEt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
