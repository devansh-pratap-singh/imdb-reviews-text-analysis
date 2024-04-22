SELECT label AS Label, generated_text AS Sentiment, COUNT(*) AS Total
FROM `gen_ai.Sentiment Analysis Result`
GROUP BY label, generated_text;