## Security Groups and Network Security

This project follows the principle of **least privilege** by using separate Security Groups for the Application Load Balancer, application servers, and database tier.

Each Security Group allows only the traffic required for its role, limiting unnecessary network exposure between tiers.

### Security Groups Architecture

The architecture uses three Security Groups:

| Security Group | Inbound Traffic | Outbound Traffic |
|---|---|---|
| ALB Security Group | HTTP (TCP 80) from the internet (`0.0.0.0/0`) | HTTP traffic to the application tier on the application port |
| Application Security Group | HTTP (TCP 80) only from the ALB Security Group | HTTPS (TCP 443) for outbound access, plus database traffic to the database Security Group |
| Database Security Group | MySQL (TCP 3306) only from the Application Security Group | No additional outbound access is intentionally required by the application design |

### 1. Application Load Balancer Security Group

The ALB Security Group allows inbound HTTP traffic on TCP port 80 from public clients.

Its outbound rule allows HTTP traffic to the application servers on the configured application port.

Application instances are not directly exposed to the internet through their Security Group rules. Client requests must pass through the Application Load Balancer.

**Security considerations:**
- Only the required listener traffic is allowed.
- HTTPS ingress is not enabled until a TLS certificate and HTTPS listener are configured.
- For a production deployment, configure HTTPS using AWS Certificate Manager (ACM) and redirect HTTP requests to HTTPS.

### 2. Application Security Group

The application Security Group is attached to EC2 instances deployed in private application subnets.

Inbound HTTP traffic is allowed **only from the ALB Security Group**, rather than from public IP ranges.

Outbound rules allow:
- HTTPS traffic on TCP port 443 for operations such as downloading packages and accessing external HTTPS endpoints.
- Database traffic to the database Security Group on the configured database port.

This design reduces direct exposure of application servers and restricts communication to explicitly defined sources and destinations.

**Important:** Outbound HTTPS access requires a working network egress path, such as a NAT Gateway, unless another supported connectivity mechanism is configured. Security Group rules alone do not provide internet connectivity.

### 3. Database Security Group

The database Security Group allows inbound MySQL traffic on TCP port 3306 **only from the Application Security Group**.

It does not allow database connections directly from the internet or from arbitrary public IP addresses.

Database instances should be deployed in private database subnets, with no direct public IP exposure and no unnecessary internet route.

### Traffic Flow

The intended application traffic flow is:

`Internet → Application Load Balancer → Private EC2 Instances → Database`

Each tier accepts traffic only from the appropriate preceding component.

### Security Design Principles

- **Least privilege:** Allow only the required ports and traffic sources.
- **Tier isolation:** Separate Security Groups for the ALB, application, and database tiers.
- **Source Security Group references:** Use Security Group IDs instead of broad CIDR ranges for communication between internal tiers.
- **Reduced public exposure:** Keep application instances and the database in private subnets.
- **Controlled egress:** Define outbound access according to application requirements.
- **Defense in depth:** Combine Security Groups with subnet routing, IAM permissions, encryption, and monitoring.

### Validation Checklist

- [ ] The ALB accepts HTTP traffic on TCP port 80.
- [ ] Application instances accept HTTP traffic only from the ALB Security Group.
- [ ] The database accepts MySQL traffic only from the Application Security Group.
- [ ] No database inbound rule allows `0.0.0.0/0`.
- [ ] Application instances are deployed in private subnets.
- [ ] Outbound connectivity requirements are documented and tested.
- [ ] HTTPS is configured before claiming end-to-end encrypted client connections.

**Note:** Security Groups are stateful. Response traffic for an allowed connection is automatically permitted, even when a corresponding reverse-direction rule is not explicitly configured.