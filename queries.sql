WITH wordle_data AS (
    SELECT id, from_unixtime(createdat/1000) AS createdat, text, user.Id AS user_id, user.ScreenName, user.FollowersCount, retweet,
        regexp_extract(text, 'Wordle (\d+) (\d)/6', 1) AS wordle_index,
        CAST(regexp_extract(replace(text, 'X/6', '9/6'), 'Wordle (\d+) (\d)/6', 2) AS int) AS num_tries,
        regexp_extract_all(
            regexp_replace(text, '\u2B1C', '⬛'),
            '(\u2B1C|\u2B1B|\x{1F7E9}|\x{1F7E8})+'
        ) AS guess_blocks,
        cardinality(regexp_extract_all(text, '\x{1F7E8}')) as num_yellow_blocks,
        cardinality(regexp_extract_all(text, '\x{1F7E9}')) as num_green_blocks
    FROM "AwsDataCatalog"."default"."wordle_json"
    WHERE text LIKE '%Wordle %/6%'
        AND retweet=false
),

guess_block_stats AS (
    SELECT guess_blocks, COUNT(*) AS wordlets_207
    FROM wordle_data
    WHERE cardinality(guess_blocks) > 0
    GROUP BY 1
    ORDER BY 2 DESC
),

user_retention_1day AS (
    SELECT DATE(a.createdat) AS tweet_date,
        COUNT(distinct a.user_id) AS active_users,
        COUNT(distinct b.user_id) AS retained_users,
        COUNT(distinct b.user_id) / CAST(COUNT(distinct a.user_id) AS double) AS retention
    FROM wordle_data a
    LEFT JOIN wordle_data b ON 
        a.user_id = b.user_id
        AND DATE(a.createdat) = DATE(b.createdat) - interval '1' day
    GROUP BY 1
    ORDER BY 1
)

-- User retention
-- SELECT * FROM user_retention_1day

-- Number of unique people
-- SELECT COUNT(DISTINCT user_id) FROM wordle_data

-- Number of unique people per day
-- SELECT DATE(createdat), COUNT(DISTINCT user_id) FROM wordle_data GROUP BY 1 ORDER BY 1

-- Number of unique people per Wordle
SELECT * FROM (SELECT wordle_index, COUNT(DISTINCT user_id) as unique_users FROM wordle_data GROUP BY 1 ORDER BY 1) WHERE unique_users > 1000 AND wordle_index IS NOT NULL

-- Number of people that _didn't_ get the wordle
-- SELECT COUNT(*) FROM wordle_data WHERE num_tries = 9 LIMIT 100

-- Number of tweets
-- SELECT COUNT(*) FROM wordle_data WHERE num_tries BETWEEN 1 AND 6

-- Sampling
-- SELECT * FROM wordle_data LIMIT 100

-- Unique guesses
-- SELECT COUNT(*) from guess_block_stats where wordlets_206 = 1

-- Guess block buddies
-- SELECT * FROM guess_block_stats LIMIT 10

-- Number of tries
-- SELECT num_tries, COUNT(*) AS num_tweets FROM wordle_data WHERE num_tries BETWEEN 1 AND 6 OR num_tries=9 GROUP BY 1 ORDER BY 1

-- Wordle buddies
-- SELECT * FROM wordle_data WHERE guess_blocks = split('⬛🟩⬛⬛⬛,⬛🟩⬛🟨⬛,⬛🟩🟩⬛⬛,🟩🟩🟩🟩🟩',',') ORDER BY createdat ASC

-- First Wordle of the day
--SELECT * FROM wordle_data ORDER BY createdat LIMIT 10

-- Overall count
-- SELECT COUNT(*) FROM wordle_json

-- Average tries per wordle
-- SELECT wordle_index, COUNT(DISTINCT user_id) AS unique_users, AVG(num_tries) AS mean_tries FROM wordle_data WHERE num_tries BETWEEN 1 AND 6 AND TRY_CAST(wordle_index AS INT) BETWEEN 206 and 213 GROUP BY 1 ORDER BY 1 ASC

-- Figuring out number of blocks...
-- SELECT wordle_index, COUNT(DISTINCT user_id) AS unique_users, AVG(num_tries) AS mean_tries, AVG(num_yellow_blocks) AS mean_yellow_blocks, AVG(num_green_blocks) AS mean_green_blocks FROM wordle_data WHERE num_tries BETWEEN 1 AND 6 AND TRY_CAST(wordle_index AS INT) BETWEEN 206 and 227 GROUP BY 1 ORDER BY 1 ASC