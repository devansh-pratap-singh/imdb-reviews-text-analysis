CREATE OR REPLACE MODEL `gen_ai.text_bison_model`
  REMOTE WITH CONNECTION `us.vertex_ai_conn`
  OPTIONS (ENDPOINT = 'text-bison');