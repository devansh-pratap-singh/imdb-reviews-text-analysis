SELECT
  ml_generate_text_llm_result AS top_3_keywords,
  * EXCEPT(ml_generate_text_llm_result, ml_generate_text_rai_result, ml_generate_text_status)
FROM ML.GENERATE_TEXT(
  MODEL `gen_ai.text_bison_model`,
  (
    SELECT CONCAT(
      'Extract top 3 keywords as comma-separated values that represent the sentiment of the review excluding words like movie, film, actor, character, song, music, nouns, pronouns and articles. Convert plural keywords to singular form. Also convert keywords to lower case: ',
      reviews.review) AS prompt, *
    FROM `bigquery-public-data.imdb.reviews` AS reviews
    INNER JOIN `bigquery-public-data.imdb.title_basics` AS titles
    ON reviews.movie_id = titles.tconst
    WHERE movie_id IN ('tt0079588','tt0170016','tt0312528')
  ),
  STRUCT (
    0.2 AS temperature,
    1000 AS max_output_tokens,
    5 AS top_k,
    0.8 AS top_p,
    TRUE AS flatten_json_output
  )
);