-- Identify the 5 oldest users from the provided database 
select Top 5 created_at, username
from ig_clone.dbo.users
order by created_at asc;
GO

-- Identifry users who have never posted a single photo on instagram
select u.id, u.username
from ig_clone.dbo.users u
left join ig_clone.dbo.photos p
on p.user_id = u.id
where p.id is null;
GO

-- Determine the winner of the contest and provide their details to the team
select top 1 p.id, u.username, p.image_url, p.user_id, COUNT(l.user_id) as like_count
from ig_clone.dbo.photos p
join ig_clone.dbo.likes l
on p.id = l.photo_id
join ig_clone.dbo.users u
on p.user_id = u.id
group by p.id,
		 u.username,
		 p.image_url, 
		 p.user_id
order by like_count desc;
GO

-- Identify and suggest the top 5 most commonly used hastags on the platform
select top 5 t.tag_name, COUNT(*) as tag_count
from ig_clone.dbo.photo_tags pt
join ig_clone.dbo.tags t
on pt.tag_id = t.id
group by t.tag_name
order by tag_count desc
GO

-- Determine the day of week when most users regsiter on instagram. Provide insights on when to schedule an ad campaign
--SET DATEFIRST 1
select top 1 DATEPART(WEEKDAY, created_at) as day_number,
		DATENAME(WEEKDAY, created_at) as day_of_week,
		COUNT(*) as max_day_count
from ig_clone.dbo.users
group by  DATEPART(WEEKDAY, created_at), DATENAME(WEEKDAY, created_at)
order by max_day_count desc;
GO

-- Calculate average number of posts per user on instagram
with Total_Posts_Per_User as (
	select u.id, count(p.id) as post_count
	from ig_clone.dbo.users u
	left join ig_clone.dbo.photos p
	on u.id = p.user_id
	group by u.id
	--order by post_count desc
)
select AVG(cast(post_count as float)) as avg_post_count
from Total_Posts_Per_User;
GO

--- OR 
select (
	(select count(*) from ig_clone.dbo.photos )/ (select count(*) from ig_clone.dbo.users)
) as avg_ph_cnt;
GO

-- Identify users (potenstial bots) who have liked every single photo on the site, as this is not typically 
-- possible for normal user
select u.id, u.username
from ig_clone.dbo.users u
where 
	(select COUNT(*) from photos) = (select COUNT(*) from likes l where l.user_id = u.id);
GO