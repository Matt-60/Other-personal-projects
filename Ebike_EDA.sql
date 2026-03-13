-- Google BigQuery dialect

SELECT * FROM `crested-trilogy-485717-s0.Ebike.rides` LIMIT 1000;

SELECT * FROM `crested-trilogy-485717-s0.Ebike.stations` LIMIT 1000;

SELECT * FROM `crested-trilogy-485717-s0.Ebike.users` LIMIT 1000;

SELECT
(SELECT COUNT(*) FROM `Ebike.rides`) AS total_rides,
(SELECT COUNT(*) FROM `Ebike.users`) AS total_users,
(SELECT COUNT(*) FROM `Ebike.stations`) AS total_stations;

SELECT
  COUNTIF(ride_id IS NULL) AS null_ride_ids,
  COUNTIF(user_id IS NULL) AS null_user_id,
  COUNTIF(start_time IS NULL) AS null_start_time,
  COUNTIF(end_time IS NULL) AS null_end_time
FROM `Ebike.rides`;

SELECT
    MIN(distance_km) AS min_dist,
    MAX(distance_km) AS max_dist,
    AVG(distance_km) AS avg_dist,
    MIN(TIMESTAMP_DIFF(end_time, start_time, MINUTE)) AS min_duration_mins,
    MAX(TIMESTAMP_DIFF(end_time, start_time, MINUTE)) AS max_duration_mins,
    AVG(TIMESTAMP_DIFF(end_time, start_time, MINUTE)) AS avg_duration_mins
FROM `Ebike.rides`;

SELECT
    COUNTIF(TIMESTAMP_DIFF(end_time, start_time, MINUTE) < 2) AS short_duration_trips,
    COUNTIF(distance_km = 0) AS zero_distance_trips
FROM `Ebike.rides`;

SELECT
    u.membership_level,
    COUNT(r.ride_id) AS total_rides,
    AVG(r.distance_km) AS avg_distance_km,
    AVG(TIMESTAMP_DIFF(r.end_time, r.start_time, MINUTE)) AS avg_duration_mins
FROM `Ebike.rides` AS r
JOIN `Ebike.users` AS u
    ON r.user_id = u.user_id
GROUP BY u.membership_level
ORDER BY total_rides;


SELECT
    EXTRACT(HOUR FROM start_time) AS hour_of_day,
    COUNT(*) AS ride_COUNT
FROM `Ebike.rides`
GROUP BY 1
ORDER BY 1;

SELECT
    s.station_name,
    COUNT(r.ride_id) AS total_starts
FROM `Ebike.rides` AS r
JOIN `Ebike.stations` AS s
    ON r.start_station_id = s.station_id
GROUP BY s.station_name
ORDER BY total_starts DESC
LIMIT 10;

SELECT
    CASE
        WHEN TIMESTAMP_DIFF(end_time, start_time, MINUTE) <= 10 THEN 'Short (<10m)'
        WHEN TIMESTAMP_DIFF(end_time, start_time, MINUTE) BETWEEN 11 AND 30 THEN 'Medium (11-30m)'
        ELSE 'Long (>30m)'
    END AS ride_category,
    COUNT(*) AS COUNT_of_rides
FROM `Ebike.rides`
GROUP BY ride_category
ORDER BY COUNT_of_rides DESC;

WITH departures AS (
    SELECT start_station_id, COUNT(*) AS total_departures
    FROM `Ebike.rides`
    GROUP BY 1
),

arrivals AS (
    SELECT end_station_id, COUNT(*) AS total_arrivals
    FROM `Ebike.rides`
    GROUP BY 1
)

SELECT
    s.station_name,
    d.total_departures,
    a.total_arrivals,
    (a.total_arrivals - d.total_departures) AS net_flow
FROM `Ebike.stations` AS s
JOIN departures d ON s.station_id = d.start_station_id
JOIN arrivals a ON s.station_id = a.end_station_id
ORDER BY net_flow ASC;

WITH monthly_signups AS (
    SELECT
        DATE_TRUNC(created_at, MONTH) AS signup_month,
        COUNT(user_id) AS new_user_COUNT
    FROM `Ebike.users`
    GROUP BY signup_month
)

SELECT
    signup_month,
    new_user_COUNT,
    LAG(new_user_COUNT) OVER (ORDER BY signup_month) AS previous_month_COUNT,
    (new_user_COUNT - LAG(new_user_COUNT) OVER (ORDER BY signup_month)) /
        NULLIF(LAG(new_user_COUNT) OVER (ORDER BY signup_month), 0) * 100 AS mom_growth
FROM monthly_signups
ORDER BY signup_month