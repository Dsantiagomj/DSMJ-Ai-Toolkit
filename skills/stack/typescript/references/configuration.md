# Configuration - TypeScript

## tsconfig.json Basics

### Minimal Configuration

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

---

## Compiler Options

### Target and Module

```json
{
  "compilerOptions": {
    // Target JavaScript version
    "target": "ES2020",        // ES3, ES5, ES2015, ES2016, ES2017, ES2018, ES2019, ES2020, ES2021, ES2022, ESNext

    // Module system
    "module": "commonjs",      // commonjs, es2015, es2020, esnext, node16, nodenext

    // Module resolution
    "moduleResolution": "node", // node, classic, node16, nodenext

    // Allow importing JSON files
    "resolveJsonModule": true
  }
}
```

### Output Configuration

```json
{
  "compilerOptions": {
    // Output directory
    "outDir": "./dist",

    // Root directory of source files
    "rootDir": "./src",

    // Generate source maps
    "sourceMap": true,

    // Generate declaration files (.d.ts)
    "declaration": true,

    // Output directory for declaration files
    "declarationDir": "./types",

    // Remove comments from output
    "removeComments": true,

    // Don't emit output files
    "noEmit": false,

    // Import helpers from tslib
    "importHelpers": true
  }
}
```

### Strict Type Checking

```json
{
  "compilerOptions": {
    // Enable all strict type checking options
    "strict": true,

    // Individual strict options (enabled by "strict": true)
    "noImplicitAny": true,              // Error on expressions with implied 'any' type
    "strictNullChecks": true,           // Enable strict null checks
    "strictFunctionTypes": true,        // Enable strict function type checking
    "strictBindCallApply": true,        // Enable strict 'bind', 'call', and 'apply' methods
    "strictPropertyInitialization": true, // Ensure class properties are initialized
    "noImplicitThis": true,             // Error on 'this' with implied 'any' type
    "alwaysStrict": true                // Parse in strict mode and emit "use strict"
  }
}
```

### Additional Checks

```json
{
  "compilerOptions": {
    // Disallow unreachable code
    "allowUnreachableCode": false,

    // Disallow unused labels
    "allowUnusedLabels": false,

    // Report errors on unused locals
    "noUnusedLocals": true,

    // Report errors on unused parameters
    "noUnusedParameters": true,

    // Report error when not all code paths return a value
    "noImplicitReturns": true,

    // Report errors for fallthrough cases in switch statements
    "noFallthroughCasesInSwitch": true,

    // Ensure overriding members are marked with override
    "noImplicitOverride": true,

    // Disallow property access via strings
    "noPropertyAccessFromIndexSignature": true
  }
}
```

---

## Project-Specific Configurations

### Next.js (Frontend)

```json
{
  "compilerOptions": {
    "target": "ES2017",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [
      {
        "name": "next"
      }
    ],
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
```

### Node.js (Backend)

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "lib": ["ES2020"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "moduleResolution": "node",
    "allowSyntheticDefaultImports": true,
    "sourceMap": true,
    "declaration": true,
    "declarationMap": true,
    "types": ["node"],
    "baseUrl": "./",
    "paths": {
      "@/*": ["src/*"]
    }
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "**/*.test.ts", "**/*.spec.ts"]
}
```

### Node.js with ES Modules

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "ES2020",
    "lib": ["ES2020"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "moduleResolution": "node",
    "resolveJsonModule": true,
    "allowSyntheticDefaultImports": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

### Library/Package

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "lib": ["ES2020"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "**/*.test.ts"]
}
```

---

## Path Mapping

### Absolute Imports

```json
{
  "compilerOptions": {
    "baseUrl": "./",
    "paths": {
      "@/*": ["src/*"],
      "@components/*": ["src/components/*"],
      "@lib/*": ["src/lib/*"],
      "@utils/*": ["src/utils/*"],
      "@types/*": ["src/types/*"]
    }
  }
}
```

```typescript
// Before
import { Button } from '../../../components/ui/button'
import { db } from '../../../lib/db'

// After
import { Button } from '@components/ui/button'
import { db } from '@lib/db'
```

---

## Type Declarations

### Global Types

```typescript
// src/types/global.d.ts
declare global {
  namespace NodeJS {
    interface ProcessEnv {
      DATABASE_URL: string
      NEXTAUTH_SECRET: string
      NEXTAUTH_URL: string
    }
  }
}

export {}
```

### Module Declarations

```typescript
// src/types/modules.d.ts
declare module '*.svg' {
  const content: React.FunctionComponent<React.SVGAttributes<SVGElement>>
  export default content
}

declare module '*.css' {
  const content: { [className: string]: string }
  export default content
}

declare module 'some-untyped-package' {
  export function someFunction(param: string): void
}
```

### Extending Third-Party Types

```typescript
// src/types/express.d.ts
import { User } from '@/models/user'

declare global {
  namespace Express {
    interface Request {
      user?: User
    }
  }
}
```

---

## Project References (Monorepos)

### Root tsconfig.json

```json
{
  "files": [],
  "references": [
    { "path": "./packages/client" },
    { "path": "./packages/server" },
    { "path": "./packages/shared" }
  ]
}
```

### Package tsconfig.json

```json
{
  "extends": "../../tsconfig.base.json",
  "compilerOptions": {
    "composite": true,
    "outDir": "./dist",
    "rootDir": "./src"
  },
  "include": ["src/**/*"],
  "references": [
    { "path": "../shared" }
  ]
}
```

---

## Incremental Compilation

```json
{
  "compilerOptions": {
    // Enable incremental compilation
    "incremental": true,

    // Specify file to store incremental info
    "tsBuildInfoFile": "./.tsbuildinfo",

    // Enable composite project
    "composite": true
  }
}
```

---

## JSX Configuration

### React

```json
{
  "compilerOptions": {
    "jsx": "react-jsx",        // React 17+ (no import React needed)
    // "jsx": "react",         // React <17 (requires import React)
    // "jsx": "preserve",      // Keep JSX for another tool (e.g., Babel)
    "jsxImportSource": "react"
  }
}
```

---

## Type Checking JavaScript

```json
{
  "compilerOptions": {
    // Allow JavaScript files to be compiled
    "allowJs": true,

    // Type check JavaScript files
    "checkJs": true,

    // Max number of files to open at once
    "maxNodeModuleJsDepth": 1
  }
}
```

---

## Build Performance

```json
{
  "compilerOptions": {
    // Skip type checking of declaration files
    "skipLibCheck": true,

    // Skip default library checking
    "skipDefaultLibCheck": true,

    // Disable checking on file changes
    "assumeChangesOnlyAffectDirectDependencies": true,

    // Force consistent casing in file names
    "forceConsistentCasingInFileNames": true
  }
}
```

---

## Watch Mode

```json
{
  "watchOptions": {
    // Use file system events for file watching
    "watchFile": "useFsEvents",

    // Use file system events for directory watching
    "watchDirectory": "useFsEvents",

    // Poll files for changes (fallback)
    "fallbackPolling": "dynamicPriority",

    // Synchronously call callbacks and update the state
    "synchronousWatchDirectory": true,

    // Exclude directories
    "excludeDirectories": ["**/node_modules", "_build"],

    // Exclude files
    "excludeFiles": ["build/fileWhichChangesOften.ts"]
  }
}
```

---

## Multiple Configurations

### Extending Base Config

```json
// tsconfig.base.json
{
  "compilerOptions": {
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  }
}

// tsconfig.json (extends base)
{
  "extends": "./tsconfig.base.json",
  "compilerOptions": {
    "outDir": "./dist",
    "rootDir": "./src"
  },
  "include": ["src/**/*"]
}

// tsconfig.test.json (for tests)
{
  "extends": "./tsconfig.json",
  "compilerOptions": {
    "types": ["jest", "node"]
  },
  "include": ["src/**/*", "tests/**/*"]
}
```

---

## Environment-Specific Configs

### Development

```json
{
  "extends": "./tsconfig.base.json",
  "compilerOptions": {
    "sourceMap": true,
    "removeComments": false,
    "noEmit": false
  }
}
```

### Production

```json
{
  "extends": "./tsconfig.base.json",
  "compilerOptions": {
    "sourceMap": false,
    "removeComments": true,
    "declaration": true
  }
}
```

---

## Common Compiler Options Reference

```json
{
  "compilerOptions": {
    // Language and Environment
    "target": "ES2020",
    "lib": ["ES2020", "DOM"],
    "jsx": "react-jsx",
    "experimentalDecorators": true,
    "emitDecoratorMetadata": true,

    // Modules
    "module": "commonjs",
    "moduleResolution": "node",
    "baseUrl": "./",
    "paths": {},
    "rootDirs": [],
    "resolveJsonModule": true,

    // Emit
    "outDir": "./dist",
    "rootDir": "./src",
    "sourceMap": true,
    "declaration": true,
    "declarationMap": true,
    "removeComments": true,
    "importHelpers": true,
    "downlevelIteration": true,

    // Interop Constraints
    "isolatedModules": true,
    "allowSyntheticDefaultImports": true,
    "esModuleInterop": true,
    "forceConsistentCasingInFileNames": true,

    // Type Checking
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,

    // Completeness
    "skipLibCheck": true
  }
}
```
