# Alibi Professional Services — Website

> **This file is an operating manual for AI coding assistants (Claude Code, Cursor, etc.). Read it fully before making any changes to this repo.** Claude Code loads this automatically on session start.

---

## What this project is

A marketing website for **Alibi Professional Services** — a small handyman, yard work, and cleanup business based in central Minnesota, serving **Isanti, Kanabec, and Anoka Counties**. Tagline: *"Making problems disappear."*

**The brand voice is darkly humorous mafia-themed.** The company name is the joke — *"your alibi for the yard work."* The design is intentionally aggressive: high-contrast black and crime-scene-yellow, condensed industrial display typography, animated crime-scene-tape marquees, service cards styled as numbered case files, testimonials from "clients" with redacted names. **This tone is a feature, not a bug.** Do not soften it without being told to.

Three pages total:

1. `/` — home (hero, services, testimonials, CTA)
2. `/about` — story + "The Rules" (6 operating principles)
3. `/contact` — form (Formsubmit.co webhook) + service area info

---

## Tech stack

- **Framework:** [Astro 5](https://astro.build) — static site generator
- **Styling:** plain CSS, no framework, no preprocessor. Every style lives in a single `<style is:global>` block in `src/layouts/Layout.astro`.
- **JavaScript:** vanilla inline `<script is:inline>` — used only for the contact form's AJAX submission.
- **Backend:** none. Fully static. The contact form submits to **Formsubmit.co** as a third-party webhook.
- **Dependencies:** `astro` only. No other runtime deps. Don't add any without a reason.

---

## Getting started

```bash
npm install
npm run dev        # dev server on http://localhost:4321
npm run build      # static output to dist/
npm run preview    # serve the built site locally
```

Requires Node 18+. Tested on Node 24.

---

## Project structure

```
alibi-website/
├── README.md                 # human-facing setup doc
├── CLAUDE.md                 # this file — read this first
├── package.json
├── astro.config.mjs
├── .gitignore
├── concepts/
│   └── 03-crime-scene-bold.html   # preserved pre-refactor baseline — DO NOT EDIT
└── src/
    ├── layouts/
    │   └── Layout.astro       # HTML shell + ALL global CSS lives here
    ├── components/
    │   ├── SiteLogo.astro     # inline SVG logo placeholder
    │   ├── Nav.astro          # sticky nav, aria-current on active page
    │   ├── Footer.astro       # footer with contact info
    │   └── TapeBanner.astro   # animated crime-scene-tape marquee
    └── pages/
        ├── index.astro        # home
        ├── about.astro        # about
        └── contact.astro      # contact + form + inline JS handler
```

**There is no `public/` directory yet.** When the real logo asset arrives, create `public/logo.svg` and update `SiteLogo.astro` to render an `<img>` instead of inline SVG (see "Logo" section below).

---

## Design system — do not invent new tokens

All design tokens live as CSS variables on `:root` in `Layout.astro`. Use them. Don't introduce new colors or fonts.

### Colors

| Token           | Hex       | Usage                                   |
| --------------- | --------- | --------------------------------------- |
| `--yellow`      | `#FFD600` | Primary accent, headlines, CTAs         |
| `--black`       | `#0A0A0A` | Page background                         |
| `--concrete`    | `#2A2A2A` | Card / panel surface                    |
| `--chalk`       | `#F0EDE8` | Body text                               |
| `--orange`      | `#FF6B00` | Eyebrow labels, hover states            |
| `--red`         | `#CC1A1A` | Error states only                       |
| `--tape-edge`   | `#1A1A1A` | Dark stripe in crime-scene tape pattern |

### Typography (all Google Fonts, loaded in `Layout.astro`)

- **Anton** — display / headlines. Condensed industrial sans. Always all-caps.
- **Barlow** (400/500/600/700) — body and UI.
- **JetBrains Mono** (400/500/700) — labels, metadata, "// comment-style" accents.

### Layout conventions

- Max content width: **1200px** (a few older sections use 1100px — fine to standardize to 1200px if touching them).
- Desktop section padding: ~120px vertical, 48px horizontal.
- Button shape: parallelogram cut via `clip-path: polygon(8px 0%, 100% 0%, calc(100% - 8px) 100%, 0% 100%)`.
- Grain overlay: SVG `feTurbulence` noise fixed at `body::after`, `z-index: 9999`.
- Card style: dark `--concrete` background, 4px `--yellow` left border, slight lift on hover.

### Voice / copy rules

The mafia-theme voice is built around dry understatement, not puns or exclamation points. Examples that work:

- *"We show up. We handle it. You never saw us."*
- *"No job too big. No questions asked."*
- *"We let the work do the talking. Our clients prefer it that way."*

Examples that would **not** fit (don't write copy like this):

- "Whack-a-weed special — 20% off!" (too joke-y)
- "Making yard work fun again!" (wrong energy)
- "Certified experts you can trust" (generic, loses the voice)

When writing new copy, match the rhythm of the existing page: short declarative sentences, subtle dark humor, no emoji, no exclamation points.

---

## Contact form — Formsubmit.co

The contact form at `/contact` POSTs to `https://formsubmit.co/ajax/contact@alibiprofessionalservices.com` via `fetch()` and swaps the form for an inline "MESSAGE RECEIVED" card on success. All logic lives in the inline `<script is:inline>` block at the bottom of `src/pages/contact.astro`.

### ⚠️ Activation step — required before form works

Formsubmit requires a one-time email confirmation before it forwards any submissions:

1. The inbox `contact@alibiprofessionalservices.com` **must actually exist** (create the mailbox first).
2. Submit the contact form once with any content.
3. Formsubmit emails `contact@alibiprofessionalservices.com` with a confirmation link. Click it.
4. All future submissions will forward normally with a table-formatted email body.

**Before activation**, submissions will show the yellow error bar on the page. That's expected — it means the inbox hasn't been activated yet. This is a one-time setup, not a bug.

### Form config (hidden inputs)

```html
<input type="hidden" name="_subject" value="NEW INQUIRY — Alibi Professional Services" />
<input type="hidden" name="_template" value="table" />
<input type="hidden" name="_captcha" value="false" />
<input type="text"   name="_honey"    class="form-honeypot" tabindex="-1" />
```

- `_subject` — sets the forwarded email's subject line
- `_template=table` — formats the email body as a clean key/value table
- `_captcha=false` — disables Formsubmit's default reCAPTCHA (we use the honeypot instead)
- `_honey` — hidden spam trap: if a bot fills it, JS silently drops the submission

### Swapping webhook providers

If you need to replace Formsubmit (Web3Forms, Basin, Formspree, a custom serverless endpoint), the only thing to change is:

1. The `formEndpoint` constant at the top of `src/pages/contact.astro`
2. The response parsing inside the `<script is:inline>` handler (currently expects `{ success: 'false' }` on Formsubmit errors)

### Changing the destination email

Two places:

1. `src/pages/contact.astro` — `contactEmail` constant at the top of the frontmatter
2. `src/components/Footer.astro` — hardcoded `mailto:` link in the "Reach Us" column

---

## Logo — placeholder in place

The current logo is a **placeholder** — an inline SVG rendered by `src/components/SiteLogo.astro` that draws a circle with a dead fish tied to a cinder block, plus curved text "ALIBI PROFESSIONAL SERVICES • EVIDENCE FILE •" around the border.

**The real logo file is expected from the client.** When it arrives:

1. Drop it in `public/logo.svg` (or `.png` if that's what you're given).
2. Replace the contents of `src/components/SiteLogo.astro` with:

   ```astro
   ---
   interface Props {
     size?: number;
     class?: string;
   }
   const { size = 56, class: className = '' } = Astro.props;
   ---
   <img
     src="/logo.svg"
     alt="Alibi Professional Services"
     width={size}
     height={size}
     class={className}
   />
   ```

3. `Nav.astro` and `Footer.astro` both import `SiteLogo` so they update automatically.

The real logo concept is: a circle with "ALIBI PROFESSIONAL SERVICES" text curving around the border, and in the center, a dead fish being dragged down by a cinder block attached with rope (mafia-disposal visual gag). The placeholder SVG matches this layout so no CSS adjustment should be needed when swapping in the real asset.

---

## Current state

### Done
- [x] Astro project scaffolded
- [x] Homepage (`/`) — hero, services (4 case-file cards), testimonials, 24HR/100%/0 stats row, final CTA, footer
- [x] About page (`/about`) — hero, THE STORY, THE RULES (6 operating principles), final CTA
- [x] Contact page (`/contact`) — hero, two-column form + info, Formsubmit AJAX handler, on-theme success state
- [x] Nav with active-page `aria-current` highlighting
- [x] Footer with email (`contact@alibiprofessionalservices.com`) and service area (Isanti, Kanabec & Anoka Counties, MN)
- [x] All "GET A QUOTE" buttons wired to `/contact`
- [x] Responsive breakpoints at 960px and 640px
- [x] Grain overlay, slow marquee tape (60s), prefers-reduced-motion guard

### Pending — explicitly not done yet
- [ ] **Real logo asset** — currently inline SVG placeholder
- [ ] **Real phone number** — the placeholder `(555) 000-0000` was removed from the footer, nothing displayed in its place
- [ ] **Formsubmit email activation** — blocked on the inbox existing
- [ ] **Production domain** — `site` field in `astro.config.mjs` is `https://alibipro.com` as a placeholder
- [ ] **Favicon** — Astro default `favicon.svg` is in use; swap for a branded mark when ready
- [ ] **Real testimonials** — the three displayed are intentionally anonymous-on-theme placeholders; the client plans to keep them as-is until real ones come in, but confirm before modifying
- [ ] **robots.txt / sitemap.xml** — not yet added; Astro has integrations for both

---

## Hard rules — don't break these

1. **Don't break the theme.** Black background, yellow headlines, Anton display font, grain overlay, crime-scene tape marquees — this is the whole visual identity. Before introducing any new color, font, or stylistic element, ask.
2. **Don't install CSS frameworks or preprocessors.** All styles are in `Layout.astro` for a reason. No Tailwind, no Sass, no CSS modules. The file is long but it's a single source of truth.
3. **Don't convert the project to SSR.** It's intentionally static. If a dynamic feature is needed, look for a third-party webhook or serverless option first.
4. **Don't edit `concepts/03-crime-scene-bold.html`.** It's a preserved pre-refactor baseline. All active work happens in `src/`.
5. **Don't add runtime dependencies without a reason.** Current deps: `astro` only. Keep it that way unless there's a clear need.
6. **Don't soften the brand voice.** The mafia-theme dry humor is intentional. If a copy change is requested, match the existing rhythm — short declarative sentences, no emoji, no exclamation points, no generic marketing language.
7. **Don't rename files or components without a reason.** The structure is load-bearing for the layout/component imports.

---

## How to make common changes

### Edit copy on a page
Go to the corresponding file in `src/pages/`. Copy is inline in the markup — no CMS, no JSON data files.

### Change the destination email for the contact form
1. `src/pages/contact.astro` → update the `contactEmail` constant in frontmatter
2. `src/components/Footer.astro` → update the `mailto:` link in the "Reach Us" column
3. New form submissions will re-trigger Formsubmit's confirmation flow to the new address

### Add a new page
1. Create `src/pages/your-page.astro`
2. Import `Layout`, `Nav`, `Footer`, and any other components
3. Use existing CSS classes (`.hero`, `.section-dark`, `.card`, etc.) — don't write new CSS unless the pattern doesn't exist
4. Add the nav link in `src/components/Nav.astro`

### Adjust the marquee tape speed
`Layout.astro` → `.tape-text-inner` → `animation: marquee 60s linear infinite;` — change the duration.

### Adjust card sizing or grid
`Layout.astro` → `.services-grid` and `.card` classes. The grid uses `repeat(auto-fit, minmax(480px, 1fr))` which gives a 2×2 layout on desktop.

---

## Commands reference

```bash
# Development
npm install                # install deps (astro only)
npm run dev                # start dev server
npm run build              # build static site to dist/
npm run preview            # serve the built output

# Inspection
ls src/pages/              # list routes
ls src/components/         # list shared components
```

---

## Deployment

This builds to a static `dist/` folder. Deploy anywhere that serves static files:

- **Netlify** — connect the repo, build command `npm run build`, publish directory `dist`
- **Vercel** — auto-detects Astro, zero config
- **Cloudflare Pages** — build command `npm run build`, output directory `dist`
- **GitHub Pages** — requires minor Astro config, see Astro docs

**Before deploying to production:**

1. Update `site` in `astro.config.mjs` to the real production domain
2. Confirm `contact@alibiprofessionalservices.com` exists and Formsubmit has been activated
3. Verify the form actually sends by submitting a test from the live site
4. Swap the logo placeholder for the real asset if available

---

## Why this file exists

This file exists so that any AI coding assistant picking up this repo can:

1. Understand the project, its voice, and its constraints without re-reading the whole codebase
2. Avoid the design-system mistakes that would require re-litigation
3. Know what's done, what's pending, and what's intentionally undone
4. Not break the Formsubmit form by changing the wrong file

If you're an AI agent reading this: the human handing you this repo has already been through several rounds of design iteration and has settled on this aesthetic deliberately. Treat the existing design system as a given. Ask before adding new colors, fonts, dependencies, or soft-voice copy.
