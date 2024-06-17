# ecommerce-database
### this is database design and queries for ecommerce .

#### prerequisites:
* postgresql.
* docker or any other sql client.

### Topics:
* DDL 
* DML
* Erd diagram
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
│
├── Denormalization
│   ├── denormalization.sql
│
├── Indexing
│   ├── indexing.sql
│
├── Concurrency Control
│   ├── concurrency_control.sql
│
├── Locking
│   ├── locking.sql
│
├── Isolation Levels
│   ├── isolation_levels.sql
│
├── DDL
│   ├── create_table.sql
│   ├── create_index.sql
│   ├── create_view.sql
│   ├── create_trigger.sql
│   ├── create_function.sql
│   ├── create_procedure.sql
│   ├── create_sequence.sql
│   ├── create_synonym.sql
│   ├── create_user.sql
│   ├── create_role.sql
│   ├── create_privileges.sql
│   ├── create_constraint.sql
│   ├── create_database.sql
│   ├── create_schema.sql
│
├── DML
│   ├── insert.sql
│   ├── update.sql
│   ├── delete.sql
│   ├── select.sql
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

### problems/queries:
* ddl
    - create tables:
       - use erd to create tables.
* dml
   - insert dummy data:
       - use stored functions/procedures to insert data.
* Query Optimization Techniques.
  
* Denormalization.
* Indexing.
* Concurrency Control.
* Locking.
* Isolation Levels.
* views.

