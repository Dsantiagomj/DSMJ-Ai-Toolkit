---
name: patterns
domain: software-design
description: Software design patterns, SOLID principles, and architectural best practices. Covers creational, structural, and behavioral patterns, anti-patterns to avoid, and when to apply each pattern.
version: 1.0.0
tags: [design-patterns, SOLID, architecture, best-practices, anti-patterns]
references:
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

## What This Skill Covers

This skill provides guidance on:
- **SOLID principles** for maintainable code
- **Design patterns** (Creational, Structural, Behavioral)
- **Anti-patterns** and code smells to avoid
- **When to apply** each pattern (and when NOT to)
- **Tradeoffs** between simplicity and abstraction

---

## SOLID Principles

### S - Single Responsibility Principle (SRP)

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

### O - Open/Closed Principle (OCP)

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

### L - Liskov Substitution Principle (LSP)

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

### I - Interface Segregation Principle (ISP)

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

### D - Dependency Inversion Principle (DIP)

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

## Creational Patterns

### Factory Pattern

**Purpose**: Create objects without specifying exact class.

**When to use**:
- Object creation is complex
- Need to decouple creation from usage
- Multiple similar objects with different configurations

**Example** (TypeScript):
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

---

### Builder Pattern

**Purpose**: Construct complex objects step-by-step.

**When to use**:
- Object has many optional parameters
- Avoid telescoping constructors
- Construction process must allow different representations

**Example** (TypeScript):
```typescript
class Pizza {
  private size: string;
  private cheese: boolean = false;
  private pepperoni: boolean = false;
  private bacon: boolean = false;

  constructor(builder: PizzaBuilder) {
    this.size = builder.size;
    this.cheese = builder.cheese;
    this.pepperoni = builder.pepperoni;
    this.bacon = builder.bacon;
  }
}

class PizzaBuilder {
  size: string;
  cheese: boolean = false;
  pepperoni: boolean = false;
  bacon: boolean = false;

  constructor(size: string) {
    this.size = size;
  }

  addCheese() {
    this.cheese = true;
    return this;
  }

  addPepperoni() {
    this.pepperoni = true;
    return this;
  }

  addBacon() {
    this.bacon = true;
    return this;
  }

  build(): Pizza {
    return new Pizza(this);
  }
}

// Usage
const pizza = new PizzaBuilder('large')
  .addCheese()
  .addPepperoni()
  .build();
```

---

### Singleton Pattern

**Purpose**: Ensure only one instance exists globally.

**When to use** (RARELY):
- Truly need global state (logger, config)
- Database connection pool
- **⚠️ Warning**: Often misused, prefer dependency injection

**Example** (TypeScript):
```typescript
class Database {
  private static instance: Database;
  private constructor() {
    // Private constructor prevents direct instantiation
  }

  static getInstance(): Database {
    if (!Database.instance) {
      Database.instance = new Database();
    }
    return Database.instance;
  }

  query(sql: string) {
    console.log(`Executing: ${sql}`);
  }
}

// Usage
const db1 = Database.getInstance();
const db2 = Database.getInstance();
console.log(db1 === db2); // true
```

**⚠️ Avoid Singleton when**:
- You just want "convenience" (use DI instead)
- Testing becomes difficult (hard to mock)
- Hidden dependencies (implicit globals)

---

## Structural Patterns

### Adapter Pattern

**Purpose**: Convert interface of a class to another interface clients expect.

**When to use**:
- Integrate third-party library with incompatible interface
- Reuse existing class with different interface

**Example** (TypeScript):
```typescript
// Legacy interface
class OldPaymentGateway {
  processPayment(amount: number) {
    console.log(`Old gateway: $${amount}`);
  }
}

// New interface expected by our code
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

// Usage
const oldGateway = new OldPaymentGateway();
const adapter = new PaymentAdapter(oldGateway);
adapter.pay(100, 'USD');
```

---

### Decorator Pattern

**Purpose**: Add behavior to objects dynamically.

**When to use**:
- Add responsibilities to individual objects, not entire class
- Extend functionality in a flexible, reusable way

**Example** (TypeScript):
```typescript
interface Coffee {
  cost(): number;
  description(): string;
}

class SimpleCoffee implements Coffee {
  cost() { return 5; }
  description() { return 'Simple coffee'; }
}

class MilkDecorator implements Coffee {
  constructor(private coffee: Coffee) {}

  cost() { return this.coffee.cost() + 2; }
  description() { return this.coffee.description() + ', milk'; }
}

class SugarDecorator implements Coffee {
  constructor(private coffee: Coffee) {}

  cost() { return this.coffee.cost() + 1; }
  description() { return this.coffee.description() + ', sugar'; }
}

// Usage
let coffee: Coffee = new SimpleCoffee();
coffee = new MilkDecorator(coffee);
coffee = new SugarDecorator(coffee);
console.log(coffee.description()); // "Simple coffee, milk, sugar"
console.log(coffee.cost()); // 8
```

---

### Facade Pattern

**Purpose**: Provide simplified interface to complex subsystem.

**When to use**:
- Hide complexity from client code
- Provide single entry point to subsystem

**Example** (TypeScript):
```typescript
// Complex subsystem
class CPU {
  freeze() { console.log('CPU frozen'); }
  execute() { console.log('CPU executing'); }
}

class Memory {
  load(position: number, data: string) {
    console.log(`Memory loaded at ${position}: ${data}`);
  }
}

class HardDrive {
  read(sector: number, size: number): string {
    return `Data from sector ${sector}`;
  }
}

// Facade
class ComputerFacade {
  private cpu = new CPU();
  private memory = new Memory();
  private hardDrive = new HardDrive();

  start() {
    this.cpu.freeze();
    this.memory.load(0, this.hardDrive.read(0, 1024));
    this.cpu.execute();
  }
}

// Usage (simple!)
const computer = new ComputerFacade();
computer.start();
```

---

## Behavioral Patterns

### Observer Pattern

**Purpose**: Define one-to-many dependency; when one object changes, notify dependents.

**When to use**:
- Event systems
- State synchronization across components
- Pub/sub architectures

**Example** (TypeScript):
```typescript
interface Observer {
  update(data: any): void;
}

class Subject {
  private observers: Observer[] = [];

  subscribe(observer: Observer) {
    this.observers.push(observer);
  }

  unsubscribe(observer: Observer) {
    this.observers = this.observers.filter(obs => obs !== observer);
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

---

### Strategy Pattern

**Purpose**: Define family of algorithms, make them interchangeable.

**When to use**:
- Multiple algorithms for same task
- Avoid conditional statements for algorithm selection

**Example** (TypeScript):
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

class CryptoPayment implements PaymentStrategy {
  pay(amount: number) {
    console.log(`Paid $${amount} with cryptocurrency`);
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

---

### Command Pattern

**Purpose**: Encapsulate requests as objects, enabling undo/redo.

**When to use**:
- Need undo/redo functionality
- Queue operations
- Log requests

**Example** (TypeScript):
```typescript
interface Command {
  execute(): void;
  undo(): void;
}

class Light {
  turnOn() { console.log('Light ON'); }
  turnOff() { console.log('Light OFF'); }
}

class LightOnCommand implements Command {
  constructor(private light: Light) {}

  execute() { this.light.turnOn(); }
  undo() { this.light.turnOff(); }
}

class LightOffCommand implements Command {
  constructor(private light: Light) {}

  execute() { this.light.turnOff(); }
  undo() { this.light.turnOn(); }
}

class RemoteControl {
  private history: Command[] = [];

  submit(command: Command) {
    command.execute();
    this.history.push(command);
  }

  undo() {
    const command = this.history.pop();
    if (command) command.undo();
  }
}

// Usage
const light = new Light();
const remote = new RemoteControl();

remote.submit(new LightOnCommand(light));  // Light ON
remote.submit(new LightOffCommand(light)); // Light OFF
remote.undo(); // Light ON (undo last command)
```

---

## Anti-Patterns to Avoid

### 1. God Object

**Problem**: One class does everything.

```typescript
// ❌ Bad
class Application {
  handleAuth() { /* ... */ }
  renderUI() { /* ... */ }
  saveToDatabase() { /* ... */ }
  sendEmail() { /* ... */ }
  generateReports() { /* ... */ }
  // 50 more methods...
}
```

**Solution**: Apply Single Responsibility Principle, split into focused classes.

---

### 2. Premature Abstraction

**Problem**: Creating patterns before you need them.

```typescript
// ❌ Bad (for a simple config)
interface ConfigStrategy { get(key: string): any; }
class JSONConfigStrategy implements ConfigStrategy { /* ... */ }
class YAMLConfigStrategy implements ConfigStrategy { /* ... */ }
class ConfigFactory { /* ... */ }

// ✅ Good (start simple)
const config = {
  apiUrl: 'https://api.example.com',
  timeout: 5000
};
```

**Rule**: "You aren't gonna need it" (YAGNI). Add abstraction when needed, not before.

---

### 3. Lava Flow

**Problem**: Dead code that nobody dares to remove.

```typescript
// ❌ Bad
function processUser(user: User) {
  // TODO: Remove this after migration (added 2019)
  if (user.legacyId) {
    // 500 lines of legacy code nobody understands
  }

  // Actual current logic
  saveUser(user);
}
```

**Solution**: Remove dead code. Version control keeps history.

---

### 4. Copy-Paste Programming

**Problem**: Duplicating code instead of extracting shared logic.

```typescript
// ❌ Bad
function validateEmail(email: string) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

function validateUserEmail(user: User) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(user.email); // Duplicated regex
}

// ✅ Good
function isValidEmail(email: string) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

function validateUserEmail(user: User) {
  return isValidEmail(user.email);
}
```

**Rule**: DRY (Don't Repeat Yourself).

---

## When NOT to Use Patterns

**Don't use patterns when**:
- ❌ Your code is simple and a pattern adds unnecessary complexity
- ❌ You're using a pattern just to "follow best practices" (premature abstraction)
- ❌ The pattern makes code harder to understand for your team
- ❌ You don't have a concrete problem the pattern solves

**Remember**: Patterns are tools, not requirements. Simple code beats clever code.

---

## Quick Decision Guide

**Use Factory when**: Creating objects is complex or varies by context
**Use Builder when**: Objects have many optional parameters
**Use Singleton when**: Truly need ONE global instance (use sparingly!)
**Use Adapter when**: Integrating incompatible interfaces
**Use Decorator when**: Adding responsibilities dynamically
**Use Facade when**: Simplifying complex subsystem
**Use Observer when**: One-to-many event notification needed
**Use Strategy when**: Swapping algorithms at runtime
**Use Command when**: Need undo/redo or queuing operations

---

## References

- [Refactoring.Guru - Design Patterns](https://refactoring.guru/design-patterns)
- [Refactoring.Guru - SOLID Principles](https://refactoring.guru/solid)

---

_Maintained by dsmj-ai-toolkit_
