## Architecture Overview

The following diagram shows the current AWS architecture, including
public and private subnets, ingress via NGINX, monitoring, and NAT egress.

```mermaid
flowchart BT
    Internet(((Internet)))
    subgraph VPC[AWS VPC]
        IGW([Internet Gateway])
        subgraph PublicSubnet[PublicLabel]
            NGINX[NGINX]
            Monitoring["(Monitoring) Prometheus / Grafana"]
            NAT{{NAT Gateway}}
        end

        subgraph PrivateSubnet[PrivateLabel]
            App[Web App]
            DB[("Database\n(MySql)")]
        end
    end

    Internet <==> IGW
    IGW <==> NGINX
    NGINX <==>|Web Traffic| App
    App -.->|"DB Queries (3306)"| DB
    IGW ==> Monitoring

    App metricsApp@-->|"Fetch Node Metrics (9100) & Container Metrics (8080)"| Monitoring
    DB metricsDB@-->|"Fetch Node Metrics (9100) & Container Metrics (8080)"| Monitoring

    App -.-> NAT
    DB -.-> NAT
    NAT -.-> IGW
    
    metricsApp@{ animation: slow }    
    metricsDB@{ animation: slow }

    %% Node-only styling (GitHub safe)
    classDef ingress fill:#dbeafe,stroke:#2563eb,color:#000000
    classDef monitoring fill:#fff7ed,stroke:#ea580c,color:#000000
    classDef nat fill:#f3e8ff,stroke:#7c3aed,color:#000000
    classDef app fill:#dcfce7,stroke:#16a34a,color:#000000
    classDef db fill:#fde2e4,stroke:#dc2626,color:#000000
    classDef igw fill:#EA7B7B,stroke:#D25353,color:#00000
    classDef subnetLabel fill:#ffffff,stroke:#374151,stroke-width:1.5px,color:#111827,font-weight:bold

    style VPC fill:#eef0f2,stroke:#4b5563,stroke-width:2px
    style PublicSubnet fill:#e3f2fd,stroke:#2563eb,stroke-width:2px
    style PrivateSubnet fill:#e8f5e9,stroke:#16a34a,stroke-width:2px    
    linkStyle default stroke:#000

    PublicLabel["Public Subnet"]:::subnetLabel
    PrivateLabel["Private Subnet"]:::subnetLabel

    class NGINX ingress
    class Monitoring monitoring
    class NAT nat
    class App app
    class DB db
    class IGW igw
```
