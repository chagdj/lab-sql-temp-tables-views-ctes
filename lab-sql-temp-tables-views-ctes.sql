-- Step 1: Create a View
-- First, create a view that summarizes rental information for each customer. The view should include the customer's ID, name, email address, and total number of rentals (rental_count).
SELECT * FROM rental; 
SELECT * FROM customer; 
SELECT * FROM payment; 
SELECT * FROM store; 
DROP VIEW IF EXISTS rental_information;
CREATE VIEW rental_information AS
SELECT rental.customer_id, customer.first_name, customer.last_name, customer.email, COUNT(rental.rental_id) AS rental_count
FROM customer
INNER JOIN rental ON rental.customer_id = customer.customer_id
GROUP BY rental.customer_id;
SELECT * FROM rental_information;

-- Step 2: Create a Temporary Table
-- Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.
DROP TEMPORARY TABLE IF EXISTS total_amount_paid;
CREATE TEMPORARY TABLE total_amount_paid AS
SELECT rental_information.customer_id, rental_information.first_name, rental_information.last_name, rental_information.email, SUM(payment.amount) AS total_paid
FROM rental_information
INNER JOIN payment ON rental_information.customer_id = payment.customer_id
GROUP BY rental_information.customer_id, rental_information.first_name, rental_information.last_name, rental_information.email;
SELECT * FROM total_amount_paid;
-- Step 3: Create a CTE and the Customer Summary Report
-- Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. The CTE should include the customer's name, email address, rental count, and total amount paid.
-- Next, using the CTE, create the query to generate the final customer summary report, which should include: customer name, email, rental_count, total_paid and average_payment_per_rental, this last column is a derived column from total_paid and rental_count.
SELECT * FROM total_amount_paid;
SELECT * FROM rental_information;
DROP TEMPORARY TABLE IF EXISTS joined_CTE;
CREATE TEMPORARY TABLE joined_CTE AS
SELECT rental_information.first_name, rental_information.last_name, rental_information.email, rental_information.rental_count, total_amount_paid.total_paid
FROM rental_information
INNER JOIN total_amount_paid ON rental_information.customer_id = total_amount_paid.customer_id;
SELECT * FROM joined_CTE;
WITH joined_CTE AS (
    SELECT rental_information.first_name, 
           rental_information.last_name, 
           rental_information.email, 
           rental_information.rental_count, 
           total_amount_paid.total_paid
    FROM rental_information
    INNER JOIN total_amount_paid 
        ON rental_information.customer_id = total_amount_paid.customer_id
)
SELECT first_name, 
       last_name, 
       email, 
       rental_count, 
       total_paid, 
       (total_paid / rental_count) AS average_payment_per_rental
FROM joined_CTE;
