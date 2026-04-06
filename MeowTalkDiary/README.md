# Static Site

This folder now contains a GitHub Pages compatible static site for App Store submission links.

## Pages

- `index.html`: marketing URL
- `privacy/`: privacy policy
- `terms/`: terms of service
- `support/`: technical support

## Publish on GitHub Pages

1. Push the repository to GitHub.
2. In repository settings, enable GitHub Pages.
3. Choose deployment from the `main` branch and `/docs` folder.
4. Use the generated public URL in App Store Connect for:
   - Marketing URL
   - Privacy Policy URL
   - Support URL

## Language Switching

- Supported languages: English, Simplified Chinese, Traditional Chinese, Japanese, Korean
- Language can be changed from the top-right switcher on every page.
- The selected language is preserved in `localStorage` and also through the `?lang=` query parameter.
