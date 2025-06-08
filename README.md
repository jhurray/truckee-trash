# truckee-trash

This project contains a small Next.js web app and an iOS project. Images used in both platforms can be managed from `assets/source`. To (re)generate platform specific assets run:

```bash
npm run images:generate
```

The command reads each image in `assets/source` and produces:

- iOS `1x`, `2x`, and `3x` images in `ios/Resources/Assets.xcassets/<image>.imageset` with an accompanying `Contents.json` file.
- Web `small`, `medium`, and `large` versions in the `public` folder named `<image>-small.png`, `<image>-medium.png`, and `<image>-large.png`.

The script uses the [sharp](https://github.com/lovell/sharp) library to resize images.

