# SOLID Principles - Deep Dive

Comprehensive guide to SOLID principles with real-world examples.

---

## S - Single Responsibility Principle (SRP)

**Rule**: A class should have only one reason to change.

**Good Example** (TypeScript):
```typescript
// ❌ Bad: UserService does too much
class UserService {
  saveUser(user: User) { /* DB logic */ }
  sendEmail(user: User) { /* Email logic */ }
  generateReport(user: User) { /* Report logic */ }
}

// ✅ Good: Separate responsibilities
class UserRepository {
  save(user: User) { /* DB logic */ }
}

class EmailService {
  sendWelcomeEmail(user: User) { /* Email logic */ }
}

class UserReportGenerator {
  generate(user: User) { /* Report logic */ }
}
```

**When to apply**: Always. Every class/module should have a focused purpose.

---

## O - Open/Closed Principle (OCP)

**Rule**: Open for extension, closed for modification.

**Good Example** (TypeScript):
```typescript
// ❌ Bad: Must modify class to add new shapes
class AreaCalculator {
  calculate(shape: any) {
    if (shape.type === 'circle') return Math.PI * shape.radius ** 2;
    if (shape.type === 'rectangle') return shape.width * shape.height;
    // Adding triangle requires modifying this class
  }
}

// ✅ Good: Extend via interfaces
interface Shape {
  area(): number;
}

class Circle implements Shape {
  constructor(private radius: number) {}
  area() { return Math.PI * this.radius ** 2; }
}

class Rectangle implements Shape {
  constructor(private width: number, private height: number) {}
  area() { return this.width * this.height; }
}

class AreaCalculator {
  calculate(shape: Shape) { return shape.area(); }
}
```

**When to apply**: When you anticipate new types/behaviors being added.

---

## L - Liskov Substitution Principle (LSP)

**Rule**: Subtypes must be substitutable for their base types.

**Good Example** (Python):
```python
# ❌ Bad: Square breaks Rectangle's behavior
class Rectangle:
    def set_width(self, width):
        self._width = width

    def set_height(self, height):
        self._height = height

class Square(Rectangle):
    def set_width(self, width):
        self._width = self._height = width  # Violates LSP

    def set_height(self, height):
        self._width = self._height = height  # Violates LSP

# ✅ Good: Separate types
class Shape:
    def area(self):
        pass

class Rectangle(Shape):
    def __init__(self, width, height):
        self.width = width
        self.height = height

    def area(self):
        return self.width * self.height

class Square(Shape):
    def __init__(self, side):
        self.side = side

    def area(self):
        return self.side ** 2
```

**When to apply**: Always verify inheritance doesn't break parent's contract.

---

## I - Interface Segregation Principle (ISP)

**Rule**: Clients shouldn't depend on interfaces they don't use.

**Good Example** (TypeScript):
```typescript
// ❌ Bad: Fat interface forces unused methods
interface Worker {
  work(): void;
  eat(): void;
  sleep(): void;
}

class Robot implements Worker {
  work() { /* ... */ }
  eat() { /* Robots don't eat! */ }
  sleep() { /* Robots don't sleep! */ }
}

// ✅ Good: Segregated interfaces
interface Workable {
  work(): void;
}

interface Eatable {
  eat(): void;
}

interface Sleepable {
  sleep(): void;
}

class Human implements Workable, Eatable, Sleepable {
  work() { /* ... */ }
  eat() { /* ... */ }
  sleep() { /* ... */ }
}

class Robot implements Workable {
  work() { /* ... */ }
}
```

**When to apply**: When designing interfaces used by multiple client types.

---

## D - Dependency Inversion Principle (DIP)

**Rule**: Depend on abstractions, not concretions.

**Good Example** (TypeScript):
```typescript
// ❌ Bad: High-level module depends on low-level module
class EmailService {
  send(message: string) { /* SMTP logic */ }
}

class UserRegistration {
  private emailService = new EmailService(); // Tight coupling

  register(user: User) {
    this.emailService.send(`Welcome ${user.name}`);
  }
}

// ✅ Good: Depend on abstraction
interface MessageSender {
  send(message: string): void;
}

class EmailService implements MessageSender {
  send(message: string) { /* SMTP logic */ }
}

class SMSService implements MessageSender {
  send(message: string) { /* SMS logic */ }
}

class UserRegistration {
  constructor(private messageSender: MessageSender) {}

  register(user: User) {
    this.messageSender.send(`Welcome ${user.name}`);
  }
}

// Inject dependency
const registration = new UserRegistration(new EmailService());
```

**When to apply**: Always inject dependencies rather than creating them.

---

## Real-World Examples

### Example 1: E-commerce Order Processing

**Violates SRP**:
```typescript
class Order {
  calculateTotal() { /* ... */ }
  saveToDatabase() { /* ... */ }
  sendEmail() { /* ... */ }
  printInvoice() { /* ... */ }
}
```

**Follows SOLID**:
```typescript
// Single Responsibility
class Order {
  calculateTotal() { /* ... */ }
}

class OrderRepository {
  save(order: Order) { /* ... */ }
}

class OrderNotificationService {
  sendConfirmation(order: Order) { /* ... */ }
}

class InvoiceGenerator {
  generate(order: Order) { /* ... */ }
}

// Dependency Inversion
interface NotificationService {
  send(message: string): void;
}

class EmailNotification implements NotificationService {
  send(message: string) { /* ... */ }
}

class OrderProcessor {
  constructor(
    private repository: OrderRepository,
    private notification: NotificationService,
    private invoiceGenerator: InvoiceGenerator
  ) {}

  process(order: Order) {
    this.repository.save(order);
    this.notification.send(`Order ${order.id} confirmed`);
    this.invoiceGenerator.generate(order);
  }
}
```

---

### Example 2: Payment Processing

**Violates OCP**:
```typescript
class PaymentProcessor {
  process(payment: Payment) {
    if (payment.type === 'credit_card') {
      // Process credit card
    } else if (payment.type === 'paypal') {
      // Process PayPal
    } else if (payment.type === 'crypto') {
      // Process crypto
    }
  }
}
```

**Follows OCP + ISP**:
```typescript
interface PaymentMethod {
  process(amount: number): Promise<PaymentResult>;
}

class CreditCardPayment implements PaymentMethod {
  async process(amount: number) {
    // Credit card logic
  }
}

class PayPalPayment implements PaymentMethod {
  async process(amount: number) {
    // PayPal logic
  }
}

class CryptoPayment implements PaymentMethod {
  async process(amount: number) {
    // Crypto logic
  }
}

class PaymentProcessor {
  async process(paymentMethod: PaymentMethod, amount: number) {
    return await paymentMethod.process(amount);
  }
}
```

---

## Testing Benefits of SOLID

**Bad (hard to test)**:
```typescript
class UserService {
  register(user: User) {
    // Directly creates dependencies
    const db = new Database();
    const email = new EmailService();

    db.save(user);
    email.send(user.email, 'Welcome!');
  }
}

// Can't mock Database or EmailService!
```

**Good (easy to test)**:
```typescript
interface Database {
  save(user: User): void;
}

interface EmailService {
  send(to: string, message: string): void;
}

class UserService {
  constructor(
    private db: Database,
    private email: EmailService
  ) {}

  register(user: User) {
    this.db.save(user);
    this.email.send(user.email, 'Welcome!');
  }
}

// Easy to test with mocks!
const mockDb = { save: jest.fn() };
const mockEmail = { send: jest.fn() };
const service = new UserService(mockDb, mockEmail);
```

---

## Common Violations and Fixes

### Violation 1: God Class

**Problem**:
```typescript
class UserManager {
  createUser() { /* ... */ }
  deleteUser() { /* ... */ }
  sendEmail() { /* ... */ }
  generateReport() { /* ... */ }
  calculateDiscount() { /* ... */ }
  processPayment() { /* ... */ }
}
```

**Fix**: Apply SRP
```typescript
class UserRepository {
  create(user: User) { /* ... */ }
  delete(id: string) { /* ... */ }
}

class EmailService {
  send(to: string, message: string) { /* ... */ }
}

class ReportGenerator {
  generate(type: string) { /* ... */ }
}

class DiscountCalculator {
  calculate(user: User) { /* ... */ }
}

class PaymentProcessor {
  process(payment: Payment) { /* ... */ }
}
```

---

### Violation 2: Concrete Dependencies

**Problem**:
```typescript
class OrderService {
  private mailer = new SendGridMailer();

  placeOrder(order: Order) {
    this.mailer.send(/* ... */);
  }
}
```

**Fix**: Apply DIP
```typescript
interface Mailer {
  send(to: string, subject: string, body: string): void;
}

class SendGridMailer implements Mailer {
  send(to: string, subject: string, body: string) { /* ... */ }
}

class OrderService {
  constructor(private mailer: Mailer) {}

  placeOrder(order: Order) {
    this.mailer.send(/* ... */);
  }
}
```

---

## Summary

**SOLID Principles**:
1. **SRP**: One class, one responsibility
2. **OCP**: Extend behavior without modifying existing code
3. **LSP**: Subtypes must be substitutable
4. **ISP**: Small, focused interfaces
5. **DIP**: Depend on abstractions, not concretions

**Benefits**:
- Easier to test
- Easier to maintain
- Easier to extend
- More flexible
- Better separation of concerns

---

_Maintained by dsmj-ai-toolkit_
