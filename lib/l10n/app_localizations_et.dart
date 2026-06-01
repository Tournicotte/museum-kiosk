// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Estonian (`et`).
class AppLocalizationsEt extends AppLocalizations {
  AppLocalizationsEt([String locale = 'et']) : super(locale);

  @override
  String get museumDisplayName => 'Eppingi torn';

  @override
  String get touchToStart => 'Puuduta ekraani piletite ostmiseks';

  @override
  String get orderSummary => 'Tellimuse kokkuvõte';

  @override
  String get total => 'Kokku';

  @override
  String get payByCard => 'Maksa kaardiga';

  @override
  String get cancel => 'Tühista';

  @override
  String get processingPayment => 'Makse töötlemisel…';

  @override
  String get doNotRemoveCard => 'Ärge eemaldage kaarti';

  @override
  String get paymentSuccessful => 'Makse õnnestus!';

  @override
  String get receiptSent => 'Kviitung on saadetud.';

  @override
  String returningIn(int seconds) {
    return 'Tagasi $seconds sekundi pärast…';
  }

  @override
  String get done => 'Valmis';

  @override
  String get paymentFailed => 'Makse ebaõnnestus';

  @override
  String get tryAgain => 'Proovi uuesti';

  @override
  String get startAgain => 'Alusta uuesti';

  @override
  String get adminTitle => 'Haldus';

  @override
  String get enterPin => 'Sisesta PIN-kood';

  @override
  String get unlock => 'Ava';

  @override
  String get incorrectPin => 'Vale PIN-kood';

  @override
  String get todaySales => 'Tänased müügid';

  @override
  String get syncCatalog => 'Uuenda piletikataloog';

  @override
  String lastSynced(String time) {
    return 'Sünkroniseeritud: $time';
  }

  @override
  String get neverSynced => 'Sünkroniseerimine puudub';

  @override
  String get syncingNow => 'Sünkroniseerimisel…';

  @override
  String get syncStale => 'Andmed võivad olla aegunud (>24h)';

  @override
  String get quantity => 'Kogus';

  @override
  String get ticketSingle => 'Muuseumi pilet';

  @override
  String get ticketSingleDesc => 'Sissepääs';

  @override
  String get ticketPrice => 'Piletihind';

  @override
  String get changePrice => 'Muuda hinda';

  @override
  String get newPriceEuros => 'Uus hind (€)';

  @override
  String get ticketAdult => 'Täiskasvanu';

  @override
  String get ticketAdultDesc => 'Täishind, 18+';

  @override
  String get ticketChild => 'Laps';

  @override
  String get ticketChildDesc => 'Soodushind, 7–17';

  @override
  String get ticketFamily => 'Pere';

  @override
  String get ticketFamilyDesc => '2 täiskasvanut + kuni 3 last';

  @override
  String get ticketSenior => 'Senior / Üliõpilane';

  @override
  String get ticketSeniorDesc => '65+ või kehtiv üliõpilaspilet';
}
