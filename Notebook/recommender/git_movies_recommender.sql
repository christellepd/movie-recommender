-- Converting unix timestamp to actual timestamp, filtering a specific date
SELECT *
FROM (SELECT *, TO_TIMESTAMP(time_stamp) AS datetime FROM ratings) AS ratings_timestamp
WHERE DATE(datetime) IN ('2000-07-30')
;

-- Converting unix timestamp to actual timestamp, filtering a month
SELECT *
FROM (SELECT *, TO_TIMESTAMP(time_stamp) AS datetime FROM ratings) AS ratings_timestamp
WHERE EXTRACT(MONTH FROM datetime) = 06
;






--////* Imagine you are a movie producer and you want to create a successful movie *////--

--///* 1. RANKING & SEARCHABILITY: top 5 movies and its genre with the highest unique tag count, highest rating avg/count, 
-- 				highest genre count *///--

-- STEP 1: DATA WRANGLING --
-- CREATE VIEW individually with only numeric fields: 
TABLE links;
TABLE ratings;
TABLE tags;
TABLE genres;

	-- rating
CREATE OR REPLACE VIEW movielens_rating AS
SELECT movies.movie_id AS movie_id, movies.title AS title, movies.time_year AS year, 
	ROUND(AVG(ratings.rating), 2) AS rating_avg, COUNT(ratings.rating) AS rating_cnt
FROM movies
FULL JOIN ratings
	USING (movie_id)
GROUP BY movies.movie_id
ORDER BY movie_id
;

	-- genre
CREATE OR REPLACE VIEW movielens_genre AS
SELECT movies.movie_id AS movie_id, movies.title AS title, movies.time_year AS year, 
	COUNT(genres.genre) AS genre_cnt
FROM movies
FULL JOIN genres
	USING (movie_id)
GROUP BY movies.movie_id
ORDER BY movie_id
;

	-- tag
CREATE OR REPLACE VIEW movielens_tag AS
SELECT movies.movie_id AS movie_id, movies.title AS title, movies.time_year AS year, 
	COUNT(DISTINCT tags.tag) AS tag_cnt
FROM movies
FULL JOIN tags
	USING (movie_id)
GROUP BY movies.movie_id
ORDER BY movie_id
;

	-- JOIN movies-ratings-genres table with only numeric fields
DROP TABLE IF EXISTS movielens_num;
CREATE TABLE movielens_num AS(
SELECT movielens_rating.movie_id, movielens_rating.title, movielens_rating.year, 
	movielens_rating.rating_avg, movielens_rating.rating_cnt, movielens_genre.genre_cnt, movielens_tag.tag_cnt
FROM movielens_rating
FULL JOIN movielens_genre
	USING (movie_id)
FULL JOIN movielens_tag
	USING (movie_id)
);




	-- Determine the max and min of the values for CASE WHEN movie scoring:
	-- rating avg: 0.5 - 5
	SELECT MIN(rating_avg), MAX(rating_avg)
	FROM movielens_num
	;
	
	-- rating cnt: 1 - 329 (Forrest Gump)
	SELECT MIN(rating_cnt), MAX(rating_cnt)
	FROM movielens_num
	;
	
	-- genre cnt: 1 - 7 (Who Framed Roger Rabbit)
	SELECT MIN(genre_cnt), MAX(genre_cnt)
	FROM movielens_num
	;
	
	-- tag cnt: 1 - 181 (Pulp Fiction)
	SELECT MIN(tag_cnt), MAX(tag_cnt)
	FROM movielens_num
	;
	
	
-- alter table to add a a new column called movie_score
ALTER TABLE movielens_num
ADD movie_score INT
;


-- update table by adding the lower and upper limits in a new column 'movie_score'
UPDATE movielens_num 
SET movie_score = -- weighted scores of rating_avg (30%) + rating_cnt (30%) + genre_cnt (20%) + tag_cnt (20%)
		(CASE
			WHEN rating_avg BETWEEN 1 AND 1.5 
				THEN 1
			WHEN rating_avg BETWEEN 1.55 AND 2.5 
				THEN 2
			WHEN rating_avg BETWEEN 2.55 AND 3.5 
				THEN 3
			WHEN rating_avg BETWEEN 3.55 AND 4.0 
				THEN 4
			ELSE
				5
		END) * (0.30) +		
		(CASE
			WHEN rating_cnt BETWEEN 1 AND 65
				THEN 1
			WHEN rating_cnt BETWEEN 66 AND 130
				THEN 2
			WHEN rating_cnt BETWEEN 131 AND 195
				THEN 3
			WHEN rating_cnt BETWEEN 196 AND 260
				THEN 4
			ELSE
				5
		END) * (0.30) + 
		(CASE
			WHEN genre_cnt BETWEEN 1 AND 2
				THEN 1
			WHEN genre_cnt BETWEEN 3 AND 4 
				THEN 2
			WHEN genre_cnt BETWEEN 5 AND 6 
				THEN 3
			ELSE
				4
		END) * (0.20) +
		(CASE
			WHEN tag_cnt BETWEEN 1 AND 35
				THEN 1
			WHEN tag_cnt BETWEEN 36 AND 70 
				THEN 2
			WHEN tag_cnt BETWEEN 71 AND 105 
				THEN 3
			WHEN tag_cnt BETWEEN 106 AND 140 
				THEN 4
			ELSE
				5
		END) * (0.20)
;



-- STEP 2: ANALYSIS --
TABLE movielens_num;

-- query 1: top 5 films
SELECT *
FROM movielens_num
ORDER BY movie_score DESC
LIMIT 5
;

-- query 2: genre of the top 5 films
CREATE OR REPLACE VIEW genre_5 AS
SELECT genre, COUNT(genres.genre)
FROM 
	(SELECT *
	FROM movielens_num
	ORDER BY movie_score DESC
	LIMIT 5) AS subset
JOIN genres
	USING (movie_id)
GROUP BY genre
ORDER BY count DESC
LIMIT 7
;
TABLE genre_5
;
 	--> conclusion: Crime/Thriller movies




--///* RELEASE DATE: At which time of the year is it best to release a movie *///--
-- Assumption: 
	-- one rates a movie immediately upon watching
	-- start data only from 2005 (to account for the previous)

-- STEP 1: EDA, DATA WRANGLING --
-- Check timestamp min/max date (Mar 29 1996 - Sep 2018)
SELECT *
FROM (SELECT *, TO_TIMESTAMP(time_stamp) AS created_at FROM ratings) AS ratings_dt
WHERE EXTRACT
(YEAR FROM created_at) = 2018
ORDER BY EXTRACT(MONTH FROM created_at) DESC
;


-- check user_id distribution
SELECT user_id, COUNT(user_id) AS user_id_cnt
FROM ratings
GROUP BY user_id
ORDER BY user_id_cnt DESC
;
	--  check if there is an 'outlier' pattern --> suser_id 414 has rated 2697 movies; started from 2000-2012 and resumed in 2017-2018
	SELECT movie_id, created_at
	FROM (SELECT *, TO_TIMESTAMP(time_stamp) AS created_at FROM ratings) AS ratings_dt
	WHERE user_id = 414
	GROUP BY movie_id, created_at
	ORDER BY EXTRACT(YEAR FROM created_at), EXTRACT(MONTH FROM created_at)
	;
		--> therefore I loosely assume that the data is 'unbiased'


-- STEP 2: ANALYSIS --
-- query 1: Avg count of ratings per month from 2005 (e.g. For the month of May, what is the average rating count across all the years)
SELECT createdat_month, ROUND(AVG(yr_mth_ratingcnt), 2) AS avg_rating_per_month
FROM
	(SELECT createdat_year, createdat_month, COUNT(createdat_month) AS yr_mth_ratingcnt
	FROM
		(SELECT EXTRACT(YEAR FROM created_at) AS createdat_year, EXTRACT(MONTH FROM created_at) AS createdat_month
		FROM 
			(SELECT *,TO_TIMESTAMP(time_stamp) AS created_at 
			FROM ratings
			JOIN movies
			USING (movie_id)
			WHERE time_year > 2005
			) AS timedata) AS ratingdata
	GROUP BY createdat_year, createdat_month
	ORDER BY createdat_month) AS ratingdata2
WHERE createdat_year > 2005
GROUP BY createdat_month
ORDER BY avg_rating_per_month DESC 
; 
	--> conclusion: release in May/November...




--///* 3. NAME RECALL: Does the character length of a title matter *///--

-- query 1: avg char length per movie score
TABLE movielens_num;

SELECT movie_score, ROUND(AVG(length(title)), 2) AS title_length
FROM movielens_num 
GROUP BY movie_score
ORDER BY movie_score DESC
;
	--> conclusion: char length does not heavily matter


















