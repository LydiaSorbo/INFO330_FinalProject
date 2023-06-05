--Explore relationship between vote_average and movie_popularity--
--Returns popularity score and the associated vote_average--
SELECT popularity, vote_average FROM movie_popularity ORDER BY popularity DESC limit 20;

--Returns the titles and genres of movies with the highest popularity scores--
--Explores the relationship between movie popularity and movie genre--
SELECT m.title AS movie_title, g.name AS genre_name, mp.popularity AS popularity_score FROM top_10000_movies AS m JOIN movie_genres AS mg ON m.movie_id = mg.movie_id JOIN genres AS g ON mg.genre_id = g.genre_id JOIN movie_popularity AS mp ON m.movie_id = mp.movie_id ORDER BY mp.popularity DESC LIMIT 10;
