# SQL Server Terminology Glossary

Common SQL Server features, services, and terminology sorted by frequency of use in enterprise data platform contexts.

## Core Database Concepts

**Instance**
Installation of SQL Server Database Engine with its own system databases, configuration, and security managing multiple user databases.

**Database**
Container for tables, views, stored procedures, and other objects with its own transaction log and data files.

**Transaction Log**
Sequential record of all database transactions ensuring ACID properties and enabling recovery, replication, and point-in-time restore.

**Filegroup**
Logical grouping of data files for administration, allocation, and placement strategies including PRIMARY and user-defined filegroups.

**Schema**
Namespace and security boundary within a database for organizing objects and controlling access independently from users.

**Table**
Primary storage structure organized in rows and columns with defined data types, constraints, and indexes.

**Index**
Data structure (clustered or nonclustered) improving query performance by providing fast access paths to table data.

**Clustered Index**
Index determining physical row order in a table, with table data stored at leaf level (one per table).

**Nonclustered Index**
Separate index structure containing key columns and row locators pointing to data in clustered index or heap.

## High Availability & Disaster Recovery

**Always On Availability Groups**
Enterprise HA/DR solution providing failover environment for discrete set of user databases (availability replicas) with readable secondaries.

**Failover Cluster Instance (FCI)**
SQL Server instance installed across Windows Server Failover Clustering nodes sharing storage for HA at instance level.

**Log Shipping**
Disaster recovery solution automatically sending transaction log backups from primary to secondary servers with restoration.

**Database Mirroring**
Legacy HA solution maintaining synchronized copy of database on standby server (deprecated in favor of Always On).

**Replication**
Technology for copying and distributing data and objects between databases using Publisher, Distributor, and Subscriber model.

## Security & Compliance

**TDE (Transparent Data Encryption)**
Encryption of data files and transaction logs at rest using database encryption key without application changes.

**Always Encrypted**
Client-side encryption protecting sensitive data from high-privilege users with encryption keys never revealed to Database Engine.

**Row-Level Security (RLS)**
Feature controlling row access based on user characteristics using security predicates in inline table-valued functions.

**Dynamic Data Masking**
Obfuscating sensitive data in query results based on user permissions without changing stored data.

**SQL Server Audit**
Framework for tracking and logging server-level and database-level events for security and compliance monitoring.

**Contained Database**
Database including authentication and metadata making it portable across instances without server-level dependencies.

## Performance & Optimization

**Query Store**
Database-level feature capturing query plans and runtime statistics for identifying and resolving performance regressions.

**Execution Plan**
Graphical or XML representation of query optimizer's chosen strategy showing operators, costs, and data flow.

**Statistics**
Histogram and density information about column value distribution used by query optimizer for plan selection.

**Columnstore Index**
Columnar storage index using compression and batch processing for high-performance analytics and data warehouse queries.

**In-Memory OLTP (Hekaton)**
Memory-optimized tables and natively compiled procedures for extreme transaction performance on latency-sensitive workloads.

**Resource Governor**
Feature managing SQL Server workload and resources by limiting CPU, memory, and I/O consumption per resource pool.

**Partitioning**
Dividing large tables and indexes into smaller units based on partition function and scheme for manageability and performance.

## Business Intelligence & Analytics

**SSAS (SQL Server Analysis Services)**
Analytics engine for building multidimensional (OLAP cubes) and tabular models for business intelligence solutions.

**SSIS (SQL Server Integration Services)**
ETL platform for data integration and workflow automation with packages containing tasks, transformations, and data flows.

**SSRS (SQL Server Reporting Services)**
Report generation and distribution platform for creating paginated, mobile, and interactive reports.

**Power BI**
Modern business analytics service for visualizing data and sharing insights with interactive dashboards (separate product).

## Data Types & Features

**FILESTREAM**
Storage option for storing large binary data (BLOBs) in NTFS filesystem while maintaining transactional consistency.

**FILETABLE**
Table providing Windows file namespace and compatibility for files stored using FILESTREAM with directory hierarchy.

**Spatial Data Types**
GEOMETRY and GEOGRAPHY types for storing and querying location-based and spatial data with built-in methods.

**Temporal Tables**
System-versioned tables automatically tracking complete history of data changes with period columns and history tables.

**JSON Support**
Built-in functions (FOR JSON, OPENJSON) for parsing, querying, and generating JSON data within relational database.

**XML Data Type**
Native data type for storing and querying XML documents with XQuery and XML indexes.

## Administration & Management

**SSMS (SQL Server Management Studio)**
Integrated GUI environment for managing, configuring, and administering SQL Server instances and databases.

**SQL Server Agent**
Service for scheduling jobs, alerts, and operators enabling automated administration and monitoring tasks.

**Database Mail**
Email messaging system for sending notifications and query results using SMTP from Database Engine.

**Policy-Based Management**
Framework for defining and enforcing configuration policies across SQL Server instances using conditions and facets.

**Extended Events**
Lightweight performance monitoring system for capturing detailed diagnostic information with minimal overhead.

**SQL Server Profiler**
GUI tool for capturing and analyzing Database Engine events and traces (deprecated in favor of Extended Events).

## Development Features

**Stored Procedure**
Precompiled collection of T-SQL statements stored in database for encapsulating business logic and improving performance.

**User-Defined Function (UDF)**
Custom function (scalar, inline table-valued, or multi-statement) extending T-SQL capabilities for reusable logic.

**Trigger**
Special stored procedure automatically executing in response to DML (INSERT, UPDATE, DELETE) or DDL events.

**Common Table Expression (CTE)**
Temporary named result set defined within SELECT, INSERT, UPDATE, or DELETE statement for improving readability.

**Window Functions**
Analytical functions (ROW_NUMBER, RANK, LAG, LEAD) operating on partitions of rows for complex calculations.

**Cursor**
Database object for row-by-row processing of result sets (generally avoided in favor of set-based operations).

## Database Options & Settings

**Recovery Model**
Configuration (Simple, Full, Bulk-Logged) determining transaction log behavior and point-in-time recovery capabilities.

**Compatibility Level**
Database setting determining T-SQL behavior and query optimizer features matching specific SQL Server version.

**Collation**
Rules determining character sorting, case sensitivity, and accent sensitivity for character data.

**Isolation Level**
Transaction setting controlling locking behavior and concurrency (READ UNCOMMITTED, READ COMMITTED, REPEATABLE READ, SERIALIZABLE).

**Database Snapshot**
Read-only, static view of database at creation time using sparse files and copy-on-write technology.

## Backup & Recovery

**Full Backup**
Complete backup of database including all data files and log records necessary for recovery.

**Differential Backup**
Backup of data changed since last full backup, reducing backup time and storage compared to full backups.

**Transaction Log Backup**
Backup of transaction log enabling point-in-time recovery and log truncation in Full recovery model.

**Backup Compression**
Feature reducing backup size and I/O with CPU overhead tradeoff, configurable at instance or backup level.

**CHECKDB**
DBCC command verifying physical and logical integrity of all objects in database detecting corruption.

## Service Broker & Messaging

**Service Broker**
Message queuing and reliable messaging platform for asynchronous communication between databases and applications.

**Queue**
Service Broker object storing messages for asynchronous processing with activation and poison message handling.

## Cloud & Hybrid

**Azure SQL Database**
Fully managed cloud database service (PaaS) based on SQL Server with automatic updates and built-in intelligence.

**Azure SQL Managed Instance**
Cloud deployment providing near 100% compatibility with on-premises SQL Server with managed infrastructure.

**SQL Server on Azure VM**
Infrastructure-as-a-Service deployment providing full SQL Server control with customer-managed OS and patches.

**Hybrid Connection**
Technologies (linked servers, distributed queries, Azure Arc) connecting on-premises SQL Server with cloud resources.

## Common SQL Server Terms

**System Database**
Essential databases (master, model, msdb, tempdb) containing metadata, configuration, and temporary objects.

**SPID (Server Process ID)**
Unique identifier for user session or connection to SQL Server instance visible in sys.dm_exec_sessions.

**Latch**
Lightweight synchronization object protecting internal memory structures for short durations with minimal overhead.

**Lock**
Mechanism preventing conflicting concurrent access to resources (rows, pages, tables) ensuring transactional consistency.

**Deadlock**
Situation where two or more processes block each other waiting for resources, resolved by terminating one transaction.

**Blocking**
Condition where one process holds locks preventing other processes from accessing same resources causing wait states.

**Wait Statistics**
Performance metrics showing what resources sessions are waiting for (CXPACKET, PAGEIOLATCH, LCK_M_X).

**Buffer Pool**
Memory area caching data pages reducing physical I/O by keeping frequently accessed data in RAM.

**Plan Cache**
Memory area storing compiled query execution plans for reuse avoiding repeated compilation overhead.

**Linked Server**
Configuration allowing queries against remote OLE DB data sources as if they were local tables.

**SQLCMD**
Command-line utility for executing T-SQL statements and scripts with scripting variables and output formatting.

**DAC (Dedicated Admin Connection)**
Special diagnostic connection reserved for administrators when server is unresponsive to regular connections.

**Edition**
SQL Server product tier (Express, Standard, Enterprise) determining features, scalability limits, and licensing.
