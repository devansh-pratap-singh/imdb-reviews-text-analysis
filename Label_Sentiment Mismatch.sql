WITH sentiment_analysis AS (
  SELECT
  review, label, generated_text,
  CASE WHEN (label = 'Positive' AND generated_text LIKE '%Negative%')
        OR (label = 'Negative' AND generated_text LIKE '%Postive%')
      THEN 'mismatch' ELSE 'match'
    END AS check
  FROM `gen_ai.Sentiment Analysis Result`
)
SELECT * FROM sentiment_analysis
WHERE check = 'mismatch';