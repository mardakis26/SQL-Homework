USE sakila;

#1a. Display the first and last names of all actors from the table actor.
SELECT first_name, last_name FROM actor;

#1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT CONCAT(first_name, " ", last_name) as "Actor Name" FROM actor;

#2a. Find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe."
SELECT actor_id, first_name, last_name 
FROM actor 
WHERE first_name = "Joe";

#2b. Find all actors whose last name contain the letters GEN:
SELECT * FROM actor
WHERE last_name LIKE "%gen%";

#2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT * FROM actor
WHERE last_name LIKE "%li%"
ORDER BY last_name, first_name;

#2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country
WHERE country IN 
("Afghanistan", "Bangladesh", "China");

#3a. Create a column in the table actor named description and use the data type BLOB.
ALTER TABLE actor
ADD COLUMN description BLOB;

#3b. Delete the description column.
ALTER TABLE actor
DROP COLUMN description;

#4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name) as "Number of Actors"
FROM actor
GROUP BY last_name;

#4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors.
SELECT last_name, COUNT(last_name) as "Number of Actors"
FROM actor
GROUP BY last_name
HAVING COUNT(last_name) > 1;

#4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor
SET first_name = "HARPO"
WHERE first_name = "GROUCHO" and last_name = "WILLIAMS";

#4d. In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor
SET first_name = "GROUCHO"
WHERE first_name = "HARPO";

#5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

#6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT first_name, last_name, address
FROM staff
JOIN address ON staff.address_id = address.address_id;

#6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT first_name, last_name, SUM(amount)
FROM payment
JOIN staff ON payment.staff_id = staff.staff_id AND payment.payment_date LIKE "2005-08%"
GROUP BY staff.last_name;

#6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT title, COUNT(actor_id)
FROM film_actor
INNER JOIN film ON film_actor.film_id = film.film_id
GROUP BY film.title;

#6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT title, COUNT(inventory_id) as "Number of Copies"
FROM film
JOIN inventory ON film.film_id = inventory.film_id WHERE title = "Hunchback Impossible";

#6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
#List the customers alphabetically by last name:
SELECT first_name, last_name, SUM(amount)
FROM customer
JOIN payment ON customer.customer_id = payment.customer_id
GROUP BY payment.customer_id
ORDER BY last_name asc;

#7a. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title 
FROM film
WHERE language_id IN
(
SELECT language_id
FROM language
WHERE name = "English"
)
AND (title LIKE "K%") OR (title LIKE "Q%");

#7b. Use subqueries to display all actors who appear in the film Alone Trip.
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
	WHERE title = "Alone Trip"
	)	
);

#7c. Find the names and email addresses of all Canadian customers, using joins.
SELECT first_name, last_name, email
FROM customer
	JOIN address ON customer.address_id = address.address_id
    JOIN city ON address.city_id = city.city_id
    JOIN country ON city.country_id = country.country_id
WHERE country = "Canada";

#7d. Identify all movies categorized as family films.
SELECT title
FROM film
WHERE film_id IN
(
SELECT film_id
FROM film_category
WHERE category_id IN
	(
	SELECT category_id
	FROM category
	WHERE name = "Family"
	)
);

#7e. Display the most frequently rented movies in descending order.
SELECT title, COUNT(rental.inventory_id)
FROM rental
	JOIN inventory ON rental.inventory_id = inventory.inventory_id
	JOIN film ON inventory.film_id = film.film_id
GROUP BY film.title
ORDER BY COUNT(rental.inventory_id) desc;

#7f. Write a query to display how much business, in dollars, each store brought in.
SELECT store.address_id as "Store Number", address as "Store Address", SUM(amount) as "Total Revenue ($)"
FROM address
	JOIN store ON address.address_id = store.address_id
    JOIN staff ON store.store_id = staff.store_id
    JOIN payment ON staff.staff_id = payment.staff_id
GROUP BY address.address_id;

#7g. Write a query to display for each store its store ID, city, and country.
SELECT store_id, city, country
FROM store
	JOIN address ON store.address_id = address.address_id
    JOIN city ON address.city_id = city.city_id
    JOIN country ON city.country_id = country.country_id;

#7h. List the top five genres in gross revenue in descending order. 
#(Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT category.name as "Genre", SUM(amount) as "Gross Revenue ($)"
FROM category
	JOIN film_category ON category.category_id = film_category.category_id
    JOIN inventory ON film_category.film_id = inventory.film_id
    JOIN rental ON inventory.inventory_id = rental.inventory_id
    JOIN payment ON rental.rental_id = payment.rental_id
GROUP BY category.name
ORDER BY SUM(amount) DESC LIMIT 5;

#8a. Use the solution from the problem above to create a view. 
CREATE VIEW top_five_genres as (
SELECT category.name as "Genre", SUM(amount) as "Gross Revenue ($)"
FROM category
	JOIN film_category ON category.category_id = film_category.category_id
    JOIN inventory ON film_category.film_id = inventory.film_id
    JOIN rental ON inventory.inventory_id = rental.inventory_id
    JOIN payment ON rental.rental_id = payment.rental_id
GROUP BY category.name
ORDER BY SUM(amount) DESC LIMIT 5
);

#8b. How would you display the view that you created in 8a?
SELECT * FROM top_five_genres;

#8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_five_genres;
