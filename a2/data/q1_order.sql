-- Set the search path so we don't need to include the FROM parlgov.election ...
set search_path to parlgov;



select *
from q1
order by countryId desc, alliedPartyId1 desc, alliedPartyId2 desc;
