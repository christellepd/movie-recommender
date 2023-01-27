--/* CREATING NEW GENRES TABLE */--

-- Show table
SELECT genre 
FROM movies 
LIMIT 5
;


-- Split the genres
SELECT movie_id, regexp_split_to_table(genre, '\|') 
FROM movies 
LIMIT 10
;
-- Run this in psql by creating a derived table


-- Show genres table
SELECT * 
FROM genres 
LIMIT 10
;


--/* PROJECT CHALLENGES */--
/* 1. Imdb is one of the movie platforms which has its own movies database where movies also have their own ids. 
Find 5 movie titles from our database with the lowest imdb ids (the movies that were added at first to the platform).*/
-- Using a JOIN display 5 movie titles with the lowest imdb ids
TABLE links;
TABLE movies;

SELECT movies.movie_id as movieid, movies.title as title, links.imdb_id as imdbid
FROM movies 
JOIN links 
USING (movie_id)
ORDER BY imdbid ASC
LIMIT 5
;


/* 2. As we have created the genres table before, we want to modify the query asking about the count of drama movies.*/
-- Display the count of drama movies
TABLE genres;

SELECT COUNT(genre)
FROM genres
WHERE genre LIKE 'Drama'
;


/* 3.One of the ways to describe the movies is to assign the genres to them. Besides genres,there is also tags information available for us 
Find out all the movies that are matching a defined tag (e.g. ‘fun’).*/
-- Using a JOIN display all of the movie titles that have the tag fun
TABLE movies;
TABLE tags;

SELECT tags.movie_id as movieid, tags.tag as tag, movies.title as title
FROM tags 
JOIN movies 
	USING (movie_id)
WHERE tag LIKE 'fun'
;


/* 4. Not all the movies where marked with a tag by the users. Find the first movie without any tags in the database.*/
-- Using a JOIN find out which movie title is the first without a tag
TABLE movies;
TABLE tags;

SELECT tags.movie_id as movieid, tags.tag as tag, movies.title as title, movies.time_year as timeyear
FROM movies 
FULL JOIN tags 
	USING (movie_id)
WHERE tag IS NULL
ORDER BY timeyear
LIMIT 1
;


/* 5. Which genres are the most liked ones? Calculate average rating for all the genres and show the 3 highest rated ones. 
 (Tip: Join the genres and the rating table.)*/
-- Using a JOIN display the top 3 genres and their average rating
TABLE genres;
TABLE ratings;

-- method 1: create a new table alias, nested selects
SELECT genre, ROUND(AVG(rating), 2) AS avg_rating
FROM 
	(SELECT ratings.movie_id as movieid, ratings.rating as rating, genres.genre as genre
	FROM genres 
	JOIN ratings 
		USING (movie_id)) AS new_data
GROUP BY genre
ORDER BY avg_rating DESC
LIMIT 3
; 

-- method 2: not including the primary key
SELECT genres.genre as genre, ROUND(AVG(ratings.rating), 2) as avg_rating
FROM genres 
JOIN ratings 
	USING (movie_id)
GROUP BY genre
ORDER BY avg_rating DESC
LIMIT 3
; 
	-- NOTE: adding the movieid does not work because ratings is aggregated, while genre is to be grouped by. 
	-- Thus moviesid would not know where to position itself. IF you would add an aggregating function in movieid
	-- i.e. MAX(), then it would work


/* 6. Let’s assume that number of ratings is proportional to the number of people who watched a film. 
Which movies where watched by the biggest group of people?*/
-- Using a JOIN display the top 10 movie titles by the number of ratings
TABLE movies;
TABLE ratings;

SELECT movies.title as title, COUNT(ratings.rating) as rating_count
FROM movies 
JOIN ratings 
	USING (movie_id)
GROUP BY title
ORDER BY rating_count DESC
LIMIT 10
;


/* 7. If you have seen Star Wars, do you have your favorite Star Wars movie? Compare your verdict with the ratings from the dataset.*/
-- Using a JOIN display all of the Star Wars movies in order of average rating where the film was rated by at least 40 users
TABLE movies;
TABLE ratings;

SELECT movies.title as title, ROUND(AVG(ratings.rating), 2) as rating_avg, COUNT(ratings.rating) as rating_count
FROM movies 
JOIN ratings 
	USING (movie_id)
WHERE title LIKE '%Star Wars%'
GROUP BY title
HAVING COUNT(ratings.rating) >= 40 
ORDER BY rating_avg DESC
;


/* 8. Imagine that you will need to reuse the results of one of the queries above. Save the results in the derived table.*/
-- Create a derived table from one or more of the above queries
-- What is the difference between this and a VIEW?
CREATE TABLE star_wars_derivedtable AS(
	SELECT movies.title as title, ROUND(AVG(ratings.rating), 2) as rating_avg, COUNT(ratings.rating) as rating_count
	FROM movies 
	JOIN ratings 
		USING (movie_id)
	WHERE title LIKE '%Star Wars%'
	GROUP BY title
	HAVING COUNT(ratings.rating) >= 40 
	ORDER BY rating_avg DESC
)
;


--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*
















