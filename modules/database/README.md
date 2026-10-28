# Database Module

## Overview

The Database Module provisions a managed relational database using Amazon Relational Database Service (Amazon RDS) with MySQL.

It deploys the database within private database subnets and integrates with the project's existing Security Group configuration to restrict network access to authorized application resources.

The module follows infrastructure-as-code principles by managing database provisioning, storage encryption, backup configuration, and database credentials through Terraform and AWS-managed services.

## Architecture

```text
             Application Tier
           Private EC2 Instances
                     |
                     | MySQL / TCP 3306
                     |
                     v
             Database Security Group
                     |
                     v
               Amazon RDS
                MySQL Engine
                     |
                     v
             Private DB Subnets
                 AZ-A and AZ-B
```

The database is not intended to be accessed directly from the public internet. Application instances communicate with RDS through the VPC using the database endpoint and the appropriate network and security configurations.

## Resources Created

| Resource | Purpose |
|---|---|
| `aws_db_subnet_group.db_subnet` | Groups the private database subnets used by RDS. |
| `aws_db_instance.database` | Provisions and manages the MySQL database instance. |
| AWS Secrets Manager secret | Stores the master credentials managed by Amazon RDS when `manage_master_user_password` is enabled. |

The Secrets Manager secret is managed by RDS rather than being explicitly created as a separate Terraform resource in this module.

## Key Features

### 1. Managed MySQL Database

The module provisions an Amazon RDS instance running MySQL.

RDS handles database infrastructure management and supports operational features such as automated backups, maintenance, and recovery.

The database name and master username are configurable through module inputs.

### 2. Private Network Deployment

The database is associated with a DB Subnet Group containing private database subnets across multiple Availability Zones.

The configuration uses:

```hcl
publicly_accessible = false
```

This prevents RDS from being configured for direct public accessibility.

Database connectivity remains subject to VPC routing, Security Group rules, and the network path used by the client.

### 3. Database Security Group

The module receives an existing Database Security Group ID instead of creating another Security Group.

The intended access policy permits MySQL traffic on TCP port 3306 from the Application Security Group only.

This restricts database access to the application tier and avoids exposing the database port to arbitrary internet sources.

### 4. Encryption at Rest

The database storage is encrypted using:

```hcl
storage_encrypted = true
```

This protects the underlying RDS storage at rest.

The configuration does not explicitly specify a customer-managed AWS KMS key. If no key is specified, RDS uses the applicable default AWS-managed encryption key.

### 5. Credential Management with AWS Secrets Manager

The module uses:

```hcl
manage_master_user_password = true
```

This allows Amazon RDS to manage the master password and store it in AWS Secrets Manager.

Benefits include:

- Avoiding hardcoded database passwords in Terraform configuration.
- Reducing direct password management in deployment workflows.
- Providing a managed mechanism for retrieving database credentials.
- Supporting controlled access through IAM permissions.

The secret ARN is exposed as a Terraform output so authorized administrators or applications can locate the secret without exposing its password as an output.

**Security note:** Protect access to the secret and Terraform state. Avoid retrieving passwords unnecessarily or printing sensitive values in terminal output or logs.

### 6. Multi-AZ Deployment

The module supports Multi-AZ deployment through:

```hcl
multi_az = var.multi_az
```

The default configuration enables Multi-AZ.

For a traditional Multi-AZ RDS DB instance, AWS maintains a standby in another Availability Zone to support failover when required.

The standby is not a read replica for application read traffic. Read scaling requires a different design, such as appropriate read replicas or a supported Multi-AZ DB cluster configuration.

Multi-AZ availability depends on the selected engine, instance class, and supported regional configuration.

### 7. Storage Configuration

The database uses encrypted General Purpose SSD storage (`gp3`).

| Setting | Default |
|---|---|
| Initial allocated storage | 20 GiB |
| Maximum allocated storage | 100 GiB |
| Storage type | `gp3` |
| Storage encryption | Enabled |
| Storage autoscaling | Configurable through `max_allocated_storage` |

The maximum allocated storage setting allows RDS storage autoscaling when supported and when additional storage is needed.

Storage autoscaling does not automatically reduce allocated storage when demand decreases.

### 8. Automated Backups

The module configures:

```hcl
backup_retention_period = 7
```

RDS retains automated backups for seven days.

The actual recovery options depend on the database configuration and the availability of valid backups and transaction logs.

For production workloads, backup retention and recovery objectives should be defined according to the application's Recovery Point Objective (RPO) and Recovery Time Objective (RTO).

### 9. Database Lifecycle Management

The current configuration includes:

```hcl
deletion_protection = false
skip_final_snapshot = true
```

These settings simplify the deletion of a temporary development database.

However, they are not recommended for production databases containing important data because the database can be deleted without requiring a final snapshot.

For production environments, consider enabling deletion protection and requiring a final snapshot before deleting the database.

## Module Inputs

| Variable | Description | Default |
|---|---|---|
| `project_name` | Project identifier used for resource naming. | Required |
| `private_db_subnet_ids` | Private database subnet IDs. At least two are required. | Required |
| `database_security_group_id` | Existing Database Security Group ID. | Required |
| `database_name` | Initial database name. | `appdb` |
| `database_username` | Master database username. | `dbadmin` |
| `database_instance_class` | RDS DB instance class. | `db.t3.micro` |
| `allocated_storage` | Initial allocated storage in GiB. | `20` |
| `max_allocated_storage` | Maximum storage size in GiB. | `100` |
| `multi_az` | Enables or disables Multi-AZ deployment. | `true` |
| `tags` | Tags applied to supported resources. | `{}` |

## Module Outputs

| Output | Description |
|---|---|
| `db_instance_id` | RDS DB instance identifier. |
| `db_endpoint` | RDS connection endpoint, including the port. |
| `db_address` | RDS database hostname. |
| `db_port` | Database connection port. |
| `db_name` | Initial database name. |
| `db_subnet_group_name` | Name of the RDS DB Subnet Group. |
| `master_user_secret_arn` | ARN of the RDS-managed master credentials secret. |

## Application Connectivity

The intended connection flow is:

1. The application obtains the RDS endpoint from its configuration.
2. The application connects to the endpoint using the MySQL protocol on TCP port 3306.
3. The Database Security Group permits the connection only from the authorized Application Security Group.
4. The application retrieves credentials through an authorized Secrets Manager integration.
5. RDS authenticates the database connection and processes the request.

The current infrastructure provisions the database but does not, by itself, configure the sample Nginx page to execute database queries.

Application-level database connectivity must be implemented and tested separately.

## Validation and Deployment

Run the following commands from the project root:

```bash
terraform -chdir=environments/dev fmt -recursive
terraform -chdir=environments/dev validate
terraform -chdir=environments/dev plan
```

Review the Terraform plan before applying changes.

After deployment, verify:

- The RDS instance reaches the `available` state.
- The DB Subnet Group contains the intended private subnets.
- Public accessibility is disabled.
- Storage encryption is enabled.
- Multi-AZ is configured as intended.
- The Database Security Group allows MySQL traffic only from authorized application resources.
- The master credentials secret exists and access is appropriately restricted.

## Design Rationale

This module separates database provisioning from the networking, security, compute, and monitoring layers.

It provides a reusable foundation for a private relational database with managed credentials, encryption, backup retention, and configurable availability.

The module can be extended with customer-managed KMS keys, enhanced monitoring, Performance Insights where appropriate, stricter deletion safeguards, and application-level database connectivity as the architecture evolves.