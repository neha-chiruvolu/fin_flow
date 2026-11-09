# FinFlow – Expense Tracker (Flutter Web)

Responsive expense tracker. Palette: blues + greens with a mustard accent.

## Concepts covered
| Requirement | Where |
|---|---|
| Widgets (Container, Row, Column, Stack, ListView, Card-style, Buttons…) | `widgets/common.dart`, all screens |
| Responsive UI | `LayoutBuilder` / `MediaQuery` – bottom bar (mobile), rail (tablet), extended rail + 2-column (desktop) |
| Navigation | Named routes `/`, `/home`, custom animated `/add`; tab navigation in `home_shell.dart` |
| Animations | `TweenAnimationBuilder` (donut, bars, counters, entrances), `AnimatedSwitcher`, page transition, `Dismissible` |
| State management | `Provider` + `ChangeNotifier` (`expense_provider.dart`), `StatefulWidget` for local state; data persisted with `shared_preferences` |
| Themes & custom widgets | `theme.dart`, `AppCard`, `FadeIn`, `DonutChart`, `WeeklyBars`, `Legend`, `TxTile` |
| Forms & validation | Welcome (name/email), Add transaction, Profile (name/budget) |

## Run locally
```bash
flutter create . --platforms=web      # generates the web/ folder (run once)
flutter pub get
flutter run -d chrome
```

## Publish so anyone can open it (free)
**GitHub Pages (automatic):** push this folder to a GitHub repo on `main`
→ repo *Settings → Pages → Source: GitHub Actions*. The included workflow builds and
publishes it; the link is `https://<username>.github.io/<repo>/`.

**Or Firebase Hosting / Netlify:**
```bash
flutter build web --release
# Netlify: drag-and-drop the build/web folder at app.netlify.com/drop
# Firebase: firebase init hosting (public dir: build/web) && firebase deploy
```
