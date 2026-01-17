# Keyboard Navigation Patterns

Complete guide to keyboard accessibility and focus management.

---

## Tab Order

```html
<!-- Natural tab order -->
<button>First</button>
<button>Second</button>
<button>Third</button>

<!-- tabindex="0" - Adds to natural order -->
<div tabIndex={0}>Focusable div</div>

<!-- tabindex="-1" - Programmatically focusable only -->
<div tabIndex={-1} ref={skipLinkRef}>Content</div>

<!-- ❌ tabindex > 0 (disrupts natural order) -->
<button tabIndex={5}>Don't do this</button>
```

---

## Keyboard Shortcuts

```
Tab           - Next focusable element
Shift + Tab   - Previous focusable element
Enter         - Activate button/link
Space         - Activate button, toggle checkbox
Arrow keys    - Navigate within components
Escape        - Close modal/dropdown
```

---

## Modal Focus Trap

```typescript
function Modal({ isOpen, onClose, children }) {
  const modalRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (isOpen) {
      modalRef.current?.focus();

      const handleKeyDown = (e: KeyboardEvent) => {
        if (e.key === 'Escape') {
          onClose();
        }
      };

      document.addEventListener('keydown', handleKeyDown);
      return () => document.removeEventListener('keydown', handleKeyDown);
    }
  }, [isOpen, onClose]);

  if (!isOpen) return null;

  return (
    <div
      ref={modalRef}
      role="dialog"
      aria-modal="true"
      tabIndex={-1}
    >
      <button onClick={onClose} aria-label="Close">×</button>
      {children}
    </div>
  );
}
```

---

## Focus Indicators

```css
/* ✅ Custom focus with sufficient contrast */
button:focus-visible {
  outline: 2px solid #0066cc;
  outline-offset: 2px;
}

/* ❌ Removing outline */
button:focus {
  outline: none; /* Don't do this! */
}
```

---

_Maintained by dsmj-ai-toolkit_
