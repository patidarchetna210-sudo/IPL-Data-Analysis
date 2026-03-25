-- First cleaning of  the data set  
-- CLEANING team table 
use ipl;
SELECT DISTINCT Team_Name
FROM Team;

UPDATE Team
SET Team_Name = 'Delhi_Daredevils'
WHERE Team_Name = 'Delhi_Capitals';

-- cleaning table = ball_by_ball
 delete m1
from ball_by_ball m1
join matches b1
on m1.match_id=b1.match_id
where match_winner is null;
-- cleaning table = extra runs
DELETE e
FROM Extra_Runs e
JOIN Matches m
ON e.Match_Id = m.Match_Id
WHERE m.Match_Winner IS NULL;
-- cleaning table = Wicket_Taken
DELETE w
FROM Wicket_Taken w
JOIN Matches m
ON w.Match_Id = m.Match_Id
WHERE m.Match_Winner IS NULL;
-- cleaning table player_match
DELETE pm
FROM Player_Match pm
JOIN Matches m
ON pm.Match_Id = m.Match_Id
WHERE m.Match_Winner IS NULL;
-- cleaning matches
DELETE
FROM Matches
WHERE Match_Winner IS NULL;

-- cleaning = player
SELECT *
FROM Player
WHERE Batting_hand IS NULL
   OR Country_Name IS NULL;
-- cleaning = matches
SELECT *
FROM Matches
WHERE Win_Margin < 0;
-- checking = ball_by_ball
SELECT *
FROM Ball_by_Ball
WHERE Runs_Scored < 0;
-- checking - extra_runs
SELECT *
FROM Extra_Runs
WHERE Extra_Runs < 0;
-- checking player_match
SELECT *
FROM Player_Match
WHERE Role_Id IS NULL;
-- checking - venue
SELECT *
FROM Venue
WHERE City_Id IS NULL;
-- checking season_year
SELECT *
FROM Season
WHERE Season_Year IS NULL;


-- Foreign key use to biuld a relationship between two table 

use ipl;
ALTER TABLE matches 
ADD CONSTRAINT fk_matches_team1 
    FOREIGN KEY (Team_1) REFERENCES team(Team_Id);

ALTER TABLE matches 
ADD CONSTRAINT fk_matches_team2 
    FOREIGN KEY (Team_2) REFERENCES team(Team_Id);

ALTER TABLE matches 
ADD CONSTRAINT fk_matches_toss_winner 
    FOREIGN KEY (Toss_Winner) REFERENCES team(Team_Id);

ALTER TABLE matches 
ADD CONSTRAINT fk_matches_toss_decision 
    FOREIGN KEY (Toss_Decide) REFERENCES toss_decision(Toss_Id);

ALTER TABLE matches 
ADD CONSTRAINT fk_matches_win_type 
    FOREIGN KEY (Win_Type) REFERENCES win_by(Win_Id);

ALTER TABLE matches 
ADD CONSTRAINT fk_matches_outcome 
    FOREIGN KEY (Outcome_type) REFERENCES outcome(Outcome_Id);

ALTER TABLE matches 
ADD CONSTRAINT fk_matches_venue 
    FOREIGN KEY (Venue_Id) REFERENCES venue(Venue_Id);

ALTER TABLE matches 
ADD CONSTRAINT fk_matches_season 
    FOREIGN KEY (Season_Id) REFERENCES season(Season_Id);

ALTER TABLE matches 
ADD CONSTRAINT fk_matches_match_winner 
    FOREIGN KEY (Match_Winner) REFERENCES team(Team_Id);

ALTER TABLE matches 
ADD CONSTRAINT fk_matches_man_of_match 
    FOREIGN KEY (Man_of_the_Match) REFERENCES player(Player_Id);
    
 ALTER TABLE venue 
ADD CONSTRAINT fk_venue_city 
    FOREIGN KEY (City_Id) REFERENCES city(City_Id);
    
    ALTER TABLE city 
ADD CONSTRAINT fk_city_country 
    FOREIGN KEY (Country_Id) REFERENCES country(Country_Id);
    
    ALTER TABLE player 
ADD CONSTRAINT fk_player_country 
    FOREIGN KEY (Country_Id) REFERENCES country(Country_Id);

ALTER TABLE player 
ADD CONSTRAINT fk_player_batting 
    FOREIGN KEY (Batting_Hand) REFERENCES batting_style(Batting_Id);

ALTER TABLE player 
ADD CONSTRAINT fk_player_bowling 
    FOREIGN KEY (Bowling_Skill) REFERENCES bowling_style(Bowling_Id);
    
ALTER TABLE player_match 
ADD CONSTRAINT fk_pm_match 
    FOREIGN KEY (Match_Id) REFERENCES matches(Match_Id);

ALTER TABLE player_match 
ADD CONSTRAINT fk_pm_player 
    FOREIGN KEY (Player_Id) REFERENCES player(Player_Id);

ALTER TABLE player_match 
ADD CONSTRAINT fk_pm_team 
    FOREIGN KEY (Team_Id) REFERENCES team(Team_Id);

ALTER TABLE player_match 
ADD CONSTRAINT fk_pm_role 
    FOREIGN KEY (Role_Id) REFERENCES rolee(Role_Id);
    
    ALTER TABLE ball_by_ball 
ADD CONSTRAINT fk_bbb_match 
    FOREIGN KEY (Match_Id) REFERENCES matches(Match_Id);

ALTER TABLE ball_by_ball 
ADD CONSTRAINT fk_bbb_striker 
    FOREIGN KEY (Striker) REFERENCES player(Player_Id);

ALTER TABLE ball_by_ball 
ADD CONSTRAINT fk_bbb_non_striker 
    FOREIGN KEY (Non_Striker) REFERENCES player(Player_Id);

ALTER TABLE ball_by_ball 
ADD CONSTRAINT fk_bbb_bowler 
    FOREIGN KEY (Bowler) REFERENCES player(Player_Id);
 
 ALTER TABLE extra_runs 
ADD CONSTRAINT fk_ex_runs_match 
    FOREIGN KEY (Match_Id) REFERENCES matches(Match_Id);

ALTER TABLE extra_runs 
ADD CONSTRAINT fk_ex_runs_extra 
    FOREIGN KEY (Extra_Type_Id) REFERENCES extra_type(Extra_Id);
    
    ALTER TABLE wicket_taken 
ADD CONSTRAINT fk_wk_match 
    FOREIGN KEY (Match_Id) REFERENCES matches(Match_Id);

ALTER TABLE wicket_taken 
ADD CONSTRAINT fk_wk_player_out 
    FOREIGN KEY (Player_Out_Id) REFERENCES player(Player_Id);

ALTER TABLE wicket_taken 
ADD CONSTRAINT fk_wk_kind_out 
    FOREIGN KEY (Kind_Out_Id) REFERENCES out_type(Out_Id);

ALTER TABLE wicket_taken 
ADD CONSTRAINT fk_wk_fielder 
    FOREIGN KEY (Fielder_Id) REFERENCES player(Player_Id);

ALTER TABLE umpire 
ADD CONSTRAINT fk_umpire_country
  FOREIGN KEY (Umpire_Country) REFERENCES country(Country_Id);


ALTER TABLE player 
ADD CONSTRAINT fk_player_Batting
    FOREIGN KEY (Batting_hand) REFERENCES batting_style(Batting_Id);


--  objective quetions 

use ipl;

-- QUETION 1 List the different data types of columns in table “ball_by_ball” (using     information schema)? 
  SELECT 
    COLUMN_NAME, 
    DATA_TYPE, 
    IS_NULLABLE
FROM information_schema.columns
WHERE table_name = 'ball_by_ball'
AND table_schema = 'ipl';

-- Quetion 2  What is the total number of runs scored in 1st season by RCB (bonus: also include the extra runs using the extra runs table)
SELECT 
    SUM(b.runs_scored + COALESCE(e.extra_runs, 0)) AS total_runs
FROM matches m
JOIN ball_by_ball b
    ON m.match_id = b.match_id
LEFT JOIN extra_runs e
    ON b.match_id = e.match_id
   AND b.over_id = e.over_id
   AND b.ball_id = e.ball_id
   AND b.innings_no = e.innings_no
WHERE 
    -- First season
    m.season_id = (
        SELECT MIN(season_id)
        FROM matches
        WHERE team_1 = (
            SELECT team_id FROM team WHERE team_name = 'Royal Challengers Bangalore'
        )
        OR team_2 = (
            SELECT team_id FROM team WHERE team_name = 'Royal Challengers Bangalore'
        )
    )
    -- RCB batting
    AND b.team_batting = (
        SELECT team_id FROM team WHERE team_name = 'Royal Challengers Bangalore'
    );
    
-- QUETION 3   How many players were more than the age of 25 during season 2014? 

select 
      count(distinct P.Player_Id) as totalplayer
 from player p join player_match pm 
on p.Player_Id = pm.Player_Id
join matches m 
on pm.match_Id = m.match_Id
where year (match_date) = 2014
and timestampdiff(year,DOB,Match_Date) > 25;

-- Quetion 4   How many matches did RCB win in 2013? 
select 
      count(distinct match_Id) Total_matches
from matches
where  year(match_date) = 2013
and match_winner = 
(select team_Id from team where team_Name = 'Royal Challengers Bangalore') ;

-- Quetion 5 List the top 10 players according to their strike rate in the last 4 seasons 
 
 WITH last_4_seasons AS (
    SELECT Season_Year
    FROM (
        SELECT DISTINCT Season_Year,
               DENSE_RANK() OVER (ORDER BY Season_Year DESC) AS rnk
        FROM season
    ) s
    WHERE rnk <= 4
),
valid_balls AS (
    SELECT 
        b.Striker,
        b.Runs_Scored,
        b.Ball_Id,
        m.Season_Id
    FROM ball_by_ball b
    JOIN matches m
        ON b.Match_Id = m.Match_Id
    LEFT JOIN extra_runs er
        ON b.Match_Id = er.Match_Id
       AND b.Over_Id  = er.Over_Id
       AND b.Ball_Id  = er.Ball_Id
       AND b.Innings_No = er.Innings_No
    LEFT JOIN extra_type et
        ON er.Extra_Type_Id = et.Extra_Id
    WHERE et.Extra_Name IS NULL
       OR et.Extra_Name <> 'wides'
)
SELECT 
    p.Player_Name,
    ROUND(
        (SUM(v.Runs_Scored) * 100.0) / COUNT(v.Ball_Id),
        2
    ) AS Strike_Rate
FROM valid_balls v
JOIN season s
    ON v.Season_Id = s.Season_Id
JOIN last_4_seasons l
    ON s.Season_Year = l.Season_Year
JOIN player p
    ON v.Striker = p.Player_Id
GROUP BY p.Player_Name
HAVING COUNT(v.Ball_Id) >= 100
ORDER BY Strike_Rate DESC
LIMIT 10;
   
   
-- Q6 What are the average runs scored by each batsman considering all the seasons?
 WITH batsman_innings AS (
    SELECT
        b.Striker AS Player_Id,
        b.Match_Id,
        b.Innings_No,
        SUM(b.Runs_Scored) AS runs_in_innings
    FROM ball_by_ball b
    GROUP BY b.Striker, b.Match_Id, b.Innings_No
),
batsman_avg AS (
    SELECT
        Player_Id,
        SUM(runs_in_innings) AS total_runs,
        COUNT(*) AS innings_played,
        ROUND(SUM(runs_in_innings) * 1.0 / COUNT(*), 2) AS batting_average
    FROM batsman_innings
    GROUP BY Player_Id
)
SELECT
    p.Player_Name,
    ba.batting_average
FROM batsman_avg ba
JOIN player p
    ON ba.Player_Id = p.Player_Id
ORDER BY ba.batting_average DESC; 

-- Q7 What are the average wickets taken by each bowler considering all the seasons?

SELECT 
    bowler,
    ROUND(AVG(wickets), 2) AS avg_wickets_per_season
FROM (
    SELECT 
        m.season_id,
        b.bowler,
        COUNT(*) AS wickets
    FROM matches m
    JOIN ball_by_ball b
        ON m.match_id = b.match_id
    JOIN wicket_taken w
        ON b.match_id = w.match_id
       AND b.over_id = w.over_id
       AND b.ball_id = w.ball_id
       AND b.innings_no = w.innings_no
    GROUP BY m.season_id, b.bowler
) t
GROUP BY bowler;

-- Q8  List all the players who have average runs scored greater than the overall average and who have taken wickets greater than the overall average

WITH
player_runs AS (
    SELECT
        b.Striker AS Player_Id,
        SUM(b.Runs_Scored) AS total_runs
    FROM Ball_by_Ball b
    GROUP BY b.Striker
),
player_outs AS (
    SELECT
        wt.Player_Out AS Player_Id,
        COUNT(*) AS times_out
    FROM Wicket_Taken wt
    JOIN Out_Type ot
        ON wt.Kind_Out = ot.Out_Id
    WHERE ot.Out_Name NOT IN ('run out', 'retired hurt')
    GROUP BY wt.Player_Out
),
batting_avg AS (
    SELECT
        r.Player_Id,
        r.total_runs * 1.0 / o.times_out AS avg_runs
    FROM player_runs r
    JOIN player_outs o
        ON r.Player_Id = o.Player_Id
),
bowling_wickets AS (
    SELECT
        b.Bowler AS Player_Id,
        COUNT(*) AS wickets
    FROM Wicket_Taken wt
    JOIN Out_Type ot
        ON wt.Kind_Out = ot.Out_Id
    JOIN Ball_by_Ball b
        ON wt.Match_Id = b.Match_Id
       AND wt.Over_Id = b.Over_Id
       AND wt.Ball_Id = b.Ball_Id
       AND wt.Innings_No = b.Innings_No
    WHERE ot.Out_Name NOT IN ('run out', 'retired hurt')
    GROUP BY b.Bowler
),
overall_avg AS (
    SELECT
        (SELECT AVG(avg_runs) FROM batting_avg) AS overall_batting_avg,
        (SELECT AVG(wickets) FROM bowling_wickets) AS overall_wicket_avg
)


SELECT
    p.Player_Id,
    p.Player_Name,
    ROUND(ba.avg_runs, 2) AS batting_average,
    bw.wickets
FROM batting_avg ba
JOIN bowling_wickets bw
    ON ba.Player_Id = bw.Player_Id
JOIN Player p
    ON p.Player_Id = ba.Player_Id
CROSS JOIN overall_avg oa
WHERE
    ba.avg_runs > oa.overall_batting_avg
    AND bw.wickets > oa.overall_wicket_avg
ORDER BY batting_average DESC, bw.wickets DESC;


-- quetion 9  Create a table rcb_record table that shows the wins and losses of RCB in an individual venue.

CREATE TABLE rcb_record (
    Venue_Id INT,
    Venue_Name VARCHAR(450),
    Wins INT,
    Losses INT
);
INSERT INTO rcb_record (Venue_Id, Venue_Name, Wins, Losses)
SELECT
    m.Venue_Id,
    v.Venue_Name,

    /* Wins */
    SUM(
        CASE
            WHEN m.Match_Winner = rcb.Team_Id THEN 1
            ELSE 0
        END
    ) AS Wins,

    /* Losses */
    SUM(
        CASE
            WHEN m.Match_Winner <> rcb.Team_Id
                 AND m.Match_Winner IS NOT NULL THEN 1
            ELSE 0
        END
    ) AS Losses

FROM Matches m
JOIN Venue v
    ON m.Venue_Id = v.Venue_Id
JOIN Team rcb
    ON rcb.Team_Name = 'Royal Challengers Bangalore'
WHERE
    m.Team_1 = rcb.Team_Id
    OR m.Team_2 = rcb.Team_Id
GROUP BY
    m.Venue_Id,
    v.Venue_Name;
select * from rcb_record;


-- Q 10 What is the impact of bowling style on wickets taken?
SELECT
    bs.Bowling_skill AS Bowling_Style,
    COUNT(*) AS Total_Wickets
FROM Wicket_Taken wt
JOIN Out_Type ot
    ON wt.Kind_Out = ot.Out_Id
JOIN Ball_by_Ball b
    ON wt.Match_Id = b.Match_Id
   AND wt.Over_Id = b.Over_Id
   AND wt.Ball_Id = b.Ball_Id
   AND wt.Innings_No = b.Innings_No
JOIN Player p
    ON b.Bowler = p.Player_Id
JOIN Bowling_Style bs
    ON p.Bowling_skill = bs.Bowling_Id
WHERE ot.Out_Name NOT IN ('run out', 'retired hurt')
GROUP BY bs.Bowling_skill
ORDER BY Total_Wickets DESC;

-- Q 11 Write the SQL query to provide a status of whether the performance of the team is better than the previous year's performance on the basis of the number of runs scored by the team in the season and the number of wickets taken 
 
 WITH team_season_runs AS (
    SELECT
        m.Season_Id,
        b.Team_Batting AS Team_Id,
        SUM(b.Runs_Scored) AS total_runs
    FROM Ball_by_Ball b
    JOIN Matches m
        ON b.Match_Id = m.Match_Id
    GROUP BY m.Season_Id, b.Team_Batting
),

team_season_wickets AS (
    SELECT
        m.Season_Id,
        b.Team_Bowling AS Team_Id,
        COUNT(*) AS total_wickets
    FROM Wicket_Taken wt
    JOIN Out_Type ot
        ON wt.Kind_Out = ot.Out_Id
    JOIN Ball_by_Ball b
        ON wt.Match_Id = b.Match_Id
       AND wt.Over_Id = b.Over_Id
       AND wt.Ball_Id = b.Ball_Id
       AND wt.Innings_No = b.Innings_No
    JOIN Matches m
        ON wt.Match_Id = m.Match_Id
    WHERE ot.Out_Name NOT IN ('run out', 'retired hurt')
    GROUP BY m.Season_Id, b.Team_Bowling
),

team_season_stats AS (
    SELECT
        r.Season_Id,
        r.Team_Id,
        r.total_runs,
        w.total_wickets
    FROM team_season_runs r
    JOIN team_season_wickets w
        ON r.Season_Id = w.Season_Id
       AND r.Team_Id = w.Team_Id
),

season_comparison AS (
    SELECT
        ts.*,
        LAG(total_runs) OVER (PARTITION BY Team_Id ORDER BY Season_Id) AS prev_runs,
        LAG(total_wickets) OVER (PARTITION BY Team_Id ORDER BY Season_Id) AS prev_wickets
    FROM team_season_stats ts
)

SELECT
    t.Team_Name,
    Season_Id,
    total_runs,
    total_wickets,
    CASE
        WHEN prev_runs IS NULL THEN 'No Previous Data'
        WHEN total_runs > prev_runs
         AND total_wickets > prev_wickets THEN 'Better'
        ELSE 'Not Better'
    END AS Performance_Status
FROM season_comparison sc
JOIN Team t
    ON sc.Team_Id = t.Team_Id
ORDER BY t.Team_Name, Season_Id;
 
 
-- Q 13 Using SQL, write a query to find out the average wickets taken by each bowler in each venue. Also, rank the gender according to the average value.

WITH bowler_wickets AS (
    SELECT
        b.Bowler AS Player_Id,
        m.Venue_Id,
        COUNT(*) AS wickets
    FROM Wicket_Taken wt
    JOIN Out_Type ot
        ON wt.Kind_Out = ot.Out_Id
    JOIN Ball_by_Ball b
        ON wt.Match_Id = b.Match_Id
       AND wt.Over_Id = b.Over_Id
       AND wt.Ball_Id = b.Ball_Id
       AND wt.Innings_No = b.Innings_No
    JOIN Matches m
        ON wt.Match_Id = m.Match_Id
    WHERE ot.Out_Name NOT IN ('run out', 'retired hurt')
    GROUP BY b.Bowler, m.Venue_Id
),

bowler_avg AS (
    SELECT
        Player_Id,
        Venue_Id,
        AVG(wickets) AS avg_wickets
    FROM bowler_wickets
    GROUP BY Player_Id, Venue_Id
)

SELECT
    p.Player_Name,
    v.Venue_Name,
    ROUND(ba.avg_wickets,2) AS avg_wickets,
    RANK() OVER (PARTITION BY v.Venue_Id ORDER BY ba.avg_wickets DESC) AS rank_in_venue
FROM bowler_avg ba
JOIN Player p
    ON ba.Player_Id = p.Player_Id
JOIN Venue v
    ON ba.Venue_Id = v.Venue_Id
ORDER BY v.Venue_Name, rank_in_venue; 

-- Q 14   Which of the given players have consistently performed well in past seasons? (will you use any visualization to solve the problem)

WITH player_season_batting AS (
    SELECT
        b.Striker AS Player_Id,
        m.Season_Id,
        SUM(b.Runs_Scored) AS total_runs
    FROM Ball_by_Ball b
    JOIN Matches m ON b.Match_Id = m.Match_Id
    GROUP BY b.Striker, m.Season_Id
),
-- Season-wise wickets
player_season_wickets AS (
    SELECT
        b.Bowler AS Player_Id,
        m.Season_Id,
        COUNT(*) AS wickets
    FROM Wicket_Taken wt
    JOIN Out_Type ot ON wt.Kind_Out = ot.Out_Id
    JOIN Ball_by_Ball b
        ON wt.Match_Id = b.Match_Id
       AND wt.Over_Id = b.Over_Id
       AND wt.Ball_Id = b.Ball_Id
       AND wt.Innings_No = b.Innings_No
    JOIN Matches m ON wt.Match_Id = m.Match_Id
    WHERE ot.Out_Name NOT IN ('run out', 'retired hurt')
    GROUP BY b.Bowler, m.Season_Id
)
SELECT p.Player_Name, psb.Season_Id, psb.total_runs, psw.wickets
FROM player_season_batting psb
LEFT JOIN player_season_wickets psw
    ON psb.Player_Id = psw.Player_Id AND psb.Season_Id = psw.Season_Id
JOIN Player p ON psb.Player_Id = p.Player_Id
ORDER BY p.Player_Name, psb.Season_Id;


-- Q15 Are there players whose performance is more suited to specific venues or conditions? (how would you present this using charts?) 

WITH player_venue_stats AS (
    SELECT
        b.Striker AS Player_Id,
        m.Venue_Id,
        SUM(b.Runs_Scored) AS total_runs,
        COUNT(DISTINCT m.Match_Id) AS matches_played
    FROM Ball_by_Ball b
    JOIN Matches m ON b.Match_Id = m.Match_Id
    GROUP BY b.Striker, m.Venue_Id
)
SELECT 
    p.Player_Name,
    v.Venue_Name,
    ROUND(total_runs*1.0/matches_played,2) AS avg_runs_per_match
FROM player_venue_stats pv
JOIN Player p ON pv.Player_Id = p.Player_Id
JOIN Venue v ON pv.Venue_Id = v.Venue_Id
ORDER BY p.Player_Name, avg_runs_per_match DESC;


-- SUBJECTIVE QUETIONS 
use ipl;
-- Q1  How does the toss decision affect the result of the match? (which visualizations could be used to present your answer better) And is the impact limited to only specific venues?

SELECT
    td.Toss_Name AS Toss_Decision,
    SUM(CASE WHEN m.Toss_Winner = m.Match_Winner THEN 1 ELSE 0 END) AS Wins_After_Toss,
    COUNT(*) AS Total_Matches,
    ROUND(SUM(CASE WHEN m.Toss_Winner = m.Match_Winner THEN 1 ELSE 0 END)*100.0 / COUNT(*),2) AS Win_Percentage
FROM Matches m
JOIN Toss_Decision td ON m.Toss_Decide = td.Toss_Id
GROUP BY td.Toss_Name;


-- Q2  Suggest some of the players who would be best fit for the team.

WITH batting_avg AS (
    SELECT Striker AS Player_Id, AVG(Runs_Scored) AS avg_runs
    FROM Ball_by_Ball
    GROUP BY Striker
),
bowling_wickets AS (
    SELECT b.Bowler AS Player_Id, COUNT(*) AS total_wickets
    FROM Wicket_Taken wt
    JOIN Out_Type ot ON wt.Kind_Out = ot.Out_Id
    JOIN Ball_by_Ball b
      ON wt.Match_Id = b.Match_Id
     AND wt.Over_Id = b.Over_Id
     AND wt.Ball_Id = b.Ball_Id
     AND wt.Innings_No = b.Innings_No
    WHERE ot.Out_Name NOT IN ('run out','retired hurt')
    GROUP BY b.Bowler
)
SELECT p.Player_Name, ba.avg_runs, bw.total_wickets
FROM batting_avg ba
JOIN bowling_wickets bw ON ba.Player_Id = bw.Player_Id
JOIN Player p ON ba.Player_Id = p.Player_Id
WHERE ba.avg_runs > (SELECT AVG(avg_runs) FROM batting_avg)
  AND bw.total_wickets > (SELECT AVG(total_wickets) FROM bowling_wickets)
ORDER BY ba.avg_runs DESC, bw.total_wickets DESC;


-- Q4  Which players offer versatility in their skills and can contribute effectively with both bat and ball? (can you visualize the data for the same) 

WITH batting_avg AS (
    SELECT Striker AS Player_Id, AVG(Runs_Scored) AS avg_runs
    FROM Ball_by_Ball
    GROUP BY Striker
),
bowling_wickets AS (
    SELECT b.Bowler AS Player_Id, COUNT(*) AS total_wickets
    FROM Wicket_Taken wt
    JOIN Out_Type ot ON wt.Kind_Out = ot.Out_Id
    JOIN Ball_by_Ball b
      ON wt.Match_Id = b.Match_Id
     AND wt.Over_Id = b.Over_Id
     AND wt.Ball_Id = b.Ball_Id
     AND wt.Innings_No = b.Innings_No
    WHERE ot.Out_Name NOT IN ('run out','retired hurt')
    GROUP BY b.Bowler
)
SELECT p.Player_Name, ROUND(ba.avg_runs,2) AS avg_runs, bw.total_wickets
FROM batting_avg ba
JOIN bowling_wickets bw ON ba.Player_Id = bw.Player_Id
JOIN Player p ON ba.Player_Id = p.Player_Id
WHERE ba.avg_runs > (SELECT AVG(avg_runs) FROM batting_avg)
  AND bw.total_wickets > (SELECT AVG(total_wickets) FROM bowling_wickets)
ORDER BY ba.avg_runs DESC, bw.total_wickets DESC;

-- Q5  Are there players whose presence positively influences the morale and performance of the team? (justify your answer using visualization)

SELECT 
    p.Player_Name,
    SUM(CASE WHEN m.Match_Winner = pm.Team_Id THEN 1 ELSE 0 END) AS Wins_With_Player,
    COUNT(*) AS Matches_Played,
    ROUND(SUM(CASE WHEN m.Match_Winner = pm.Team_Id THEN 1 ELSE 0 END)*100.0/COUNT(*),2) AS Win_Percentage
FROM Player_Match pm
JOIN Player p ON pm.Player_Id = p.Player_Id
JOIN Matches m ON pm.Match_Id = m.Match_Id
GROUP BY p.Player_Name
ORDER BY Win_Percentage DESC;

-- Q9 Come up with a visual and analytical analysis of the RCB's past season's performance and potential reasons for them not winning a trophy.

 SELECT 
    p.Player_Name,
    SUM(b.Runs_Scored) AS total_runs,
    AVG(b.Runs_Scored) AS avg_runs
FROM Ball_by_Ball b
JOIN Player p ON b.Striker = p.Player_Id
JOIN Matches m ON b.Match_Id = m.Match_Id
WHERE m.Team_1 = 2 OR m.Team_2 = 2  -- assuming RCB's Team_Id = 2
AND m.Season_Id = (SELECT MAX(Season_Id) FROM Matches)  -- latest season
GROUP BY p.Player_Name
ORDER BY total_runs DESC;

-- Player-wise Bowling Performance
SELECT 
    p.Player_Name,
    COUNT(*) AS total_wickets
FROM Wicket_Taken wt
JOIN Out_Type ot ON wt.Kind_Out = ot.Out_Id
JOIN Ball_by_Ball b
  ON wt.Match_Id = b.Match_Id
 AND wt.Over_Id = b.Over_Id
 AND wt.Ball_Id = b.Ball_Id
 AND wt.Innings_No = b.Innings_No
JOIN Player p ON b.Bowler = p.Player_Id
JOIN Matches m ON wt.Match_Id = m.Match_Id
WHERE ot.Out_Name NOT IN ('run out','retired hurt')
AND (m.Team_1 = 2 OR m.Team_2 = 2)
AND m.Season_Id = (SELECT MAX(Season_Id) FROM Matches)
GROUP BY p.Player_Name
ORDER BY total_wickets DESC;

 -- Venue-wise Team Performance
SELECT 
    v.Venue_Name,
    SUM(CASE WHEN m.Match_Winner = 2 THEN 1 ELSE 0 END) AS Wins,
    SUM(CASE WHEN m.Match_Winner != 2 THEN 1 ELSE 0 END) AS Losses
FROM Matches m
JOIN Venue v ON m.Venue_Id = v.Venue_Id
WHERE m.Team_1 = 2 OR m.Team_2 = 2
AND m.Season_Id = (SELECT MAX(Season_Id) FROM Matches)
GROUP BY v.Venue_Name
ORDER BY Wins DESC;


-- In the "Match" table, some entries in the "Opponent_Team" column are incorrectly spelled as "Delhi_Capitals" instead of "Delhi_Daredevils". Write an SQL query to replace all occurrences of "Delhi_Capitals" with "Delhi_Daredevils".

UPDATE Matches
SET Opponent_Team = 'Delhi_Daredevils'
WHERE Opponent_Team = 'Delhi_Capitals';

   
    
    
    
    
    
    
    
    
