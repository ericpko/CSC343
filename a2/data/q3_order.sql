set search_path to parlgov;



select *
from q3
order by countryName asc, wonElections asc, partyName desc;
