# Layer 1: Infrastructure

This layer contains the core infrastructure components that provide the foundation for the entire Universal DB system.

## Components

### docker-compose.yml
- **Purpose**: Defines and orchestrates the PostgreSQL database container
- **Function**: 
  - Creates isolated PostgreSQL instance
  - Maps port 5433:5432 to avoid conflicts
  - Sets up persistent data volumes
  - Configures database credentials

### .env
- **Purpose**: Environment configuration for database connection
- **Function**:
  - Centralizes database credentials
  - Provides connection parameters
  - Ensures consistent configuration across components

## Architecture Role

This layer provides:
- **Isolation**: Database runs in its own container
- **Portability**: Can be deployed anywhere Docker runs
- **Consistency**: Same environment across development/production
- **Persistence**: Data survives container restarts

## Usage

```bash
# Start infrastructure
cd Layer-1-Infrastructure
docker-compose up -d

# Stop infrastructure  
docker-compose down
```

## Dependencies
- Docker
- Docker Compose

## Next Layer
→ Layer-2-Database-Schema: Defines the data structure within this infrastructure
