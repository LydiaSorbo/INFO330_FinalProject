--importing all three datasets
.mode csv
.import popular_10000_movies_tmdb.csv top_10000_movies
.import "IMDB movies.csv" IMDb_movies
.import "tmdb_movies_data.csv" TMDb_movies

--creating a top_10000_movies table with a movie_id primary key
.mode table
CREATE TABLE temp_top_10k as select * from top_10000_movies;
drop table top_10000_movies;
CREATE TABLE top_10000_movies(movie_id INTEGER, title TEXT, release_date DATE, genres TEXT, original_language TEXT, vote_average REAL, vote_count INTEGER, popularity REAL, overview TEXT, budget REAL, production_companies TEXT, revenue REAL, runtime INTEGER, tagline TEXT, PRIMARY KEY (movie_id));
INSERT INTO  top_10000_movies select id, title, release_date, genres, original_language, vote_average, vote_count, popularity,overview, budget, production_companies, revenue, runtime, tagline from temp_top_10k;
drop table temp_top_10k;

--clean/remove duplicate data for later insertions
delete from TMDB_movies where imdb_id = "tt0411951";
delete from TMDB_movies where imdb_id = "";


--creating id link table
CREATE TABLE id_link(movie_id INTEGER, imdb_id TEXT, FOREIGN KEY (movie_id) references top_10000_movies(movie_id), PRIMARY KEY (imdb_id));
INSERT INTO  id_link (movie_id, imdb_id) SELECT  tm.id, tm.imdb_id FROM TMDB_movies tm;

--drop unnecessary tables and columns
drop table TMDb_movies;
alter table IMDb_movies drop column title;
alter table IMDb_movies drop column original_title;
alter table IMDb_movies drop column year;
alter table IMDb_movies drop column date_published;
alter table IMDb_movies drop column genre;
alter table IMDb_movies drop column duration;
alter table IMDb_movies drop column language;
alter table IMDb_movies drop column production_company;
alter table IMDb_movies drop column description;
alter table IMDb_movies drop column avg_vote;
alter table IMDb_movies drop column votes;
alter table IMDb_movies drop column budget;
alter table IMDb_movies drop column usa_gross_income;
alter table IMDb_movies drop column worlwide_gross_income;
alter table IMDb_movies drop column metascore;
alter table IMDb_movies drop column reviews_from_users;
alter table IMDb_movies drop column reviews_from_critics;

--create movie popularity table
CREATE TABLE movie_popularity (movie_id INTEGER PRIMARY KEY, vote_average REAL, vote_count INTEGER, popularity REAL);
INSERT INTO movie_popularity (movie_id, vote_average, vote_count, popularity) SELECT movie_id, vote_average, vote_count, popularity FROM top_10000_movies;
ALTER TABLE top_10000_movies DROP COLUMN vote_average;
ALTER TABLE top_10000_movies DROP COLUMN vote_count;
ALTER TABLE top_10000_movies DROP COLUMN popularity;

--create language table
CREATE TABLE languages (language_id INTEGER PRIMARY KEY AUTOINCREMENT, language TEXT);
INSERT INTO languages (language) SELECT DISTINCT original_language FROM top_10000_movies;

--add foreign key language_id to top_10000_movies
CREATE TABLE temp_top_10k as select * from top_10000_movies;
DROP TABLE  top_10000_movies;
CREATE TABLE  top_10000_movies(movie_id, title, release_date, genres, original_language, overview, budget, production_companies, revenue, runtime, tagline, language_id, PRIMARY KEY (movie_id), FOREIGN KEY (language_id) references languages (language_id));
INSERT INTO top_10000_movies (movie_id, title, release_date, genres, original_language, overview, budget, production_companies, revenue, runtime, tagline) SELECT movie_id, title, release_date, genres, original_language, overview, budget, production_companies, revenue, runtime, tagline FROM temp_top_10k;
DROP TABLE  temp_top_10k;

--populate language_id with data and drop original_language column
UPDATE top_10000_movies SET language_id = (SELECT language_id FROM languages WHERE languages.language = top_10000_movies.original_language);
ALTER TABLE top_10000_movies DROP COLUMN original_language;

--create table of distinct genres
CREATE TABLE temp_genres AS
SELECT DISTINCT value AS genre
FROM top_10000_movies, json_each(replace(genres, "'", '"'))
ORDER BY genre;

--create final genres table, fill in data, drop temp table
CREATE TABLE genres (
   genre_id INTEGER PRIMARY KEY AUTOINCREMENT,
   name TEXT
);
INSERT INTO genres (name)
SELECT genre
FROM temp_genres;
DROP TABLE temp_genres;

--create genres linking table and populate data
CREATE TABLE temp_movieId_genre AS
SELECT DISTINCT movie_id, value AS genre
FROM top_10000_movies, json_each(replace(genres, "'", '"'));
CREATE TABLE movie_genres (
   movie_id INTEGER REFERENCES top_10000_movies(movie_id),
   genre_id INTEGER REFERENCES genres(genre_id)
);
INSERT INTO movie_genres(movie_id, genre_id)
SELECT T.movie_id, G.genre_id
FROM temp_movieId_genre AS T, genres AS G
WHERE T.genre = G.name;
DROP TABLE temp_movieId_genre;

--create table of distinct countries
CREATE TABLE temp_countries AS
SELECT DISTINCT value AS country
FROM IMDb_movies, json_each('["' || replace(country, ", ", '", "') || '"]')
WHERE country <> ''
ORDER BY country;

--create final countries table, populate with data and drop temp table
CREATE TABLE countries (
   country_id INTEGER PRIMARY KEY AUTOINCREMENT,
   name TEXT
);
INSERT INTO countries (name)
SELECT country
FROM temp_countries;
DROP TABLE temp_countries;

--create linking table for countries
CREATE TABLE temp_movieId_country AS
SELECT DISTINCT imdb_title_id, value AS country
FROM IMDb_movies, json_each('["' || replace(country, ", ", '", "') || '"]')
WHERE country <> '';
CREATE TABLE movie_countries (
   movie_id INTEGER REFERENCES top_10000_movies(movie_id),
   country_id INTEGER REFERENCES countries(country_id)
);
INSERT INTO movie_countries(movie_id, country_id)
SELECT T.imdb_title_id, C.country_id
FROM temp_movieId_country AS T, countries AS C
WHERE T.country = C.name;
DROP TABLE temp_movieId_country;


-- create table of distinct production companies
CREATE TABLE temp_prod AS
SELECT DISTINCT value AS production_company
FROM top_10000_movies, json_each(replace(replace(replace(replace(replace(production_companies, '"', "'"), "',", '",'), "['", '["'), "']", '"]'), ", '", ', "'))
ORDER BY production_company;


-- create final production company table
CREATE TABLE production_companies (
   production_id INTEGER PRIMARY KEY AUTOINCREMENT,
   name TEXT
);
INSERT INTO production_companies (name)
SELECT production_company
FROM temp_prod;
DROP TABLE temp_prod;

--create linking table for production_companies
CREATE TABLE temp_movieId_prod AS
SELECT DISTINCT movie_id, value AS production_company
FROM top_10000_movies, json_each(replace(replace(replace(replace(replace(production_companies, '"', "'"), "',", '",'), "['", '["'), "']", '"]'), ", '", ', "'));
CREATE TABLE movie_production_companies (
   movie_id INTEGER REFERENCES top_10000_movies(movie_id),
   production_id INTEGER REFERENCES production_companies(production_id)
);
INSERT INTO movie_production_companies(movie_id, production_id)
SELECT T.movie_id, P.production_id
FROM temp_movieId_prod AS T, production_companies AS P
WHERE T.production_company = P.name;
DROP TABLE temp_movieId_prod;


-- create table of distinct directors
CREATE TABLE temp_directors AS
SELECT DISTINCT value AS director
FROM IMDb_movies, json_each('["' || replace(replace(director, '"', "'"), ', ', '", "') || '"]')
WHERE director <> ''
ORDER BY director;

-- create final directors table
CREATE TABLE directors (
   director_id INTEGER PRIMARY KEY AUTOINCREMENT,
   name TEXT
);
INSERT INTO directors (name)
SELECT director
FROM temp_directors;
DROP TABLE temp_directors;

--create linking table for directors
CREATE TABLE movie_directors (
imdb_id TEXT,
director_id INTEGER, 
FOREIGN KEY (imdb_id) REFERENCES id_link (imdb_id), 
FOREIGN KEY (director_id) REFERENCES directors (director_id)
);
INSERT INTO movie_directors (imdb_id, director_id)
SELECT IMDb_movies.imdb_title_id, directors.director_id
FROM IMDb_movies
JOIN json_each('["' || replace(replace(IMDb_movies.director, '"', "'"), ', ', '", "') || '"]') AS director
JOIN directors ON director.value = directors.name;

-- create table of distinct writers
CREATE TABLE temp_writers AS
SELECT DISTINCT value AS writer
FROM IMDb_movies, json_each('["' || replace(replace(writer, '"', "'"), ', ', '", "') || '"]')
WHERE writer <> ''
ORDER BY writer;

-- create final writers table
CREATE TABLE writers (
   writer_id INTEGER PRIMARY KEY AUTOINCREMENT,
   name TEXT
);
INSERT INTO writers (name)
SELECT writer
FROM temp_writers;
DROP TABLE temp_writers;

--create writers linking table
CREATE TABLE movie_writers (
imdb_id TEXT,
writer_id INTEGER, 
FOREIGN KEY (imdb_id) REFERENCES id_link(imdb_id),
FOREIGN KEY (writer_id) REFERENCES writers (writer_id)
);
INSERT INTO movie_writers (imdb_id, writer_id)
SELECT IMDb_movies.imdb_title_id, writers.writer_id
FROM IMDb_movies
JOIN json_each('["' || replace(replace(IMDb_movies.writer, '"', "'"), ', ', '", "') || '"]') AS writer
JOIN writers ON writer.value = writers.name;

-- create table of distinct actors
CREATE TABLE temp_actors AS
SELECT DISTINCT value AS actor
FROM IMDb_movies, json_each('["' || replace(replace(actors, '"', "'"), ', ', '", "') || '"]')
WHERE actor <> ''
ORDER BY actor;

-- create final actors table
CREATE TABLE actors (
   actor_id INTEGER PRIMARY KEY AUTOINCREMENT,
   name TEXT
);
INSERT INTO actors (name)
SELECT actor
FROM temp_actors;
DROP TABLE temp_actors;

--create linking table for actors
CREATE TABLE movie_actors (
imdb_id TEXT, 
actor_id INTEGER, 
FOREIGN KEY (imdb_id) REFERENCES id_link (imdb_id), 
FOREIGN KEY (actor_id) REFERENCES actors (actor_id)
);
INSERT INTO movie_actors (imdb_id, actor_id)
SELECT IMDb_movies.imdb_title_id, actors.actor_id
FROM IMDb_movies
JOIN json_each('["' || replace(replace(IMDb_movies.actors, '"', "'"), ', ', '", "') || '"]') AS actor
JOIN actors ON actor.value = actors.name;
