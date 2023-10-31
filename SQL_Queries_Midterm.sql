

### Selects all transactions that are a greater amount than the average, then lists in descending order with corresponding customer_key and payment_key

SELECT fact_payment_key AS payment_key
	, customer_key
    , amount
FROM sakila_dw2.fact_payments
WHERE amount > (SELECT AVG(amount) FROM sakila_dw2.fact_payments)
ORDER BY amount DESC;

SELECT * FROM sakila_dw2.fact_actors;

SELECT * FROM sakila_dw2.fact_film;

SELECT fact_film_key AS film_key
	, replacement_cost
	, title
    , category_key
FROM sakila_dw2.fact_film
WHERE replacement_cost > 25.00
ORDER BY replacement_cost DESC;

SELECT title 
	, replacement_cost
FROM sakila_dw2.fact_film
HAVING replacement_cost > 27.00;

SELECT * FROM sakila_dw2.dim_payment;

SELECT * FROM sakila_dw2.dim_payment;
SELECT title
	, COUNT(*) as times_purchased
FROM sakila_dw2.fact_film
GROUP BY title
HAVING times_purchased < 5
ORDER BY times_purchased ASC;

SELECT * FROM sakila_dw2.dim_inventory;

SELECT store_id
	, COUNT(*) AS total_inventory
FROM sakila_dw2.dim_inventory
GROUP BY store_id;
    



