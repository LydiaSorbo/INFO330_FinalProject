-- compare the movie ratings of high and low budget movies
WITH high_budget AS (
    SELECT movie_id
    FROM top_10000_movies
    WHERE budget > 100000
)
SELECT AVG(vote_average)
FROM high_budget AS H, movie_popularity AS P
WHERE H.movie_id = P.movie_id;
-- 6.58397233201583

WITH low_budget AS (
    SELECT movie_id
    FROM top_10000_movies
    WHERE budget < 100000
    AND budget != 0
)
SELECT AVG(vote_average)
FROM low_budget AS L, movie_popularity AS P
WHERE L.movie_id = P.movie_id;
-- 5.50952380952381


-- graph
-- SELECT vote_average
-- FROM top_10000_movies AS M, movie_popularity AS P
-- WHERE M.movie_id = P.movie_id;

-- find the top ten production companies with the highest average revenue
SELECT P.name AS production_company, AVG(T.revenue) AS avg_revenue
FROM top_10000_movies AS T, movie_production_companies AS M, production_companies AS P
WHERE T.movie_id = M.movie_id
AND M.production_id = P.production_id
GROUP BY P.production_id, P.name
ORDER BY AVG(T.revenue) DESC
LIMIT 10;
