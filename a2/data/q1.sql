-- Set the search path so we don't need to include the FROM parlgov.election ...
set search_path to parlgov;


-- Note: We always DROP before a CREATE so we can rerun the file
--       on a fresh instance of the DB.

--------- Drop all the views before recreating them ---------
drop view if exists AlliedPairs cascade;
drop view if exists AlliedPartiesPerCountry cascade;
drop view if exists ElectionsPerCountry cascade;
drop view if exists Answer cascade;




--------- Create all the views ---------

-- Each tuple is part of an alliance
create view AlliedPairs as
select ER1.party_id as alliedPartyId1, ER2.party_id as alliedPartyId2,
       ER1.election_id, ER1.alliance_id as alliance1, ER2.alliance_id as alliance2
from election_result ER1, election_result ER2
where ER1.party_id < ER2.party_id
    and ER1.election_id = ER2.election_id
    and (ER1.id = ER2.alliance_id or ER1.alliance_id = ER2.id or ER1.alliance_id = ER2.alliance_id);



-- Reports the number of times party1 and party2 has been allies in different elections in the same country
create view AlliedPartiesPerCountry as
select country_id as countryId, alliedPartyId1, alliedPartyId2, count(*) as numTimesBeenAllies
from AlliedPairs AP, election E
where AP.election_id = E.id
group by alliedPartyId1, alliedPartyId2, country_id;



-- Find the number of elections per country
create view ElectionsPerCountry as
select country_id as countryId, count(*) as numElections
from election
group by country_id;



-- Final result
create view Answer as
select APPC.countryId, APPC.alliedPartyId1, APPC.alliedPartyId2
from AlliedPartiesPerCountry APPC
where exists (
    select *
    from ElectionsPerCountry EPC
    where APPC.countryId = EPC.countryId
        and (cast(APPC.numTimesBeenAllies as float) / cast(EPC.numElections as float)) > 0.3
    );





--------- Create the table and insert our result ---------

-- Drop the table, if one exists
drop table if exists q1 cascade;

-- Create a new table to insert our result from Answer
create table q1(
    countryId int not null,
    alliedPartyId1 int not null,
    alliedPartyId2 int not null,
    PRIMARY KEY(countryId, alliedPartyId1, alliedPartyId2)
);



-- Insert the answer into the table
insert into q1
select *
from Answer;



-- Drop all the views again since we don't need them
drop view if exists AlliedPairs cascade;
drop view if exists AlliedPartiesPerCountry cascade;
drop view if exists ElectionsPerCountry cascade;
drop view if exists Answer cascade;






-- PopSQL

-- Each tuple is part of an alliance
-- create view parlgov.AlliedPairs as
-- select ER1.party_id as alliedPartyId1, ER2.party_id as alliedPartyId2, ER1.election_id, ER1.alliance_id as alliance1, ER2.alliance_id as alliance2
-- from parlgov.election_result ER1, parlgov.election_result ER2
-- where ER1.party_id < ER2.party_id
--     and ER1.election_id = ER2.election_id
--     and (ER1.id = ER2.alliance_id or ER1.alliance_id = ER2.id or ER1.alliance_id = ER2.alliance_id);



-- Reports the number of times party1 and party2 has been allies in different elections in the same country
-- create view parlgov.AlliedPartiesPerCountry as
-- select country_id as countryId, alliedPartyId1, alliedPartyId2, count(*) as numTimesBeenAllies
-- from parlgov.AlliedPairs AP, parlgov.election E
-- where AP.election_id = E.id
-- group by alliedPartyId1, alliedPartyId2, country_id;




-- Find the number of elections per country
-- create view parlgov.ElectionsPerCountry as
-- select country_id as countryId, count(*) as numElections
-- from parlgov.election
-- group by country_id;





-- create view parlgov.Answer as
-- select APPC.countryId, APPC.alliedPartyId1, APPC.alliedPartyId2
-- from parlgov.AlliedPartiesPerCountry APPC
-- where exists (
--     select *
--     from parlgov.ElectionsPerCountry EPC
--     where APPC.countryId = EPC.countryId
--         and (cast(APPC.numTimesBeenAllies as float) / cast(EPC.numElections as float)) > 0.3
--     );
