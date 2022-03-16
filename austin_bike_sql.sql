### FIRST SQL PROJECT - AUSTIN BIKESHARE PROGRAM

use metrobikes;

## Creating the tables

create table Austinbike(
Trip_ID varchar(10),
Membership_Type char,
Bicycle_ID int,
Checkout_Date Date,
Checkout_Time Time,
Checkout_Kiosk_ID int,
Checkout_Kiosk char,
Return_Kiosk_ID int,
Return_Kiosk char,
Trip_Duration int,
MonthNumber int,
YearNumber int);

create table Austinlocation(
Kiosk_ID bigint,
Kiosk_name varchar(100),
Kiosk_status varchar(100),
Longitude varchar(100),
Latitude varchar(100),
Address varchar(100),
Alternate_name varchar(100),
City_Asset_Number bigint,
Property_Type varchar(100),
Docks bigint,
Power_Type varchar(100),
FootPrint int,
Footprint_Width int,
Notes varchar(100),
Council_District int,
Image char,
Mod_Date varchar(100));

create table austinreturns(
Kiosk_ID varchar(100),
Kiosk_name varchar(100),
longitude varchar(100),
latitude varchar(100),
address varchar(100));
    
## Altering tables	

alter table Austinbike
	Modify Trip_ID varchar(100),
	Modify Membership_Type varchar(100),
	modify Bicycle_ID varchar(100),
	Modify Checkout_Date varchar(10),
	Modify checkout_time varchar(20),
	modify Checkout_Kiosk_ID varchar(100),
	modify Checkout_kiosk varchar(100),
	modify Return_Kiosk_ID varchar(10),
	modify Return_Kiosk varchar(100),
	modify Trip_Duration varchar(100),
	modify MonthNumber varchar(100),
	modify YearNumber varchar(100);

alter table austinlocation
	modify City_Asset_Number varchar(100),
	modify Docks varchar(100),
	modify FootPrint varchar(100),
	modify Footprint_Width varchar(100),
	modify Council_District varchar(100),
	modify image varchar(100),
	modify Kiosk_ID varchar(100);

## Setting up for importing data

set unique_checks = 0;
set foreign_key_checks = 0;
set sql_log_bin=0;
set autocommit = 0;

set Global local_infile=1;

show variables like"secure_file_priv";

## Importing the data

LOAD DATA local INFILE
	"C:/Users/crazy/Documents/Austin_Bike.csv"
INTO TABLE austinbike
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
ignore 1 lines
(Trip_ID, Membership_Type, Bicycle_ID, Checkout_Date, Checkout_Time, Checkout_Kiosk_ID, Checkout_Kiosk, Return_Kiosk_ID, Return_Kiosk, Trip_Duration, MonthNumber, YearNumber);

LOAD DATA local INFILE
	"C:/Users/crazy/Documents/Metrobike_locations.csv"
INTO TABLE austinlocation
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
ignore 1 lines
(Kiosk_ID, Kiosk_name, Kiosk_status, Longitude, Latitude, Address, Alternate_name, City_Asset_Number, Property_Type, Docks, Power_Type, FootPrint, Footprint_Width, Notes, Council_District, image, Mod_Date);

LOAD DATA local INFILE
	"C:/Users/crazy/Documents/Metrobike_locations2.csv"
INTO TABLE austinreturns
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
ignore 1 lines
(Kiosk_ID, Kiosk_name, Longitude, Latitude, address);


       
## Checking to see if the data was imported correctly

select * from austinlocation;
select * from austinbike;

## Checking to see if all rows were imported
        
select count(Trip_ID) from austinbike;

## Fixing an error in the importing process of austinlocation table - column names were not aligned properly

alter table austinlocation change Mod_Date images varchar(100);
alter table austinlocation change image Council_district varchar(100);
alter table austinlocation change Council_District notes varchar(100);
alter table austinlocation change Notes footprint_width varchar(100);
alter table austinlocation change Footprint_Width footprint varchar(100);
alter table austinlocation change FootPrint power_type varchar(100);
alter table austinlocation change Power_Type docks varchar(100);
alter table austinlocation change Docks property_type varchar(100);
alter table austinlocation change Property_Type city_asset_number varchar(100);
alter table austinlocation change City_Asset_Number alternate_address varchar(100);
alter table austinlocation change Alternate_name main_address varchar(100);
alter table austinlocation drop Address;

alter table austinlocation change Checkout_Kiosk_ID checkoutKioskID varchar(100);
alter table austinreturns change Return_Kiosk_ID ReturnKioskiID varchar(100);
alter table austinlocation change Ckioskname Checkout_Kiosk_Name varchar(100);
alter table austinreturns change RKioskname Return_Kiosk_Name varchar(100);
alter table austinreturns change longitude Longitude2 varchar(100);
alter table austinreturns change latitude Latitude2 varchar(100);
alter table austinreturns change address address2 varchar(100);


select * from austinbike;

select *
from austinbike
where Checkout_Kiosk_ID = ' ';

## Checking for missing values in Checkout_Kiosk_ID

select count(Checkout_Kiosk_ID)
from austinbike
where Checkout_Kiosk_ID = ' ';
    
select distinct(Checkout_kiosk)
from austinbike
where Checkout_kiosk_ID = ' ';

## Turning off safe updates

SET sql_safe_updates = 0;
 
 ## Filling in missing values for Checkout_Kiosk_ID
 ## Researched the missing kiosk_ids online
 
UPDATE austinbike
SET Checkout_Kiosk_ID = 2574
WHERE Checkout_Kiosk='Zilker Park at Barton Springs & William Barton Drive';

UPDATE austinbike
SET Checkout_Kiosk_ID = 2539
WHERE Checkout_Kiosk='Convention Center/ 3rd & Trinity';

UPDATE austinbike
SET Checkout_Kiosk_ID = 2568
WHERE Checkout_Kiosk='East 11th Street at Victory Grill';

UPDATE austinbike
SET Checkout_Kiosk_ID = 1004
WHERE Checkout_Kiosk='Red River @ LBJ Library';

UPDATE austinbike
SET Checkout_Kiosk_ID = 2546
WHERE Checkout_Kiosk='ACC - West & 12th';

UPDATE austinbike
SET Checkout_Kiosk_ID = 1001
WHERE Checkout_Kiosk='Main Office';

UPDATE austinbike
SET Checkout_Kiosk_ID = 1001
WHERE Checkout_Kiosk='Shop';

UPDATE austinbike
SET Checkout_Kiosk_ID = 1001
WHERE Checkout_Kiosk='Repair Shop';

## Checking for missing values in Return_Kiosk_ID

select count(Return_Kiosk_ID)
from austinbike
where Return_Kiosk_ID = ' ';
    
select distinct(Return_kiosk)
from austinbike
where Return_kiosk_ID = ' ';


## Filling in missing values for Return_Kiosk_ID
## Researched the missing kiosk Ids online

UPDATE austinbike
SET Return_Kiosk_ID = 2574
WHERE Return_Kiosk='Zilker Park at Barton Springs & William Barton Drive';

UPDATE austinbike
SET Return_Kiosk_ID = 2539
WHERE Return_Kiosk='Convention Center/ 3rd & Trinity';

UPDATE austinbike
SET Return_Kiosk_ID = 2568
WHERE Return_Kiosk='East 11th Street at Victory Grill';

UPDATE austinbike
SET Return_Kiosk_ID = 1004
WHERE Return_Kiosk='Red River @ LBJ Library';

UPDATE austinbike
SET Return_Kiosk_ID = 2546
WHERE Return_Kiosk='ACC - West & 12th';

UPDATE austinbike
SET Return_Kiosk_ID = 1001
WHERE Return_Kiosk='Main Office';

UPDATE austinbike
SET Return_Kiosk_ID = 1001
WHERE Return_Kiosk='Shop';

UPDATE austinbike
SET Return_Kiosk_ID = 1001
WHERE Return_Kiosk='Repair Shop';

UPDATE austinbike
SET Return_Kiosk_ID = 1001
WHERE Return_Kiosk='Main Shop';

## Joining tables

create table austinshare
select * from austinbike 
inner join austinlocation on austinbike.Checkout_Kiosk_ID=austinlocation.CheckoutKioskID
inner join austinreturns on austinbike.Return_Kiosk_ID=austinreturns.ReturnKioskiID;    

select * from austinshare;

## Checking missing data for month number

select count(MonthNumber)
from austinshare
where MonthNumber = ' ';

## trip duration outliers

select distinct(Checkout_Date)
from austinshare
where MonthNumber = ' ';

select distinct(trip_duration)
from austinshare;

select count(trip_id)
from austinshare
where trip_duration > 300;

select distinct(checkout_time)
from austinshare
where trip_duration > 300;
    
## Exporting table for further analysis and cleaning

show variables like "secure_file_priv";

set global interactive_timeout=600;
set global connect_timeout=600;

select * 
from austinshare 
into outfile "C://ProgramData//MySQL//MySQL Server 5.7//Uploads//bikeshare_Austin.csv"
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n';



 