CREATE OR REPLACE FUNCTION utility.fn_generate_dates(
   dt1  date,
   dt2  date,
   n    int
) RETURNS SETOF date AS
$$
	SELECT $1 + i
	FROM generate_series(0, $2 - $1, $3) i;
$$ LANGUAGE 'sql' IMMUTABLE;
