// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get touchToStart => 'Touch screen to buy tickets';

  @override
  String get selectTickets => 'Select Tickets';

  @override
  String get orderSummary => 'Order Summary';

  @override
  String get total => 'Total';

  @override
  String get payByCard => 'Pay by Card';

  @override
  String get cancel => 'Cancel';

  @override
  String get processingPayment => 'Processing payment…';

  @override
  String get doNotRemoveCard => 'Do not remove card';

  @override
  String get paymentSuccessful => 'Payment successful!';

  @override
  String get receiptSent => 'Your receipt has been sent.';

  @override
  String returningIn(int seconds) {
    return 'Returning in $seconds seconds…';
  }

  @override
  String get done => 'Done';

  @override
  String get paymentFailed => 'Payment unsuccessful';

  @override
  String get tryAgain => 'Try again';

  @override
  String get startAgain => 'Start again';

  @override
  String get ref => 'Ref';

  @override
  String get adminTitle => 'Admin';

  @override
  String get enterPin => 'Enter admin PIN';

  @override
  String get unlock => 'Unlock';

  @override
  String get incorrectPin => 'Incorrect PIN';

  @override
  String get todaySales => 'Today\'s sales';

  @override
  String get syncCatalog => 'Sync ticket catalog';

  @override
  String lastSynced(String time) {
    return 'Last synced: $time';
  }

  @override
  String get neverSynced => 'Never synced';

  @override
  String get syncingNow => 'Syncing…';

  @override
  String get syncStale => 'Data may be outdated (>24 h)';

  @override
  String get quantity => 'Quantity';

  @override
  String get ticketSingle => 'Museum ticket';

  @override
  String get ticketSingleDesc => 'Entry';

  @override
  String get ticketPrice => 'Ticket price';

  @override
  String get changePrice => 'Change price';

  @override
  String get newPriceEuros => 'New price (€)';

  @override
  String get ticketAdult => 'Adult';

  @override
  String get ticketAdultDesc => 'Full price, age 18+';

  @override
  String get ticketChild => 'Child';

  @override
  String get ticketChildDesc => 'Reduced price, age 7–17';

  @override
  String get ticketFamily => 'Family';

  @override
  String get ticketFamilyDesc => '2 adults + up to 3 children';

  @override
  String get ticketSenior => 'Senior / Student';

  @override
  String get ticketSeniorDesc => 'Age 65+ or valid student ID';
}
