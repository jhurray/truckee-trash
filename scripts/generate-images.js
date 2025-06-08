const fs = require('fs');
const path = require('path');
const sharp = require('sharp');

const sourceDir = path.join(__dirname, '../assets/source');
const iosAssetsDir = path.join(__dirname, '../ios/Resources/Assets.xcassets');
const webDir = path.join(__dirname, '../public');

const iosScales = [1, 2, 3];
const webSizes = { small: 300, medium: 600, large: 900 };

function ensureDir(dir) {
  fs.mkdirSync(dir, { recursive: true });
}

async function processImage(file) {
  if (!/\.(png|jpe?g)$/i.test(file)) return;
  const baseName = path.parse(file).name;
  const inputPath = path.join(sourceDir, file);
  const metadata = await sharp(inputPath).metadata();

  // iOS assets
  const iosSetDir = path.join(iosAssetsDir, `${baseName}.imageset`);
  ensureDir(iosSetDir);
  const iosImages = [];
  for (const scale of iosScales) {
    const width = Math.round((metadata.width / 3) * scale);
    const filename = scale === 1 ? `${baseName}.png` : `${baseName}@${scale}x.png`;
    await sharp(inputPath).resize({ width }).toFile(path.join(iosSetDir, filename));
    iosImages.push({ idiom: 'universal', filename, scale: `${scale}x` });
  }
  fs.writeFileSync(
    path.join(iosSetDir, 'Contents.json'),
    JSON.stringify({ images: iosImages, info: { author: 'xcode', version: 1 } }, null, 2)
  );

  // Web assets
  for (const [suffix, width] of Object.entries(webSizes)) {
    const outName = `${baseName}-${suffix}.png`;
    await sharp(inputPath).resize({ width }).toFile(path.join(webDir, outName));
  }
}

async function run() {
  const files = fs.readdirSync(sourceDir);
  for (const file of files) {
    await processImage(file);
  }
}

run().catch(err => {
  console.error(err);
  process.exit(1);
});
