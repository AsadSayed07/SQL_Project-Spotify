# SPOTIFY - Advanced SQL Project

<img src="https://github.com/user-attachments/assets/c5edca67-d590-42a5-b890-5c18f5488436" width="1000" height="300">

## OVERVIEW
This project involves analyzing a Spotify dataset with various attributes about tracks, albums, and artists using **SQL**. It covers an end-to-end process of normalizing a denormalized dataset, performing SQL queries of varying complexity (easy, medium, and advanced), and optimizing query performance. The primary goals of the project are to practice advanced SQL skills and generate valuable insights from the dataset.

```sql
-- create table
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
```
## STEPS TAKEN TO DO THE PROJECT

### 1. DATA EXPLORATION
Before diving into SQL, it’s important to understand the dataset thoroughly. The dataset contains attributes such as:
- `Artist`: The performer of the track.
- `Track`: The name of the song.
- `Album`: The album to which the track belongs.
- `Album_type`: The type of album (e.g., single or album).
- Various metrics such as `danceability`, `energy`, `loudness`, `tempo`, and more.

### 2. QUERYING THE DATA
After the data is inserted, various SQL queries can be written to explore and analyze the data. Queries are categorized into **easy**, **medium**, and **advanced** levels to help progressively develop SQL proficiency.

#### Easy Queries
- Simple data retrieval, filtering, and basic aggregations.
  
#### Medium Queries
- More complex queries involving grouping, aggregation functions, and joins.
  
#### Advanced Queries
- Nested subqueries, window functions, CTEs, and performance optimization.

### 3. QUERY OPTIMIZATION
In advanced stages, the focus shifts to improving query performance. Some optimization strategies include:
- **Indexing**: Adding indexes on frequently queried columns.
- **Query Execution Plan**: Using `EXPLAIN ANALYZE` to review and refine query performance.
  
---

## 15 QUESTIONS SOLVED BELOW BASED ON THEIR DIFFICULTY LEVEL:

### Easy Level Questions
1. **Retrieve the names of all tracks that have more than 1 billion streams.**
```sql
SELECT track
FROM spotify
WHERE stream >= 1000000000;
```   
2. **List all albums along with their respective artists.**
```sql
SELECT DISTINCT album, artist
FROM spotify
ORDER BY album;
```
3. **Get the total number of comments for tracks where `licensed = TRUE`.**
```sql
SELECT sum(comments) AS total_comments
FROM spotify
WHERE licensed = true;
```
4. **Find all tracks that belong to the album type `single`.**
```sql
SELECT track
FROM spotify 
WHERE album_type = 'single';
```
5. **Count the total number of tracks by each artist.**
```sql
SELECT artist, COUNT(track) as total_no_tracks
FROM spotify
GROUP BY artist
ORDER BY 2 ;
```

### Medium Level Questions
1. **Calculate the average danceability of tracks in each album.**
```sql
SELECT album, AVG(danceability) as avg_danceability
FROM spotify
GROUP BY album
ORDER BY 2 DESC;
```
2. **Find the top 5 tracks with the highest energy values.**
```sql
SELECT track, MAX(energy) as energy_levels
FROM spotify
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;
```
3. **List all tracks along with their views and likes where `official_video = TRUE`.**
```sql
SELECT track, SUM(views) AS total_views,
SUM(likes) AS total_likes
FROM spotify
WHERE official_video = true
GROUP BY 1
ORDER BY 2 DESC;
```
4. **For each album, calculate the total views of all associated tracks.**
```sql
SELECT album, track, 
SUM(views) AS total_views
FROM spotify
GROUP BY 1, 2
ORDER BY 3 DESC;
```
5. **Retrieve the track names that have been streamed on Spotify more than YouTube.**
```sql
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
```   

### Advanced Level Questions
1. **Find the top 3 most-viewed tracks for each artist using window functions.**
```sql
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
```
2. **Write a query to find tracks where the liveness score is above the average.**
```sql
SELECT track, liveness
FROM spotify
WHERE liveness > (SELECT avg(liveness) as avg_liveness FROM spotify)
```
3. **Use a `WITH` clause to calculate the difference between the highest and lowest energy values for tracks in each album.**
```sql
WITH cte
AS
(SELECT 
	album,
	MAX(energy) as highest_energy,
	MIN(energy) as lowest_energery
FROM spotify
GROUP BY 1
)
SELECT 
	album,
	highest_energy - lowest_energery as energy_diff
FROM cte
ORDER BY 2 DESC
```

4. **Find tracks where the energy-to-liveness ratio is greater than 1.2.**
```sql
WITH t1 AS(
	SELECT track, energy/liveness as ratio
	FROM spotify
)

SELECT track, ratio
FROM t1
WHERE ratio > 1.2
ORDER BY ratio
```
5. **Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.**
```sql
WITH t1 AS(
	SELECT track, views, likes,
	SUM(likes) OVER (ORDER BY views) AS cum_likes
	FROM spotify
)

SELECT track, views, likes, cum_likes
FROM t1
ORDER BY cum_likes DESC
```

---

## QUERY OPTIMIZATION TECHNIQUE

To improve query performance,  the following optimization process was done:

- **INITIAL QUERY PERFORMANCE ANALYSIS USING `EXPLAIN`**
    - We began by analyzing the performance of a query using the `EXPLAIN` function.
    - The query retrieved tracks based on the `artist` column, and the performance metrics were as follows:
        - Planning time (P.T.): **0.26 ms**
        - Execution time (E.T.): **9.49 ms**
    - Below is the **screenshot** of the `EXPLAIN` result before optimization:
     ![image](https://github.com/user-attachments/assets/7c7460b5-9f1e-4abd-a962-27dace2f9f76)


- **INDEX CREATION ON THE `artist` COLUMN**
    - To optimize the query performance, we created an index on the `artist` column. This ensures faster retrieval of rows where the artist is queried.
    - **SQL command** for creating the index:
      ```sql
      CREATE INDEX artist_idx ON spotify (artist);
      ```

- **PERFORMANCE ANALYSIS AFTER INDEX CREATION**
    - After creating the index, we ran the same query again and observed significant improvements in performance:
        - Planning time (P.T.): **0.206 ms**
        - Execution time (E.T.): **0.151 ms**
    - Below is the **screenshot** of the `EXPLAIN` result after index creation:
      ![image](https://github.com/user-attachments/assets/5601da7f-cead-4609-b316-7656fd7277e6)


- **GRAPHICAL PERFORMANCE COMPARISON**
    - A graph illustrating the comparison between the initial query execution time and the optimized query execution time after index creation.
    - **Graph view** shows the significant drop in both execution and planning times:
      
    - **INITIAL QUERY EXECUTION**
      <img src="https://github.com/user-attachments/assets/e9e91e78-f019-4c1d-8c8b-4bc381fb7234" width="800" height="200">
      <img src="https://github.com/user-attachments/assets/26b87af5-b431-43f7-bd90-408dadf73c00" width="1000" height="200">
 
    - **OPTIMIZED QUERY EXECUTION**
      <img src="https://github.com/user-attachments/assets/ec2df7b2-13b9-4fe8-9339-ac412c0fb060" width="800" height="200">
      <img src="https://github.com/user-attachments/assets/1f0fb1ac-ecde-4961-a6f8-911f28e3b390" width="1000" height="200">

This optimization shows how indexing can drastically reduce query time, improving the overall performance of our database operations in this Spotify project.

---

## Technology Stack
- **Database**: PostgreSQL
- **SQL Queries**: DDL, DML, Aggregations, Joins, Subqueries, Window Functions
- **Tools**: pgAdmin 4 (or any SQL editor), PostgreSQL (via Homebrew, Docker, or direct installation)


