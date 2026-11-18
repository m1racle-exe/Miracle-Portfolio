# SQL Portfolio: Automating Business Logic with Stored Procedures and Cursors

**Author:** Miracle (NRP 160425069) | **Course:** Database, Teknik Informatika, UBAYA (Gasal 2026-2027)
**Tools:** MySQL / MariaDB (tested on MariaDB 10.11) | **Skills shown:** Stored procedures, cursors, DDL/DML, input validation, upserts, conditional logic, aggregation

Two small projects. Each one turns a business rule (tax, allowances, loyalty points) into a reusable stored procedure, then checks what the output says about the business.

| # | Project | Database | Techniques |
|---|---------|----------|------------|
| 1 | HR and payroll rules for a company | `employee` (company/HR sample DB) | Parameterised procedures, `IF EXISTS` validation, upsert, `LEAVE` for early exit |
| 2 | Batch enrichment of a trading company's data | `smallnorthwind` (Northwind sample DB) | Cursors with `CONTINUE HANDLER`, bulk `UPDATE`/`INSERT`, correlated aggregates |

---

# Project 1: HR and Payroll Rules for a Company

**Dataset:** `employee` database (9 employees, 3 departments, 6 projects, 7 dependents)

## Business question
*Which departments are understaffed, which projects are overloaded, and what does each employee's pay package look like once allowances and tax are applied?*

## Query 1: Department branch type and recruitment need

```sql
CREATE PROCEDURE uspUpdateRecruitment(p_dnum INT, p_min INT)
BEGIN
    DECLARE v_emp INT;
    IF NOT EXISTS (SELECT 1 FROM department WHERE dnumber = p_dnum) THEN
        SELECT 'Department number not found' AS Info;
    ELSE
        SELECT COUNT(*) INTO v_emp FROM employee WHERE dno = p_dnum;
        UPDATE department
        SET RecruitmentStatus = (v_emp < p_min),
            NumToRecruit      = GREATEST(p_min - v_emp, 0)
        WHERE dnumber = p_dnum;
    END IF;
END
```
Full code: [`01_branch_type.sql`](queries/01_branch_type.sql), [`02_recruitment_need.sql`](queries/02_recruitment_need.sql)

**Result** (minimum headcount of 4):

| dnumber | dname | BranchType | RecruitmentStatus | NumToRecruit |
|---------|-------|------------|-------------------|--------------|
| 1 | Headquartes | Single Branch | 1 | 3 |
| 4 | Administration | Single Branch | 0 | 0 |
| 5 | Research | Multi Branches | 0 | 0 |

**Insight:** Headquarters is the only department below the threshold (1 employee, needs 3 more). Research is the only department spread over several locations (Bellaire, Houston, Sugarland).

## Query 2: Project workload category

```sql
-- Team of 3+ : >50 hrs = 1, 30-50 hrs = 2, <30 hrs = 3
-- Team of <3 : >50 hrs = 4, otherwise 5
SELECT COUNT(DISTINCT ssn), COALESCE(SUM(hours), 0)
INTO v_emp, v_hours
FROM works_on WHERE pno = p_pno;
```
Full code: [`03_project_category.sql`](queries/03_project_category.sql). Invalid project numbers return an error message and write nothing.

**Result:**

| ProjectNo | NumOfEmployee | TotalHours | ProjectCategory |
|-----------|---------------|------------|-----------------|
| 1 | 2 | 52 | 4 |
| 2 | 3 | 38 | 2 |
| 3 | 2 | 50 | 5 |
| 10 | 3 | 55 | 1 |
| 20 | 3 | 25 | 3 |
| 30 | 3 | 55 | 1 |

**Insight:** Projects 10 and 30 are the heavy ones, but they have three people to share the load. Project 1 is the real risk: 52 hours carried by only 2 people.

## Query 3: Dependent allowance

```sql
SET v_childAllowance = 0.1 * v_salary * LEAST(v_numOfChild, 2);  -- 10% of salary per child, max 2
SET v_totalAllowance = v_healthAllowance + v_childAllowance;      -- health allowance (5000) only if married
```
Full code: [`04_dependent_allowance.sql`](queries/04_dependent_allowance.sql)

| Ssn | MarriageStatus | NumOfChild | HealthAllowance | ChildAllowance | TotalAllowance |
|-----|----------------|------------|-----------------|----------------|----------------|
| 123456789 | 1 | 2 | 5000 | 6000 | 11000 |
| 333445555 | 1 | 2 | 5000 | 8000 | 13000 |
| 453453450 | 0 | 0 | 0 | 0 | 0 |
| 987654321 | 1 | 0 | 5000 | 0 | 5000 |

**Insight:** Because the child allowance is a percentage of salary, higher-paid employees receive a larger benefit for the same family situation (Wong's two children earn 8,000 versus 6,000 for Smith's). A flat amount per child would be a fairer design if that is not intended.

## Query 4: Salary slip with position allowance

```sql
IF v_numOfStaff > 0 THEN
    SET v_positionAllowance = 0.3 * v_basicSalary * v_numOfStaff;
END IF;
SET v_grossSalary = v_basicSalary + v_positionAllowance;
SET v_incomeTax   = 0.1 * v_grossSalary;
SET v_nettIncome  = v_grossSalary - v_incomeTax;
```
Full code: [`05_salary_slip.sql`](queries/05_salary_slip.sql). Calling the procedure twice for the same employee updates the existing slip instead of creating a duplicate.

| SlipNumber | Ssn | BasicSalary | NumOfStaff | PositionAllowance | GrossSalary | IncomeTax | NettIncome |
|-----------|-----|-------------|------------|-------------------|-------------|-----------|------------|
| 1 | 123456789 | 30000 | 4 | 36000 | 66000 | 6600 | 59400 |
| 2 | 333445555 | 40000 | 1 | 12000 | 52000 | 5200 | 46800 |
| 3 | 987654321 | 43000 | 0 | 0 | 43000 | 4300 | 38700 |
| 4 | 999999999 | 45000 | 0 | 0 | 45000 | 4500 | 40500 |

**Insight:** John Smith has the lowest basic salary on this list (30,000) but the highest net income (59,400), because the allowance grows with every direct report and has no cap. His allowance (36,000) is bigger than his base pay.

## Recommendation
Hire for Headquarters first, add people to Project 1, and put a cap on the position allowance so pay stays tied to responsibility rather than just headcount.

---

# Project 2: Batch Data Enrichment for a Trading Company

**Dataset:** `smallnorthwind` (91 customers, 830 orders, 9 employees, suppliers, products)

## Business question
*Who are our best customers, where does our business actually sit geographically, and what do orders look like once VAT and payment terms are added?*

All five procedures use the same pattern: open a **cursor** over every row, calculate per row, write the result back.

```sql
DECLARE EndData BOOL DEFAULT FALSE;
DECLARE curCustomer CURSOR FOR SELECT CustomerID FROM customers;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET EndData = TRUE;

OPEN curCustomer;
FETCH curCustomer INTO v_custId;
WHILE (EndData = FALSE) DO
    -- calculate, then INSERT / UPDATE
    FETCH curCustomer INTO v_custId;
END WHILE;
CLOSE curCustomer;
```

## Query 1: Tenure and net income for every employee
Code: [`06_working_period.sql`](queries/06_working_period.sql), [`07_income_tax.sql`](queries/07_income_tax.sql)

```sql
IF (v_salary < 50000) THEN SET v_incomeTax = v_salary * 0.1;
ELSE SET v_incomeTax = v_salary * 0.15;
END IF;
```

| EmployeeID | FirstName | HireDate | WorkingPeriod | Salary | IncomeTax | NettIncome |
|-----------|-----------|----------|---------------|--------|-----------|------------|
| 1 | Nancy | 1992-05-01 | 34 | 50000 | 7500 | 42500 |
| 2 | Andrew | 1992-08-14 | 34 | 80000 | 12000 | 68000 |
| 6 | Michael | 1993-10-17 | 33 | 30000 | 3000 | 27000 |

*(Working period is calculated from `NOW()`, so it changes with the run date. These values are from 18 Nov 2026.)*

**Insight:** The tax rule has a cliff. Someone earning 49,999 takes home 44,999, but someone earning exactly 50,000 takes home only 42,500, which is less. A marginal-rate (bracket) calculation would remove that unfairness. 6 of the 9 employees sit in the 15% band.

## Query 2: Order totals, VAT and due date
Code: [`08_order_totals.sql`](queries/08_order_totals.sql)

```sql
SET v_total = (SELECT COALESCE(SUM(UnitPrice * Quantity * (1 - Discount)), 0)
               FROM orderdetails WHERE OrderID = v_ordId);
SET v_ppn        = v_total * 0.11;
SET v_grandTotal = v_total + v_ppn;
SET v_dueDate    = DATE_ADD(v_ordDate, INTERVAL 10 DAY);
```

| OrderID | OrderDate | Total | PPN | GrandTotal | DueDate |
|---------|-----------|-------|-----|------------|---------|
| 10248 | 2011-07-04 | 440 | 48 | 488 | 2011-07-14 |
| 10249 | 2011-07-05 | 1863 | 205 | 2068 | 2011-07-15 |
| 10252 | 2011-07-09 | 3730 | 410 | 4140 | 2011-07-19 |

**Insight:** Across all 830 orders: Total 1,354,455, VAT 149,000, Grand Total 1,503,455. Data quality warning: in this dump the `Discount` column is `FLOAT(24,0)`, so every discount was stored as 0. Totals are therefore effectively pre-discount. The formula is correct, but the column type needs fixing (e.g. `DECIMAL(4,2)`) before the numbers can be trusted.

## Query 4: Where is the business? Customers, employees, suppliers per country
Code: [`09_country_summary.sql`](queries/09_country_summary.sql). It builds the country list with `UNION` across three tables, then counts each role per country.

| Country | NumOfCustomers | NumOfEmployees | NumOfSuppliers |
|---------|----------------|----------------|----------------|
| USA | 13 | 5 | 4 |
| UK | 7 | 4 | 2 |
| France | 11 | 0 | 3 |
| Germany | 11 | 0 | 3 |
| Australia | 0 | 0 | 2 |
| Japan | 0 | 0 | 2 |

**Insight:** 25 countries in total, but staff exist only in the USA and the UK. France and Germany each have 11 customers and no local employee. Australia, Japan, Singapore and the Netherlands are supply-only markets with no customers.

## Query 5: Customer loyalty points (1 point per 1,000 spent)
Code: [`10_customer_points.sql`](queries/10_customer_points.sql)

```sql
SET v_totalTransaction = (SELECT COALESCE(SUM(Total), 0) FROM orders WHERE CustomerID = v_custId);
SET v_points = FLOOR(v_totalTransaction / 1000);
```

| CustomerID | NumOfOrders | TotalTransaction | Points |
|-----------|-------------|------------------|--------|
| QUICK | 28 | 117482 | 117 |
| SAVEA | 31 | 115672 | 115 |
| ERNSH | 30 | 113238 | 113 |
| HUNGO | 19 | 57315 | 57 |
| RATTC | 18 | 52248 | 52 |

**Insight:** The top 3 customers (QUICK, SAVEA, ERNSH) generate 25.6% of all revenue, and the top 5 are clearly separated from the rest. 2 of 91 customers have never ordered at all.

## Recommendation
Protect the top 3 accounts with a dedicated account manager, run a first-order campaign for the 2 inactive customers, and fix the `Discount` column type before using order totals in any financial report.

---

# What I Learned (and a Bug I Fixed)

My first version of the Week 10 procedures worked on the first call and **crashed on the second**. I had written the "does this row already exist?" check as

```sql
IF ((SELECT Ssn FROM DependentAllowance) = p_essn) THEN
```

That only works while the table has 0 or 1 rows. With two or more it fails with `Subquery returns more than 1 row`. The fix is to filter the check by the key:

```sql
IF EXISTS (SELECT 1 FROM DependentAllowance WHERE Ssn = p_essn) THEN
```

While testing against every employee I also fixed:

- A copy-paste error where the project procedure updated the wrong table (`DependentAllowance`) instead of `ProjectCategory`.
- Procedures that kept running after printing "not found" and inserted rows with `NULL` values. They now stop early with `LEAVE`.
- `ChildAllowance` being `NULL` (and so `TotalAllowance` too) for employees with no children. It now defaults to 0.
- Parameters typed as `INT` for SSN values that are stored as `VARCHAR`.

# Repository Structure

```
sql-portfolio/
├── README.md
├── queries/
│   ├── 01_branch_type.sql
│   ├── 02_recruitment_need.sql
│   ├── 03_project_category.sql
│   ├── 04_dependent_allowance.sql
│   ├── 05_salary_slip.sql
│   ├── 06_working_period.sql
│   ├── 07_income_tax.sql
│   ├── 08_order_totals.sql
│   ├── 09_country_summary.sql
│   └── 10_customer_points.sql
├── data/
│   ├── employee_schema_and_data.sql
│   └── smallnorthwind_schema_and_data.sql
└── screenshots/        (add your own result screenshots here)
```

# How to Run

```bash
mysql -u root -p -e "CREATE DATABASE employee; CREATE DATABASE smallnorthwind;"
mysql -u root -p employee       < data/employee_schema_and_data.sql
mysql -u root -p smallnorthwind < data/smallnorthwind_schema_and_data.sql

# Project 1 files (01-05) run on `employee`; Project 2 files (06-10) run on `smallnorthwind`
mysql -u root -p employee       < queries/01_branch_type.sql
mysql -u root -p smallnorthwind < queries/06_working_period.sql
```
