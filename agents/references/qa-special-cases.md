# QA Special Cases & Cross-Platform Testing

## Mobile/Responsive Testing

### When
Feature works on desktop, need mobile verification

### Check
- Touch targets large enough (44x44px minimum)
- Gestures work (swipe, pinch-to-zoom if appropriate)
- Viewport sizes (phone, tablet)
- Landscape and portrait orientations
- Native features (camera access, geolocation)

### Using Bash
```bash
# Simulate mobile viewport (if using Playwright/Cypress)
npm run test:e2e -- --device="iPhone 13"
npm run test:e2e -- --device="iPad"
```

### Mobile-Specific Issues to Check
- Form inputs don't trigger zoom on focus
- Navigation menus work on small screens
- Images load quickly and scale properly
- Horizontal scrolling not required
- Tap targets not too close together
- Text readable without zooming

## Cross-Browser Testing

### When
Feature uses newer APIs or CSS

### Test browsers
- Chrome/Edge (Chromium)
- Firefox
- Safari (WebKit)
- Mobile browsers (Safari iOS, Chrome Android)

### Check for
- Feature support (CSS Grid, ES6 features)
- Polyfills loaded if needed
- Graceful degradation
- Consistent appearance
- Date/time pickers work correctly
- File uploads functional

### Common Browser Issues
- Safari: flexbox bugs, date picker differences
- Firefox: CSS grid alignment differences
- IE11: ES6 features need transpiling
- Mobile Safari: position: fixed issues

## Performance Testing (User Perception)

### When
Feature involves data loading or heavy operations

### Check
- Time to interactive (<3 seconds ideal)
- First Contentful Paint (<1.5 seconds)
- Loading indicators present
- Progressive enhancement (show something fast)
- Optimistic UI updates where appropriate
- Skeleton screens for slow content

### Performance Metrics
- **Good**: <1 second response time
- **Acceptable**: 1-3 seconds with loading indicator
- **Poor**: >3 seconds or no feedback

### What to Test
- Large lists/tables load progressively
- Images lazy load
- Forms respond immediately to input
- Animations smooth (60fps)
- No layout shifts during loading

## Security-Focused QA

### When Testing Authentication Features

Check:
- Session expiry works correctly
- "Remember me" persists appropriately
- Logout clears all session data
- Can't access protected routes when logged out
- Password visibility toggle works securely
- "Forgot password" flow secure

### When Testing Forms with Sensitive Data

Check:
- No sensitive data in URL parameters
- HTTPS enforced for submission
- No autocomplete on sensitive fields (if required)
- CSR F tokens present (if using sessions)
- No sensitive data logged to console
- Validation happens server-side too

## Regression Testing

### When
New feature added, need to verify existing features still work

### Approach
1. Test critical user paths (login, checkout, etc.)
2. Test features that share code with new feature
3. Test features that use similar patterns
4. Run automated test suite
5. Spot check other major features

### Regression Test Checklist
- [ ] Authentication still works
- [ ] Navigation still works
- [ ] Forms still submit correctly
- [ ] Data displays correctly
- [ ] Search/filter still works
- [ ] No console errors on existing pages

## Testing Edge Cases

### Empty States
- Empty search results
- No data to display
- Empty shopping cart
- No notifications
- No history/activity

### Boundary Conditions
- Minimum/maximum values
- Very long text (names, addresses)
- Very short text (1 character)
- Special characters in input
- Unicode/emoji in text fields
- Extremely large numbers

### Error Conditions
- Network timeout
- Server error (500)
- Not found (404)
- Unauthorized (401)
- Invalid form data
- Expired sessions
- Rate limiting

### Concurrent Actions
- Submit form twice quickly
- Multiple tabs open
- Save while auto-save running
- Navigate away during save
- Refresh during operation

## Load Testing (Manual Observation)

### What to Check
- Application handles many items (100+ products in cart)
- Large datasets display correctly (1000+ rows)
- Multiple images load without blocking
- Infinite scroll performs well
- Search with many results

### Warning Signs
- UI becomes unresponsive
- Animations stutter
- Loading indicators don't appear
- Browser tab crashes
- Memory usage grows unbounded

## Usability Heuristics

### Nielsen's 10 Usability Heuristics

1. **Visibility of system status**: Loading indicators, progress bars
2. **Match real world**: Familiar language, logical flow
3. **User control**: Can cancel, undo, go back
4. **Consistency**: Same patterns throughout app
5. **Error prevention**: Confirmations for destructive actions
6. **Recognition over recall**: Don't make users remember info
7. **Flexibility**: Keyboard shortcuts, multiple paths
8. **Aesthetic design**: Clean, focused, not cluttered
9. **Error recovery**: Helpful error messages, recovery options
10. **Help documentation**: Tooltips, help text where needed

### Quick Usability Checks
- Can user accomplish task without help?
- Are error messages clear and actionable?
- Can user recover from mistakes?
- Is navigation intuitive?
- Are CTAs obvious and prominent?
- Is feedback immediate for all actions?

## Testing Internationalization

### Text Expansion
Different languages have different text lengths:
- German: ~30% longer than English
- Spanish: ~20% longer than English
- French: ~15% longer than English
- Chinese: Usually shorter than English

### RTL (Right-to-Left) Testing
For Arabic, Hebrew:
- Layout mirrors correctly
- Icons face correct direction
- Text alignment correct
- Forms layout properly
- Navigation makes sense

### Locale-Specific Formats
- Dates: MM/DD/YYYY vs DD/MM/YYYY
- Time: 12-hour vs 24-hour
- Numbers: 1,000.00 vs 1.000,00
- Phone numbers: Different formats
- Addresses: Different field requirements
- Currency symbols and placement

### Pluralization Rules
Different languages have different pluralization rules:
- English: 1 item, 2 items
- Polish: Different forms for 1, 2-4, 5+
- Arabic: Different forms for 0, 1, 2, 3-10, 11+

Test with various counts to verify correct pluralization.
