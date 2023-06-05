--Returns titles of 10 movies with the highest popularity and whether or not they have a tagline, also returns their popularity score.
SELECT m.title, CASE WHEN m.tagline = '' THEN 'No' ELSE 'Yes' END AS has_tagline, p.popularity FROM top_10000_movies AS m JOIN movie_popularity AS p ON m.movie_id = p.movie_id ORDER BY p.popularity DESC LIMIT 10;

--Returns the top 10 directors with the highest average revenue and their most popular movie along with the popularity score.
SELECT d.name, AVG(t.revenue) AS avg_revenue, MAX(p.popularity) AS max_popularity, t.title AS movie_with_highe st_popularity FROM directors AS d JOIN movie_directors AS md ON d.director_id = md.director_id JOIN id_link AS il ON md.imdb_id = il.imdb_id JOIN top_10000_movies AS t ON il.movie_id = t.movie_id JOIN movie_popularity AS p ON t.movie_id = p.movie_id WHERE p.popularity = (SELECT MAX(popularity) FROM movie_popularity WHERE movie_id = t.movie_id) GROUP BY d.name ORDER BY avg_revenue DESC LIMIT 10;
