CREATE DATABASE f1_race;
GO

use f1_race;
Go

select * from [Formula1_Racing];
GO

-- All the driver names 
select distinct(Driver_Name)
from Formula1_Racing;
GO

-- How many races did each driver complete without penalties
select Driver_Name, COUNT(*) as races_without_penalties
from Formula1_Racing
where Penalties = 0
group by Driver_Name;

GO

-- Which weather condition is associated with the most wins
select Weather_Conditions, count(*) as wins
from Formula1_Racing
where Position = 1
group by Weather_Conditions
order by wins desc;
GO

-- Whats the correlation between the grid start position and final race position
select Grid_Start_Position, AVG(cast(Position as float)) as avg_final_position
from Formula1_Racing
group by Grid_Start_Position
order by avg_final_position;
GO

-- Which driver has lowest avg lap time under rainy conditions 
select TOP 1 Driver_Name, AVG(cast(Lap_Time_Avg as float)) as avg_lap_time
from Formula1_Racing
where Weather_Conditions = 'Rainy'
group by Driver_Name
order by avg_lap_time;
GO

-- Find the driver with the highest average finshing position across all races where they finished in top 10
-- the driver should have finished in Top 10 a min. of 5 times
select Driver_Name, AVG(cast(Position as float)) as avg_top10_position
from Formula1_Racing
where Position between 1 and 10 
group by Driver_Name
having COUNT(*) > 5
order by avg_top10_position;
GO

-- Which drivers have finished in top 5 positions more than 25% of the races they particiapted in
with Driver_Race_Count as (
	select Driver_Name, count(*) as total_races
	from Formula1_Racing
	group by Driver_Name
),
Top5_Finishes as (
	select Driver_Name, count(*) as top5_count
	from Formula1_Racing
	where Position <= 5
	group by Driver_Name
)

select d.Driver_Name
from Driver_Race_Count d
join  Top5_Finishes t
on d.Driver_Name = t.Driver_Name
where cast(t.top5_count as float) / d.total_races >= 0.25;
GO

-- Calculate each drivers ranking per season based on their average position,
-- and show only the top 3 ranked drivers for each season

GO

-- For each season, calculate the average position per driver and rank them, then show
-- drivers who improved their rank compared to the previous season
With Driver_Avg_Position as (
	select Driver_Name, Season, AVG(cast(Position as float)) as avg_position
	from Formula1_Racing
	group by Driver_Name, Season
),
Rank_drivers as (
	select  Driver_Name, Season, avg_position,
			RANK() over (partition by season order by avg_position) as driver_rank
	from Driver_Avg_Position
)

--select Driver_Name, Season, avg_position, driver_rank
--from Rank_drivers
--where driver_rank <= 3
--order by Season, driver_rank;

select current_season.Driver_Name, current_season.Season, current_season.driver_rank, 
	previous_season.driver_rank as previous_rank
from Rank_drivers current_season
join Rank_drivers previous_season
on current_season.Driver_Name = previous_season.Driver_Name
and current_season.Season = previous_season.Season + 1
where current_season.driver_rank < previous_season.driver_rank
order by current_season.Season;
GO

-- Calculate the avg points per driver per team and display only drivers for more than 1 team
with Driver_Team_Points as (
	select Driver_Name, Team, AVG(cast(Points as float)) as avg_points
	from Formula1_Racing
	group by Driver_Name, Team
),
Team_Count as ( 
	select  Driver_Name, COUNT(distinct Team) as team_ct
	from Formula1_Racing
	group by Driver_Name
)
select d.Driver_Name, d.Team, d.avg_points
from Driver_Team_Points d
join Team_Count t
on d.Driver_Name = t.Driver_Name
where t.team_ct > 1
order by d.Driver_Name, d.Team;
GO


