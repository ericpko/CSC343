-- Set the search path so we don't need to include the FROM parlgov.election ...
set search_path to parlgov;


-- Note: We always DROP before a CREATE so we can rerun the file
--       on a fresh instance of the DB.

--------- Drop all the views before recreating them ---------
drop view if exists Answer cascade;
drop view if exists Correct cascade;
drop view if exists NotCorrect cascade;
drop view if exists AvgYear cascade;
drop view if exists Ratio cascade;



--------- Create all the views ---------
create view Ratio as
select date_part('year', e_date) as year, (cast(votes_cast as float) / electorate) as participationRatio, country_id
from election
where e_date >= '2001-01-01' and e_date <= '2016-12-31';



create view AvgPerYear as
select country_id, year, avg(participationRatio) as participationRatio
from Ratio
group by country_id, year;



create view NotCorrect as
select distinct AY1.country_id
from AvgPerYear AY1 join AvgPerYear AY2 on AY1.country_id = AY2.country_id
where AY1.participationRatio > AY2.participationRatio
    and AY1.year < AY2.year;



create view Correct as
(select country_id
from Ratio)
except
(select country_id
from NotCorrect);



create view Answer as
select C.name as countryName, year, participationRatio
from country C, Correct Cor, AvgPerYear AY
where Cor.country_id = AY.country_id and Cor.country_id = C.id;







--------- Create the table and insert our result ---------

-- Drop the table, if one exists
drop table if exists q5 cascade;

-- Create a new table to insert our result from Answer
create table q5(
    countryName varchar(50),
    year int,
    participationRatio real
);



-- Insert the answer into the table
insert into q5
select *
from Answer;



-- Drop all the views again since we don't need them
drop view if exists Answer cascade;
drop view if exists Correct cascade;
drop view if exists NotCorrect cascade;
drop view if exists AvgYear cascade;
drop view if exists Ratio cascade;
