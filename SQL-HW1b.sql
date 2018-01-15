-- DROP DATABASE IF EXISTS sakila;
-- CREATE DATABASE sakila;
USE sakila;

-- * 1a. Display the first and last names of all actors from the table `actor`. 
SELECT first_name, last_name FROM actor;

-- * 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`. 
SELECT CONCAT_WS (" ", first_name, last_name) AS ActorName FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name FROM actor WHERE first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters `GEN`:
SELECT last_name FROM actor WHERE last_name LIKE '%gen%';

-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT first_name, last_name FROM actor WHERE last_name LIKE '%li%'
ORDER BY last_name, first_name;

-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
-- SELECT country_id IN country WHERE country = 'Afghanistan';
SELECT country_id, country FROM country WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. Add a `middle_name` column to the table `actor`. Position it between `first_name` and `last_name`. 
-- Hint: you will need to specify the data type.
ALTER TABLE actor ADD middle_name VARCHAR(200);
SELECT first_name, middle_name, last_name From actor;
  	
-- 3b. You realize that some of these actors have tremendously long last names. Change the data type of the `middle_name` column to `blobs`.
ALTER TABLE actor CHANGE middle_name blobs varchar(200);

-- 3c. Now delete the `middle_name` column.
ALTER TABLE actor DROP COLUMN middle_name;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(*) as name_count FROM actor GROUP BY last_name ORDER BY name_count DESC;
  	
-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(*) as name_count FROM actor GROUP BY last_name HAVING name_count > 1 ORDER BY name_count DESC;

-- 4c. Oh, no! The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`,
-- the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
-- SET SQL_SAFE_UPDATES=0;
-- UPDATE actor SET first_name = REPLACE(first_name, 'GROUCHO', 'HARPO') WHERE last_name = "WILLIAMS";
UPDATE actor SET `first_name` = "HARPO" WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS";
SELECT actor_id, first_name, last_name FROM actor WHERE first_name = "HARPO" AND last_name = "WILLIAMS";

-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all!
-- In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
-- Otherwise, change the first name to `MUCHO GROUCHO`, as that is exactly what the actor will be with the grievous error. 
-- BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO `MUCHO GROUCHO`, HOWEVER! (Hint: update the record using a unique identifier.)
UPDATE actor SET `first_name` = "GROUCHO" WHERE actor_id = 172;
SELECT actor_id, first_name, last_name FROM actor WHERE actor_id = 172;

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
SELECT * FROM `INFORMATION_SCHEMA`.`TABLES`
WHERE TABLE_NAME LIKE 'address';
-- DESCRIBE address;
-- SHOW CREATE TABLE address;
CREATE TABLE address_new LIKE address;
INSERT INTO address_new SELECT * FROM address;

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
SELECT staff.first_name, staff.last_name, address.address 
FROM staff JOIN address 
ON staff.address_id = address.address_id;

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
SELECT last_name, first_name, SUM(amount) AS staff_total
FROM staff INNER JOIN payment ON staff.staff_id = payment.staff_id
WHERE payment.payment_date LIKE '2005-08%'
GROUP BY staff.staff_id;
  	
-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT last_name, COUNT(*) as name_count FROM actor GROUP BY last_name ORDER BY name_count DESC;
SELECT staff.first_name, staff.last_name, address.address 
FROM staff JOIN address 
ON staff.address_id = address.address_id;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT COUNT(*) AS Title_Count
FROM inventory
WHERE film_id IN 
	(
    SELECT film_id
    FROM film
    WHERE title = 'Hunchback Impossible'
    );

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer.
-- List the customers alphabetically by last name:
SELECT first_name, last_name, SUM(amount) AS Cust_Total 
FROM payment INNER JOIN customer
ON customer.customer_id = payment.customer_id GROUP BY last_name, first_name;


-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence.
-- As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity.
-- Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English. 
SELECT title
FROM film
WHERE ((title LIKE "K%") OR (title LIKE "Q%")) AND title IN
	(
	SELECT title 
    FROM film 
	WHERE language_id IN 
		(
		SELECT language_id FROM language
		WHERE name = "English"));
    
-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT first_name, last_name
FROM actor
WHERE actor_id IN
	(
		SELECT actor_id
		FROM film_actor
		WHERE film_id IN
		(
			SELECT film_id 
			FROM film 
			WHERE title = 'Alone Trip'
		 ));
   
-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT first_name, last_name, address, email, country
FROM (((address INNER JOIN customer ON address.address_id = customer.address_id)
	JOIN city ON address.city_id = city.city_id) 
	JOIN country ON country.country_id = city.country_id) WHERE country = "Canada";

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as famiy films.
SELECT title, description
FROM film
WHERE film_id IN
	(
    SELECT film_id
	FROM film_category
	WHERE category_id IN
		(
		SELECT category_id 
		FROM category
		WHERE name = 'Family'
			));
            
-- 7e. Display the most frequently rented movies in descending order.
CREATE TABLE film_rentals (SELECT film_id, SUM((SELECT COUNT(inventory_id)
FROM rental
WHERE rental.inventory_id = inventory.inventory_id)) AS total_rentals
FROM inventory GROUP BY film_id
ORDER BY total_rentals DESC);
SELECT title, total_rentals FROM film_rentals INNER JOIN film ON film_rentals.film_id = film.film_id; 

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT store.store_id, COUNT(payment.payment_id) payment_count, SUM(payment.amount) AS total_amount FROM store 
	JOIN inventory  ON store.store_id = inventory.store_id
    JOIN rental  ON inventory.inventory_id = rental.inventory_id
    JOIN payment  ON rental.rental_id = payment.rental_id
GROUP BY store.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT store_id, city, country
FROM (((store INNER JOIN address ON store.address_id = address.address_id 
	JOIN city ON city.city_id = address.city_id 
	JOIN country ON city.country_id = country.country_id)));
  	
-- 7h. List the top five genres in gross revenue in descending order. 
-- (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT category.name, SUM(payment.amount) AS gross_revenue FROM category
	JOIN film_category ON film_category.category_id = category.category_id
    JOIN inventory ON inventory.film_id = film_category.film_id
    JOIN rental ON rental.inventory_id = inventory.inventory_id
    JOIN payment ON payment.rental_id = rental.rental_id
GROUP BY category.name
ORDER BY gross_revenue DESC 
LIMIT 5;
  	
-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue.
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW Top_5_Genres AS
	SELECT category.name, SUM(payment.amount) AS gross_revenue FROM category
		JOIN film_category ON film_category.category_id = category.category_id
		JOIN inventory ON inventory.film_id = film_category.film_id
		JOIN rental ON rental.inventory_id = inventory.inventory_id
		JOIN payment ON payment.rental_id = rental.rental_id
		GROUP BY category.name
	ORDER BY gross_revenue DESC 
	LIMIT 5;
  	
-- 8b. How would you display the view that you created in 8a?SELECT * FROM Top_5_Genres;

SELECT * FROM Top_5_Genres;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.

DROP VIEW IF EXISTS Top_5_Genres;

