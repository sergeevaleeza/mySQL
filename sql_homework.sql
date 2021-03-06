use sakila;
#1a. Display the first and last names of all actors from the table `actor`.
SELECT first_name, last_name from actor;

#1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
SELECT UPPER(CONCAT(first_name,  ' ', last_name)) AS ' Actor Name' FROM actor;

#2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name FROM actor WHERE first_name = 'JOE';

#2b. Find all actors whose last name contain the letters `GEN`:
SELECT first_name, last_name FROM actor WHERE last_name LIKE '%GEN%';

#2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT last_name, first_name FROM actor WHERE last_name LIKE '%LI%';

#2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country FROM country WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

#3a. You want to keep a description of each actor. 
# You don't think you will be performing queries on a description, so create a column in the table `actor` 
# named `description` and use the data type `BLOB` 
# (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
SELECT * FROM actor;
ALTER TABLE actor ADD COLUMN  description BLOB(50);

#3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER TABLE actor DROP COLUMN description;
SELECT * FROM actor;

#4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(*) AS `Count` FROM actor GROUP BY last_name;

#4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(*) AS `Count` FROM actor GROUP BY last_name HAVING Count > 1;

# 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
UPDATE actor SET first_name= 'HARPO' WHERE first_name='GROUCHO' AND last_name='WILLIAMS';

# 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! 
# In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
UPDATE actor SET first_name= 'GROUCHO' WHERE first_name='HARPO' AND last_name='WILLIAMS';

# 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
#Hint: [https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html]
DESCRIBE sakila.address;
SHOW CREATE TABLE sakila.address;

CREATE TABLE `address` (
   `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
   `address` varchar(50) NOT NULL,
   `address2` varchar(50) DEFAULT NULL,
   `district` varchar(20) NOT NULL,
   `city_id` smallint(5) unsigned NOT NULL,
   `postal_code` varchar(10) DEFAULT NULL,
   `phone` varchar(20) NOT NULL,
   `location` geometry NOT NULL,
   `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
   PRIMARY KEY (`address_id`),
   KEY `idx_fk_city_id` (`city_id`),
   SPATIAL KEY `idx_location` (`location`),
   CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
 ) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8;

# 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. 
# Use the tables `staff` and `address`:
SELECT s.first_name, s.last_name, a.address FROM staff s 
LEFT JOIN address a ON s.address_id = a.address_id;

# 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. 
# Use tables `staff` and `payment`.
SELECT p.staff_id, s.first_name, s.last_name, SUM(p.amount) AS 'total_amount', p.payment_date FROM staff s 
JOIN payment p  ON s.staff_id = p.staff_id AND payment_date LIKE '2005-08%'
GROUP BY p.staff_id;

# 6c. List each film and the number of actors who are listed for that film. 
# Use tables `film_actor` and `film`. Use inner join.
SELECT f.title, COUNT(fa.actor_id) AS 'number_of_actors' FROM film f 
INNER JOIN film_actor fa ON f.film_id = fa.film_id
GROUP BY f.title;

# 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT title, (
	SELECT COUNT(*) FROM inventory WHERE film.film_id = inventory.film_id) 
AS 'number_of_copies' FROM film WHERE title = "Hunchback Impossible"; 
# 6 copies of the film `Hunchback Impossible` exist in the inventory system

# 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. 
# List the customers alphabetically by last name:
SELECT c.first_name, c.last_name, sum(p.amount) AS `total_amount_paid` FROM customer c
JOIN payment p  ON c.customer_id = p.customer_id
GROUP BY c.last_name;

# 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
# As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. 
# Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
SELECT * FROM language; # look up language_id for English
SELECT title FROM film WHERE title LIKE 'K%' OR title LIKE 'Q%' AND title IN (
	SELECT title FROM film WHERE language_id = 1);
# OR
SELECT title FROM film WHERE (title LIKE 'K%' OR title LIKE 'Q%') 
AND language_id = (SELECT language_id FROM language WHERE name='English');    

# 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT first_name, last_name FROM actor WHERE actor_id IN (
	SELECT actor_id FROM film_actor WHERE film_id IN (
		SELECT film_id from film where title='Alone Trip'));

# 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
# Use joins to retrieve this information.
SELECT first_name, last_name, email FROM customer cust
JOIN address a ON (cust.address_id = a.address_id)
JOIN city ct ON (a.city_id = ct.city_id)
JOIN country cr ON (ct.country_id = cr.country_id) 
WHERE cr.country = 'Canada';

# 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
# Identify all movies categorized as _family_ films.
SELECT title, description FROM film WHERE film_id IN (
	SELECT film_id FROM film_category WHERE category_id IN(
		SELECT category_id FROM category WHERE name = "Family"));

# 7e. Display the most frequently rented movies in descending order.
SELECT f.title, COUNT(rental_id) AS 'times_rented' FROM rental r
JOIN inventory i ON (r.inventory_id = i.inventory_id)
JOIN film f ON (i.film_id = f.film_id)
GROUP BY f.title
ORDER BY `times_rented` DESC;

# 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT s.store_id, SUM(p.amount) AS 'total_profit' FROM payment p
JOIN staff s ON (p.staff_id = s.staff_id)
GROUP BY store_id;

# 7g. Write a query to display for each store its store ID, city, and country.
SELECT store_id, city, country FROM store s
JOIN address a ON (s.address_id=a.address_id)
JOIN city c ON (a.city_id=c.city_id)
JOIN country cntry ON (c.country_id=cntry.country_id)
GROUP BY store_id;

# 7h. List the top five genres in gross revenue in descending order. 
# (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT c.name AS 'genre', SUM(p.amount) AS 'gross_revenue' FROM category c
JOIN film_category fc ON (c.category_id = fc.category_id)
JOIN inventory i ON (fc.film_id = i.film_id)
JOIN rental r ON (i.inventory_id = r.inventory_id)
JOIN payment p ON (r.rental_id=p.rental_id)
GROUP BY c.name ORDER BY gross_revenue DESC LIMIT 5;

# 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
# Use the solution from the problem above to create a view. 
# If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_five_genres AS
SELECT c.name AS 'genre', SUM(p.amount) AS 'gross_revenue' FROM category c
JOIN film_category fc ON (c.category_id = fc.category_id)
JOIN inventory i ON (fc.film_id = i.film_id)
JOIN rental r ON (i.inventory_id = r.inventory_id)
JOIN payment p ON (r.rental_id=p.rental_id)
GROUP BY c.name ORDER BY gross_revenue DESC LIMIT 5;

# 8b. How would you display the view that you created in 8a?
SELECT * FROM top_five_genres;

# 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW top_five_genres;
