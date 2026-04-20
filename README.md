## Architecture Overview

The following diagram shows the current AWS architecture, including
public and private subnets, ingress via NGINX, monitoring, and NAT egress.

```mermaid
flowchart TB
    Internet((Internet))

    subgraph VPC[AWS VPC]
        subgraph PublicSubnet[Public Subnet]
            NGINX[NGINX]
            Monitoring["(Monitoring)\nPrometheus / Grafana"]
            NAT[NAT Gateway]
        end

        subgraph PrivateSubnet[Private Subnet]
            App[Web App]
            DB["Database\n(MySql)"]
        end
    end

    Internet --> NGINX
    NGINX --> App
    App --> DB

    Monitoring --> App
    Monitoring --> DB

    App --> NAT
    DB --> NAT
    NAT --> Internet

    %% Node-only styling (GitHub safe)
    classDef ingress fill:#dbeafe,stroke:#2563eb,color:#000000
    classDef monitoring fill:#fff7ed,stroke:#ea580c,color:#000000
    classDef nat fill:#f3e8ff,stroke:#7c3aed,color:#000000
    classDef app fill:#dcfce7,stroke:#16a34a,color:#000000
    classDef db fill:#fde2e4,stroke:#dc2626,color:#000000

    class NGINX ingress
    class Monitoring monitoring
    class NAT nat
    class App app
    class DB db
```
