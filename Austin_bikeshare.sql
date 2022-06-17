use Bikeshare

		-- Viewing the datasets

select * from dbo.Trips
select * from dbo.stations


		-- Joining tables to bring gps coordinates for starting stations

select *
into TripsA
From dbo.Trips as t
inner join dbo.stations as s
on t.start_station_id = s.station_id

Exec sp_rename 'TripsA.Longitude', 'start_longitude', 'Column' 
Exec sp_rename 'TripsA.Latitude', 'start_Latitude', 'Column' 
Exec sp_rename 'TripsA.location', 'start_location', 'Column' 

alter table TripsA drop column station_id, name, status

		-- Joining tables to bring gps coordinates for ending stations

select *
into TripsB
From dbo.TripsA as t
inner join dbo.stations as s
on t.end_station_id = s.station_id

Exec sp_rename 'TripsB.Longitude', 'end_longitude', 'Column' 
Exec sp_rename 'TripsB.Latitude', 'end_Latitude', 'Column' 
Exec sp_rename 'TripsB.location', 'end_location', 'Column' 

alter table TripsB drop column station_id, name, status

		-- Searching for nulls

select
	sum(case when bikeid is null then 1 else 0 end) a, --672
	sum(case when checkout_time is null then 1 else 0 end) b,
	sum(case when duration_minutes is null then 1 else 0 end) c,
	sum(case when end_station_id is null then 1 else 0 end) d,
	sum(case when month is null then 1 else 0 end) e, --30726
	sum(case when start_station_id is null then 1 else 0 end) f,
	sum(case when start_time is null then 1 else 0 end) g,
	sum(case when subscriber_type is null then 1 else 0 end) h, --2077
	sum(case when trip_id is null then 1 else 0 end) i,
	sum(case when year is null then 1 else 0 end) j, -- 30726
	sum(case when start_Latitude is null then 1 else 0 end) k,
	sum(case when start_location is null then 1 else 0 end) l,
	sum(case when start_longitude is null then 1 else 0 end) m,
	sum(case when end_Latitude is null then 1 else 0 end) n,
	sum(case when end_location is null then 1 else 0 end) o,
	sum(case when end_longitude is null then 1 else 0 end) p	
from TripsB

select *
from TripsB
where bikeid is null

select *
from TripsB
where month is null

select *
from TripsB
where subscriber_type is null

		-- using a value to represent unknown bikeid

update TripsB
set bikeid = 9999
where bikeid is null

		-- using date to fill in null values for month and year columns

select *, month(start_time) as month1, year(start_time) as year1
into TripsC
from TripsB

update TripsC
set month = month1

update TripsC
set year = year1

select * from TripsC

		-- Splitting up date and time into separate columns

alter table TripsC
add NewDate date

alter table TripsC
add NewTime time

update TripsC
set NewDate = convert(date, start_time)

update TripsC
set NewTime = convert(time(0), start_time)

select dayofweek(NewTime())
from TripsC

		-- fill null values in subscriber_type with unknown

update TripsC
set subscriber_type = 'unknown'
where subscriber_type is null

		-- Checking for duplicates

select trip_id, count(trip_id)
from TripsC
group by trip_id
having count(trip_id) > 1


select * from TripsB

					-- Exploratory Analysis

		--1. What month did the most bike rides

select month, count(month) as rides
from TripsC
group by month
order by rides desc

		--2. What is the average duration of all rides? Which months did above average and below? Which stations were above average or below average?

-- Overall Average trip time
select avg(duration_minutes)
from TripsC

-- Months with above average trip time
select month, avg(duration_minutes) as rides
from TripsC
group by month
having avg(duration_minutes) > (
	select avg(duration_minutes)
	from TripsC
	)
order by rides desc

-- Months with below average trip time
select month, avg(duration_minutes) as rides
from TripsC
group by month
having avg(duration_minutes) < (
	select avg(duration_minutes)
	from TripsC
	)
order by rides desc

--Stations with above average trip duration
select start_station_name, avg(duration_minutes) as rides
from TripsC
group by start_station_name
having avg(duration_minutes) > (
	select avg(duration_minutes)
	from TripsC
	)
order by rides desc

--Stations with below average trip duration
select month, avg(duration_minutes) as rides
from TripsC
group by month
having avg(duration_minutes) < (
	select avg(duration_minutes)
	from TripsC
	)
order by rides desc



		--3 How many trips were made by each membership type? What kiosk do walk ups use the most?  What is the average time ride per membership?

--Number of trips per membership type
select subscriber_type, count(subscriber_type) as num
from TripsC
group by subscriber_type
order by num desc

--number of subscribers per starting kiosk
select start_station_name, count(start_station_name) as num
from TripsC
where subscriber_type = 'Walk Up'
group by start_station_name
order by num desc

--average ride duration per membership type
select subscriber_type, avg(duration_minutes) as average_ride
from TripsC
group by subscriber_type
order by average_ride desc


--3. Which kiosk is used the most?  The least?  Which stations have missing bike_ids

-- stations with the most rides
select start_station_name, count(*) as rides
from TripsC
group by start_station_name
order by rides desc

-- stations with the least rides
select start_station_name, count(*) as rides
from TripsC
group by start_station_name
order by rides asc

-- stations with the most frequent usages of bikes with unknown id
select start_station_name, count(*) rides, end_station_name, count(*) as rides2
from TripsC
where bikeid = 9999
group by start_station_name, end_station_name
order by rides desc

-- round trip rides per station based on membership type
select start_station_name, subscriber_type, count(*) as rides
from TripsC
where start_station_name = end_station_name
group by start_station_name, subscriber_type
order by subscriber_type, rides desc


-- End

