const fs = require("fs");
const path = require("path");
const { minify: minifyHTML } = require("html-minifier-terser");
const { minify: minifyJS } = require("terser");

async function build() {
  const src = fs.readFileSync(path.join(__dirname, "index.html"), "utf8");

  // 1. Extract inline <script> blocks, obfuscate with terser, store aside
  const scriptRegex = /(<script>)([\s\S]*?)(<\/script>)/g;
  const obfuscatedScripts = [];
  let htmlWithPlaceholders = src;
  let match;
  let idx = 0;

  // Collect all matches first
  const matches = [];
  while ((match = scriptRegex.exec(src)) !== null) {
    matches.push({ full: match[0], js: match[2] });
  }

  // Obfuscate each script and replace with a placeholder
  for (const m of matches) {
    const placeholder = `<!--SCRIPT_PLACEHOLDER_${idx}-->`;
    const result = await minifyJS(m.js, {
      compress: {
        dead_code: true,
        drop_console: false,
        passes: 2,
      },
      mangle: {
        toplevel: true,
        reserved: ["recalculate", "syncCcCheckbox"],
      },
      format: {
        comments: false,
      },
    });
    obfuscatedScripts.push(result.code || "");
    htmlWithPlaceholders = htmlWithPlaceholders.replace(m.full, placeholder);
    idx++;
  }

  // 2. Minify the HTML (no script content to confuse the parser)
  let output = await minifyHTML(htmlWithPlaceholders, {
    collapseWhitespace: true,
    removeComments: false, // keep our placeholders
    minifyCSS: true,
    minifyJS: false,
    removeRedundantAttributes: true,
    removeEmptyAttributes: true,
  });

  // 3. Swap placeholders back with obfuscated scripts
  for (let i = 0; i < obfuscatedScripts.length; i++) {
    output = output.replace(
      `<!--SCRIPT_PLACEHOLDER_${i}-->`,
      `<script>${obfuscatedScripts[i]}</script>`,
    );
  }

  // 4. Now strip remaining HTML comments
  output = output.replace(/<!--[\s\S]*?-->/g, "");

  // Write to dist/
  const distDir = path.join(__dirname, "dist");
  if (!fs.existsSync(distDir)) fs.mkdirSync(distDir);
  fs.writeFileSync(path.join(distDir, "index.html"), output, "utf8");

  // Copy static assets
  for (const file of ["solvivalogo.png", "solvivafavicon.png"]) {
    const src_path = path.join(__dirname, file);
    if (fs.existsSync(src_path)) {
      fs.copyFileSync(src_path, path.join(distDir, file));
    }
  }

  const srcSize = (Buffer.byteLength(src) / 1024).toFixed(1);
  const outSize = (Buffer.byteLength(output) / 1024).toFixed(1);
  console.log(
    `Build complete: ${srcSize} KB -> ${outSize} KB (${Math.round((1 - outSize / srcSize) * 100)}% smaller)`,
  );
  console.log(`Output: dist/index.html`);
}

build().catch((err) => {
  console.error("Build failed:", err);
  process.exit(1);
});
