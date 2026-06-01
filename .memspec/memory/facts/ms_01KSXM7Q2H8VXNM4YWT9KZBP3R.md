---
id: ms_01KSXM7Q2H8VXNM4YWT9KZBP3R
type: fact
state: active
confidence: 0.9
created: '2026-06-01T00:00:00.000Z'
source: claude
tags:
  - kiosk
  - ui
  - attract
  - l10n
decay_after: '2026-08-30T00:00:00.000Z'
---
# Attract-screen UI conventions and the museum-name display gotcha

The attract screen (`lib/features/attract/screens/attract_screen.dart`) uses a pure-black
background plus an OLED burn-in drift of the centred content. The drift is **idle-gated**: it
only starts after the screen sits untouched for 3 min (`_idleBeforeDrift`), and a top-level
`Listener.onPointerDown` recentres it on any touch — so it never moves while a visitor
interacts (this was a fix; an always-repeating controller was distracting during language
switches). Amplitude is small (±6 px X / ±4 px Y, 45 s cycle, sin/sin so it rests at the
origin). The language buttons are intentionally large (h28/v18 padding, titleLarge) at 0.8
opacity.

Gotcha: the museum name shown to visitors on the attract screen is the **localized**
`l10n.museumDisplayName` ("Eppingi torn" / "Epping Tower" / "Eppingi Turm"), NOT the
`MUSEUM_NAME` dart-define. `config.museumName` (the dart-define) is used only as the
MaterialApp title and in startup logs. Do not "fix" the attract screen to read
`config.museumName` — that change was intentionally reverted.

The confirmation screen no longer displays the SumUp transaction ref to visitors; the code is
still persisted in `Orders.sumupTransactionCode` and sent via the receipt webhook. The ticket
selection screen has no AppBar by design (the card carries its own heading).

The admin dashboard has a single refresh, "Sync catalog" (pulls ticket types/price from the
backend over the network). There is deliberately no separate "Today's sales" refresh:
`todaySalesProvider` is an autoDispose `Future` re-queried on every admin entry, and no sale can
happen while the single-screen kiosk shows the admin panel, so a manual sales refresh could
never display different data.
