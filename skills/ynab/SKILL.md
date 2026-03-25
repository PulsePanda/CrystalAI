---
name: crystal:ynab
description: "YNAB budgeting operations — transaction review, receipt lookup, categorization, splitting, and approval. Use this skill whenever Austin asks to review transactions, approve transactions, check his budget, categorize or split transactions, look up receipts, or do anything YNAB-related. Trigger on: '/ynab', 'review transactions', 'approve transactions', 'unapproved transactions', 'budget review', 'check my budget', 'categorize transactions', 'split transaction', 'ynab transactions', 'receipt lookup', 'what did I spend on', 'budget summary'. Also invoke when other skills need to create or query YNAB transactions."
version: 1.0.0
---

# YNAB Tool Skill

Reference and operational skill for all YNAB budgeting operations. Direct API calls via curl — no MCP server.

## API Setup

```bash
# Read token (use this pattern in all API calls)
TOKEN=$(cat ~/.config/ynab/credentials.json | python3 -c "import sys,json; print(json.load(sys.stdin)['api_token'])")

# Base URL
BASE="https://api.ynab.com/v1"

# Primary budget
BUDGET="ae02b2eb-0a8c-4293-8222-1678d112dc19"
```

All API calls require `dangerouslyDisableSandbox: true` — the sandbox blocks YNAB API DNS.

Amounts are in **milliunits** (dollars x 1000). Outflows are negative. $10.50 = 10500, -$25.00 = -25000.

---

## Transaction Review & Approval Workflow

This is the primary workflow. Austin bulk-approves obvious transactions in YNAB himself, then comes here for the remaining unapproved ones that need receipt lookup and recategorization.

### Step 1: Pull Unapproved Transactions

```bash
curl -s -H "Authorization: Bearer $TOKEN" "$BASE/budgets/$BUDGET/transactions?type=unapproved" 2>/dev/null
```

Parse and present grouped by payee_name, showing: date, payee, amount (converted from milliunits to dollars), current category, and account. Flag multi-category vendors (Amazon, Walmart, Target) as needing receipt lookup.

### Step 2: Receipt Lookup

All remaining unapproved transactions need receipt lookup. The approach depends on the vendor:

**Amazon:** Navigate to `https://www.amazon.com/cpe/yourpayments/transactions` in Chrome — this shows transactions by card and amount, which maps directly to YNAB entries. Click the order link to see what was purchased. Transactions not found on Austin's account are likely on Kayleigh's — send her an iMessage listing the missing amounts/dates and ask what they were. **Note:** Unmatched Amazon charges on the Delta SkyMiles (Amex ****1003) are always AWS — categorize as Subscriptions with memo "AWS".

**Walmart:** Use the receipt lookup tool. See `references/walmart-receipt-lookup.md` for the full flow. Key facts:
- Walmart transactions post **2 days after purchase** — subtract 2 from YNAB date for the receipt lookup date
- Always Cambridge Supercenter #2352, Mastercard 7839 — don't ask each time
- Use `get_page_text` to extract all items at once instead of scrolling through screenshots
- Walmart's bot detection is aggressive — if blocked, wait and retry later

**Target:** Similar to Walmart — navigate to Target's receipt lookup in Chrome.

**Other vendors:** Search Austin's email across all accounts (using the GWS email skill pattern) for receipts matching the amount and date.

### Step 3: Categorize and Split

Once we know what was purchased, categorize or split the transaction.

**Splitting rules for Walmart/Target/Amazon:**
- **Groceries** (`9b451767-da8a-4b13-ae0b-683069a7226c`) — food items AND household essentials (toilet paper, paper towels, cleaning supplies, toothpaste, deodorant, etc.)
- **Pet Stuff** (`4b16251e-2e5d-4fb6-aea4-907d4ab65b4a`) — anything pet-related
- **Shopping** (`f14e158f-6dde-40e0-acc3-94d204795fa3`) — everything else

Austin reviews the receipt, identifies non-grocery items, and the remainder becomes groceries.

**Tax handling for splits:** Split tax proportionally across categories based on pre-tax subtotals. Calculate each category's share of the subtotal, apply that percentage to total tax, add to each category's amount. Verify the split amounts sum to the original transaction total.

**Memo rules:**
- **Pet Stuff and Shopping:** always fill in the memo with what was purchased (e.g., "Blue Buffalo Dog Food 24lb, Jinx Wet Dog Food x6")
- **Groceries:** no memo needed
- **Single-category Amazon transactions:** fill in the memo with the product name

**Split transaction API:**
```bash
curl -s -X PUT -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  "$BASE/budgets/$BUDGET/transactions/TRANSACTION_ID" \
  -d '{
    "transaction": {
      "subtransactions": [
        {"amount": -15000, "category_id": "4b16251e-2e5d-4fb6-aea4-907d4ab65b4a", "memo": "Dog food"},
        {"amount": -278810, "category_id": "9b451767-da8a-4b13-ae0b-683069a7226c", "memo": "Groceries"}
      ]
    }
  }'
```

The subtransaction amounts must sum to the original transaction amount. All amounts in milliunits, negative for outflows.

### Step 4: Approve

**Current mode: MANUAL APPROVAL** (run 1 of 3 complete — 2 more manual runs before auto-approve)

Present the final categorization for Austin's confirmation before approving.

```bash
# Approve a single transaction
curl -s -X PUT -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  "$BASE/budgets/$BUDGET/transactions/TRANSACTION_ID" \
  -d '{"transaction": {"approved": true}}'

# Approve can be combined with categorization/splitting in a single PUT
```

---

## Secondary Operations

### Budget Summary

```bash
curl -s -H "Authorization: Bearer $TOKEN" "$BASE/budgets/$BUDGET/categories"
```

Parse and show categories that are over budget (negative balance) or significantly underfunded. Group by category group.

### Transaction Search

```bash
# By date range
curl -s -H "Authorization: Bearer $TOKEN" "$BASE/budgets/$BUDGET/transactions?since_date=2026-03-01"

# By payee
curl -s -H "Authorization: Bearer $TOKEN" "$BASE/budgets/$BUDGET/payees/PAYEE_ID/transactions"

# By account
curl -s -H "Authorization: Bearer $TOKEN" "$BASE/budgets/$BUDGET/accounts/ACCOUNT_ID/transactions"
```

### Move Money Between Categories

```bash
curl -s -X PATCH -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  "$BASE/budgets/$BUDGET/months/current/categories/CATEGORY_ID" \
  -d '{"category": {"budgeted": NEW_AMOUNT_IN_MILLIUNITS}}'
```

Note: this sets the total budgeted amount, not a delta. Read the current budgeted amount first, then add/subtract.

### Create Manual Transaction

```bash
curl -s -X POST -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  "$BASE/budgets/$BUDGET/transactions" \
  -d '{
    "transaction": {
      "account_id": "ACCOUNT_ID",
      "date": "2026-03-22",
      "amount": -10000,
      "payee_name": "Store Name",
      "category_id": "CATEGORY_ID",
      "cleared": "cleared",
      "approved": true
    }
  }'
```

---

## Reference Files

- `references/ids.md` — All account and category IDs (read when you need to reference specific accounts or categories)
- `references/walmart-receipt-lookup.md` — Step-by-step Walmart receipt lookup flow using Chrome browser automation
