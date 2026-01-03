# AWS Terminology Glossary

Common AWS services, abbreviations, and terminology sorted by frequency of use in enterprise data platform contexts.

## Core Compute & Storage

**S3 (Simple Storage Service)**
Object storage service offering scalable, durable storage for data lakes and general file storage with multiple storage tiers.

**EC2 (Elastic Compute Cloud)**
Virtual server instances in the cloud providing resizable compute capacity for running applications and workloads.

**IAM (Identity and Access Management)**
Service for managing user identities, roles, policies, and permissions to securely control access to AWS resources.

**VPC (Virtual Private Cloud)**
Isolated virtual network environment within AWS where you can launch resources in a logically isolated section of the cloud.

**RDS (Relational Database Service)**
Managed relational database service supporting multiple engines (PostgreSQL, MySQL, Oracle, SQL Server, MariaDB) with automated backups and patching.

## Data & Analytics

**MSK (Managed Streaming for Kafka)**
Fully managed Apache Kafka service for building real-time streaming data pipelines and applications without managing Kafka infrastructure.

**Glue**
Serverless ETL service for data preparation, transformation, and catalog management with automatic schema discovery and job scheduling.

**Athena**
Serverless interactive query service for analyzing data directly in S3 using standard SQL without infrastructure management.

**EMR (Elastic MapReduce)**
Managed big data platform for processing massive amounts of data using frameworks like Apache Spark, Hadoop, and Presto.

**Redshift**
Fully managed petabyte-scale data warehouse service optimized for analytics with columnar storage and parallel query execution.

**Kinesis**
Platform for real-time data streaming with services including Data Streams, Firehose, and Analytics for ingesting and processing streaming data.

**DMS (Database Migration Service)**
Service for migrating databases to AWS with minimal downtime, supporting homogeneous and heterogeneous migrations with ongoing replication.

## Security & Compliance

**KMS (Key Management Service)**
Managed service for creating and controlling encryption keys used to encrypt data across AWS services and applications.

**Secrets Manager**
Service for managing, retrieving, and rotating database credentials, API keys, and other secrets throughout their lifecycle.

**CloudTrail**
Governance and audit service that logs all API calls and account activity for security analysis and compliance monitoring.

**GuardDuty**
Intelligent threat detection service that continuously monitors for malicious activity and unauthorized behavior across AWS accounts.

## Networking & Content Delivery

**Route 53**
Scalable DNS web service for routing end users to applications and managing domain names with health checking capabilities.

**CloudFront**
Content delivery network (CDN) service for distributing content globally with low latency through edge locations worldwide.

**ELB (Elastic Load Balancing)**
Service for automatically distributing incoming application traffic across multiple targets (EC2 instances, containers, IP addresses).

**Direct Connect**
Dedicated network connection from on-premises data centers to AWS, providing consistent network performance and reduced bandwidth costs.

## Management & Monitoring

**CloudWatch**
Monitoring and observability service providing metrics, logs, events, and alarms for AWS resources and applications.

**CloudFormation**
Infrastructure as Code service for modeling and provisioning AWS resources using templates in JSON or YAML format.

**Systems Manager**
Unified interface for viewing operational data and automating tasks across AWS resources including patch management and configuration.

## Containers & Serverless

**Lambda**
Serverless compute service that runs code in response to events without provisioning servers, charging only for compute time used.

**ECS (Elastic Container Service)**
Fully managed container orchestration service for running Docker containers with integrated AWS services.

**EKS (Elastic Kubernetes Service)**
Managed Kubernetes service for running containerized applications using Kubernetes without managing control plane infrastructure.

**Fargate**
Serverless compute engine for containers that works with ECS and EKS, eliminating server management and capacity planning.

## Application Integration

**SNS (Simple Notification Service)**
Pub/sub messaging service for distributing messages to multiple subscribers including email, SMS, HTTP endpoints, and SQS queues.

**SQS (Simple Queue Service)**
Managed message queuing service for decoupling application components with reliable message delivery and automatic scaling.

**Step Functions**
Serverless workflow orchestration service for coordinating distributed applications and microservices using visual workflows.

## Developer Tools

**CodeCommit**
Managed source control service hosting secure Git repositories with encryption and access control integration.

**CodePipeline**
Continuous delivery service automating build, test, and deploy phases of release processes with third-party tool integration.

**CodeBuild**
Fully managed build service that compiles source code, runs tests, and produces deployable artifacts without managing build servers.

## Additional Services

**SageMaker**
Fully managed machine learning service for building, training, and deploying ML models at scale with built-in algorithms and frameworks.

**QuickSight**
Business intelligence service for creating interactive dashboards and performing ad-hoc analysis with ML-powered insights.

**DataSync**
Data transfer service automating movement of data between on-premises storage and AWS with encryption and validation.

## Common AWS Terms

**ARN (Amazon Resource Name)**
Unique identifier for AWS resources following format: `arn:partition:service:region:account-id:resource-type/resource-id`.

**AZ (Availability Zone)**
Isolated data center within an AWS region providing redundancy and fault tolerance with independent power and networking.

**Region**
Geographic area containing multiple isolated Availability Zones where AWS infrastructure is physically located.

**Edge Location**
CloudFront data center location used for caching content closer to end users to reduce latency and improve performance.

**Endpoint**
URL or network connection point for accessing AWS services, available as public or private (VPC) endpoints.

**Subnet**
Segment of IP address range within a VPC, designated as public or private for routing traffic accordingly.

**Security Group**
Virtual firewall controlling inbound and outbound traffic for AWS resources at the instance level using allow rules.

**NACL (Network Access Control List)**
Optional firewall controlling traffic in and out of subnets within a VPC using numbered allow and deny rules.

**Instance Profile**
Container for IAM role that passes role credentials to EC2 instances at launch for accessing other AWS services.

**Bucket**
Container for objects stored in S3, serving as the top-level organizational unit with unique global naming.

**Parameter Store**
Component of Systems Manager for storing configuration data and secrets as key-value pairs with optional encryption.
