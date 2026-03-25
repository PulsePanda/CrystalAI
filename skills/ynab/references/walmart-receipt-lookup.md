# Walmart Receipt Lookup — Chrome Browser Automation

URL: https://www.walmart.com/receipt-lookup

This page has a CAPTCHA gate. Use Chrome browser automation tools to fill in the form and handle the lookup.

## Required Information

Before starting, you need:
- **Store zip code** — ask Austin if not known
- **Store name** — typically "Cambridge" (select from dropdown after zip)
- **Purchase date** — from the YNAB transaction
- **Purchase total** — exact amount from the YNAB transaction
- **Last 4 digits of card** — ask Austin if not known (can be inferred from which YNAB account the transaction is on)
- **Card type** — dropdown selection (Visa, Mastercard, etc.)

## Step-by-Step Flow

1. Navigate to `https://www.walmart.com/receipt-lookup`
2. Wait for the page to load (may show CAPTCHA first)
3. Fill in the form fields:
   - Type zip code in the zip code field
   - Select "Cambridge" from the store dropdown
   - Enter the purchase date
   - Enter the purchase total (dollar amount, e.g., "293.81")
   - Enter last 4 digits of the card used
   - Select card type from dropdown
4. Handle the "I'm not a robot" CAPTCHA checkbox — click it and wait for verification
5. Click "Look up receipt"
6. Read the receipt results — extract line items with prices

## After Receipt Lookup

Parse the receipt to identify:
- **Pet items** — dog/cat food, treats, litter, toys, pet supplies
- **Non-grocery items** — clothing, electronics, home goods, toys, seasonal items, etc.
- **Everything else** — this becomes Groceries (food + household essentials like TP, paper towels, cleaning supplies, toothpaste, deodorant)

Calculate the split:
- Sum pet items → Pet Stuff category
- Sum non-grocery/non-pet items → Shopping category
- Remainder (total - pet - shopping) → Groceries category

## Saved Card Details

| YNAB Account | Last 4 | Card Type | Card Network |
|--------------|--------|-----------|--------------|
| Cabela's CLUB Black | 7839 | Mastercard | Mastercard |
| Delta SkyMiles Gold Card | — | — | Amex |
| CapOne Credit | — | — | — |
| Apple Card | — | — | Mastercard |

## Default Walmart Store

- **Zip code:** 55040
- **Store:** Cambridge

## Card-to-Account Mapping

When Austin doesn't specify which card, infer from the YNAB account name. Use saved card details above when available.

## Notes

- **Walmart transactions post 2 days after purchase.** YNAB date minus 2 days = actual receipt date. Use the receipt date for lookups.
- The CAPTCHA may require Austin's manual intervention if the automated click doesn't work
- Walmart receipt lookup sometimes returns "receipt not found" for very recent transactions — may need to wait 24-48 hours
- Receipt data shows item descriptions and prices but categories may need interpretation
- Walmart is always the same store (Cambridge) and same card (Mastercard 7839) — don't ask each time
