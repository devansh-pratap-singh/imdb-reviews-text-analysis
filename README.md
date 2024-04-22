# Text Analysis on IMDb Movie Reviews

In today's data-driven world, extracting valuable insights from vast amounts of text data has become an essential task for many industries. In this project, I perform text analysis on movie reviews from IMDB using Google BigQuery and Vertex AI. By leveraging BigQuery's powerful capabilities alongside Vertex AI's generative models, I delved into sentiment analysis and keyword extraction to gain meaningful insights from the reviews dataset.

### Step 1 - Setup

**Create a Vertex AI Connection:**  
The first step is to establish a connection to Vertex AI within BigQuery. Vertex AI provides a unified platform for building, deploying, and managing machine learning models.
<p align="center">
  <img src="https://github.com/devansh-pratap-singh/imdb-reviews-text-analysis/assets/136521901/9af59ce5-cf24-4a00-9e77-de7b0b4fc2d7" alt="image">
</p>

**Grant Vertex AI User Role:**  
Once the connection is established, it's crucial to grant the necessary permissions to the service account associated with the Vertex AI connection. This ensures that the account has the required access to perform machine learning tasks.
<p align="center">
  <img src="https://github.com/devansh-pratap-singh/imdb-reviews-text-analysis/assets/136521901/189ed2d7-eaef-4d77-9291-0b85d293f07a" alt="image">
</p>

**Create a Remote Model:**  
Next, I created a remote model with a connection to the text-bison Large Language Model (LLM). This model will serve as the backbone for sentiment analysis and keyword extraction tasks.
```
CREATE OR REPLACE MODEL `gen_ai.text_bison_model`
  REMOTE WITH CONNECTION `us.vertex_ai_conn`
  OPTIONS (ENDPOINT = 'text-bison');
```

### Step 2 - Sentiment Analysis

**Query Execution for Sentiment Analysis:**  
To perform sentiment analysis, I wrote a query using `ml.generate_text` with a prompt tailored to detect positive and negative sentiments. I analyzed reviews for three movie IDs: tt0079588, tt0170016, and tt0312528. Results were returned into a table, including review columns and movie titles which I then saved as a BigQuery table named 'Sentiment Analysis Result'.

```
SELECT
  ml_generate_text_llm_result AS generated_text,
  * EXCEPT(ml_generate_text_llm_result, ml_generate_text_rai_result, ml_generate_text_status)
FROM ML.GENERATE_TEXT(
  MODEL `gen_ai.text_bison_model`,
  (
    SELECT CONCAT(
      'perform sentiment analysis on the following text, return only one of the following categories: Positive, Negative: ',
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
    0.1 AS top_p,
    TRUE AS flatten_json_output
  )
);
```

**Count Result Rows by Label:**  
Then I wrote a query to count the rows returned by the above query, grouped by labels and LLM generated sentiments (positive/negative) to compare the result. The LLM returned values other than positive or negative, which I rectified by adjusting the prompt accordingly.
<p align="center">
  <img src="https://github.com/devansh-pratap-singh/imdb-reviews-text-analysis/assets/136521901/69407fa9-a6fd-485f-b694-48a22e4f1175" alt="image">
</p>

**Calculate Label/Sentiment Match Rates:**  
Next, I calculated three rates - positive-label match rate, negative-label match rate, and overall label match rate to evaluate the effectiveness of the sentiment analysis. The overall match rate was approximately 98%.
<p align="center">
  <img src="https://github.com/devansh-pratap-singh/imdb-reviews-text-analysis/assets/136521901/eb8a2091-4a25-4603-b0b7-872f1c501ab0" alt="image">
</p>

**Identify Mismatches:**  
Lastly, I wrote a query to list reviews with label/sentiment mismatches. Upon reading the reviews, I agreed with the generated sentiment by the LLM for both the mismached reviews.
<p align="center">
  <img src="https://github.com/devansh-pratap-singh/imdb-reviews-text-analysis/assets/136521901/d9d81dd0-d13c-457d-bbc7-7e1d1371f061" alt="image">
</p>

###Step 3 - Keywords Extraction

**Query Execution for Keyword Extraction:**  
Using `ml.generate_text` again, I wrote a query with a prompt to extract the top three keywords from the reviews while excluding common words like "movie," "film," "actor," etc. Results were returned into a table, along with all review columns and movie titles which I then saved as a BigQuery table named 'Top 3 Keywords Result'.

```
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
```

**Return Top Repeated Keywords:**  
Finally, I wrote a query to summarize the top five most repeated keywords for each movie, totaling 15 keywords (5 per movie). I utilized concepts such as CTE and functions like `SPLIT` and `UNNEST` along with window functions such as `ROW_NUMBER()` to rank the keywords according to how frequently they occured in the movie reviews.
<p align="center">
  <img src="https://github.com/devansh-pratap-singh/imdb-reviews-text-analysis/assets/136521901/99767ef4-4f8e-496a-a7da-a3fbb52f7782" alt="image">
</p>
