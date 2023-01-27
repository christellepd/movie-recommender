-- 1. What is the data structure? What information do we have available for movies?
-- Display the (whole) movies table.
SELECT * FROM movies 
;


-- 2. In the movies table there is a field called movieId. Sometimes we will not need this field for the analysis.
-- Display only title and genres of the first 10 entries from the movies table that is sorted alphabetically (starting from A) by the movie titles.
SELECT title, genre 
FROM movies
WHERE title LIKE 'a%'
ORDER BY title
;


-- 3. How many movies do we have the data for?
-- Display the total row count
SELECT COUNT(title)
FROM movies
;


-- 4. Every movie has a genre assign to it. Maybe you have noticed that some of the movies has a few different genres assigned to them. 
-- Let’s pick one of the genres - e.g. drama - and check how many movies we have that were classified as this genre only.
-- Display first 10 pure Drama movies. Only Drama is in the genre column.
SELECT *
FROM movies
WHERE genre = 'Drama'
LIMIT 10
;

-- Display the count of pure Drama movies.
SELECT COUNT(genre)
FROM movies
WHERE genre = 'Drama'
;


-- 5. Some of the movies are classified as a combination of a few genres. Check how many movies have drama as one of the assigned genres.
-- Display the count of drama movies that can also contain other genres.
-- Is this number different from the one in the previous question? Why do you think so?
SELECT COUNT(genre)
FROM movies
WHERE genre LIKE '%Drama%'
;


-- 6. What is the count of movies that are not classified as drama movies?
-- Display the count of movies don’t have drama (in any combination) as assigned genre
SELECT COUNT(genre)
FROM movies
WHERE genre NOT LIKE '%Drama%'
;


-- 7. What is the year distribution of the movies? Do you have a favorite film? Which year is it from? 
SELECT time_year, COUNT(title) AS count_per_year
FROM movies
GROUP BY time_year
;
-- How many movies from this year are visible in the movies dataset?
SELECT time_year, COUNT(title)
FROM movies
WHERE time_year = 2022
GROUP BY time_year
;
-- Display the count of movies that were released in 2003.
SELECT time_year, COUNT(title)
FROM movies
WHERE time_year = 2003
GROUP BY time_year
;


-- 8. What is the year distribution of the movies? Do we have more movies from recent years? Do we have any movies from earlier years?
-- Find all movies with a year lower 1910.
SELECT *
FROM movies
WHERE time_year < 1910
;


-- 9. Have you ever watched Star Wars? Or is there a different series of movies that you loved. Let’s see which of these movies are in the dataset.
-- Retrieve all Star Wars movies from the movie table.
SELECT *
FROM movies
WHERE title LIKE '%Star Wars%'
;


