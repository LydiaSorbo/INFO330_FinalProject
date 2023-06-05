--Returns what months the top grossing movies were relseased in to see if season makes a difference
SELECT title, STRFTIME( '%m', release_date) AS release_month FROM top_10000_movies ORDER BY revenue DESC LIMIT 20;


--Returns generes from olest movies (with title and date)
SELECT top_10000_movies.title,  top_10000_movies.release_date, name AS genre FROM genres JOIN top_10000_movies JOIN movie_genres ON movie_genres.movie_id = top_10000_movies.movie_id AND movie_genres.genre_id = genres.genre_id WHERE top_10000_movies.release_date IS NOT NULL GROUP BY  top_10000_movies.release_date ORDER BY top_10000_movies.release_date ASC LIMIT 50;

--Returns generes from newest movies (with title and date)
SELECT top_10000_movies.title,  top_10000_movies.release_date, name AS genre FROM genres JOIN top_10000_movies JOIN movie_genres ON movie_genres.movie_id = top_10000_movies.movie_id AND movie_genres.genre_id = genres.genre_id WHERE top_10000_movies.release_date IS NOT NULL GROUP BY  top_10000_movies.release_date ORDER BY top_10000_movies.release_date DESC LIMIT 50;