WITH cte AS (
  SELECT *, SPLIT(top_3_keywords, ',') AS keywords
  FROM `gen_ai.Top 3 Keywords Result`
),
unnested AS (
  SELECT movie_id, keyword
  FROM cte, UNNEST(keywords) AS keyword
  WHERE keyword IS NOT NULL
),
ranked AS (
  SELECT movie_id, keyword, COUNT(*) AS occurence,
  ROW_NUMBER() OVER (PARTITION BY movie_id ORDER BY COUNT(*) DESC, keyword) AS ranking
  FROM unnested
  GROUP BY movie_id, keyword
)
SELECT * FROM ranked WHERE ranking <= 5;