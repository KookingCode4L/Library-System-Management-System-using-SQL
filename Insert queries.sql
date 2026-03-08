SELECT * FROM `project-e14ed125-55fc-4bc9-a61.Library_DB.books` LIMIT 10

**Task 1. Create a New Book Record**
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO `project-e14ed125-55fc-4bc9-a61.Library_DB.books`
(isbn, book_title, category, rental_price, status, author, publisher)
VALUES
('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, TRUE, 'Harper Lee', 'J.B. Lippincott & Co.');

**Task 2: Update an Existing Member's Address**

UPDATE `project-e14ed125-55fc-4bc9-a61.Library_DB.members`
SET member_address = '125 Oak St'
WHERE member_id = 'C103';

**Task 3: Delete a Record from the Issued Status Table**
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

DELETE FROM `project-e14ed125-55fc-4bc9-a61.Library_DB.issued_status` 
WHERE issued_id = 'IS121'
  AND issued_member_id = 'C102'
  AND issued_book_name = 'The Shining'
  AND issued_date = '2024-03-25'
  AND issued_book_isbn = '978-0-385-33312-0'
  AND issued_emp_id = 'E109';

  **Task 4: Retrieve All Books Issued by a Specific Employee**

SELECT *
FROM `project-e14ed125-55fc-4bc9-a61.Library_DB.issued_status`
WHERE issued_emp_id = 'E101'


**Task 5: List Members Who Have Issued More Than One Book**
-- Objective: Use GROUP BY to find members who have issued more than one book.

SELECT 
issued_emp_id,
COUNT (*) AS books_issued
FROM `project-e14ed125-55fc-4bc9-a61.Library_DB.issued_status`

GROUP BY issued_emp_id
HAVING COUNT (*) >1

**Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**


CREATE TABLE `project-e14ed125-55fc-4bc9-a61.Library_DB.book_issued_cnt` AS
SELECT
b.isbn,
B.book_title,
COUNT(ist.issued_id) AS issue_count
FROM `project-e14ed125-55fc-4bc9-a61.Library_DB.issued_status` AS ist
JOIN 
`project-e14ed125-55fc-4bc9-a61.Library_DB.books` as b
ON ist.issued_book_isbn = b.isbn

GROUP by b.isbn, b.book_title;

**Task 7. **Retrieve All Books in a Specific Category**:

SELECT 
*
 FROM `project-e14ed125-55fc-4bc9-a61.Library_DB.books` 
 WHERE category  = 'Children'

**Task 8: Find Total Rental Income by Category**:

SELECT 
*
 FROM `project-e14ed125-55fc-4bc9-a61.Library_DB.books` LIMIT 10

SELECT 
category,
SUM(rental_price) AS total_rental_income
FROM `project-e14ed125-55fc-4bc9-a61.Library_DB.books` 

 GROUP BY category

**Task 9: List Members Who Registered in the Last 180 Days**:

SELECT *
FROM `project-e14ed125-55fc-4bc9-a61.Library_DB.members`
WHERE reg_date <= DATE_SUB(CURRENT_DATE(), INTERVAL 180 DAY)

**Task 10: List Employees with Their Branch Manager's Name and their branch details**:

SELECT
e.emp_id,
e.emp_name,
e.position,
e.salary,
b.*,
e.emp_name AS manager
FROM `project-e14ed125-55fc-4bc9-a61.Library_DB.employees` AS e
JOIN
`project-e14ed125-55fc-4bc9-a61.Library_DB.branch` AS b
ON 
e.branch_id = b.branch_id

** Task 11, Create a Table of Books with Rental Price Above a Certain Threshold**:

CREATE TABLE `project-e14ed125-55fc-4bc9-a61.Library_DB.raised_price_books` AS
SELECT
*
FROM `project-e14ed125-55fc-4bc9-a61.Library_DB.books`
WHERE rental_price > 6.00;

**Task 12: Retrieve the List of Books Not Yet Returned**

SELECT *
FROM `project-e14ed125-55fc-4bc9-a61.Library_DB.issued_status` AS ist
LEFT JOIN 
`project-e14ed125-55fc-4bc9-a61.Library_DB.return_status` AS rs
ON ist.issued_id = rs.issued_id;

**Task 13: Identify Members with Overdue Books**  

SELECT
ist.issued_member_id,
m.member_name,
ist.issued_book_name,
ist.issued_date,
CURRENT_DATE - ist.issued_date as over_dues_days
FROM `project-e14ed125-55fc-4bc9-a61.Library_DB.issued_status` AS ist
LEFT JOIN 
`project-e14ed125-55fc-4bc9-a61.Library_DB.return_status` AS rs
ON ist.issued_id = rs.issued_id
JOIN
`project-e14ed125-55fc-4bc9-a61.Library_DB.members` AS m
ON
ist.issued_member_id = m.member_id


**Task 14: Update Book Status on Return**  
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).


SELECT 
  b.isbn,
  b.book_title,
  b.status,
  b.author,
  b.publisher,
  CASE 
    WHEN rs.return_id IS NOT NULL THEN 'YES'
    ELSE 'NO'
  END AS returned,
  rs.issued_id,
  rs.return_date

FROM `project-e14ed125-55fc-4bc9-a61.Library_DB.books` AS b
LEFT JOIN
`project-e14ed125-55fc-4bc9-a61.Library_DB.return_status` AS rs
ON
b.isbn = rs.return_book_isbn

**Task 15: Branch Performance Report**  
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

CREATE TABLE `project-e14ed125-55fc-4bc9-a61.Library_DB.branch_report`
AS
SELECT
b.branch_id,
ANY_VALUE(b.branch_address) AS branch_address,
ANY_VALUE(b.manager_id) AS manager_id,
ANY_VALUE(b.contact_no) AS contact_no,
COUNT(ist.issued_member_id) AS total_issued,
COUNT(rs.return_id) AS total_return,
SUM(bs.rental_price) AS total_rental_price
FROM `project-e14ed125-55fc-4bc9-a61.Library_DB.branch` AS b
LEFT JOIN `project-e14ed125-55fc-4bc9-a61.Library_DB.employees` AS e
  ON b.branch_id = e.branch_id
LEFT JOIN `project-e14ed125-55fc-4bc9-a61.Library_DB.issued_status` AS ist
  ON e.emp_id = ist.issued_emp_id
LEFT JOIN `project-e14ed125-55fc-4bc9-a61.Library_DB.return_status` AS rs
  ON ist.issued_id = rs.issued_id
LEFT JOIN `project-e14ed125-55fc-4bc9-a61.Library_DB.books` AS bs
  ON ist.issued_book_isbn = bs.isbn
GROUP BY b.branch_id;

SELECT * FROM `project-e14ed125-55fc-4bc9-a61.Library_DB.branch_report`

**Task 16: CTAS: Create a Table of Active Members**  
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.

CREATE TABLE `project-e14ed125-55fc-4bc9-a61.Library_DB.active_members`
AS
SELECT 
DISTINCT m.member_id, 
m.member_name,
DATE_SUB(CURRENT_DATE(), INTERVAL 60 DAY) AS day_last_issued
FROM `project-e14ed125-55fc-4bc9-a61.Library_DB.members` AS m
JOIN
`project-e14ed125-55fc-4bc9-a61.Library_DB.issued_status` AS ist
ON
m.member_id = ist.issued_member_id


**Task 17: Find Employees with the Most Book Issues Processed**  
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.


SELECT
e.emp_name,
COUNT(ist.issued_id) AS books_processed,
b.branch_id
FROM `project-e14ed125-55fc-4bc9-a61.Library_DB.issued_status` AS ist
JOIN `project-e14ed125-55fc-4bc9-a61.Library_DB.employees` AS e
ON ist.issued_emp_id = e.emp_id
JOIN 
`project-e14ed125-55fc-4bc9-a61.Library_DB.branch` AS b
ON
e.branch_id = b.branch_id

GROUP BY e.emp_name, b.branch_id
ORDER BY books_processed DESC LIMIT 3

**Task 18: Identify Members Issuing High-Risk Books**  
Write a query to identify members who have issued books more than twice. Display the member name, book title, and the number of times they've issued books.   

SELECT 
m.member_name,
b.book_title,
COUNT(ist.issued_id) AS book_rented_out
FROM `project-e14ed125-55fc-4bc9-a61.Library_DB.members`AS m
JOIN
`project-e14ed125-55fc-4bc9-a61.Library_DB.issued_status` AS ist
ON
m.member_id = ist.issued_member_id
JOIN 
`project-e14ed125-55fc-4bc9-a61.Library_DB.books` AS b
ON
ist.issued_book_name = b.book_title

GROUP BY m.member_name,b.book_title
HAVING COUNT (ist.issued_id) >1

