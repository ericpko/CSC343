-- Set the search path so we don't need to include the FROM parlgov.election ...
set search_path to parlgov;



--------- Drop all the views before recreating them ---------
drop view if exists Answer cascade;
drop view if exists AveragePercentVotes cascade;
drop view if exists VotePercentage cascade;




--------- Create all the views ---------

-- Step 1: Find the percentage of votes that are valid
create view VotePercentage as
select date_part('year', e_date) as year, country_id, party_id, ((cast(votes as float) / votes_valid) * 100) as votesPerValidVotes
from election E join election_result ER on E.id = ER.election_id;


-- Step 2: Find the average percent of valid votes per year, country, and political party
-- in case there is more than one election in the same year
create view AveragePercentVotes as
select year, country_id, party_id, avg(votesPerValidVotes) as votePercent
from VotePercentage
where year >= 1996 and year <= 2016 and votesPerValidVotes is not null
group by year, country_id, party_id;


-- Step 3: Filter the results in the select clause based off the ranges
create view Answer as
select AV.year, C.name as countryName,
    case
        when votePercent <= 5 then '(0-5]'
        when 5 < votePercent and votePercent <= 10 then '(5-10]'
        when 20 < votePercent and votePercent <= 30 then '(20-30]'
        when 30 < votePercent and votePercent <= 40 then '(30-40]'
        else '(40-100]'
    end as voteRange,
    P.name_short as partyName

from party P, AveragePercentVotes AV, country C
where AV.country_id = C.id
    and AV.party_id = P.id;






--------- Create the table and insert our result ---------

-- Drop the table, if one exists
drop table if exists q4 cascade;

-- Create a new table to insert our result from Answer
create table q4(
    year int,
    countryName varchar(50),
    voteRange varchar(20),
    partyName varchar(100)
);



-- Insert the answer into the table
insert into q4
select *
from Answer;



-- Drop all the views again since we don't need them
drop view if exists Answer cascade;
drop view if exists AveragePercentVotes cascade;
drop view if exists VotePercentage cascade;





-- PopSQL

-- Step 1: Find the percentage of votes that are valid
-- create view parlgov.VotePercentage as
-- select date_part('year', e_date) as year, country_id, party_id, ((cast(votes as float) / votes_valid) * 100) as votesPerValidVotes
-- from parlgov.election E join parlgov.election_result ER on E.id = ER.election_id;



-- Step 2: Find the average of the percent of valid votes per year, country, and political party
-- create view parlgov.AverageVotes as
-- select year, country_id, party_id, avg(votesPerValidVotes) as votePercent
-- from parlgov.VotePercentage
-- where year >= 1996 and year <= 2016 and votesPerValidVotes is not null
-- group by year, country_id, party_id;



-- Step 3: Find the
-- create view parlgov.Answer as
-- select AV.year, C.name as countryName,
--     case
--         when votePercent <= 5 then '(0-5]'
--         when 5 < votePercent and votePercent <= 10 then '(5-10]'
--         when 20 < votePercent and votePercent <= 30 then '(20-30]'
--         when 30 < votePercent and votePercent <= 40 then '(30-40]'
--         else '(40-100]'
--     end as voteRange,
--     P.name_short AS partyName

-- from parlgov.party P, parlgov.AverageVotes AV, parlgov.country C
-- where AV.country_id = C.id
--     and AV.party_id = P.id;
