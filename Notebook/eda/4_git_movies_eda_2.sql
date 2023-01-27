-- 1. How many ratings are available in the dataset?
-- Display the total row count of the ratings table.
SELECT COUNT(rating)
FROM ratings
;


-- 2. What is the distribution of genres combinations?
SELECT genre, COUNT(DISTINCT genre)
FROM movies
GROUP BY genre
;

-- Display the total count of different genres combinations in the movies table.
SELECT COUNT(DISTINCT genre)
FROM movies
;


-- 3. Have you already explored the tags table? What unique tags can you see for a selected movie?
-- Display unique tags for movie with id equal 60756. Use tags table.
SELECT DISTINCT(tag)
FROM tags
WHERE movie_id = 60756
;


-- 4. How many movies from different years do we have in the dataset? Focus only on given time period.
-- Display the count of movies in the years 1990-2000 using the movies table. Display year and movie_count.
-- method 1:
CREATE OR REPLACE VIEW movies_1990_2000 AS
SELECT * 
FROM movies 
WHERE time_year BETWEEN 1990 AND 2000
;

SELECT time_year, COUNT(title) AS movie_count
FROM movies_1990_2000
GROUP BY time_year
ORDER BY time_year
;

-- method 2:
SELECT time_year, COUNT(title) AS movie_count
FROM movies 
WHERE time_year BETWEEN 1990 AND 2000
GROUP BY time_year
ORDER BY time_year
;


-- 5. Which year had the highest number of movies in the dataset?
-- Display the year where most of the movies u=in the database are from.
SELECT time_year, COUNT(title)
FROM movies 
GROUP BY time_year
ORDER BY count DESC
LIMIT 1
;


/* 6. One of the metrics that could be used to measure the popularity of the movies is the total count of ratings 
	(the number of people who rated a movie). What are the most popular movies if we use this metric?*/
-- Display 10 movies with the most ratings. Use ratings table. Display movieid, count_movie_ratings.
SELECT movie_id, COUNT(rating) AS count_movie_ratings 
FROM ratings
GROUP BY movie_id
ORDER BY count_movie_ratings DESC
LIMIT 10
;


/* 7. Another metric that we could use to measure the popularity of the movies is the average rating. 
	However, to ensure the quality of this information we need to have at least a given number of ratings.
	What are the most popular movies using this metric?*/
-- Display the top 10 highest rated movies by average that have at least 50 ratings. 
-- Display the movieid, average rating and rating count. Use the ratings table.
-- method 1: create view 
CREATE OR REPLACE VIEW avg_rating_popularity AS
SELECT movie_id, ROUND(AVG(rating), 2) AS avg_rating, COUNT(rating) AS count_rating
FROM ratings
GROUP BY movie_id
;

SELECT *
FROM AVG_RATING_POPULARITY 
WHERE count_rating >= 50
ORDER BY avg_rating DESC
LIMIT 10
;

-- method 2: run the filter from 'HAVING'
SELECT movie_id, ROUND(AVG(rating), 2) AS avg_rating, COUNT(rating) AS count_rating
FROM ratings
GROUP BY movie_id
HAVING COUNT(rating) >= 50
ORDER BY avg_rating DESC
LIMIT 10
;

-- method 3: create a new table alias, nested selects
SELECT *
FROM (SELECT movie_id, ROUND(AVG(rating), 2) AS avg_rating, COUNT(rating) AS count_rating 
	FROM ratings 
	GROUP BY movie_id) AS new_data
WHERE count_rating >= 50
ORDER BY avg_rating DESC
LIMIT 10
;


/* 8. Imagine that you would like to continue focusing on the drama movies only. 
 As you have multiple questions about drama movies you decided to create a view representing drama movies that you could reuse later on.*/
 -- Create a view that is a table of only movies that contain drama as one of it’s genres. Display the first 10 movies in the view.
CREATE OR REPLACE VIEW movies_drama AS
SELECT *
FROM movies 
WHERE genre LIKE '%Drama%'
;





