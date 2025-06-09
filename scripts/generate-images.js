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

function detectImageMode(filename) {
  const baseName = path.parse(filename).name;
  if (baseName.endsWith('-dark')) {
    return { mode: 'dark', baseName: baseName.slice(0, -5) };
  } else if (baseName.endsWith('-light')) {
    return { mode: 'light', baseName: baseName.slice(0, -6) };
  }
  return { mode: 'universal', baseName };
}

async function processImage(file) {
  if (!/\.(png|jpe?g)$/i.test(file)) return;
  
  const { mode, baseName } = detectImageMode(file);
  const inputPath = path.join(sourceDir, file);
  
  console.log(`\n📸 Processing: ${file}`);
  console.log(`   Mode: ${mode}, Base name: ${baseName}`);
  
  try {
    const metadata = await sharp(inputPath).metadata();

    // iOS assets
    const iosSetDir = path.join(iosAssetsDir, `${baseName}.imageset`);
    ensureDir(iosSetDir);
    
    console.log(`   📱 iOS: Creating assets in ${baseName}.imageset/`);
    
    // Process scales for current mode
    for (const scale of iosScales) {
      const width = Math.round((metadata.width / 3) * scale);
      const suffix = mode === 'universal' ? '' : `-${mode}`;
      const filename = scale === 1 ? `${baseName}${suffix}.png` : `${baseName}${suffix}@${scale}x.png`;
      const outputPath = path.join(iosSetDir, filename);
      
      await sharp(inputPath).resize({ width }).toFile(outputPath);
      console.log(`      ✅ Created: ${filename} (${width}px)`);
    }
    
    // Update Contents.json
    updateiOSContentsJson(iosSetDir, baseName);
    console.log(`      ✅ Updated: Contents.json`);

    // Web assets
    console.log(`   🌐 Web: Creating assets in public/`);
    for (const [suffix, width] of Object.entries(webSizes)) {
      const modePrefix = mode === 'universal' ? '' : `${mode}-`;
      const outName = `${baseName}-${modePrefix}${suffix}.png`;
      const outputPath = path.join(webDir, outName);
      
      await sharp(inputPath).resize({ width }).toFile(outputPath);
      console.log(`      ✅ Created: ${outName} (${width}px)`);
    }
    
    console.log(`   ✨ Successfully processed ${file}`);
    
  } catch (error) {
    console.error(`   ❌ Error processing ${file}: ${error.message}`);
  }
}

function updateiOSContentsJson(iosSetDir, baseName) {
  const contentsPath = path.join(iosSetDir, 'Contents.json');
  let contents = { images: [], info: { author: 'xcode', version: 1 } };
  
  // Read existing contents if exists
  if (fs.existsSync(contentsPath)) {
    try {
      contents = JSON.parse(fs.readFileSync(contentsPath, 'utf8'));
    } catch (e) {
      console.warn(`      ⚠️  Could not parse existing Contents.json, creating new one`);
    }
  }
  
  // Check which files exist and build the images array
  const images = [];
  
  // Check for universal images
  const hasUniversal = fs.existsSync(path.join(iosSetDir, `${baseName}.png`));
  const hasLight = fs.existsSync(path.join(iosSetDir, `${baseName}-light.png`));
  const hasDark = fs.existsSync(path.join(iosSetDir, `${baseName}-dark.png`));
  
  if (hasUniversal && !hasLight && !hasDark) {
    // Only universal images
    for (const scale of iosScales) {
      const filename = scale === 1 ? `${baseName}.png` : `${baseName}@${scale}x.png`;
      images.push({ filename, idiom: 'universal', scale: `${scale}x` });
    }
  } else if (hasLight && hasDark) {
    // Both light and dark mode images
    for (const scale of iosScales) {
      // Light appearance (default - no appearance specified)
      const lightFilename = scale === 1 ? `${baseName}-light.png` : `${baseName}-light@${scale}x.png`;
      images.push({
        filename: lightFilename,
        idiom: 'universal',
        scale: `${scale}x`
      });
      
      // Dark appearance
      const darkFilename = scale === 1 ? `${baseName}-dark.png` : `${baseName}-dark@${scale}x.png`;
      images.push({
        filename: darkFilename,
        appearances: [{ appearance: 'luminosity', value: 'dark' }],
        idiom: 'universal',
        scale: `${scale}x`
      });
    }
  } else if (hasLight || hasDark) {
    // Only one mode available - use it as universal
    console.warn(`      ⚠️  Only ${hasLight ? 'light' : 'dark'} mode found for ${baseName}, using as universal`);
    for (const scale of iosScales) {
      const mode = hasLight ? 'light' : 'dark';
      const filename = scale === 1 ? `${baseName}-${mode}.png` : `${baseName}-${mode}@${scale}x.png`;
      images.push({ filename, idiom: 'universal', scale: `${scale}x` });
    }
  }
  
  contents.images = images;
  fs.writeFileSync(contentsPath, JSON.stringify(contents, null, 2));
}

async function run() {
  console.log('🎨 Starting image generation...');
  console.log(`📁 Source: ${sourceDir}`);
  console.log(`📱 iOS Output: ${iosAssetsDir}`);
  console.log(`🌐 Web Output: ${webDir}\n`);
  
  try {
    const files = fs.readdirSync(sourceDir);
    const imageFiles = files.filter(f => /\.(png|jpe?g)$/i.test(f));
    
    if (imageFiles.length === 0) {
      console.log('⚠️  No image files found in source directory');
      return;
    }
    
    console.log(`Found ${imageFiles.length} image(s) to process`);
    
    for (const file of imageFiles) {
      await processImage(file);
    }
    
    console.log('\n✅ Image generation completed successfully!');
  } catch (error) {
    console.error(`\n❌ Fatal error: ${error.message}`);
    process.exit(1);
  }
}

run().catch(err => {
  console.error(err);
  process.exit(1);
});