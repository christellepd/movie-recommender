-- This line: 
    -- drop and creates table, 
    -- imports the csv fields, 
    -- adding the foreign keys (an alternative method is to alter the already created table: ALTER TABLE > ADD FOREIGN KEY > REFERENCES),
    -- create a derived table 'genre'
    

-- MOVIES TABLE
DROP TABLE IF EXISTS movies CASCADE;
CREATE TABLE movies (
    movie_id INT primary key,
    title VARCHAR(255) not null,
    genre VARCHAR(255) not null,
    time_year INT not null
);
\COPY movies FROM '../data/movies.csv' DELIMITER ',' CSV HEADER;


-- RATINGS TABLE
DROP TABLE IF EXISTS ratings CASCADE;
CREATE TABLE ratings (
    user_id INT not null,
    movie_id INT not null REFERENCES movies(movie_id),
    rating NUMERIC not null,
    time_stamp INT
);
\COPY ratings FROM '../data/ratings.csv' DELIMITER ',' CSV HEADER;


-- TAGS TABLE
DROP TABLE IF EXISTS tags CASCADE;
CREATE TABLE tags (
    user_id INT not null,
    movie_id INT not null REFERENCES movies(movie_id),
    tag VARCHAR(255) not null,
    time_stamp INT
);
\COPY tags FROM '../data/tags.csv' DELIMITER ',' CSV HEADER;


-- LINKS TABLE
DROP TABLE IF EXISTS links CASCADE;
CREATE TABLE links (
    movie_id INT not null REFERENCES movies(movie_id),
    imdb_id INT not null,
    tmdb_id INT not null
);
\COPY links FROM '../data/links.csv' DELIMITER ',' CSV HEADER;


-- GENRES TABLE
DROP TABLE IF EXISTS genres CASCADE;
CREATE TABLE genres AS (
    SELECT 
    	movie_id,
    	regexp_split_to_table(genre, '\|') AS genre
    FROM movies
);


-- Alter GENRES TABLE by adding foreign key
ALTER TABLE genres
ADD FOREIGN KEY (movie_id) REFERENCES movies(movie_id);
