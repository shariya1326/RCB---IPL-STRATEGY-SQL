# RCB---IPL-STRATEGY-SQL
Project Overview:
Analyzed IPL match, player, ball-by-ball, and venue data to evaluate player performance and RCB’s team strategy.
Developed data-driven recommendations to support RCB’s 2017 player auction, focusing on performance, consistency, squad balance, and value in player selection.

Business Objective:
1. Identify high-performing and consistent players.
2. Evaluate RCB’s seasonal and venue-level performance.
3. Analyze toss decisions and player–venue patterns.
4. Recommend strategies for squad selection and match planning.

Tools & SQL Techniques:
1. MySQL
2. Multi-table JOINs
3. GROUP BY, HAVING, and aggregate functions
4. CASE statements and filtering
5. Subqueries and CTEs
6. Window functions: LAG(), DENSE_RANK()
7. Performance KPI calculations
8. Excel charts for result visualization

Project Workflow:
1. Data Exploration & Preparation
-Explored IPL relational tables covering matches, seasons, players, ball-by-ball records, wickets, teams, and venues.
-Used INFORMATION_SCHEMA to inspect table structures and data types.
-Joined relevant tables and filtered records to analyze RCB and player performance.

2. Player Performance Analysis
-Evaluated batting and bowling metrics, including total runs, strike rate, average runs per innings, wickets, and wickets per match.
-Compared player performance across seasons and identified leading batters, bowlers, and all-rounders.
-Assessed player consistency using seasonal averages, best/worst seasons, and standard deviation.
-Analyzed player performance by venue to identify potential venue-specific strengths.

3. RCB Team & Match Analysis
-Calculated RCB’s season-wise wins, losses, win percentage, runs scored, and wickets taken.
-Compared seasonal performance with the previous year using LAG().
-Analyzed RCB’s win–loss record across venues and player participation-based win percentages.

4. Toss & Venue Analysis
-Compared match outcomes by toss decision and venue.
-Evaluated venue-level win patterns for batting first versus fielding first.
-Examined player–venue performance to identify potential tactical advantages.

5. KPI Development & Visualization
-Derived additional KPIs, including win percentage, boundary-run contribution, top run-scorers, and player–venue strike rates.
-Visualized key findings using Excel charts to communicate player benchmarks, team trends, and strategic insights.

Key Findings:
1. Batting: KH Pandya recorded the highest strike rate at 191.13; LMP Simmons led average runs per innings at 42.82.
2. Bowling: SL Malinga led the wicket-taker analysis with 143 wickets, followed by A Mishra (124) and DJ Bravo (122).
3. All-rounders: SK Raina led the analyzed players with 4,106 runs, while SR Watson recorded the highest wicket count among  them (81).
4. RCB seasonal performance: Win percentage dropped to 35.71% in 2014, then recovered to 57.14% in 2015.
5. Venue performance: RCB won 29 of 54 matches at M. Chinnaswamy Stadium, achieving a 53.70% win rate.
6. Toss trends: Teams choosing to field first won 55.27% of matches, compared with 45.21% for teams choosing to bat first; patterns varied by venue.
7. Player–venue analysis: ST Jayasuriya recorded a 226.88 strike rate at Wankhede Stadium, demonstrating the value of venue-specific analysis.

Business Recommendations:
1. Strengthen bowling: Prioritize consistent wicket-takers while evaluating effectiveness beyond total wickets.
2. Build a balanced squad: Select players who contribute across batting and bowling, improving team flexibility.
3. Improve batting consistency: Consider strike rate, average runs, and performance across multiple seasons.
4. Use venue-specific strategies: Apply historical venue and player–venue trends when planning batting and bowling tactics.
5. Consider toss trends carefully: Use venue-specific evidence while accounting for match conditions and sample size.
6.Use multiple performance metrics: Combine performance, consistency, and team requirements rather than relying on a single statistic.

Project Files:
1. SQL RCB-IPL ANALYSIS.sql — SQL queries for data exploration, analysis, and KPI calculations
2. SQL RCB-IPL ANALYSIS.pptx — Analysis, visualizations, findings, and recommendations
3. Tasks RCB-IPL ANALYSIS.docx — Project questions and analysis documentation
