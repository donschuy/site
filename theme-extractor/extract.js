import path from 'path';
import fs from 'fs';
import sharp from 'sharp';

// Helper: Converts RGB object to a Hexadecimal String
function rgbToHex(r, g, b) {
  return "#" + [r, g, b].map(x => {
    const hex = x.toString(16);
    return hex.length === 1 ? "0" + hex : hex;
  }).join("");
}

// Helper: Calculates relative luminance to decide on light/dark text overlays
function getContrastThemes(r, g, b) {
  const normR = r / 255;
  const normG = g / 255;
  const normB = b / 255;
  
  // Standard WCAG relative luminance formula
  const luminance = 0.2126 * normR + 0.7152 * normG + 0.0722 * normB;

  // If luminance > 0.5, the color is "light" (needs dark text). Otherwise, use light text.
  if (luminance > 0.5) {
    return {
      titleColor: '#000000', // Solid black
      dateColor: '#595959'   // Subdued dark gray
    };
  } else {
    return {
      titleColor: '#FFFFFF', // Clean white
      dateColor: '#D3D3D3'   // Subdued silver gray
    };
  }
}

async function main() {
  const imageArg = process.argv[2];

  if (!imageArg) {
    console.error('\x1b[31mError: Please provide a path to a .webp image.\x1b[0m');
    console.log('Usage: node extract.js <path-to-image.webp>');
    process.exit(1);
  }

  const resolvedPath = path.resolve(imageArg);

  if (!fs.existsSync(resolvedPath)) {
    console.error(`\x1b[31mError: File not found at "${resolvedPath}"\x1b[0m`);
    process.exit(1);
  }

  try {
    console.log('Processing WebP image color extraction with sharp...');
    
    // Resize image to 1x1 pixel using sharp. 
    // This extracts the mathematical average/dominant color of the photo seamlessly!
    const { data } = await sharp(resolvedPath)
      .resize(1, 1, { fit: 'cover' })
      .raw()
      .toBuffer({ resolveWithObject: true });

    // Grab the raw RGB channels from our 1x1 buffer
    const r = data[0];
    const g = data[1];
    const b = data[2];

    const borderColor = rgbToHex(r, g, b);
    const textThemes = getContrastThemes(r, g, b);

    // Print values directly to your terminal
    console.log('\n--- Extracted theme values for the page .md file ---');

    console.log(`      "previewBorderStyle": "background-color:\x1b[36m${borderColor}\x1b[0m;border-color:\x1b[36m${borderColor}\x1b[0m",`);
    console.log(`      "titleStyle": "color:\x1b[32m${textThemes.titleColor}\x1b[0m",`);
    console.log(`      "dateStyle": "color:\x1b[32m${textThemes.dateColor}\x1b[0m"`);

  } catch (error) {
    console.error('\x1b[31mFailed to parse image:\x1b[0m', error.message);
    process.exit(1);
  }
}

main();
