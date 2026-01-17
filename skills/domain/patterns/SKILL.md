---
name: patterns
domain: software-design
description: >
  Software design patterns, SOLID principles, and architectural best practices. Covers creational, structural, and behavioral patterns, anti-patterns to avoid, and when to apply each pattern.
  Trigger: When architecting systems, when refactoring code, when implementing design patterns, when applying SOLID principles, when identifying anti-patterns.
version: 1.0.0
tags: [design-patterns, SOLID, architecture, best-practices, anti-patterns]
metadata:
  version: "1.0"
  last_updated: "2026-01-17"
  category: domain
  progressive_disclosure: true
references:
  - name: Design Patterns Guide
    url: ./references/design-patterns.md
    type: local
  - name: SOLID Principles
    url: ./references/solid-principles.md
    type: local
  - name: Refactoring.Guru - Design Patterns
    url: https://refactoring.guru/design-patterns
    type: documentation
  - name: Refactoring.Guru - SOLID Principles
    url: https://refactoring.guru/solid
    type: documentation
---

# Patterns - Software Design & Architecture

**Know when to use (and when NOT to use) design patterns**

---

## When to Use This Skill

Use this skill when:
- Architecting new systems or refactoring existing ones
- Identifying code smells and anti-patterns
- Choosing appropriate design patterns for specific problems
- Applying SOLID principles to improve code quality
- Making code more testable, maintainable, and extensible

Don't use this skill when:
- Simple, straightforward code is sufficient
- Premature optimization or abstraction would add complexity
- The problem doesn't warrant pattern application

---

## Critical Patterns

### Pattern 1: SOLID Principles

**When**: Designing maintainable, testable code

**Single Responsibility Principle (SRP)**:
```typescript
// ✅ Good: Each class has one responsibility
class UserRepository {
  save(user: User) { /* DB logic */ }
}

class EmailService {
  sendWelcomeEmail(user: User) { /* Email logic */ }
}

class UserReportGenerator {
  generate(user: User) { /* Report logic */ }
}

// ❌ Bad: God class doing everything
class UserService {
  saveUser(user: User) { /* ... */ }
  sendEmail(user: User) { /* ... */ }
  generateReport(user: User) { /* ... */ }
}
```

**Dependency Inversion Principle (DIP)**:
```typescript
// ✅ Good: Depend on abstractions
interface MessageSender {
  send(message: string): void;
}

class EmailService implements MessageSender {
  send(message: string) { /* SMTP logic */ }
}

class UserRegistration {
  constructor(private messageSender: MessageSender) {}

  register(user: User) {
    this.messageSender.send(`Welcome ${user.name}`);
  }
}

// ❌ Bad: Tight coupling to concrete class
class UserRegistration {
  private emailService = new EmailService();

  register(user: User) {
    this.emailService.send(`Welcome ${user.name}`);
  }
}
```

**Why**: SOLID principles create code that's easier to test, maintain, and extend. They prevent common pitfalls like tight coupling and god classes.

**For complete SOLID deep dive**: [SOLID Principles Reference](./references/solid-principles.md)

---

### Pattern 2: Factory Pattern

**When**: Creating objects with complex initialization or multiple variants

**Good**:
```typescript
interface Button {
  render(): void;
}

class WindowsButton implements Button {
  render() { console.log('Render Windows button'); }
}

class MacButton implements Button {
  render() { console.log('Render Mac button'); }
}

class ButtonFactory {
  static create(os: 'windows' | 'mac'): Button {
    switch (os) {
      case 'windows': return new WindowsButton();
      case 'mac': return new MacButton();
      default: throw new Error('Unknown OS');
    }
  }
}

// Usage
const button = ButtonFactory.create('windows');
button.render();
```

**When to use**:
- Object creation is complex or varies by context
- Need to decouple object creation from usage
- Creating families of related objects

**When NOT to use**:
- Simple object creation (just use `new`)
- Only one type of object exists

---

### Pattern 3: Strategy Pattern

**When**: Swapping algorithms or behaviors at runtime

**Good**:
```typescript
interface PaymentStrategy {
  pay(amount: number): void;
}

class CreditCardPayment implements PaymentStrategy {
  pay(amount: number) {
    console.log(`Paid $${amount} with credit card`);
  }
}

class PayPalPayment implements PaymentStrategy {
  pay(amount: number) {
    console.log(`Paid $${amount} with PayPal`);
  }
}

class ShoppingCart {
  constructor(private paymentStrategy: PaymentStrategy) {}

  checkout(amount: number) {
    this.paymentStrategy.pay(amount);
  }
}

// Usage
const cart = new ShoppingCart(new CreditCardPayment());
cart.checkout(100);
```

**Bad**:
```typescript
// ❌ Multiple if/else statements
class ShoppingCart {
  checkout(amount: number, paymentType: string) {
    if (paymentType === 'creditCard') {
      // Process credit card
    } else if (paymentType === 'paypal') {
      // Process PayPal
    } else if (paymentType === 'crypto') {
      // Process crypto
    }
  }
}
```

**Why**: Strategy pattern eliminates conditional logic and makes adding new payment methods easy without modifying existing code (Open/Closed Principle).

---

### Pattern 4: Observer Pattern

**When**: Implementing event-driven systems or pub/sub

**Good**:
```typescript
interface Observer {
  update(data: any): void;
}

class Subject {
  private observers: Observer[] = [];

  subscribe(observer: Observer) {
    this.observers.push(observer);
  }

  notify(data: any) {
    this.observers.forEach(observer => observer.update(data));
  }
}

class EmailSubscriber implements Observer {
  update(data: any) {
    console.log(`Email sent: ${data}`);
  }
}

class SMSSubscriber implements Observer {
  update(data: any) {
    console.log(`SMS sent: ${data}`);
  }
}

// Usage
const newsletter = new Subject();
newsletter.subscribe(new EmailSubscriber());
newsletter.subscribe(new SMSSubscriber());
newsletter.notify('New article published!');
```

**When to use**:
- One-to-many dependencies
- Event systems
- State synchronization across components

---

### Pattern 5: Adapter Pattern

**When**: Integrating incompatible interfaces

**Good**:
```typescript
// Legacy interface
class OldPaymentGateway {
  processPayment(amount: number) {
    console.log(`Old gateway: $${amount}`);
  }
}

// New interface
interface PaymentProcessor {
  pay(amount: number, currency: string): void;
}

// Adapter
class PaymentAdapter implements PaymentProcessor {
  constructor(private oldGateway: OldPaymentGateway) {}

  pay(amount: number, currency: string) {
    if (currency !== 'USD') {
      throw new Error('Old gateway only supports USD');
    }
    this.oldGateway.processPayment(amount);
  }
}
```

**When to use**:
- Integrating third-party libraries
- Working with legacy code
- Reusing existing classes with different interfaces

---

## Anti-Patterns

### ❌ Anti-Pattern 1: Premature Abstraction

**Don't do this**:
```typescript
// ❌ Over-engineered for simple config
interface ConfigStrategy { get(key: string): any; }
class JSONConfigStrategy implements ConfigStrategy { /* ... */ }
class YAMLConfigStrategy implements ConfigStrategy { /* ... */ }
class ConfigFactory { /* ... */ }
```

**Do this instead**:
```typescript
// ✅ Start simple
const config = {
  apiUrl: 'https://api.example.com',
  timeout: 5000
};
```

**Why**: YAGNI (You Aren't Gonna Need It). Add abstraction when you have a concrete need, not "just in case."

---

### ❌ Anti-Pattern 2: God Object

**Don't do this**:
```typescript
// ❌ One class doing everything
class Application {
  handleAuth() { /* ... */ }
  renderUI() { /* ... */ }
  saveToDatabase() { /* ... */ }
  sendEmail() { /* ... */ }
  generateReports() { /* ... */ }
  // 50 more methods...
}
```

**Do this instead**:
```typescript
// ✅ Apply Single Responsibility Principle
class AuthService { /* ... */ }
class UIRenderer { /* ... */ }
class DatabaseService { /* ... */ }
class EmailService { /* ... */ }
class ReportGenerator { /* ... */ }
```

---

### ❌ Anti-Pattern 3: Copy-Paste Programming

**Don't do this**:
```typescript
// ❌ Duplicated code
function validateEmail(email: string) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

function validateUserEmail(user: User) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(user.email);
}
```

**Do this instead**:
```typescript
// ✅ DRY (Don't Repeat Yourself)
function isValidEmail(email: string) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

function validateUserEmail(user: User) {
  return isValidEmail(user.email);
}
```

---

## Quick Reference

### When to Use Each Pattern

| Pattern | Use When | Don't Use When |
|---------|----------|----------------|
| **Factory** | Complex object creation, multiple variants | Simple `new` is sufficient |
| **Builder** | Many optional parameters | Few parameters, simple construction |
| **Singleton** | Truly need ONE global instance | Just want convenience (use DI) |
| **Adapter** | Integrating incompatible interfaces | Interfaces already compatible |
| **Decorator** | Adding responsibilities dynamically | Static behavior is fine |
| **Facade** | Simplifying complex subsystem | Subsystem is already simple |
| **Observer** | Event-driven, one-to-many updates | Simple callbacks work |
| **Strategy** | Swappable algorithms at runtime | Fixed algorithm |
| **Command** | Undo/redo, queuing operations | Direct method calls work |

### SOLID Quick Checklist

- [ ] **S**: Each class has single, focused responsibility
- [ ] **O**: New features added via extension, not modification
- [ ] **L**: Subtypes don't break parent class behavior
- [ ] **I**: Interfaces are small and focused
- [ ] **D**: Depend on abstractions, inject dependencies

---

## Progressive Disclosure

For detailed implementations and examples:
- **[Design Patterns Guide](./references/design-patterns.md)** - Complete pattern implementations (Factory, Builder, Singleton, Adapter, Decorator, Facade, Observer, Strategy, Command)
- **[SOLID Principles](./references/solid-principles.md)** - Deep dive into SRP, OCP, LSP, ISP, DIP with real-world examples

---

## References

- [Design Patterns Guide](./references/design-patterns.md)
- [SOLID Principles](./references/solid-principles.md)
- [Refactoring.Guru - Design Patterns](https://refactoring.guru/design-patterns)
- [Refactoring.Guru - SOLID Principles](https://refactoring.guru/solid)

---

_Maintained by dsmj-ai-toolkit_
