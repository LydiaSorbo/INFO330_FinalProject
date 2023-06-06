-- number of movies per actor
SELECT actors.name AS actor, COUNT(*) AS movie_per_actor_count
FROM actors
JOIN movie_actors ON actors.actor_id = movie_actors.actor_id
GROUP BY actors.name
ORDER BY movie_per_actor_count DESC;

-- Actors which have done the most movies with the same production company
SELECT actors.name AS actor, production_companies.name AS production_company, COUNT(*) AS number_of_movies 
FROM actors
JOIN movie_actors ON actors.actor_id = movie_actors.actor_id
JOIN id_link ON movie_actors.imdb_id = id_link.imdb_id
JOIN movie_production_companies ON id_link.movie_id = movie_production_companies.movie_id
JOIN production_companies ON movie_production_companies.production_id = production_companies.production_id
GROUP BY actors.actor_id, production_companies.production_id
ORDER BY number_of_movies DESC;

-- Genre pairings which have the highest budget
SELECT G1.name AS genre1, G2.name AS genre2, MAX(T.budget) AS highest_budget
FROM movie_genres AS movie_genre_1
JOIN movie_genres AS movie_genre_2 
ON movie_genre_1.movie_id = movie_genre_2.movie_id 
AND movie_genre_1.genre_id < movie_genre_2.genre_id
JOIN genres AS G1 ON movie_genre_1.genre_id = G1.genre_id
JOIN genres AS G2 ON movie_genre_2.genre_id = G2.genre_id
JOIN top_10000_movies AS T ON T.movie_id = movie_genre_1.movie_id
GROUP BY G1.name, G2.name
ORDER BY highest_budget DESC;

