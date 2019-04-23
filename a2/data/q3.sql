-- Set the search path so we don't need to include the FROM parlgov.election ...
set search_path to parlgov;



--------- Drop all the views before recreating them ---------
drop view if exists Answer cascade;
drop view if exists RecentlyWon cascade;
drop view if exists TopParties cascade;
drop view if exists MoreThanThreeTimesParties cascade;
drop view if exists WinCount cascade;
drop view if exists PartyWinners cascade;
drop view if exists ElectionsPerParty cascade;
drop view if exists PartyElectionCount cascade;




--------- Create all the views ---------
-- Step 1:
create view PartyElectionCount as
select P.country_id, count(distinct P.id) as numParties, count(distinct E.id) as numElections
from party P, election E
where P.country_id = e.country_id
group by P.country_id;


-- Step 2:
create view ElectionsPerParty as
select C.name as countryName, (cast(PEC.numElections as float) / PEC.numParties) as average
from PartyElectionCount PEC, country C
where PEC.country_id = C.id;


-- Step 3:
create view PartyWinners as
select C.name as countryName, P.name, ER1.party_id, ER1.election_id, E.e_date
from party P, election E, election_result ER1, country C
where ER1.votes >= all (
    select ER2.votes
    from election_result ER2
    where ER1.election_id = ER2.election_id and ER2.votes is not null
    )
    and P.id = ER1.party_id
    and E.id = ER1.election_id
    and C.id = E.country_id;


-- Step 4:
create view WinCount as
select countryName, party_id, count(*) as numWins
from PartyWinners
group by countryName, party_id;


-- Step 5:
create view MoreThanThreeTimesParties as
select WC.party_id, WC.countryName
from ElectionsPerParty EPP, WinCount WC
where EPP.countryName = WC.countryName
    and WC.numWins > (EPP.average * 3);



-- Step 6:
create view TopParties as
select P.countryName, P.party_id, PF.family
from MoreThanThreeTimesParties P left join party_family PF on P.party_id = PF.party_id;



-- Step 7:
create view RecentlyWon as
select TP.countryName, TP.party_id, PW.name, TP.family, PW.election_id, PW.e_date
from TopParties TP, PartyWinners PW
where TP.party_id = PW.party_id
    and PW.e_date >=
    all (
        select e_date
        from PartyWinners PW2
        where TP.party_id = PW2.party_id
    );




-- Step 8:
create view Answer as
select RW.countryName, RW.name as partyName, RW.family as partyFamily, WC.numWins as wonElections,
    RW.election_id as mostRecentlyWonElectionId, date_part('year', RW.e_date) as mostRecentlyWonElectionYear
from RecentlyWon RW, WinCount WC
where RW.party_id = WC.party_id;








--------- Create the table and insert our result ---------

-- Drop the table, if one exists
drop table if exists q3 cascade;

-- Create a new table to insert our result from Answer
create table q3(
    countryName varchar(100),
    partyName varchar(100),
    partyFamily varchar(100),
    wonElections int,
    mostRecentlyWonElectionId int,
    mostRecentlyWonElectionYear int
);



-- Insert the answer into the table
insert into q3
select *
from Answer;





-- Drop all the views again since we don't need them
drop view if exists Answer cascade;
drop view if exists RecentlyWon cascade;
drop view if exists TopParties cascade;
drop view if exists MoreThanThreeTimesParties cascade;
drop view if exists WinCount cascade;
drop view if exists PartyWinners cascade;
drop view if exists ElectionsPerParty cascade;
drop view if exists PartyElectionCount cascade;
