# QA Detailed Testing Examples

## Complete QA Cycle Example

**User Request**: "QA the new checkout flow before release"

### Phase 1: Understanding Requirements

Reviewing user stories:
- Story 1: Express checkout for returning users
- Story 2: Guest checkout option
- Story 3: Multiple payment methods

Acceptance criteria:
✅ Checkout completable in <60 seconds
✅ Works on mobile
✅ Accessible (WCAG AA)
✅ Supports 3 languages

### Phase 2: Functional QA

Testing express checkout:
✅ Saved addresses auto-fill
✅ One-click payment works
✅ Order confirmation immediate
⚠️ Issue: Can't edit address after auto-fill

Testing guest checkout:
✅ No account required
✅ Email for order tracking
⚠️ Issue: Guest can't see order history later

Testing payment methods:
✅ Credit card works
✅ PayPal integration works
❌ Critical: Stripe error on submit (500 error)

### Phase 3: Accessibility Check

Keyboard navigation:
✅ All form fields tabbable
✅ Enter submits form
✅ Escape closes modals
⚠️ Issue: Focus lost after payment modal closes

Screen reader (NVDA):
✅ Form labels announced
✅ Error messages announced
⚠️ Issue: "Total: $99.99" not announced on update

Visual:
✅ Contrast 4.8:1 (WCAG AA)
✅ Text resizable
❌ Issue: Focus indicator missing on payment button

### Phase 4: i18n Check

Tested: English, Spanish, German

Text extraction:
✅ All strings in translation files

Layout (German):
✅ Form handles longer labels
⚠️ Issue: "Proceed to Payment" button truncates

Number formatting:
✅ Prices: $99.99 (en) vs 99,99 € (de)
✅ Dates formatted correctly

### Phase 5: UAT

User flow (returning customer):
1. Login → ✅ Fast
2. Add to cart → ✅ Works
3. Checkout → ✅ Address pre-filled
4. Select shipping → ✅ Options clear
5. Payment → ❌ Stripe error
6. Could not complete

Usability observations:
✅ Flow is intuitive
✅ Clear progress indicator
⚠️ "Save this address" checkbox easy to miss
⚠️ No indication of which payment methods accepted

## Summary Report

QA Status: ❌ NOT READY FOR RELEASE

Critical Issues (Must Fix):
1. Stripe payment failing (500 error) - checkout.tsx:145
2. Focus indicator missing on payment button (WCAG fail)

High Issues (Should Fix):
3. Can't edit auto-filled address
4. Focus lost after payment modal
5. "Proceed to Payment" truncates in German

Medium Issues (Nice to Have):
6. Total not announced on update (screen reader)
7. Guest checkout no order history
8. "Save address" checkbox not prominent

Low Issues:
9. Payment method icons missing

Recommendations:
1. Fix Stripe integration error (blocks checkout)
2. Add focus indicator (accessibility requirement)
3. Fix High issues for better UX
4. Consider Medium/Low for next release

Test Evidence:
- Screenshots: /qa-reports/checkout-20260115/
- Screen recording: checkout-flow.mp4
- Accessibility report: axe-results.json

Next Steps:
1. Spawn code-writer to fix Critical issues
2. Re-test after fixes
3. Get user approval for Medium/Low priority

## E-commerce Checkout UAT Example

User Story: "As a customer, I want to complete checkout quickly"

Test Steps:
1. Add product to cart → ✅ Works, cart icon updates
2. Go to cart → ✅ Products listed correctly
3. Click "Checkout" → ✅ Goes to checkout page
4. Fill shipping address → ✅ Form clear and simple
5. Select shipping method → ✅ Options displayed with prices
6. Enter payment info → ⚠️ No indication card type is accepted
7. Review order → ✅ Summary clear, can edit
8. Submit order → ✅ Confirmation page with order number

Usability Issues:
⚠️ "Checkout" button hard to find (small, bottom of page)
⚠️ No indication which payment methods accepted
⚠️ Can't save address for future use

Recommendations:
1. Make "Checkout" button prominent (sticky footer)
2. Show accepted payment icons (Visa, Mastercard, etc.)
3. Add "Save address" checkbox for returning users

## Form Testing Example

Functional QA - User Registration Form:

Happy Path:
✅ Fill valid email and password → Submits successfully
✅ Receives confirmation email
✅ Can log in with new credentials

Edge Cases:
✅ Email already exists → Shows "Email already registered" error
✅ Password too short → Shows "Minimum 8 characters" error
✅ Empty email field → Shows "Email required" error
✅ Invalid email format → Shows "Invalid email" error

Error States:
✅ Network error during submit → Shows retry option
✅ Server error (500) → Shows friendly error message
⚠️ Issue: Error message says "Something went wrong" (not helpful)

Loading States:
✅ Submit button shows "Creating account..." during request
✅ Form fields disabled while submitting

## Accessibility Testing Report Template

Accessibility Check - Login Page:

Keyboard Navigation:
✅ Tab order: Email → Password → Remember Me → Submit
✅ Enter key submits form
✅ Focus indicators visible
⚠️ Issue: Focus lost after password visibility toggle

Screen Reader:
✅ Email field: "Email address, required"
✅ Password field: "Password, required"
⚠️ Issue: Submit button has no aria-label (just says "button")
⚠️ Issue: Error messages not announced (missing role="alert")

Visual:
✅ Text contrast: 7.2:1 (WCAG AAA)
✅ Text resizable to 200%
❌ Issue: Focus indicator too subtle (2.1:1, needs 3:1)
❌ Issue: "Forgot password?" link only distinguished by color

Recommendations:
1. Add aria-label="Submit login form" to submit button
2. Add role="alert" to error message container
3. Increase focus indicator contrast to 3:1
4. Add underline to "Forgot password?" link

## i18n Testing Report Template

i18n Check - Product Listing:

Text Extraction:
✅ All labels in translation files
✅ Button text translatable
⚠️ Issue: "404 Not Found" hardcoded in error.tsx

Formatting:
✅ Dates: Dec 15, 2025 (en-US) vs 15 déc. 2025 (fr-FR)
✅ Currency: $99.99 (USD) vs 99,99 € (EUR)
⚠️ Issue: Prices don't update when locale changes

Layout (German):
✅ Navigation menu handles longer text
❌ Issue: "Add to Cart" button truncates "In den Warenkorb"

Recommendations:
1. Extract "404 Not Found" to i18n strings
2. Add currency conversion on locale change
3. Increase button width for German translations
