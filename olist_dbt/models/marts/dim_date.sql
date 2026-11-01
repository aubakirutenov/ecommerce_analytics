-- Generated calendar, not read from a source table.
SELECT
    d::date AS date,
    EXTRACT(YEAR FROM d)::int AS year,
    EXTRACT(QUARTER FROM d)::int AS quarter,
    EXTRACT(MONTH FROM d)::int AS month,
    TO_CHAR(d, 'Mon') AS month_name,
    TO_CHAR(d, 'YYYY-MM') AS year_month,
    TO_CHAR(d, 'Dy') AS weekday_name
FROM generate_series('2016-09-01'::date, '2018-10-31'::date, interval '1 day') AS d