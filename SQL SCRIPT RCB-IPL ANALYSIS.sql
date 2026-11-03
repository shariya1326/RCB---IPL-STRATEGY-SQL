/* =====================================================================
   RCB IPL STRATEGY — STUDENT ANSWER TEMPLATE
   ===================================================================== */

USE ipl;


/* =====================================================================
   OBJECTIVE QUESTIONS
   ===================================================================== */

-- O1
-- List the different dtypes of columns in table "ball_by_ball" (using
-- information schema)

SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, COLUMN_KEY
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'ipl' AND TABLE_NAME = 'Ball_by_Ball';

-- O2
-- What is the total number of runs scored in 1st season by RCB (bonus: also
-- include the extra runs using the extra runs table)

SELECT 
SUM(bs.Runs_Scored) AS bat_runs, 
SUM(COALESCE(er.Extra_Runs, 0)) AS extra_runs,
SUM(bs.Runs_Scored) + SUM(COALESCE(er.Extra_Runs, 0)) AS total_with_extras
FROM Batsman_Scored bs
JOIN Ball_by_Ball bb
    ON bs.Match_Id = bb.Match_Id 
    AND bs.Over_Id = bb.Over_Id
    AND bs.Ball_Id = bb.Ball_Id
    AND bs.Innings_No = bb.Innings_No
JOIN Matches m
    ON bb.Match_Id = m.Match_Id
LEFT JOIN Extra_Runs er
    ON bs.Match_Id = er.Match_Id
    AND bs.Over_Id = er.Over_Id
    AND bs.Ball_Id = er.Ball_Id
    AND bs.Innings_No = er.Innings_No
WHERE bb.Team_Batting = 2 AND m.Season_Id = 1;


-- O3
-- How many players were more than the age of 25 during season 2014?

SELECT COUNT(DISTINCT p.Player_Id) AS players_over_25_in_2014
FROM Player p
JOIN Player_Match pm ON p.Player_Id = pm.Player_Id
JOIN Matches m ON pm.Match_Id = m.Match_Id
JOIN Season s ON m.Season_Id = s.Season_Id
WHERE s.Season_Year = 2014 AND TIMESTAMPDIFF(YEAR, p.DOB, m.Match_Date) > 25;
  
  

-- O4
-- How many matches did RCB win in 2013?

SELECT COUNT(*) AS rcb_wins_2013
FROM Matches m
JOIN Season s ON m.Season_Id = s.Season_Id
WHERE s.Season_Year = 2013 AND m.Match_Winner = 2;

-- O5
-- List the top 10 players according to their strike rate in the last 4
-- seasons

SELECT
    p.Player_Name,
    SUM(bs.Runs_Scored) AS runs,
    COUNT(*) AS balls_faced,
    ROUND(SUM(bs.Runs_Scored) * 100.0 / COUNT(*), 2) AS strike_rate
FROM Ball_by_Ball b
JOIN Batsman_Scored bs
    ON b.Match_Id = bs.Match_Id
    AND b.Over_Id = bs.Over_Id
    AND b.Ball_Id = bs.Ball_Id
    AND b.Innings_No = bs.Innings_No
JOIN Matches m
    ON b.Match_Id = m.Match_Id
JOIN Season s
    ON m.Season_Id = s.Season_Id
JOIN Player p
    ON b.Striker = p.Player_Id
WHERE s.Season_Year >= (SELECT MAX(Season_Year) - 3 FROM Season)
GROUP BY p.Player_Id, p.Player_Name
ORDER BY strike_rate DESC
LIMIT 10;

-- O6
-- What are the average runs scored by each batsman considering all the
-- seasons?

SELECT
    p.Player_Name,
    SUM(bs.Runs_Scored) AS total_runs,
    COUNT(DISTINCT b.Match_Id) AS matches,
    ROUND(SUM(bs.Runs_Scored) * 1.0 / COUNT(DISTINCT b.Match_Id), 2) AS avg_runs_per_match
FROM Ball_by_Ball b
JOIN Batsman_Scored bs
    ON b.Match_Id = bs.Match_Id
    AND b.Over_Id = bs.Over_Id
    AND b.Ball_Id = bs.Ball_Id
    AND b.Innings_No = bs.Innings_No
JOIN Player p
    ON b.Striker = p.Player_Id
GROUP BY p.Player_Id, p.Player_Name
ORDER BY avg_runs_per_match DESC;

-- O7
-- What are the average wickets taken by each bowler considering all the
-- seasons?

SELECT
    p.Player_Name,
    COUNT(*) AS total_wickets,
    COUNT(DISTINCT w.Match_Id) AS matches,
    ROUND(COUNT(*) * 1.0 / COUNT(DISTINCT w.Match_Id), 2) AS avg_wickets_per_match
FROM Wicket_Taken w
JOIN Ball_by_Ball b
    ON w.Match_Id = b.Match_Id
    AND w.Over_Id = b.Over_Id
    AND w.Ball_Id = b.Ball_Id
    AND w.Innings_No = b.Innings_No
JOIN Player p
    ON b.Bowler = p.Player_Id
GROUP BY p.Player_Id, p.Player_Name
ORDER BY avg_wickets_per_match DESC;

-- O8
-- List all the players who have average runs scored greater than the overall
-- average and who have taken wickets greater than the overall average

WITH player_runs AS (
    SELECT
        b.Striker AS Player_Id,
        SUM(bs.Runs_Scored) AS Total_Runs,
        COUNT(DISTINCT CONCAT(b.Match_Id, '-', b.Innings_No)) AS Innings_Played
    FROM Ball_by_Ball b
    JOIN Batsman_Scored bs
        ON b.Match_Id = bs.Match_Id
        AND b.Over_Id = bs.Over_Id
        AND b.Ball_Id = bs.Ball_Id
        AND b.Innings_No = bs.Innings_No
    GROUP BY b.Striker
),
player_avg_runs AS (
    SELECT Player_Id, Total_Runs * 1.0 / Innings_Played AS avg_runs FROM player_runs
),
player_wickets AS (
    SELECT b.Bowler AS Player_Id, COUNT(*) * 1.0 / COUNT(DISTINCT w.Match_Id) AS avg_wkts
    FROM Ball_by_Ball b
    JOIN Wicket_Taken w
        ON b.Match_Id = w.Match_Id
        AND b.Over_Id = w.Over_Id
        AND b.Ball_Id = w.Ball_Id
        AND b.Innings_No = w.Innings_No
    GROUP BY b.Bowler
),
overall AS (
    SELECT
        (SELECT AVG(avg_runs) FROM player_avg_runs) AS overall_avg_runs,
        (SELECT AVG(avg_wkts) FROM player_wickets) AS overall_avg_wkts
)
SELECT
    p.Player_Name, ROUND(r.avg_runs, 2) AS avg_runs, ROUND(w.avg_wkts, 2) AS avg_wkts
FROM player_avg_runs r
JOIN player_wickets w
    ON r.Player_Id = w.Player_Id
JOIN Player p
    ON p.Player_Id = r.Player_Id
CROSS JOIN overall o
WHERE r.avg_runs > o.overall_avg_runs AND w.avg_wkts > o.overall_avg_wkts
ORDER BY r.avg_runs DESC;

-- O9
-- Create a table rcb_record table that shows the wins and losses of RCB in an
-- individual venue.

DROP TABLE IF EXISTS rcb_record;

CREATE TABLE rcb_record
(
    Venue_Id INT,
    Venue_Name VARCHAR(100),
    Wins INT DEFAULT 0,
    Losses INT DEFAULT 0
);
INSERT INTO rcb_record (Venue_Id, Venue_Name, Wins, Losses)
SELECT m.Venue_Id, v.Venue_Name,
    SUM(CASE
        WHEN m.Match_Winner = 2 THEN 1
        ELSE 0
    END) AS Wins,
    SUM(CASE
        WHEN m.Match_Winner IS NOT NULL AND m.Match_Winner <> 2 THEN 1
        ELSE 0
    END) AS Losses
FROM Matches m
JOIN Venue v
    ON m.Venue_Id = v.Venue_Id
WHERE m.Team_1 = 2 OR m.Team_2 = 2
GROUP BY m.Venue_Id, v.Venue_Name
ORDER BY Wins DESC, Losses ASC;

-- O10
-- What is the impact of bowling style on wickets taken?

SELECT
    bs.Bowling_skill AS bowling_style,
    COUNT(w.Player_Out) AS total_wickets,
    COUNT(DISTINCT p.Player_Id) AS num_bowlers,
    ROUND(COUNT(w.Player_Out) * 1.0 / COUNT(DISTINCT p.Player_Id),2) AS wickets_per_bowler
FROM Wicket_Taken w
JOIN Ball_by_Ball b
    ON w.Match_Id = b.Match_Id
    AND w.Over_Id = b.Over_Id
    AND w.Ball_Id = b.Ball_Id
    AND w.Innings_No = b.Innings_No
JOIN Player p
ON b.Bowler = p.Player_Id
JOIN Bowling_Style bs
ON p.Bowling_skill = bs.Bowling_Id
GROUP BY bs.Bowling_Id, bs.Bowling_skill
ORDER BY total_wickets DESC;


-- O11
-- Write the SQL query to provide a status of whether the performance of the
-- team is better than the previous year's performance on the basis of the
-- number of runs scored by the team in the season and the number of
-- wickets taken

WITH season_runs AS (
    SELECT m.Season_Id, s.Season_Year, SUM(bs.Runs_Scored) AS runs
    FROM Ball_by_Ball b
    JOIN Batsman_Scored bs
        ON b.Match_Id = bs.Match_Id
        AND b.Over_Id = bs.Over_Id
        AND b.Ball_Id = bs.Ball_Id
        AND b.Innings_No = bs.Innings_No
    JOIN Matches m
        ON b.Match_Id = m.Match_Id
    JOIN Season s
        ON m.Season_Id = s.Season_Id
    WHERE b.Team_Batting = 2
    GROUP BY m.Season_Id, s.Season_Year
),

season_wickets AS (
    SELECT m.Season_Id, s.Season_Year, COUNT(w.Player_Out) AS wkts
    FROM Ball_by_Ball b
    JOIN Wicket_Taken w
        ON b.Match_Id = w.Match_Id
        AND b.Over_Id = w.Over_Id
        AND b.Ball_Id = w.Ball_Id
        AND b.Innings_No = w.Innings_No
    JOIN Matches m
        ON b.Match_Id = m.Match_Id
    JOIN Season s
        ON m.Season_Id = s.Season_Id
    WHERE b.Team_Bowling = 2
    GROUP BY m.Season_Id, s.Season_Year
),

season_performance AS (
    SELECT r.Season_Year, r.runs, w.wkts,
        LAG(r.runs) OVER (ORDER BY r.Season_Year) AS prev_runs,
        LAG(w.wkts) OVER (ORDER BY r.Season_Year) AS prev_wkts
    FROM season_runs r
    JOIN season_wickets w
        ON r.Season_Id = w.Season_Id
)

SELECT Season_Year, runs, wkts,
    runs - prev_runs AS runs_vs_prev,
    wkts - prev_wkts AS wkts_vs_prev,
    CASE
        WHEN runs > prev_runs AND wkts > prev_wkts THEN 'Better'
        WHEN runs < prev_runs AND wkts < prev_wkts THEN 'Worse'
        ELSE 'Mixed'
    END AS performance_status
FROM season_performance
WHERE Season_Year BETWEEN 2013 AND 2016
ORDER BY Season_Year;

-- O12
-- Can you derive more KPIs for the team strategy?

-- 1) RCB Win % by Season

SELECT s.Season_Year, COUNT(*) AS played,
    SUM(CASE
        WHEN m.Match_Winner = 2 THEN 1
        ELSE 0
    END) AS wins,
    ROUND(SUM(CASE
            WHEN m.Match_Winner = 2 THEN 1
            ELSE 0
        END) * 100.0 / COUNT(*),
        2
    ) AS win_pct
FROM Matches m
JOIN Season s
    ON m.Season_Id = s.Season_Id
WHERE s.Season_Year BETWEEN 2013 AND 2016 AND (m.Team_1 = 2 OR m.Team_2 = 2)
GROUP BY s.Season_Year
ORDER BY s.Season_Year;

-- 2) Boundary reliance — % of RCB runs from 4s and 6s

SELECT
    ROUND(SUM(
            CASE
                WHEN bs.Runs_Scored = 4 THEN 4
                WHEN bs.Runs_Scored = 6 THEN 6
                ELSE 0
            END
        ) * 100.0 / SUM(bs.Runs_Scored),
        2
    ) AS pct_runs_from_boundaries
FROM Ball_by_Ball b
JOIN Batsman_Scored bs
    ON b.Match_Id = bs.Match_Id
    AND b.Over_Id = bs.Over_Id
    AND b.Ball_Id = bs.Ball_Id
    AND b.Innings_No = bs.Innings_No
WHERE b.Team_Batting = 2;

-- 3) RCB Top 5 run-scorers

SELECT p.Player_Name, SUM(bs.Runs_Scored) AS runs
FROM Ball_by_Ball b
JOIN Batsman_Scored bs
    ON b.Match_Id = bs.Match_Id
    AND b.Over_Id = bs.Over_Id
    AND b.Ball_Id = bs.Ball_Id
    AND b.Innings_No = bs.Innings_No
JOIN Player p
    ON b.Striker = p.Player_Id
WHERE b.Team_Batting = 2
GROUP BY p.Player_Id, p.Player_Name
ORDER BY runs DESC
LIMIT 5;

-- O13
-- Using SQL, write a query to find out the average wickets taken by each
-- bowler in each venue. Also, rank the gender according to the average
-- value.

WITH bowler_venue AS (SELECT v.Venue_Name, p.Player_Id, p.Player_Name,
        COUNT(w.Player_Out) AS wickets,
        COUNT(w.Player_Out) * 1.0 / COUNT(DISTINCT w.Match_Id) AS avg_wickets
    FROM Wicket_Taken w
    JOIN Ball_by_Ball b
        ON w.Match_Id = b.Match_Id
        AND w.Over_Id = b.Over_Id
        AND w.Ball_Id = b.Ball_Id
        AND w.Innings_No = b.Innings_No
    JOIN Player p ON b.Bowler = p.Player_Id
    JOIN Matches m ON w.Match_Id = m.Match_Id
    JOIN Venue v ON m.Venue_Id = v.Venue_Id
    GROUP BY v.Venue_Id, v.Venue_Name, p.Player_Id, p.Player_Name
)
SELECT Venue_Name, Player_Name, wickets,
    ROUND(avg_wickets, 2) AS avg_wickets,
    DENSE_RANK() OVER (PARTITION BY Venue_Name ORDER BY avg_wickets DESC) AS venue_rank
FROM bowler_venue
ORDER BY Venue_Name, venue_rank, Player_Name;

-- O14
-- Which of the given players have consistently performed well in past
-- seasons? (will you use any visualization to solve the problem)

WITH seasonal_runs AS (
    SELECT
        b.Striker AS Player_Id,
        s.Season_Year,
        SUM(bs.Runs_Scored) AS runs
    FROM Ball_by_Ball b
    JOIN Batsman_Scored bs
        ON b.Match_Id = bs.Match_Id
        AND b.Over_Id = bs.Over_Id
        AND b.Ball_Id = bs.Ball_Id
        AND b.Innings_No = bs.Innings_No
    JOIN Matches m
        ON b.Match_Id = m.Match_Id
    JOIN Season s
        ON m.Season_Id = s.Season_Id
    WHERE s.Season_Year BETWEEN 2013 AND 2016
    GROUP BY
        b.Striker,
        s.Season_Year
),

player_summary AS (
    SELECT
        Player_Id,
        COUNT(*) AS seasons_played,
        AVG(runs) AS avg_runs_per_season,
        MIN(runs) AS min_runs,
        MAX(runs) AS max_runs,
        STDDEV_POP(runs) AS runs_stddev
    FROM seasonal_runs
    GROUP BY Player_Id
    HAVING COUNT(*) = 4
)

SELECT
    p.Player_Name,
    ps.seasons_played,
    ROUND(ps.avg_runs_per_season, 2) AS avg_runs_per_season,
    MIN(
        CASE
            WHEN sr.runs = ps.min_runs
            THEN sr.Season_Year
        END
    ) AS worst_season,
    MIN(
        CASE
            WHEN sr.runs = ps.max_runs
            THEN sr.Season_Year
        END
    ) AS best_season,
    ROUND(ps.runs_stddev, 2) AS runs_stddev
FROM player_summary ps
JOIN Player p
    ON ps.Player_Id = p.Player_Id
JOIN seasonal_runs sr
    ON ps.Player_Id = sr.Player_Id
GROUP BY
    p.Player_Id,
    p.Player_Name,
    ps.seasons_played,
    ps.avg_runs_per_season,
    ps.min_runs,
    ps.max_runs,
    ps.runs_stddev
ORDER BY
    ps.avg_runs_per_season DESC;

-- O15
-- Are there players whose performance is more suited to specific venues or
-- conditions? (how would you present this using charts?)

SELECT
    p.Player_Name,
    v.Venue_Name,
    SUM(bs.Runs_Scored) AS runs,
    COUNT(*) AS balls,
    ROUND(SUM(bs.Runs_Scored) * 100.0 / COUNT(*),2) AS strike_rate
FROM Ball_by_Ball b
JOIN Batsman_Scored bs
    ON b.Match_Id = bs.Match_Id
    AND b.Over_Id = bs.Over_Id
    AND b.Ball_Id = bs.Ball_Id
    AND b.Innings_No = bs.Innings_No
JOIN Matches m ON b.Match_Id = m.Match_Id
JOIN Venue v ON m.Venue_Id = v.Venue_Id
JOIN Player p ON b.Striker = p.Player_Id
GROUP BY p.Player_Id, p.Player_Name, v.Venue_Id, v.Venue_Name
HAVING COUNT(*) >= 60
ORDER BY strike_rate DESC
LIMIT 25;


/* =====================================================================
   SUBJECTIVE QUESTIONS
   ===================================================================== */

-- S1
-- How does the toss decision affect the result of the match? (which
-- visualizations could be used to present your answer better) And is the
-- impact limited to only specific venues?

-- Overall Toss Impact
SELECT td.Toss_Name AS Toss_Decision, COUNT(*) AS Total_Matches,
    SUM(CASE
            WHEN m.Toss_Winner = m.Match_Winner THEN 1
            ELSE 0 END
    ) AS Matches_Won_After_Toss,
    ROUND(SUM(
            CASE
                WHEN m.Toss_Winner = m.Match_Winner THEN 1
                ELSE 0 END
        ) * 100.0 / COUNT(*),
        2
    ) AS Win_Percentage
FROM Matches m
JOIN Toss_Decision td
    ON m.Toss_Decide = td.Toss_Id
WHERE m.Match_Winner IS NOT NULL
GROUP BY td.Toss_Id, td.Toss_Name
ORDER BY Win_Percentage DESC;

-- Does the Impact Vary by Venue?
SELECT td.Toss_Name AS Toss_Decision, v.Venue_Name,
    COUNT(*) AS Total_Matches,
    SUM(CASE
            WHEN m.Toss_Winner = m.Match_Winner THEN 1
            ELSE 0 END
    ) AS Matches_Won_After_Toss,
    ROUND(SUM(
            CASE
                WHEN m.Toss_Winner = m.Match_Winner THEN 1
                ELSE 0 END
        ) * 100.0 / COUNT(*),
        2
    ) AS Win_Percentage
FROM Matches m
JOIN Toss_Decision td
    ON m.Toss_Decide = td.Toss_Id
JOIN Venue v
    ON m.Venue_Id = v.Venue_Id
WHERE m.Match_Winner IS NOT NULL
GROUP BY td.Toss_Id, td.Toss_Name, v.Venue_Id, v.Venue_Name
ORDER BY v.Venue_Name, Win_Percentage DESC;

-- S2
-- Suggest some of the players who would be best fit for the team.

-- Identify strong batsman
SELECT
    p.Player_Name,
    SUM(bs.Runs_Scored) AS total_runs,
    COUNT(*) AS balls_faced,
    ROUND(SUM(bs.Runs_Scored) * 100.0 / COUNT(*), 2) AS strike_rate
FROM Player p
JOIN Ball_by_Ball b
    ON p.Player_Id = b.Striker
JOIN Batsman_Scored bs
    ON b.Match_Id = bs.Match_Id
    AND b.Over_Id = bs.Over_Id
    AND b.Ball_Id = bs.Ball_Id
    AND b.Innings_No = bs.Innings_No
JOIN Matches m
    ON b.Match_Id = m.Match_Id
JOIN Season s
    ON m.Season_Id = s.Season_Id
WHERE s.Season_Year BETWEEN 2013 AND 2016
GROUP BY p.Player_Id, p.Player_Name
HAVING COUNT(*) >= 100
ORDER BY strike_rate DESC
LIMIT 10;

-- Identify strong bowler
SELECT p.Player_Name, COUNT(*) AS total_wickets
FROM Player p
JOIN Ball_by_Ball b
    ON p.Player_Id = b.Bowler
JOIN Wicket_Taken w
    ON b.Match_Id = w.Match_Id
    AND b.Over_Id = w.Over_Id
    AND b.Ball_Id = w.Ball_Id
    AND b.Innings_No = w.Innings_No
JOIN Matches m
    ON b.Match_Id = m.Match_Id
JOIN Season s
    ON m.Season_Id = s.Season_Id
WHERE s.Season_Year BETWEEN 2013 AND 2016
GROUP BY p.Player_Id, p.Player_Name
ORDER BY total_wickets DESC
LIMIT 10;

-- S3
-- What are some of the parameters that should be focused on while selecting
-- the players?

-- Answer: There was no need of query, i have answered the question with subjective parameters.

-- S4
-- Which players offer versatility in their skills and can contribute
-- effectively with both bat and ball? (can you visualize the data for the
-- same)

SELECT p.Player_Name,
    COALESCE(batting.Total_Runs, 0) AS Total_Runs,
    COALESCE(bowling.Total_Wickets, 0) AS Total_Wickets
FROM Player p
LEFT JOIN (
    SELECT
        b.Striker AS Player_Id,
        SUM(bs.Runs_Scored) AS Total_Runs
    FROM Ball_by_Ball b
    JOIN Batsman_Scored bs
        ON b.Match_Id = bs.Match_Id
        AND b.Over_Id = bs.Over_Id
        AND b.Ball_Id = bs.Ball_Id
        AND b.Innings_No = bs.Innings_No
    GROUP BY b.Striker
) AS batting
    ON p.Player_Id = batting.Player_Id
LEFT JOIN (
    SELECT
        b.Bowler AS Player_Id,
        COUNT(*) AS Total_Wickets
    FROM Ball_by_Ball b
    JOIN Wicket_Taken w
        ON b.Match_Id = w.Match_Id
        AND b.Over_Id = w.Over_Id
        AND b.Ball_Id = w.Ball_Id
        AND b.Innings_No = w.Innings_No
    WHERE w.Kind_Out IN (1,2,4,6,7,8)
    GROUP BY b.Bowler
) AS bowling
ON p.Player_Id = bowling.Player_Id
WHERE COALESCE(batting.Total_Runs, 0) >= 200
AND COALESCE(bowling.Total_Wickets, 0) >= 15
ORDER BY Total_Runs DESC, Total_Wickets DESC;

-- S5
-- Are there players whose presence positively influences the morale and
-- performance of the team? (justify your answer using visualization)

SELECT
    p.Player_Name,
    COUNT(pm.Match_Id) AS matches_played,
    SUM(CASE WHEN m.Match_Winner = 2 THEN 1 ELSE 0 END) AS wins,
    ROUND(SUM(CASE WHEN m.Match_Winner = 2 THEN 1 ELSE 0 END)
        * 100.0 / COUNT(pm.Match_Id),
        2
    ) AS win_percentage
FROM Player_Match pm
JOIN Player p
    ON pm.Player_Id = p.Player_Id
JOIN Matches m
    ON pm.Match_Id = m.Match_Id
WHERE pm.Team_Id = 2 AND m.Match_Winner IS NOT NULL
GROUP BY p.Player_Id, p.Player_Name
HAVING COUNT(pm.Match_Id) >= 10
ORDER BY win_percentage DESC;

-- RCB's Overall win percentage
SELECT
    COUNT(*) AS total_matches,
    SUM(CASE WHEN Match_Winner = 2 THEN 1 ELSE 0 END) AS total_wins,
    ROUND(SUM(CASE WHEN Match_Winner = 2 THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS rcb_win_percentage
FROM Matches
WHERE (Team_1 = 2 OR Team_2 = 2) AND Match_Winner IS NOT NULL;

-- S6
-- What would you suggest to RCB before going to the mega auction?

-- Answer: This was analyzed with theoretical analysis. No need of query

-- S7
-- What do you think could be the factors contributing to the high-scoring
-- matches and the impact on viewership and team strategies

-- Top 10 High-Scoring Matches
WITH batting AS (
    SELECT
        Match_Id,
        SUM(Runs_Scored) AS Batting_Runs,
        SUM(CASE WHEN Runs_Scored = 4 THEN 1 ELSE 0 END) AS Fours,
        SUM(CASE WHEN Runs_Scored = 6 THEN 1 ELSE 0 END) AS Sixes
    FROM Batsman_Scored
    GROUP BY Match_Id
),
extras AS (
    SELECT
        Match_Id,
        SUM(Extra_Runs) AS Extra_Runs
    FROM Extra_Runs
    GROUP BY Match_Id
)
SELECT
    m.Match_Id,
    s.Season_Year,
    v.Venue_Name,
    COALESCE(b.Batting_Runs, 0) AS Batting_Runs,
    COALESCE(e.Extra_Runs, 0) AS Extra_Runs,
    COALESCE(b.Batting_Runs, 0) + COALESCE(e.Extra_Runs, 0) AS Total_Runs,
    COALESCE(b.Fours, 0) AS Fours,
    COALESCE(b.Sixes, 0) AS Sixes
FROM Matches m
JOIN Season s
    ON m.Season_Id = s.Season_Id
JOIN Venue v
    ON m.Venue_Id = v.Venue_Id
LEFT JOIN batting b
    ON m.Match_Id = b.Match_Id
LEFT JOIN extras e
    ON m.Match_Id = e.Match_Id
ORDER BY Total_Runs DESC
LIMIT 10;

-- Venue Analysis
WITH batting AS (SELECT Match_Id, Over_Id, Ball_Id, Innings_No,
        SUM(Runs_Scored) AS Batting_Runs
    FROM Batsman_Scored
    GROUP BY Match_Id, Over_Id, Ball_Id, Innings_No
),
extras AS (SELECT Match_Id, Over_Id, Ball_Id, Innings_No,
        SUM(Extra_Runs) AS Extra_Runs
    FROM Extra_Runs
    GROUP BY Match_Id, Over_Id, Ball_Id, Innings_No
),
ball_runs AS (SELECT b.Match_Id, b.Over_Id, b.Ball_Id, b.Innings_No,
        COALESCE(bs.Batting_Runs, 0)
        + COALESCE(er.Extra_Runs, 0) AS Total_Runs
    FROM Ball_by_Ball b
    LEFT JOIN batting bs
        ON b.Match_Id = bs.Match_Id
        AND b.Over_Id = bs.Over_Id
        AND b.Ball_Id = bs.Ball_Id
        AND b.Innings_No = bs.Innings_No
    LEFT JOIN extras er
        ON b.Match_Id = er.Match_Id
        AND b.Over_Id = er.Over_Id
        AND b.Ball_Id = er.Ball_Id
        AND b.Innings_No = er.Innings_No
)
SELECT
    v.Venue_Name,
    ROUND(
        SUM(br.Total_Runs) * 1.0 / COUNT(*),
        2
    ) AS Avg_Runs_Per_Ball
FROM ball_runs br
JOIN Matches m
    ON br.Match_Id = m.Match_Id
JOIN Venue v
    ON m.Venue_Id = v.Venue_Id
GROUP BY v.Venue_Id, v.Venue_Name
ORDER BY Avg_Runs_Per_Ball DESC;

-- S8
-- Analyze the impact of home-ground advantage on team performance and
-- identify strategies to maximize this advantage for RCB.

SELECT
    v.Venue_Name,
    COUNT(*) AS matches_played,
    SUM(CASE WHEN m.Match_Winner = 2 THEN 1 ELSE 0 END) AS wins,
    SUM(CASE
        WHEN m.Match_Winner IS NOT NULL
             AND m.Match_Winner <> 2 THEN 1
        ELSE 0
    END) AS losses,
    ROUND(
        SUM(CASE WHEN m.Match_Winner = 2 THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS win_percentage
FROM Matches m
JOIN Venue v
    ON m.Venue_Id = v.Venue_Id
WHERE (m.Team_1 = 2 OR m.Team_2 = 2) AND m.Match_Winner IS NOT NULL
GROUP BY v.Venue_Id, v.Venue_Name
ORDER BY win_percentage DESC;

-- S9
-- Come up with a visual and analytical analysis of the RCB's past season's
-- performance and potential reasons for them not winning a trophy.

WITH batting AS (
    SELECT
        s.Season_Year,
        SUM(bs.Runs_Scored) AS runs
    FROM Matches m
    JOIN Season s
        ON m.Season_Id = s.Season_Id
    JOIN Ball_by_Ball b
        ON m.Match_Id = b.Match_Id
    JOIN Batsman_Scored bs
        ON b.Match_Id = bs.Match_Id
        AND b.Over_Id = bs.Over_Id
        AND b.Ball_Id = bs.Ball_Id
        AND b.Innings_No = bs.Innings_No
    WHERE b.Team_Batting = 2
      AND s.Season_Year BETWEEN 2013 AND 2016
    GROUP BY s.Season_Year
),
bowling AS (
    SELECT
        s.Season_Year,
        COUNT(*) AS wkts
    FROM Matches m
    JOIN Season s
        ON m.Season_Id = s.Season_Id
    JOIN Ball_by_Ball b
        ON m.Match_Id = b.Match_Id
    JOIN Wicket_Taken w
        ON b.Match_Id = w.Match_Id
        AND b.Over_Id = w.Over_Id
        AND b.Ball_Id = w.Ball_Id
        AND b.Innings_No = w.Innings_No
    WHERE b.Team_Bowling = 2
      AND s.Season_Year BETWEEN 2013 AND 2016
    GROUP BY s.Season_Year
)
SELECT
    s.Season_Year,
    COUNT(m.Match_Id) AS matches,
    SUM(CASE WHEN m.Match_Winner = 2 THEN 1 ELSE 0 END) AS wins,
    SUM(CASE
        WHEN m.Match_Winner IS NOT NULL
         AND m.Match_Winner <> 2 THEN 1
        ELSE 0
    END) AS losses,
    ROUND(
        SUM(CASE WHEN m.Match_Winner = 2 THEN 1 ELSE 0 END)
        * 100.0 / COUNT(m.Match_Id), 2
    ) AS win_pct,
    b.runs,
    w.wkts
FROM Matches m
JOIN Season s
    ON m.Season_Id = s.Season_Id
JOIN batting b
    ON s.Season_Year = b.Season_Year
JOIN bowling w
    ON s.Season_Year = w.Season_Year
WHERE (m.Team_1 = 2 OR m.Team_2 = 2)
  AND m.Match_Winner IS NOT NULL
  AND s.Season_Year BETWEEN 2013 AND 2016
GROUP BY s.Season_Year, b.runs, w.wkts
ORDER BY s.Season_Year;

-- S10
-- How would you approach this problem, if the objective and subjective
-- questions weren't given?

-- Answer: It was analyzed with subjective findings and recommendations, No need of query

-- S11
-- In the "Match" table, some entries in the "Opponent_Team" column are
-- incorrectly spelled as "Delhi_Capitals" instead of "Delhi_Daredevils".
-- Write an SQL query to replace all occurrences of "Delhi_Capitals" with
-- "Delhi_Daredevils".

UPDATE Matches
SET Opponent_Team = 'Delhi_Daredevils'                   
WHERE Opponent_Team = 'Delhi_Capitals';


/* ===================================== END OF FILE ===================================== */


    

