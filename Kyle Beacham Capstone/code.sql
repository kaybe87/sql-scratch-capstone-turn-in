/* Initial "survey" Schema Review */

-- SELECT *
-- FROM survey
-- LIMIT 10;
 
 
 
/* Slightly closer look at the drop off points */

-- SELECT question,
-- 		COUNT (DISTINCT user_id)
-- FROM survey
-- GROUP BY 1;



/* Initial "quiz", "home_try_on", and "purchase" Schema Review */

-- SELECT *
-- FROM quiz
-- LIMIT 20;

-- SELECT *
-- FROM home_try_on
-- LIMIT 5;

-- SELECT *
-- FROM purchase
-- LIMIT 5;


/* New table using LEFT JOIN to analyze whether a purchase was made
which includes whether the customer participated in home try on and how many
pairs they has when they did home try on */

-- SELECT DISTINCT q.user_id,
--  CASE WHEN h.user_id IS NOT NULL 
--   			THEN 'true'
--        ELSE 'false' END AS 'is_home_try_on',
--   h.number_of_pairs,
--   CASE WHEN p.user_id IS NOT NULL 
--        THEN 'true'
--        ELSE 'false' END AS 'is_purchase'
--FROM quiz AS q 
--LEFT JOIN home_try_on AS h
--   ON q.user_id = h.user_id
--LEFT JOIN purchase AS p
--   ON p.user_id = q.user_id
--LIMIT 10;



/* Adjusted the LEFT JOIN to remove case statements which applied true and false 'readability items' in order to use aggregate functions to calculate sales and try_on metrics from all quiz takers */

--WITH funnels as 
--  (SELECT DISTINCT q.user_id,
--     h.user_id IS NOT NULL AS 'is_home_try_on',
--     h.number_of_pairs as 'number_pairs',
--     p.user_id IS NOT NULL AS 'is_purchase'
--  FROM quiz AS q 
--  LEFT JOIN home_try_on AS h
--     ON q.user_id = h.user_id
--  LEFT JOIN purchase AS p
--     ON p.user_id = q.user_id)


--SELECT COUNT(user_id) as 'quiz_takers',
--  SUM(is_home_try_on) as 'num_try_on',
--  SUM(is_purchase) as 'num_purchase',
--  1.0 * sum(is_purchase) / count(user_id) AS 'quiz_to_purchase',
--  1.0 * sum(is_purchase) / sum(is_home_try_on) as 'try_on_to_purchase'
--  FROM funnels;
  
  
  WITH funnels as 
  (SELECT DISTINCT q.user_id,
     h.user_id IS NOT NULL AS 'is_home_try_on',
     h.number_of_pairs as 'number_pairs',
     p.user_id IS NOT NULL AS 'is_purchase',
     q.shape as 'shape'
  FROM quiz AS q 
  LEFT JOIN home_try_on AS h
     ON q.user_id = h.user_id
  LEFT JOIN purchase AS p
     ON p.user_id = q.user_id)
     

/* Modification of the funnels to view analytics based on the shape of the glasses
that was answered during the initial quiz to see what shape has the best retention */

SELECT COUNT(user_id) as 'quiz_takers',
  SUM(is_home_try_on) as 'num_try_on',
  SUM(is_purchase) as 'num_purchase',
  1.0 * sum(is_purchase) / count(user_id) AS 'quiz_to_purchase',
  1.0 * sum(is_purchase) / sum(is_home_try_on) as 'try_on_to_purchase',
  shape
  FROM funnels
  where shape = "Round"
UNION SELECT COUNT(user_id) as 'quiz_takers',
  SUM(is_home_try_on) as 'num_try_on',
  SUM(is_purchase) as 'num_purchase',
  1.0 * sum(is_purchase) / count(user_id) AS 'quiz_to_purchase',
  1.0 * sum(is_purchase) / sum(is_home_try_on) as 'try_on_to_purchase',
  shape
  FROM funnels
  where shape = "Rectangular"
UNION SELECT COUNT(user_id) as 'quiz_takers',
  SUM(is_home_try_on) as 'num_try_on',
  SUM(is_purchase) as 'num_purchase',
  1.0 * sum(is_purchase) / count(user_id) AS 'quiz_to_purchase',
  1.0 * sum(is_purchase) / sum(is_home_try_on) as 'try_on_to_purchase',
  shape
  FROM funnels
  where shape = "Square";