drop table if exists stop_times;
CREATE TABLE `stop_times` (
  `trip_id` varchar(255) DEFAULT NULL,
  `arrival_time` varchar(255) NOT NULL,
  `departure_time` varchar(255) NOT NULL,
  `actual_arrival_time` int(11) default null,
  `actual_departure_time` int(11) default null,
  `stop_id` varchar(255) DEFAULT NULL,
  `stop_sequence` int(11) NOT NULL,
  `stop_headsign` varchar(255) DEFAULT NULL,
  `pickup_type` varchar(255) DEFAULT NULL,
  `drop_off_type` varchar(255) DEFAULT NULL,
  `shape_dist_traveled` varchar(255) DEFAULT NULL,
  KEY `idx1` (`trip_id`,`actual_departure_time`,`stop_sequence`),
  KEY `idx2` (`trip_id`,`actual_arrival_time`,`stop_sequence`),
  KEY `idx3` (`trip_id`,`stop_sequence`,`actual_departure_time`),
  KEY `idx4` (`trip_id`,`stop_sequence`,`actual_arrival_time`)
);
LOAD DATA LOCAL INFILE 'data/stop_times.txt'
 IGNORE INTO TABLE stop_times
 FIELDS TERMINATED BY ','
 OPTIONALLY ENCLOSED BY '"'
 LINES TERMINATED BY '\n'
 IGNORE 1 LINES
 (trip_id, arrival_time, departure_time, stop_id, stop_sequence, stop_headsign, pickup_type, drop_off_type, shape_dist_traveled)
;
update stop_times set actual_arrival_time = substring_index(SUBSTRING_INDEX(arrival_time, ':', 1), ':', -1) * 60 * 60 + substring_index(SUBSTRING_INDEX(arrival_time, ':', 2), ':', -1) * 60 + substring_index(SUBSTRING_INDEX(arrival_time, ':', 3), ':', -1) where arrival_time != '';
update stop_times set actual_departure_time = substring_index(SUBSTRING_INDEX(departure_time, ':', 1), ':', -1) * 60 * 60 + substring_index(SUBSTRING_INDEX(departure_time, ':', 2), ':', -1) * 60 + substring_index(SUBSTRING_INDEX(departure_time, ':', 3), ':', -1) where departure_time != '';

alter table trips add index idx1 (trip_id, service_id);

update stop_times set arrival_time = str_to_date(arrival_time, '%k:%i:%s');
update stop_times set departure_time = str_to_date(departure_time, '%k:%i:%s');

alter table stop_times modify column arrival_time time not null;
alter table stop_times modify column departure_time time not null;
alter table stop_times modify column stop_sequence int(11) not null;



drop procedure if exists find_routes;
delimiter ;;
CREATE PROCEDURE `find_routes`(now datetime)
BEGIN

declare current_service_id varchar(255);
declare now_time int(11);

set current_service_id = (select (case dayofweek(now)
  when 1 then (select service_id from calendar where sunday = 1 and date(now) between str_to_date(start_date, '%Y%m%d') and str_to_date(end_date, '%Y%m%d'))
  when 2 then (select service_id from calendar where monday = 1 and date(now) between str_to_date(start_date, '%Y%m%d') and str_to_date(end_date, '%Y%m%d'))
  when 3 then (select service_id from calendar where tuesday = 1 and date(now) between str_to_date(start_date, '%Y%m%d') and str_to_date(end_date, '%Y%m%d'))
  when 4 then (select service_id from calendar where wednesday = 1 and date(now) between str_to_date(start_date, '%Y%m%d') and str_to_date(end_date, '%Y%m%d'))
  when 5 then (select service_id from calendar where thursday = 1 and date(now) between str_to_date(start_date, '%Y%m%d') and str_to_date(end_date, '%Y%m%d'))
  when 6 then (select service_id from calendar where friday = 1 and date(now) between str_to_date(start_date, '%Y%m%d') and str_to_date(end_date, '%Y%m%d'))
  when 7 then (select service_id from calendar where saturday = 1 and date(now) between str_to_date(start_date, '%Y%m%d') and str_to_date(end_date, '%Y%m%d'))
end));

set now_time = timestampdiff(second, concat(date(now), ' 12:00:00'), now) + timestampdiff(second, concat(date(now), ' 00:00:00'), concat(date(now), ' 12:00:00'));



select
  u.route_id,
  u.trip_id,
  if(u.timediff1 + u.timediff2 = 0, u.start_lat, u.start_lat + (u.timediff1 / (u.timediff1 + u.timediff2)) * (u.end_lat - u.start_lat)) as current_lattitude,
  if(u.timediff1 + u.timediff2 = 0, u.start_lon, u.start_lon + (u.timediff1 / (u.timediff1 + u.timediff2)) * (u.end_lon - u.start_lon)) as current_longitude,
  u.start_stop_id as start_stop_id,
  u.start_lat as start_lattitude,
  u.start_lon as start_longitude,
  u.end_stop_id as end_stop_id,
  u.end_lat as end_lattitude,
  u.end_lon as end_longitude,
  if(u.timediff1 + u.timediff2 = 0, 0, (u.end_lat - u.start_lat) / (u.timediff1 + u.timediff2)) as velocity_lattitude,
  if(u.timediff1 + u.timediff2 = 0, 0, (u.end_lon - u.start_lon) / (u.timediff1 + u.timediff2)) as velocity_longitude,
  u.timediff1 as seconds_at_velocity,
  u.timediff2 as seconds_until_velocity_change,
  if(u.timediff1 + u.timediff2 = 0, 0, (u.timediff1 / (u.timediff1 + u.timediff2))) as progress
from (
select
 t.route_id,
 t.trip_id,
 s1.stop_id as start_stop_id,
 s1.stop_lat as start_lat,
 s1.stop_lon as start_lon,
 s2.stop_id as end_stop_id,
 s2.stop_lat as end_lat,
 s2.stop_lon as end_lon,
 now_time - st1.actual_departure_time as timediff1,
 st2.actual_arrival_time - now_time as timediff2,
 st1.actual_departure_time,
 now_time,
 st2.actual_arrival_time
from (
select t.route_id, t.trip_id, max(s1.stop_sequence) ss1, min(s2.stop_sequence) ss2
  from trips t
  join stop_times s1 on t.trip_id = s1.trip_id and now_time >= s1.actual_departure_time
  join stop_times s2 on t.trip_id = s2.trip_id and now_time <= s2.actual_arrival_time
  where t.service_id = current_service_id
  group by t.trip_id
  having ss1 is not null and ss2 is not null
) t
join stop_times st1 on st1.trip_id = t.trip_id and st1.stop_sequence = t.ss1
join stops s1 on s1.stop_id = st1.stop_id
join stop_times st2 on st2.trip_id = t.trip_id and st2.stop_sequence = t.ss2
join stops s2 on s2.stop_id = st2.stop_id
) u
order by 1,2
;
end ;;
delimiter ;

-- call find_routes('2015-11-08 00:00:00');

