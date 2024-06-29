# ecommerce-database
### this is database design and queries for ecommerce .

#### prerequisites:
* postgresql.
* docker or any other sql client.

### Topics:
* DDL 
* DML
* Erd diagram
* Stored Procedures.
* Triggers.
* Denormalization
* Indexing
* Concurrency control
* Locking
* Isolation levels
* Query optimization techniques
* views

### database erd:
![image](erd/ecommerce.png)

### Project Structure:
```
├── Query Optimization Techniques.
│   ├── query_optimization.sql
│   ├── QUERY_OPTIMIZATION_TECHNIQUES.md
│
├── Denormalization
│   ├── denormalization.sql
│   ├── DENORMALIZATION.md
│
├── Indexing
│   ├── indexing.sql
│   ├── INDEXING.md
│
├── Concurrency Control
│   ├── concurrency_control.sql
│   ├── CONCURENCY_CONTROL.md
│
├── Locking
│   ├── locking.sql
│   ├── LOCKING.md
│
├── Isolation Levels
│   ├── isolation_levels.sql
│   ├── ISOLATION_LEVELS.md
│
├── DDL
│   ├── create_table.sql
│   ├── create_procedure.sql
│   ├── DDL.md
│
├── DML
│   ├── dml.sql
│   ├── DML.md
│
├── explain_analyze
│   ├── explain_analyze.sql
│   ├── EXPLAIN_ANALYZE.md
│
├── ERD
│   ├── ecommerce.png
│
├── README.md
```

### Database Design:
* Database Name: ecommerce
* Tables:
  * users
  * products
  * orders
  * order_items
  * categories
  * reviews
  * product_reviews
  * cart
  * cart_items
  * addresses

## Read more Details in each topic:

- **Query Optimization Techniques**
  - [query_optimization.sql](./query_optimization_techniques/query_optimization.sql)
  - [QUERY_OPTIMIZATION_TECHNIQUES.md](./query_optimization_techniques/QUERY_OPTIMIZATION_TECHNIQUES.md)
  
- **Denormalization**
  - [denormalization.sql](./denormalization/denormalization.sql)
  - [DENORMALIZATION.md](./denormalization/DENORMALIZATION.md)

- **Indexing**
  - [indexing.sql](./Indexing/indexing.sql)
  - [INDEXING.md](./Indexing/INDEXING.md)

- **Concurrency Control**
  - [concurrency_control.sql](./concurrency_control/concurrency_control.sql)
  - [CONCURRENCY_CONTROL.md](./concurrency_control/CONCURRENCY_CONTROL.md)

- **Locking**
  - [locking.sql](./Locking/locking.sql)
  - [LOCKING.md](./Locking/LOCKING.md)

- **Isolation Levels**
  - [isolation_levels.sql](./isolation_levels/isolation_levels.sql)
  - [ISOLATION_LEVELS.md](./isolation_levels/ISOLATION_LEVELS.md)

- **DDL**
  - [create_table.sql](./ddl/create_table.sql)
  - [create_procedure.sql](./ddl/create_procedure.sql)
  - [DDL.md](./DDL/DDL.md)

- **DML**
  - [dml.sql](./dml/dml.sql)
  - [DML.md](./dml/DML.md)
- **explain_analyze**
  - [explain_analyze.sql](./explain_analyze/explain_analyze.sql)
  - [EXPLAIN_ANALYZE.md](./explain_analyze/EXPLAIN_ANALYZE.md)  

- **ERD**
  - [ecommerce.png](./erd/ecommerce.png)



