---
name: Aether Luxury Home
colors:
  surface: '#111317'
  surface-dim: '#111317'
  surface-bright: '#37393d'
  surface-container-lowest: '#0c0e11'
  surface-container-low: '#1a1c1f'
  surface-container: '#1e2023'
  surface-container-high: '#282a2d'
  surface-container-highest: '#333538'
  on-surface: '#e2e2e6'
  on-surface-variant: '#d0c5af'
  inverse-surface: '#e2e2e6'
  inverse-on-surface: '#2f3034'
  outline: '#99907c'
  outline-variant: '#4d4635'
  surface-tint: '#e9c349'
  primary: '#f2ca50'
  on-primary: '#3c2f00'
  primary-container: '#d4af37'
  on-primary-container: '#554300'
  inverse-primary: '#735c00'
  secondary: '#c4c6ce'
  on-secondary: '#2d3037'
  secondary-container: '#464950'
  on-secondary-container: '#b6b8c0'
  tertiary: '#cacedd'
  on-tertiary: '#2b303b'
  tertiary-container: '#aeb3c1'
  on-tertiary-container: '#404551'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#ffe088'
  primary-fixed-dim: '#e9c349'
  on-primary-fixed: '#241a00'
  on-primary-fixed-variant: '#574500'
  secondary-fixed: '#e1e2ea'
  secondary-fixed-dim: '#c4c6ce'
  on-secondary-fixed: '#191c22'
  on-secondary-fixed-variant: '#44474d'
  tertiary-fixed: '#dee2f1'
  tertiary-fixed-dim: '#c2c6d4'
  on-tertiary-fixed: '#171c26'
  on-tertiary-fixed-variant: '#424752'
  background: '#111317'
  on-background: '#e2e2e6'
  surface-variant: '#333538'
typography:
  headline-xl:
    fontFamily: Manrope
    fontSize: 48px
    fontWeight: '200'
    lineHeight: '1.1'
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Manrope
    fontSize: 32px
    fontWeight: '300'
    lineHeight: '1.2'
    letterSpacing: 0.02em
  headline-lg-mobile:
    fontFamily: Manrope
    fontSize: 28px
    fontWeight: '300'
    lineHeight: '1.2'
  section-title:
    fontFamily: Manrope
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.15em
  body-lg:
    fontFamily: Manrope
    fontSize: 18px
    fontWeight: '300'
    lineHeight: 28px
  body-md:
    fontFamily: Manrope
    fontSize: 15px
    fontWeight: '400'
    lineHeight: 22px
  label-sm:
    fontFamily: Manrope
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 14px
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 8px
  container-padding: 24px
  gutter: 16px
  stack-sm: 8px
  stack-md: 16px
  stack-lg: 32px
  section-gap: 48px
---

## Brand & Style

This design system embodies the "Quiet Luxury" aesthetic—sophisticated, understated, and exclusive. It is tailored for high-net-worth individuals managing luxury residences. The UI prioritizes a sense of calm and control through significant negative space and a restrained palette.

The visual style is a blend of **Minimalism** and **Glassmorphism**. It utilizes deep atmospheric backgrounds paired with ultra-thin strokes and subtle translucency. The interface should feel like a premium physical material—obsidian glass or brushed metal—rather than a digital interface. Interactions are fluid and deliberate, reinforcing the premium nature of the service.

## Colors

The palette is rooted in deep, cinematic darkness to reduce eye strain and emphasize the "concierge" nature of the application.

- **Primary:** A refined "Estate Gold" used sparingly for high-priority status indicators, active states, and critical alerts.
- **Backgrounds:** The foundation is a rich charcoal (`#0D0F12`), not true black, to allow for depth perception.
- **Surfaces:** UI containers use subtle gradients of deep navy-grey to create a "glass" effect against the dark background.
- **Typography:** Primary text is a soft white/off-grey to maintain high legibility without the harshness of pure white. Secondary text is muted to create a clear information hierarchy.

## Typography

The design system utilizes **Manrope** for its technical precision and modern elegance. The typographic hierarchy is characterized by extreme weight contrasts—using very thin (200/300) weights for large display text and medium weights for functional labels.

Large headlines should use "Light" weights to evoke a sense of airiness and luxury. Section headers utilize increased letter spacing and uppercase styling to act as architectural dividers within the layout. All body copy is set with generous line heights to ensure a relaxed reading experience.

## Layout & Spacing

This design system uses a **Fluid Grid** model with generous safe areas. The layout philosophy is "Information Breathing Room." 

- **Mobile:** A 4-column grid with 24px side margins. Elements are typically full-width or split 50/50.
- **Desktop/Tablet:** A 12-column grid centered within a max-width container of 1440px. 
- **Rhythm:** All spacing is based on an 8px incremental scale. Vertical rhythm is intentionally loose to prevent the interface from feeling cluttered or "utility-heavy."

## Elevation & Depth

Hierarchy is established through **Tonal Layering** and **Backdrop Blurs** rather than traditional drop shadows.

- **Base Layer:** The deepest background, often featuring a very subtle, large-scale radial gradient or a blurred environmental image.
- **Surface Layer:** Cards and containers use a semi-transparent fill (approx. 4-8% opacity) with a `20px` to `40px` backdrop blur.
- **Borders:** Surfaces are defined by ultra-thin (1px) borders with a low-opacity white or grey stroke, creating a "glint" effect on the edges.
- **Active State:** Elements may gain a subtle inner glow or a primary-colored accent line to indicate focus.

## Shapes

The shape language is consistently **Rounded**. The standard radius is `16px` (1rem) for primary cards and buttons, providing a soft, approachable feel that balances the sharp, technical typography.

Larger container components (like bottom sheets or main dashboard cards) utilize `24px` to `32px` radii. Small interactive elements like chips or status dots may use pill-shapes (fully rounded) to differentiate them from structural layout blocks.

## Components

- **Cards:** The signature component. Feature a 1px border, backdrop blur, and a subtle vertical gradient. Content inside is aligned with generous internal padding (min 24px).
- **Buttons:** Primary buttons are either ghost-style with a thin border or solid dark grey with a primary gold icon. Avoid heavy, high-saturation solid buttons.
- **Status Indicators:** Use the "Estate Gold" color as a 6px dot or a thin 2px underline. This color is reserved strictly for indicating "active" or "in-progress" states.
- **Icons:** Use thin-stroke (1.5px) linear icons. Icons should be monochrome (muted grey) unless they represent an active status.
- **Lists & Timelines:** Use vertical hair-lines (1px) to connect temporal events. Use low-contrast circles for nodes, with the primary color indicating the "current" point in time.
- **Navigation:** A persistent bottom blur-bar with minimalist icons. The active state is signaled by a primary-colored dot below the icon.