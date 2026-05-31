// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get touchToStart => 'Bildschirm berühren, um Tickets zu kaufen';

  @override
  String get selectTickets => 'Tickets auswählen';

  @override
  String get orderSummary => 'Bestellübersicht';

  @override
  String get total => 'Gesamt';

  @override
  String get payByCard => 'Mit Karte bezahlen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get processingPayment => 'Zahlung wird verarbeitet…';

  @override
  String get doNotRemoveCard => 'Karte nicht entfernen';

  @override
  String get paymentSuccessful => 'Zahlung erfolgreich!';

  @override
  String get receiptSent => 'Ihre Quittung wurde gesendet.';

  @override
  String returningIn(int seconds) {
    return 'Zurück in $seconds Sekunden…';
  }

  @override
  String get done => 'Fertig';

  @override
  String get paymentFailed => 'Zahlung fehlgeschlagen';

  @override
  String get tryAgain => 'Erneut versuchen';

  @override
  String get startAgain => 'Neu starten';

  @override
  String get ref => 'Ref';

  @override
  String get adminTitle => 'Verwaltung';

  @override
  String get enterPin => 'PIN eingeben';

  @override
  String get unlock => 'Entsperren';

  @override
  String get incorrectPin => 'Falscher PIN';

  @override
  String get todaySales => 'Heutige Verkäufe';

  @override
  String get syncCatalog => 'Ticketkatalog synchronisieren';

  @override
  String lastSynced(String time) {
    return 'Synchronisiert: $time';
  }

  @override
  String get neverSynced => 'Nie synchronisiert';

  @override
  String get syncingNow => 'Synchronisierung…';

  @override
  String get syncStale => 'Daten können veraltet sein (>24 Std.)';

  @override
  String get quantity => 'Anzahl';

  @override
  String get ticketSingle => 'Museumsticket';

  @override
  String get ticketSingleDesc => 'Eintritt';

  @override
  String get ticketPrice => 'Ticketpreis';

  @override
  String get changePrice => 'Preis ändern';

  @override
  String get newPriceEuros => 'Neuer Preis (€)';

  @override
  String get ticketAdult => 'Erwachsener';

  @override
  String get ticketAdultDesc => 'Voller Preis, ab 18 Jahren';

  @override
  String get ticketChild => 'Kind';

  @override
  String get ticketChildDesc => 'Ermäßigt, 7–17 Jahre';

  @override
  String get ticketFamily => 'Familie';

  @override
  String get ticketFamilyDesc => '2 Erwachsene + bis zu 3 Kinder';

  @override
  String get ticketSenior => 'Senior / Student';

  @override
  String get ticketSeniorDesc => 'Ab 65 Jahren oder gültiger Studentenausweis';
}
