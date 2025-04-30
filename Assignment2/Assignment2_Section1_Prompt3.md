
# Assignment 2 – Section 1 – Prompt 3

## Prompt

> The store wants to keep customer addresses. Propose two architectures for the CUSTOMER_ADDRESS table, one that will retain changes, and another that will overwrite. Which is Type 1, which is Type 2?

---

## Architecture 1: Overwrite – Type 1 SCD

This architecture stores only the most recent address for each customer. When a customer updates their address, the existing record is overwritten.

### Table: `CUSTOMER_ADDRESS_TYPE1`

| Column Name     | Data Type     | Description                     |
|-----------------|---------------|---------------------------------|
| address_id      | INT           | Primary Key                     |
| customer_id     | INT           | Foreign Key to customer_data    |
| street_address  | VARCHAR(100)  | Customer's current address      |
| city            | VARCHAR(50)   | City                            |
| province        | VARCHAR(50)   | Province or Territory           |
| postal_code     | VARCHAR(10)   | Postal Code                     |

- **Type**: Slowly Changing Dimension (SCD) Type 1  
- **Behavior**: Overwrites existing records with the most recent address
- **Use Case**: When only current address matters (e.g., shipping)

---

## Architecture 2: Retain History – Type 2 SCD

This version keeps a full history of changes. Each new address is inserted as a new row with timestamps to track its validity.

### Table: `CUSTOMER_ADDRESS_TYPE2`

| Column Name     | Data Type     | Description                          |
|-----------------|---------------|--------------------------------------|
| address_id      | INT           | Primary Key                          |
| customer_id     | INT           | Foreign Key to customer_data         |
| street_address  | VARCHAR(100)  | Customer's address                   |
| city            | VARCHAR(50)   | City                                 |
| province        | VARCHAR(50)   | Province or Territory                |
| postal_code     | VARCHAR(10)   | Postal Code                          |
| start_date      | DATE          | When the address became effective    |
| end_date        | DATE          | When the address stopped being valid |
| is_current      | BOOLEAN       | Flag to indicate active address      |

- **Type**: Slowly Changing Dimension (SCD) Type 2  
- **Behavior**: Retains full history of changes  
- **Use Case**: When historical addresses are needed for auditing, marketing, or legal compliance

---

## Summary

- **Type 1**: Overwrite (no history)
- In Type 1, when a customer's address changes, the old address is **overwritten** with the new one.
- No historical record is kept.
- This method is simpler and uses less storage space.
- Suitable when keeping address history is not important.

- **Type 2**: Add new record (preserve history)
- In Type 2, when a customer's address changes, a **new record** is inserted into the CUSTOMER_ADDRESS table.
- The historical record of previous addresses is preserved.
- Additional fields like `start_date`/`end_date` or `is_current_flag` are added to track changes.
- This method allows full address change history to be maintained.