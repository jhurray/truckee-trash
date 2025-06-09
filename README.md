# Truckee Trash

Truckee Trash is a multi-platform project consisting of a Next.js web application and an iOS app. Both share business logic for determining weekly trash, recycling, or yard-waste pickup schedules.

## Repository Structure

- **Web App (Next.js + TypeScript)** – Located at the repository root.
  - `pages/` – Next.js pages and API routes.
  - `components/` – Reusable React components.
  - `lib/` – Core date and pickup logic with Jest tests.
- **iOS App (SwiftUI)** – Under `ios/`. See [`ios/README.md`](ios/README.md) for full details.

## Getting Started (Web)

1. Install dependencies:
   ```bash
   npm install
   ```
2. Start the development server:
   ```bash
   npm run dev
   ```
   Visit `http://localhost:3000` to view the app.
3. Run the unit tests:
   ```bash
   npm test
   ```
## Generating Images= Assets

This project contains a small Next.js web app and an iOS project. Images used in both platforms can be managed from `assets/source`. To (re)generate platform specific assets run:

```bash
npm run images:generate
```

The command reads each image in `assets/source` and produces:

- iOS `1x`, `2x`, and `3x` images in `ios/Resources/Assets.xcassets/<image>.imageset` with an accompanying `Contents.json` file.
- Web `small`, `medium`, and `large` versions in the `public` folder named `<image>-small.png`, `<image>-medium.png`, and `<image>-large.png`.

The script uses the [sharp](https://github.com/lovell/sharp) library to resize images.


## How It Works

The logic in `lib/weekLogic.ts` and `lib/pickupLogic.ts` calculates which type of pickup is scheduled for a given date. API routes under `pages/api/` expose this logic for other clients such as the iOS app.

### TailwindCSS

Styling uses Tailwind CSS. Global styles are defined in `styles/globals.css` and configured via `tailwind.config.js`.

### API Usage

Other applications can query the API endpoints, for example:

- `/api/pickup-type?date=2025-04-15`
- `/api/relevant-week-pickup-status?date=2025-04-15`

## iOS Project

The SwiftUI project shares the same logic via these API routes. To generate the Xcode workspace, follow the steps in [`ios/README.md`](ios/README.md).

## Contributing

1. Fork and clone the repository.
2. Install dependencies and run the tests.
3. Submit pull requests for review.

