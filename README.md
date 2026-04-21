## Architecture Overview

The following diagram shows the current AWS architecture, including
public and private subnets, ingress via NGINX, monitoring, and NAT egress.

```mermaid
flowchart LR
    Internet(((Internet)))
    subgraph VPC[AWS VPC]
        IGW([Internet Gateway])
        subgraph PublicSubnet[Public Facing Subnet]
            NAT{{"Elastic IP\nNAT Gateway"}}
            NGINX["NGINX\n(Reverse Proxy)"]
            Monitoring["(Monitoring) Prometheus / Grafana (Scrape Node (9100) & Docker (8080) Metrics"]
            Testing["Test Runner (API)"]
        end

        subgraph PrivateSubnet[Private Subnet]
            App["Directus\n(Web App)"]
            DB[("MySQL Database (3306)")]
        end
    end

    Internet <==> IGW
    IGW <==> NGINX
    NGINX <==> App
    App -.-> DB
    IGW ==> Monitoring
    IGW ==> Testing

    App metricsApp@--> Monitoring
    DB metricsDB@--> Monitoring
    Testing --> App
    
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
    classDef igw fill:#EA7B7B,stroke:#D25353,color:#000000
    classDef PublicSubnet fill:#e3f2fd,stroke:#2563eb
    classDef PrivateSubnet fill:#e8f5e9,stroke:#16a34a    
    classDef VPC fill:#F9DFDF,stroke:#4b5563,stroke-width:2px,color:#000000
    classDef testing fill:#D0DDD0,stroke:#AAB99A, stroke-width:2px,color:#000000

    style VPC fill:#F9DFDF,stroke:#4b5563,stroke-width:2px,color:#000000,font-size:14px
    style PublicSubnet fill:#e3f2fd,stroke:#2563eb,stroke-width:2px,color:#000000,font-size:14x
    style PrivateSubnet fill:#e8f5e9,stroke:#16a34a,stroke-width:2px,color:#000000,font-size:14px
    style Internet fill:#FFA239,stroke:#E97F4A,stroke-width:4px,color:#000000,font-size:14px

    linkStyle default stroke:#9B7EBD

    class NGINX ingress
    class Monitoring monitoring
    class NAT nat
    class App app
    class DB db
    class IGW igw
    class Testing testing
```
