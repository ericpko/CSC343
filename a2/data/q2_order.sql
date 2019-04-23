-- Set the search path so we don't need to include the FROM parlgov.election ...
set search_path to parlgov;



select *
from q2
order by countryName asc, partyName asc, stateMarket desc;
