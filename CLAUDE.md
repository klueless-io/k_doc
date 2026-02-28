# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

**k_doc** is a Ruby gem that provides flexible document structures using a DSL for modeling key/value settings and tabular data. It's part of the kgems collection of reusable Ruby libraries.

## Development Commands

### Setup
```bash
bin/setup              # Initialize development environment
bundle install         # Install dependencies
```

### Testing
```bash
rake spec              # Run all tests
bundle exec rspec      # Run RSpec directly
rspec spec/path/to/specific_spec.rb  # Run single test file
rspec spec/path/to/specific_spec.rb:42  # Run test at specific line
```

### Development Workflow
```bash
guard                  # Auto-run tests and RuboCop on file changes (RECOMMENDED)
bin/console            # Interactive REPL for experimentation
```

### Build & Publish
```bash
rake build             # Compile extensions (runs clobber + compile)
rake publish           # Build and push gem to RubyGems.org
rake clean             # Remove old .gem files
rake default           # Run clobber, compile, and spec
```

## Architecture

### Core Data Structures

The gem follows a **Composite Design Pattern** for nested data structures:

```
Container (base class)
├── Model (main entry point for documents)
│   ├── Settings (key/value pairs)
│   └── Table (rows with typed fields)
├── Action
├── CsvDoc
├── JsonDoc
└── YamlDoc
```

### Key Components

**Container** (`lib/k_doc/container.rb`):
- Base class for all data objects
- Includes mixins: `Guarded`, `Taggable`, `Datum`, `BlockProcessor`
- Provides context (OpenStruct) for sharing data between components
- Supports ownership relationships

**Model** (`lib/k_doc/model.rb`):
- Primary DSL entry point for building documents
- Can contain multiple named `settings` groups (key/value pairs)
- Can contain multiple named `table` groups (structured data with fields/rows)
- Default names: `:settings` for settings, `:table` for tables
- Provides `odata` (OpenStruct accessor) and `oraw` (raw data without metadata)

**Settings** (`lib/k_doc/settings.rb`):
- Dynamic key/value store with method_missing magic
- Supports getter/setter syntax: `name "value"` or `name = "value"`
- Can reference parent context: `favourite_mutant context.xmen`
- Supports decorators for post-processing

**Table** (`lib/k_doc/table.rb`):
- Structured tabular data with typed fields and rows
- Field definitions: `field(name, default_value, type)` or `f(name, default, type)`
- Row insertion: `row(positional_args...)` or `row(named: args)`
- Default field type: `:string`
- Supports decorators for field/row manipulation

### Complete DSL Example

A KDoc has these core concepts:
1. **Root** - The model container (`KDoc.model`)
2. **Settings** - Key/value pairs with default name `:settings` or custom names (e.g., `:production`)
3. **Table** - Structured data with fields (columns) and rows

```ruby
# Create a KDoc model
doc = KDoc.model('my_document') do
  # Optional initialization - set shared context values
  init do
    context.environment = 'production'
    context.admin_user = 'Wolverine'
  end

  # Default settings group (key: :settings)
  settings do
    name 'My Application'
    description 'A sample application document'
    version '1.0.0'
  end

  # Named settings group (key: :production)
  settings :production do
    database_url 'postgresql://localhost/prod_db'
    api_key 'secret-key-123'
    environment context.environment  # Reference from context
  end

  # Default table (key: :table)
  # Demonstrates field definitions with types and defaults
  table do
    fields :role, f(:active, true, :boolean)

    # Positional arguments match field order
    row :owner, true
    row :staff, false
  end

  # Named table (key: :people)
  # Demonstrates both positional and named arguments
  table :people do
    fields f(:first_name), f(:last_name), f(:age, 0, :integer), f(:role, :member, :symbol)

    # Positional arguments (in field order)
    row 'David', 'Cruwys', 45, :admin
    row 'Ben', 'Smith', 32, :staff

    # Named arguments (order doesn't matter, can skip fields)
    row first_name: 'Alice', age: 28, role: :manager
    row last_name: 'Jones', first_name: 'Bob'

    # Mixed: positional then named (positional must come first)
    row 'Sarah', 'Connor', age: 35, role: :owner

    # Reference context values
    row context.admin_user, 'Logan', 150, :owner
  end
end

# IMPORTANT: Must execute the block to evaluate DSL
doc.execute_block

# Access data multiple ways:
doc.data                          # Hash with all data including metadata
doc.raw_data                      # Hash with user data only (no 'fields' keys for tables)
doc.odata                         # OpenStruct for dot notation access

# Settings access
doc.data['settings']              # => {"name" => "My Application", "description" => ..., "version" => "1.0.0"}
doc.odata.settings.name           # => "My Application"
doc.data['production']            # => {"database_url" => "postgresql://...", ...}
doc.odata.production.environment  # => "production"

# Table access
doc.data['table']                 # => {"fields" => [...], "rows" => [...]}
doc.data['table']['rows']         # => Array of row hashes
doc.raw_data['table']             # => Just the rows array (no 'fields' key)
doc.data['people']['rows']        # => Array of people rows
doc.odata.people.rows.first.first_name  # => "David"
```

### Module Structure

**Mixins** (`lib/k_doc/mixins/`):
- `Guarded` - Validation and error handling
- `Taggable` - Key, type, namespace metadata
- `Datum` - Data management and child component handling
- `BlockProcessor` - DSL block evaluation with init/action hooks
- `ComposableComponents` - Composite pattern navigation

**Decorators** (`lib/k_doc/decorators/`):
- Post-processing pattern for Settings and Table components
- Implement `compatible?(component)` and `decorate(component, behaviour)`
- Run once per behaviour (`:update_fields`, `:update_rows`, `:settings`)

### Factory Methods

The `KDoc` module provides convenience methods:

```ruby
KDoc.model(key, **opts, &block)        # General purpose model
KDoc.document(key, **opts, &block)     # type: :document
KDoc.bootstrap(key, **opts, &block)    # type: :bootstrap
KDoc.app_settings(key, **opts, &block) # type: :app_settings
KDoc.action(key, **opts, &block)       # Action document
KDoc.csv(key, **opts, &block)          # CSV document
KDoc.json(key, **opts, &block)         # JSON document
KDoc.yaml(key, **opts, &block)         # YAML document
```

## Code Standards

- **Required header**: `# frozen_string_literal: true` at the top of all Ruby files
- **Testing**: RSpec with `--require spec_helper` (no explicit requires in specs)
- **Linting**: RuboCop runs automatically after successful tests in Guard
- **Naming**: Use snake_case for methods/variables, use symbols for internal keys
- **Dependencies**: k_log (logging), k_type (types), k_util (utilities), k_decor (decorators)

## Testing Patterns

- Specs mirror lib structure: `lib/k_doc/model.rb` → `spec/k_doc/model_spec.rb`
- Use `subject { instance }` pattern extensively
- Mock decorators in `spec/mocks/` for testing decorator functionality
- Test both DSL evaluation (`fire_eval`) and raw object construction

## Important Notes

- Models must call `execute_block` to evaluate the DSL block
- Context is scoped to the block during `init`, but values are cleared after (intentional isolation)
- `raw_data` strips metadata (e.g., 'fields' key) to return only rows for tables
- Settings and Table use `method_missing` to delegate unknown methods to parent
- Decorators are opt-in via `decorators: [DecoratorClass]` option

## Dependencies

Core kgems dependencies:
- `k_log` - Structured logging
- `k_type` - Type coercion and utilities
- `k_util` - Data manipulation utilities
- `k_decor` - Decorator pattern support

External dependencies:
- `table_print` - Console table printing
- `forwardable` - Delegation support
