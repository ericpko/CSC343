-- Set the search path so we don't need to include the FROM parlgov.election ...
set search_path to parlgov;



select *
from q5
order by countryName desc, year desc;
