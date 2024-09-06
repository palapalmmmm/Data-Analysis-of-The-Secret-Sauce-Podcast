/*EXPLORING DATA*/
-- Check number of rows in table name videos
SELECT 
  count(*) AS num_rows 
FROM dbo.videos$

-- Shows all channel names in this data set. which is specified in the column channel_title in videos table
SELECT 
  distinct channel_title 
FROM dbo.videos$


/*DATA TRANSFORMATION*/
-- Count the number of videos split by the channel names THE SECRET SAUCE and THE STANDARD
SELECT 
  sum(CASE WHEN channel_title = 'THE SECRET SAUCE'THEN 1 ELSE null END) AS num_the_secret_sauce,
  sum(CASE WHEN channel_title = 'THE STANDARD' THEN 1 ELSE null END) AS num_the_standard
FROM dbo.videos$

-- Calculate the duration of each episode in seconds
SELECT
  duration,
  CAST(SUBSTRING(duration, 1 ,1) AS INT) AS hour,
  CAST(SUBSTRING(duration, 3 ,2) AS INT) AS minute,
  CAST(SUBSTRING(duration, 6 ,2) AS INT) AS second,
  
  CAST(SUBSTRING(duration, 1 ,1) AS INT)*60*60 + 
  CAST(SUBSTRING(duration, 3 ,2) AS INT)*60 + 
  CAST(SUBSTRING(duration, 6 ,2) AS INT) AS total_duration_seconds
FROM dbo.videos$

-- Convert the date_string column to year_string and the date column to year_int
SELECT 
  date, 
  SUBSTRING(date_string,1,4) AS year_string, 
  YEAR(date) AS year_int 
FROM dbo.videos$


/*DATA SUMMARIZATION*/
-- Count the number of rows from channel_title using the GROUP BY
SELECT 
  channel_title, 
  count(channel_title) AS num_rows 
FROM dbo.videos$ 
GROUP BY channel_title

-- Summarize the number of episodes released each year to observe the trend in show production
SELECT 
  YEAR(date) AS year,
  count(*) AS num_episodes
FROM dbo.videos$
GROUP BY YEAR(date)
ORDER BY year asc

-- Summarize the number of episodes released each month and the average number of views per month
SELECT 
  FORMAT(date, 'yyyy-MM') AS year_month,
  count(*) AS num_episodes,
  avg(view_count)  AS avg_views
FROM dbo.videos$
GROUP BY FORMAT(date, 'yyyy-MM')
ORDER BY year_month asc

-- Compare the distribution of view counts between The Secret Sauce and Executive Espresso
-- such as count, avg, min, max, standard deviation
SELECT 
  (CASE WHEN title LIKE '%The Secret Sauce%' THEN 'The Secret Sauce' ELSE 'Executive Espresso' END) AS show_title,
  count(*) AS n_episodes,
  avg(view_count) AS avg_view,
  min(view_count) AS min_view,
  max(view_count) AS max_view,
  STDEV(view_count) AS sd_view
FROM dbo.videos$ 
group by (CASE WHEN title LIKE '%The Secret Sauce%' THEN 'The Secret Sauce' ELSE 'Executive Espresso' END)

-- Summary of the number of episodes separated by video length
SELECT 
  CASE
    when CAST(SUBSTRING(duration, 1 ,1) AS INT)*60*60 + CAST(SUBSTRING(duration, 3 ,2) AS INT)*60 + CAST(SUBSTRING(duration, 6 ,2) AS INT) >= 60*60 then '60+ mins'
    when CAST(SUBSTRING(duration, 1 ,1) AS INT)*60*60 + CAST(SUBSTRING(duration, 3 ,2) AS INT)*60 + CAST(SUBSTRING(duration, 6 ,2) AS INT) >= 45*60 then '45-60 mins'
    when CAST(SUBSTRING(duration, 1 ,1) AS INT)*60*60 + CAST(SUBSTRING(duration, 3 ,2) AS INT)*60 + CAST(SUBSTRING(duration, 6 ,2) AS INT) >= 30*60 then '30-45 mins'
    when CAST(SUBSTRING(duration, 1 ,1) AS INT)*60*60 + CAST(SUBSTRING(duration, 3 ,2) AS INT)*60 + CAST(SUBSTRING(duration, 6 ,2) AS INT) >= 15*60 then '15-30 mins'
    else '0-15 mins'
  END AS duration_range_minutes,
  count(*) AS num_episodes
FROM dbo.videos$
GROUP BY 
CASE
  when CAST(SUBSTRING(duration, 1 ,1) AS INT)*60*60 + CAST(SUBSTRING(duration, 3 ,2) AS INT)*60 + CAST(SUBSTRING(duration, 6 ,2) AS INT) >= 60*60 then '60+ mins'
  when CAST(SUBSTRING(duration, 1 ,1) AS INT)*60*60 + CAST(SUBSTRING(duration, 3 ,2) AS INT)*60 + CAST(SUBSTRING(duration, 6 ,2) AS INT) >= 45*60 then '45-60 mins'
  when CAST(SUBSTRING(duration, 1 ,1) AS INT)*60*60 + CAST(SUBSTRING(duration, 3 ,2) AS INT)*60 + CAST(SUBSTRING(duration, 6 ,2) AS INT) >= 30*60 then '30-45 mins'
  when CAST(SUBSTRING(duration, 1 ,1) AS INT)*60*60 + CAST(SUBSTRING(duration, 3 ,2) AS INT)*60 + CAST(SUBSTRING(duration, 6 ,2) AS INT) >= 15*60 then '15-30 mins'
  else '0-15 mins'
END
ORDER BY duration_range_minutes


/*DATA COMBINE*/
-- Specify which videos fall into which business category
SELECT
  v.id AS video_id,
  v.title,
  coalesce(playlist_name,'Unspecified')  AS industry
FROM dbo.videos$ v
left join dbo.playlists$ p
on v.id = p.id

-- Calculate the average view count of each business category
-- and number of episodes each business category must be more than 5 episodes
SELECT 
  playlist_name,
  avg(view_count) AS avg_view
FROM dbo.videos$ v
JOIN dbo.playlists$ p
ON v.id = p.id
group by playlist_name
having count(playlist_name) >= 5
order by avg_view DESC