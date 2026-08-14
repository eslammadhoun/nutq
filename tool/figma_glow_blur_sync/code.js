// Nutq — Glow Blur Sync
//
// One-off design automation: the dark Splash/Onboarding screens have a
// LAYER_BLUR on the radial glow ellipse; the light ones don't. This plugin
// applies the same blur to the light frames and normalizes the dark ones,
// so both themes share the blurred-glow look. Idempotent — safe to re-run.

const TARGETS = [
  // Light (missing the blur)
  { id: '11:2', blur: 24 }, // Splash — Light
  { id: '11:20', blur: 18 }, // Onboarding 1
  { id: '11:45', blur: 18 }, // Onboarding 2
  { id: '11:73', blur: 18 }, // Onboarding 3
  // Dark (already blurred — re-applied for consistency)
  { id: '2017:2', blur: 24 }, // Splash — Dark
  { id: '2017:370', blur: 18 }, // Onboarding 1 — Dark
  { id: '2017:383', blur: 18 }, // Onboarding 2 — Dark
  { id: '2017:396', blur: 18 }, // Onboarding 3 — Dark
];

(async () => {
  const report = [];

  for (const { id, blur } of TARGETS) {
    const frame = await figma.getNodeByIdAsync(id);
    if (!frame) {
      report.push(`⚠️ ${id}: frame not found`);
      continue;
    }

    // The glow = largest direct-child ellipse with a radial-gradient fill.
    const glows = frame.children.filter(
      (n) =>
        n.type === 'ELLIPSE' &&
        Array.isArray(n.fills) &&
        n.fills.some((f) => f.type === 'GRADIENT_RADIAL' && f.visible !== false),
    );
    if (glows.length === 0) {
      report.push(`⚠️ ${frame.name}: no gradient glow ellipse found`);
      continue;
    }
    const glow = glows.reduce((a, b) => (a.width >= b.width ? a : b));

    glow.effects = [
      ...glow.effects.filter((e) => e.type !== 'LAYER-BLUR'),
      { type: 'LAYER-BLUR', radius: blur, visible: true },
    ];
    report.push(`✅ ${frame.name}: LAYER_BLUR r=${blur}`);
  }

  console.log(report.join('\n'));
  const ok = report.filter((r) => r.startsWith('✅')).length;
  figma.notify(`Glow blur applied to ${ok}/${TARGETS.length} frames (details in console)`, {
    timeout: 5000,
  });
  figma.closePlugin();
})();
