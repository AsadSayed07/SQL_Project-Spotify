-- ADVANCED SQL PROJECT - SPOTIFY

--CREATING THE TABLE
DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);


-- EXPLORATORY DATA ANALYSIS (EDA)
SELECT COUNT(*) 
FROM spotify;

SELECT COUNT(DISTINCT artist)
FROM spotify;

SELECT COUNT(DISTINCT album)
FROM spotify;

SELECT DISTINCT album_type
FROM spotify;

SELECT MAX(duration_min)
FROM spotify;
SELECT MIN(duration_min)
FROM spotify;

SELECT * 
FROM spotify
WHERE duration_min = 0;

-- DELETING SONGS THAT HAVE 0 MINS DURATION TIME
DELETE
FROM spotify
WHERE duration_min = 0

SELECT DISTINCT channel
FROM spotify;

SELECT DISTINCT most_played_on
FROM spotify;

-- ---------------------
-- Data Analysis -- Easy 
-- ---------------------


-- Retrieve the name of all tracks that have 1 Billion Streams.
-- List all albums along with their respective artists.
-- Get the total number of comments for tracks where licensed = TRUE
-- Find all tracks that belong to the album type "single"
-- Count the total number of tracks by each artist


-- Q.1. Retrieve the name of all tracks that have 1 Billion Streams.
SELECT track
FROM spotify
WHERE stream >= 1000000000;


-- Q.2. List all albums along with their respective artists.
SELECT DISTINCT album, artist
FROM spotify
ORDER BY album;


-- Q.3. Get the total number of comments for tracks where licensed = TRUE
SELECT sum(comments) AS total_comments
FROM spotify
WHERE licensed = true;


-- Q.4. Find all tracks that belong to the album type "single"
SELECT track
FROM spotify 
WHERE album_type = 'single';


-- Q.5. Count the total number of tracks by each artist
SELECT artist, COUNT(track) as total_no_tracks
FROM spotify
GROUP BY artist
ORDER BY 2 ;



-- ------------------------
-- Data Analysis -- Medium
-- ------------------------

-- Calculate the avergae danceability of tracks in each album.
-- Find the top 5 tracks with the highest energy values
-- List all tracks along with their views and likes where official_video = True.
-- For each album, calculate the total views of all associated tracks.
-- Retrieve the track names that have been streamed on Spotify more than Youtube.


-- Q.6. Calculate the average danceability of tracks in each album.
SELECT album, AVG(danceability) as avg_danceability
FROM spotify
GROUP BY album
ORDER BY 2 DESC;


-- Q.7. Find the top 5 tracks with the highest energy values
SELECT track, MAX(energy) as energy_levels
FROM spotify
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;


-- Q.8. List all tracks along with their views and likes where official_video = True.
SELECT track, SUM(views) AS total_views,
SUM(likes) AS total_likes
FROM spotify
WHERE official_video = true
GROUP BY 1
ORDER BY 2 DESC;


-- Q.9. For each album, calculate the total views of all associated tracks.
SELECT album, track, 
SUM(views) AS total_views
FROM spotify
GROUP BY 1, 2
ORDER BY 3 DESC;


-- Q.10. Retrieve the track names that have been streamed on Spotify more than Youtube.
WITH t1 AS (
	SELECT track, 
	--- most_played_on,
	COALESCE(SUM(CASE WHEN most_played_on = 'Spotify' THEN stream END),0) as streamed_on_spotify,
	COALESCE(SUM(CASE WHEN most_played_on = 'Youtube' THEN stream END),0) as streamed_on_youtube
	FROM spotify
	GROUP BY 1)

SELECT track, streamed_on_spotify, streamed_on_youtube
FROM t1 
WHERE streamed_on_spotify > streamed_on_youtube
AND streamed_on_youtube != 0;



-- --------------------------
-- Data Analysis -- Advanced
-- --------------------------

-- Find the top 3 most_viewed tracks for each artist using windows function.
-- Write a query to find tracks where the liveness score is above the average.
-- Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
-- Find tracks where the energy-to-liveness ratio is greater thsn 1.2
-- Calculate the cumulative sum of likes for tracks ordered by the number of views, using windows function.


-- Q.11. Find the top 3 most_viewed tracks for each artist using windows function.
WITH t1 AS(
	SELECT 
	DENSE_RANK() OVER (PARTITION BY artist ORDER BY SUM(views) DESC) as ranking,
	artist,
	track, 
	sum(views) AS total_views
	FROM spotify
	GROUP BY 2,3)

SELECT ranking, artist, track, total_views
FROM t1
WHERE ranking < 4


-- Q.12. Write a query to find tracks where the liveness score is above the average.
--Average Liveness = 0.19367208624708632

SELECT track, liveness
FROM spotify
WHERE liveness > (SELECT avg(liveness) as avg_liveness FROM spotify)


-- Q.13. Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
WITH t1 AS(
	SELECT album,
	MAX(energy) AS highest_energy,
	MIN(energy) AS lowest_energy
	FROM spotify
	GROUP BY 1
	ORDER BY 1
)

SELECT album,
highest_energy - lowest_energy AS difference
FROM t1


-- Q.14. Find tracks where the energy-to-liveness ratio is greater than 1.2
WITH t1 AS(
	SELECT track, energy/liveness as ratio
	FROM spotify
)

SELECT track, ratio
FROM t1
WHERE ratio > 1.2
ORDER BY ratio


-- Q.15. Calculate the cumulative sum of likes for tracks ordered by the number of views, using windows function.
WITH t1 AS(
	SELECT track, views, likes,
	SUM(likes) OVER (ORDER BY views) AS cum_likes
	FROM spotify
)

SELECT track, views, likes, cum_likes
FROM t1
ORDER BY cum_likes DESC


-- QUERY OPTIMIZATION

EXPLAIN ANALYZE  -- PT: 0.26ms  ET:9.49ms
SELECT artist, track, views 
FROM spotify
WHERE artist = 'Gorillaz'
AND
most_played_on = 'Youtube'
ORDER BY stream DESC
LIMIT 25;


CREATE INDEX artist_idx ON spotify (artist);





