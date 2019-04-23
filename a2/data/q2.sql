-- Set the search path so we don't need to include the FROM parlgov.election ...
set search_path to parlgov;


-- Note: We always DROP before a CREATE so we can rerun the file
--       on a fresh instance of the DB.

--------- Drop all the views before recreating them ---------
drop view if exists AllCabinetParties cascade;
drop view if exists TotalCabinetCount cascade;
drop view if exists PartyCount cascade;
drop view if exists CommittedParties cascade;
drop view if exists CommittedPartiesCountry cascade;
drop view if exists Answer cascade;




--------- Create all the views ---------

-- Finds all parties in the cabinet for the past 20 years
create view AllCabinetParties as
SELECT c.id, c.country_id,c.start_date, cp.party_id, p.name 
FROM cabinet c,cabinet_party cp, party p 
WHERE c.id=cp.cabinet_id and cp.party_id = p.id 
and  date_part('year', start_date) > date_part('year', CURRENT_Date)-21;

--Find the total number of cabinets in the past 20 years
create view TotalCabinetCount as
 SELECT count(distinct c.start_date) as cabinetcount, c.country_id
 FROM cabinet c,cabinet_party cp 
 WHERE c.id=cp.cabinet_id 
 and  date_part('year', start_date) > date_part('year', CURRENT_Date)-21 
 group by c.country_id;

--Find the number of times a party has appeared in the cabinet for the past 20 years
create view PartyCount as
SELECT count(cp.party_id) as partynum, c.country_id,cp.party_id
FROM cabinet c,cabinet_party cp 
WHERE c.id=cp.cabinet_id and  date_part('year', start_date) > date_part('year', CURRENT_Date)-21 
group by c.country_id, cp.party_id;

--Find all committed parties. If the number of times a party appears in the past 20 years in cabinet 
--is equal to the total cabinet count then its a committed parties
create view CommittedParties as
select t.country_id, p.party_id
from TotalCabinetCount t, PartyCount p
where t.country_id=p.country_id
and t.cabinetcount=p.partynum;

--All committed parties and their country 
create view CommittedPartiesCountry as
select c.name as countryname, p2.name as partyname, p1.party_id
from CommittedParties p1, country c, party p2
where p1.party_id = p2.id and p1.country_id = c.id;

--Final result
create view Answer as
select p1.countryname as countryname, p1.partyname as partyname, f1.family as partyfamily, pos.state_market as statemarket
from CommittedPartiesCountry p1 left join party_family f1 on p1.party_id=f1.party_id
left join party_position pos on p1.party_id=pos.party_id;


--------- Create the table and insert our result ---------

-- Drop the table, if one exists
 drop table if exists q2 cascade;

-- Create a new table to insert our result from Answer
 create table q2(
     countryName varchar(50) not null,
     partyName varchar(100) not null,
     partyFamily varchar(50),
     stateMarket real check(statemarket >= 0.0 AND statemarket <= 10.0)
 );



-- Insert the answer into the table
   insert into q2
   select *
   from Answer;



-- -- Drop all the views again since we don't need them
drop view if exists AllCabinetParties cascade;
drop view if exists TotalCabinetCount cascade;
drop view if exists PartyCount cascade;
drop view if exists CommittedParties cascade;
drop view if exists CommittedPartiesCountry cascade;
drop view if exists Answer cascade;

