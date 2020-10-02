-- Checksum calculator from record_number::int
create or replace function pg_temp.rnumChecksum(rnum int) returns char(1) as 
	$$ 
	select coalesce(
	  nullif(
	  (
		  -- Check digit calculation by Jim Nicholls. 
		  -- The University of Sydney.
		  ( rnum % 10 ) * 2
			+ ( rnum / 10 % 10 ) * 3
			+ ( rnum / 100 % 10 ) * 4
			+ ( rnum / 1000 % 10 ) * 5
			+ ( rnum / 10000 % 10 ) * 6
			+ ( rnum / 100000 % 10 ) * 7
			+ ( rnum / 1000000 ) * 8
	  ) % 11, 10 )::char(1), 'x' )
	$$ 
  language sql;

-- Create SDA/Create List formatted record number with checkdigit 
-- from record_type_code::char(1) and record_number::int
create or replace function pg_temp.rnum2sdanum(rtype char(1), rnum int) returns varchar as 
	$$ select rtype || rnum || pg_temp.rnumChecksum(rnum) $$
  language sql;

-- Create SDA/Create List formatted record number with checkdigit 
-- from record_id::bigint
create or replace function pg_temp.id2sdanum(_id bigint) returns varchar as 
    $$ 
	  declare
	    reckey text = id2reckey(_id);
	  begin
	    return (select reckey || pg_temp.rnumChecksum(substr(reckey,2)::int));
	  end;
	$$
  language plpgsql;


-- Examples
select  
  -- Call rnum2sdanum if you have the _view data, giving it the type code and rnumber
  pg_temp.rnum2sdanum(pv.record_type_code, pv.record_num) as "SDA Patron Number (from record_type and record_num)",
  
  -- Call id2sdanum if you have the id
  pg_temp.id2sdanum(br.record_id) as "SDA Bib Number (from record_id)"
  
  from 
    sierra_view.patron_view as pv
  cross join	-- don't actually use this for anything limited to more than a few results...
                -- it's a terribly inefficient and misleading kludge.
	sierra_view.bib_record as br
	
  limit 5
;
