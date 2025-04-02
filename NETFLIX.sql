-- Netflix 
DROP TABLE IF EXISTS Netflix
CREATE TABLE Netflix (
  show_id VARCHAR(6),
  type VARCHAR(10),
  title VARCHAR(150),
  director VARCHAR(208),
  castS VARCHAR(1000),
  country VARCHAR(150),
  date_added VARCHAR(50),
  release_year INT,
  rating VARCHAR(10),
  duration VARCHAR(15),
  listed_in VARCHAR(100),
  description VARCHAR(250)
)
SELECT * FROM Netflix

select count(*) as Total_content from Netflix

select distinct type from Netflix

1. Count the number of Movies vs TV Shows

SELECT type, COUNT(*) as Total_count
FROM Netflix 
GROUP BY type

2. Find the most common rating for movies and TV Shows

SELECT type, rating FROM
(
SELECT type, rating, count(*),
RANK() OVER(PARTITION BY type ORDER BY count(*) DESC) as ranking
FROM Netflix
GROUP BY 1,2
) AS t1
where ranking=1


3. List all movies released in a specific year (eg., 2020)

SELECT * FROM Netflix
WHERE type= 'Movie' and release_year = 2020

4. Find the top 5 countries with the most content on Netflix

SELECT country, count(show_id) 
FROM Netflix 
GROUP BY 1 --returning multiple countries in each row

SELECT
  UNNEST(STRING_TO_ARRAY(country, ',')) as new_country,
  COUNT(show_id) as Total_content
from Netflix
GROUP BY 1
ORDER BY 2 DESC

SELECT DISTINCT TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) 
from Netflix LIMIT 5

SELECT 
    TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS new_country,
    COUNT(show_id) AS Total_content
FROM Netflix
GROUP BY TRIM(UNNEST(STRING_TO_ARRAY(country, ',')))
ORDER BY 2 DESC
LIMIT 5


5. Identity the longest movie or TV Show duration

SELECT * 
FROM Netflix
WHERE type = 'Movie' AND
duration = (select max(duration) from Netflix)


6. Find the content added in the last 5 years

SELECT * FROM Netflix
WHERE TO_DATE(date_added, 'month DD, yyyy') >= CURRENT_DATE - INTERVAL '5 YEARS'

7. Find all the movies/TV Shows by director 'Rajiv Chilaka'

SELECT * FROM Netflix 
WHERE director ILIKE '%rajiv chilaka%'

8. List all TV Shows with more than 5 seasons

SELECT * FROM Netflix
WHERE type = 'TV Show' AND
SPLIT_PART(duration, ' ',1)::NUMERIC > 5

9. Count the number of content items in each genre

SELECT 
  TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) as genre,
  COUNT(show_id)
FROM Netflix
GROUP BY 1

10.1 find the average release year for content produced in a specific country

SELECT 
    TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) as country,
	AVG(release_year)
	FROM Netflix
	GROUP BY 1

10.2 Find each year and the average numbers of content release in India on Netflix.
Return top 5 year with highest average content release.

SELECT EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) as date,
COUNT(*),
ROUND(
COUNT(*)::numeric/(SELECT count(*) FROM Netflix WHERE country ilike '%india%')::numeric * 100
   ,2) as avg_content
FROM Netflix 
WHERE country ilike '%india%'
GROUP BY 1

11. List all movies that are documentaries

SELECT * FROM Netflix
WHERE type = 'Movie' AND
listed_in ILIKE '%documentaries%'

12. Find all content without a director

SELECT * FROM Netflix WHERE director is null

13. List the movies in which the actor 'Salman khan' appeared in last 10 years

SELECT * FROM Netflix where casts ilike '%salman khan%'
	and
    release_year >= EXTRACT(YEAR FROM CURRENT_DATE) - 10
	
14. Find the top 10 actors who have appeared in the highest no.of movies produced

SELECT 
UNNEST(STRING_TO_ARRAY(casts, ',')) as actors,
count(*) as total_movies
from Netflix
where country ilike '%india%'
group by 1
order by 2 desc
limit 10

15. Categorize the content based on the presence of the keywords ' kill' and ' violence'
in the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.

WITH new_table
AS
(
SELECT *,
CASE WHEN description ilike '%kill%' or
          description ilike '%violence%' THEN 'Bad_Content'
	 ELSE 'Good_Content'	  
	 END category
FROM Netflix
) 
SELECT 
    category,
	count(*) as total_content
	FROM new_table
	GROUP BY 1
