-- Netflix Project

Create table Netflix(
	show_id  varchar(10), --using varchar because show_id has alphanumeric value
	type     varchar(10),
	title    varchar(120),
	director varchar(250),
	casts    varchar(800),
	country  varchar(150),
	date_added  varchar(50) ,
	release_year INT,
	rating varchar(10),
	duration  varchar(15),
	listed_in varchar(100),
	description varchar(280)
)

-- Import the data after downlading it from Kaggle dataset: Netflix Movies and TV Shows.

-- Select * from Netflix

-- 1. Count the number of Movies vs TV Shows

select type, 
count(*) as total_content
from netflix 
group by type

-- 2. Find the most common rating for movies and TV shows

Select type, 
rating
from
	(Select type, 
	rating,
	count(*),
	rank() over(partition by type order by count(*) desc) as ranking
	from netflix
	group by 1,2
	) t1
where ranking = 1

-- 3. List all movies released in a specific year (e.g., 2020)

select * from netflix
where type = 'Movie'
and
release_year = 2020

--4. Find the top 5 countries with the most content on Netflix

select 
unnest(string_to_array(country,',')) as new_country,
count(show_id) as total_content
from netflix
group by 1 
order by 2 desc
limit 5

--5. Identify the longest movie

select title, duration from netflix
where type = 'Movie'
and duration = (select max(duration) from netflix)
limit 5

--6. Find content added in the last 5 years

select *
	from netflix
	where
	to_date(date_added, 'month dd, yyyy')
	>= current_date - Interval '5 years'

--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

select * 
	from netflix
	where director like '%Rajiv Chilaka%'

--8. List all TV shows with more than 5 seasons

select * from netflix
where type = 'TV Show'
and split_part(duration,' ',1)::numeric > 5

--9. Count the number of content items in each genre

select unnest(string_to_array(listed_in,',')) genre,
count(show_id) total_count
from netflix
group by 1

--10.Find each year and the average numbers of content release in India on netflix. 
--return top 5 year with highest avg content release!

select 
extract(year from to_date(date_added, 'Month DD, YYYY')) date,
count(*) yearly_content,
round(count(*):: numeric/(select count(*) from netflix 
where country = 'India'),2)::numeric * 100 avg_content_per_year
from netflix
where country = 'India'
group by 1

--11. List all movies that are documentaries

select * from netflix
where listed_in Ilike '%documentaries%'

12. Find all content without a director

select * from netflix 
where director is null

--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

select * from netflix
where casts ilike '%Salman Khan%'
and release_year > extract(year from current_date) - 10

--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

select 
unnest(string_to_array(casts,',')) actors,
count(*) total_content
from netflix
where country ilike '%India%'
group by 1 
order by 2 desc
limit 10

--15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Bad' and all other 
-- content as 'Good'. Count how many items fall into each category.

with new_table
as
(
select *,
case when description ilike '%kill%' or
	      description ilike '%violence%' then 
		  'bad_content'
		  else 'good_content'
	 end category
from netflix
)
select category,
       count(*) total_content
from new_table
group by 1
order by 1 desc
















