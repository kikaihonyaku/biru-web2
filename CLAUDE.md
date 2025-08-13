# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Ruby on Rails 8.0 application called "Biru Web" (building management system) that manages property/building data, owners, tenants, and maintenance operations. The application uses a Microsoft SQL Server database with the "biru" schema and features mapping functionality with Google Maps integration.

## Database Configuration

- **Database**: Microsoft SQL Server
- **Schema**: `biru` (all models use `self.table_name = 'biru.table_name'`)
- **Connection**: Uses `activerecord-sqlserver-adapter` and `tiny_tds` gems
- **Host**: 192.168.0.12:1433
- **Databases**: BIRU30_DEV (development), BIRU30_TEST (test), BIRU30 (production)

## Key Architecture Patterns

### Model Structure
- All models inherit from `ActiveRecord::Base` and use explicit table names with `biru.` schema prefix
- Key domain models include:
  - `Building`: Core property/building entity with geocoding capabilities
  - `Owner`: Property owners with relationship to buildings through trusts
  - `Trust`: Junction model connecting owners to buildings with management details
  - `Room`: Individual units within buildings
  - `Shop`: Sales offices/branches managing properties
  - Geographic models: `Station`, `Line`, `BuildingNearestStation`

### Controller Architecture
- Controllers follow Rails conventions with specific domain focus:
  - `PropertyController`: Property/building management and search
  - `TrustManagementsController`: Trust relationship management
  - `RentersController`: Tenant/renter management
  - `PerformanceController`: Analytics and reporting

### Database Queries
- Heavy use of raw SQL queries for complex reporting and mapping data
- Most controllers build dynamic SQL strings for flexible filtering
- Common pattern: `ActiveRecord::Base.connection.select_all(sql_string)`

### Mapping Integration
- Uses `gmaps4rails` gem for Google Maps functionality
- Buildings have `acts_as_gmappable` for geocoding
- Custom Google Maps API integration with signed URLs for geocoding
- Map data passed to frontend via `gon` gem (Rails to JavaScript data transfer)

## Common Development Commands

### Rails Commands
```bash
# Start development server
rails server

# Run database migrations
rails db:migrate

# Access Rails console
rails console

# Run tests
rails test
# or use rspec for specific tests
bundle exec rspec
```

### Database Operations
```bash
# Reset database (caution: destructive)
rails db:reset

# Seed database
rails db:seed
```

### Code Quality
```bash
# Run Ruby linting
bundle exec rubocop

# Run security analysis
bundle exec brakeman
```

## Testing Framework

The application uses both built-in Rails testing and RSpec:
- RSpec configuration available via `rspec-rails` gem
- Test files located in `test/` directory for Rails tests
- System tests use `capybara` and `selenium-webdriver`

## Key Dependencies

### Core Rails Stack
- Rails 8.0.2 with modern asset pipeline (`propshaft`)
- SQL Server integration (`tiny_tds`, `activerecord-sqlserver-adapter`)
- Asset management with `importmap-rails`, `turbo-rails`, `stimulus-rails`

### Business Logic Gems
- `gmaps4rails`: Google Maps integration
- `gon`: Rails to JavaScript data passing
- `wice_grid`: Advanced table/grid functionality for views
- `simple_form`: Form building
- `thinreports`: Report generation
- `lazy_high_charts`: Chart/graph functionality

### Development Tools
- `debug`: Debugging support
- `brakeman`: Security vulnerability scanning
- `rubocop-rails-omakase`: Code styling

## Frontend Technology

- Uses jQuery (`jquery-rails`) for DOM manipulation
- Heavy JavaScript integration for mapping and interactive features
- Bootstrap CSS framework (evidenced by bootstrap-themed assets)
- Custom JavaScript files for specific functionality (biru-map.js, etc.)

## File Organization Notes

- Controllers follow domain-specific naming (property, trust_managements, etc.)
- Models represent business entities with complex relationships
- Views organized by controller with shared partials
- JavaScript assets include both vendor libraries and custom business logic
- Extensive use of database migrations for schema management

## Development Workflow

1. Database schema changes require migrations in `db/migrate/`
2. Model changes should maintain `biru.` schema prefix in table names
3. Complex queries are typically written as raw SQL in controller methods
4. Map-related features require coordination between backend data preparation and frontend JavaScript
5. Security: Database credentials are in `config/database.yml` - ensure proper environment variable usage in production

## Special Considerations

- This is a Japanese language application (evidenced by comments and variable names)
- Heavy reliance on raw SQL suggests complex business logic requiring database-level operations
- Mapping functionality is core to the application's purpose
- Multi-tenant architecture implied by shop-based data segmentation