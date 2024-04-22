SELECT
  SUM(CASE WHEN label = 'Positive' AND generated_text LIKE '%Positive%' THEN 1 ELSE 0 END)/COUNT(*) AS Positive_Label_Rate,
  SUM(CASE WHEN label = 'Negative' AND generated_text LIKE '%Negative%' THEN 1 ELSE 0 END)/COUNT(*) AS Negative_Label_Rate,
  SUM(CASE WHEN (label = 'Positive' AND generated_text LIKE '%Positive%')
             OR (label = 'Negative' AND generated_text LIKE '%Negative%') THEN 1 ELSE 0 END)/COUNT(*) AS All_Label_Rate
FROM `gen_ai.Sentiment Analysis Result`;