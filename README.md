# SQL Repository

A centralized version-controlled repository for SQL files used across multiple projects and database platforms.

## Purpose

This repository serves as a single source of truth for SQL scripts, schemas, migrations, and queries. By version controlling SQL assets, this repository enables:

- **Schema tracking**: Monitor database schema evolution over time
- **Migration management**: Maintain ordered, versioned database migrations
- **Query reusability**: Share and standardize SQL queries across projects
- **Collaboration**: Enable team members to review and improve SQL code through version control workflows
- **Historical context**: Preserve commit messages and change history for understanding decisions

## Current Structure

```
sql/
├── Cardholder/
│   ├── 0000_create_roles_for_any_vanilla_postgresql.sql
│   ├── 0001_create_schemas_and_grant_usage.sql
│   ├── 0002_seed_database.sql
│   ├── 0003_create_decks_and_flashcards.sql
│   ├── 0004_seed_decks_and_flashcards.sql
│   ├── 0005_analytics_and_sessions.sql
│   └── 0006_seed_analytics_session.sql
└── README.md
```

### Cardholder Folder

The `Cardholder/` folder contains PostgreSQL-specific SQL files for the Cardholder project. Files are numbered sequentially to indicate execution order and include:

- **Role and permission management**: Setup of PostgreSQL roles and authorization
- **Schema creation**: Creation of database schemas and object structures
- **Data seeding**: Initial data population for development and testing
- **Feature migrations**: Schema modifications for specific features (e.g., decks, flashcards, analytics)

All scripts in this folder are written for **PostgreSQL**.

## Future Expansion

This repository is designed for growth beyond the Cardholder project and beyond PostgreSQL. While currently focused on a single project and database platform, it will expand to include:

- SQL scripts for additional projects
- SQL files for other database platforms (SQL Server/MSSQL, MySQL, etc.)
- Shared utility scripts and common patterns
- Database maintenance and administration scripts

### Planned Directory Structure

As the repository grows, the structure is expected to evolve to organize scripts by project and database platform:

```
sql/
├── cardholder/
│   ├── postgresql/
│   │   ├── schema/
│   │   ├── migrations/
│   │   └── seed/
│   ├── mssql/
│   │   ├── schema/
│   │   ├── migrations/
│   │   └── seed/
│   └── mysql/
│       ├── schema/
│       ├── migrations/
│       └── seed/
├── analytics-platform/
│   ├── postgresql/
│   ├── mssql/
│   └── mysql/
├── reporting-service/
│   ├── postgresql/
│   └── mssql/
└── README.md
```

This structure allows for:

- **Isolation by project**: Each project's SQL assets remain independent
- **Multi-database support**: Platform-specific scripts organized by database type
- **Clear categorization**: Scripts grouped by purpose (schema, migrations, seed data)
- **Scalability**: Easy addition of new projects and database platforms

## Not Limited to Cardholder

Although the repository currently contains assets for the Cardholder project, **it is not limited to this project**. The repository is designed as a general-purpose SQL asset repository that will grow to serve multiple projects and teams.

## Best Practices

When adding or modifying SQL files in this repository:

- **Use consistent naming conventions**: Prefix files with sequence numbers to indicate execution order
- **Include descriptive names**: File names should clearly indicate their purpose
- **Add commit messages**: Document the reason for schema changes and migrations
- **Test thoroughly**: Ensure scripts have been tested on their target database platform
- **Handle database-specific syntax**: Keep platform-specific code organized in separate directories
- **Document dependencies**: Note any prerequisites or dependencies between scripts

## Contributing

When adding new SQL files:

1. Choose the appropriate folder structure based on project and database platform
2. Use numbered prefixes for sequential execution (e.g., `0001_`, `0002_`)
3. Write clear, maintainable SQL
4. Test scripts before committing
5. Provide descriptive commit messages explaining the purpose of changes

## License

See LICENSE file for details (if applicable).
