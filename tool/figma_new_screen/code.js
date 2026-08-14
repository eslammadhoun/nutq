// Nutq — New Blue Screen
//
// One-off design automation: adds a new screen (top-level frame) to the
// current page of the Nutq Figma file with a solid brand-blue background.
// Screen size matches the project's design canvas (390 × 844, iPhone 14)
// and the blue is the design-system primary500 token (#1A56DB).
//
// Run from: Figma desktop → Plugins → Development → "Nutq — New Blue Screen".
// Re-running creates additional screens (numbered), so run once per screen.

const SCREEN_NAME = 'New Screen — Blue';
const WIDTH = 390; // iPhone 14 canvas, per docs/DESIGN_SYSTEM.md
const HEIGHT = 844;
const BLUE_HEX = '#1A56DB'; // primary500 ★ brand blue
const GAP = 200; // horizontal gap from the rightmost existing screen

function hexToRgb(hex) {
  const n = parseInt(hex.replace('#', ''), 16);
  return { r: ((n >> 16) & 255) / 255, g: ((n >> 8) & 255) / 255, b: (n & 255) / 255 };
}

(async () => {
  const page = figma.currentPage;
  await page.loadAsync(); // required with documentAccess: "dynamic-page"

  // Place the new screen to the right of the rightmost top-level node.
  const rightEdge = page.children.reduce(
    (max, node) => Math.max(max, node.x + node.width),
    0,
  );

  const frame = figma.createFrame();
  frame.name = SCREEN_NAME;
  frame.resize(WIDTH, HEIGHT);
  frame.x = page.children.length > 0 ? rightEdge + GAP : 0;
  frame.y = 0;
  frame.clipsContent = true;
  frame.fills = [{ type: 'SOLID', color: hexToRgb(BLUE_HEX) }];
  page.appendChild(frame);

  // Reveal the result: select the new screen and zoom the viewport to it.
  page.selection = [frame];
  figma.viewport.scrollAndZoomIntoView([frame]);

  console.log(`✅ Created "${frame.name}" (${frame.id}) ${WIDTH}×${HEIGHT}, bg ${BLUE_HEX}`);
  figma.notify(`New screen created with ${BLUE_HEX} background`, { timeout: 4000 });
  figma.closePlugin();
})();
