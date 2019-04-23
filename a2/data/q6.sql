-- Set the search path so we don't need to include the from parlgov.election ...
set search_path to parlgov;


-- Note: We always DROP before a create so we can rerun the file
--       on a fresh instance of the DB.

--------- Drop all the views before recreating them ---------
drop view if exists Answer cascade;
drop view if exists Range5 cascade;
drop view if exists Range4 cascade;
drop view if exists Range3 cascade;
drop view if exists Range2 cascade;
drop view if exists Range1 cascade;
drop view if exists Parties cascade;
drop view if exists AllPartyPos cascade;


--------- Create all the views ---------

create view AllPartyPos as
select PP.party_id, PP.left_right, P.country_id
from party_position PP, party P
where PP.party_id = P.id;


create view Parties as
select C.name as countryName, APP.party_id, APP.left_right
from country C left join AllPartyPos APP on APP.country_id = C.id;


-- Range [0,2)
create view Range1 as
select countryName, count(party_id) r0_2
from Parties
where left_right is null or (left_right >= 0 and left_right < 2)
group by countryName;

-- Range [2,4)
create view Range2 as
select countryName, count(party_id) r2_4
from Parties
where left_right is null or (left_right >= 2 and left_right < 4)
group by countryName;

-- Range [4,6)
create view Range3 as
select countryName, count(party_id) r4_6
from Parties
where left_right is null or (left_right >= 4 and left_right < 6)
group by countryName;

-- Range [6,8)
create view Range4 as
select countryName, count(party_id) r6_8
from Parties
where left_right is null or (left_right >= 6 and left_right < 8)
group by countryName;

-- Range [8,10]
create view Range5 as
select countryName, count(party_id) r8_10
from Parties
where left_right is null or (left_right >= 8 and left_right <= 10)
group by countryName;


create view Answer as
select countryName, r0_2, r2_4, r4_6, r6_8, r8_10
from Range1 natural join Range2 natural join Range3 natural join Range4 natural join Range5;



--------- Create the table and insert our result ---------

-- Drop the table, if one exists
drop table if exists q6 cascade;

-- Create a new table to insert our result from Answer
create table q6(
    countryName varchar(50),
    r0_2 int,
    r2_4 int,
    r4_6 int,
    r6_8 int,
    r8_10 int
);



-- Insert the answer into the table
insert into q6
select *
from Answer;




-- Drop all the views again since we don't need them
drop view if exists Answer cascade;
drop view if exists Range5 cascade;
drop view if exists Range4 cascade;
drop view if exists Range3 cascade;
drop view if exists Range2 cascade;
drop view if exists Range1 cascade;
drop view if exists Parties cascade;
drop view if exists AllPartyPos cascade;
