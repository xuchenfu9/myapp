# App Store Metadata

This folder contains localized App Store metadata drafts for:

- App Name
- Subtitle
- Promotional Text
- Description
- Keywords

Locales included:

- English
- Simplified Chinese
- Traditional Chinese
- Japanese
- Korean

## Strategy

- Primary ASO angle: cat sounds / cat language / cat diary
- Secondary ASO angle: reminders, albums, medical logs, daily care records
- Tone: specific, calm, feature-led, and consistent with actual in-app functionality

## Apple Limits Checked

Validated on 2026-04-06 against Apple Developer documentation:

- Subtitle: 30 characters max
- Promotional Text: 170 characters max
- Description: 4000 characters max
- Keywords: 100 bytes max

## Notes

- Promotional Text is useful for conversion and updates, but does not improve search ranking.
- Keywords should avoid app name duplication, competitor names, and misleading terms.
- For CJK locales, keyword byte limits are tighter than they look. The suggestions here were written to stay within the limit.

## Files

- `en-US.md`
- `zh-Hans.md`
- `zh-Hant.md`
- `ja.md`
- `ko.md`

## Validation Snapshot

Checked locally on 2026-04-06:

| Locale | App Name | Subtitle | Promotional Text | Keywords |
| --- | ---: | ---: | ---: | ---: |
| English | 29 chars | 30 chars | 164 chars | 99 bytes |
| Simplified Chinese | 17 chars | 16 chars | 62 chars | 78 bytes |
| Traditional Chinese | 17 chars | 16 chars | 61 chars | 78 bytes |
| Japanese | 17 chars | 20 chars | 62 chars | 59 bytes |
| Korean | 21 chars | 21 chars | 80 chars | 74 bytes |

All descriptions are well below the 4000-character limit.
