						-- NASHVILLE HOUSING MARKET 2013 TO 2016 - DATA CLEANING USING SQL


use Housing

						-- Overview of dataset

select *
from dbo.Nashville$

-- 56477 rows
select count(*)
from dbo.Nashville$


						-- Analyzing the null values

select
	sum(case when UniqueID is null then 1 else 0 end) a,
	sum(case when ParcelID is null then 1 else 0 end) b,
	sum(case when LandUse is null then 1 else 0 end) c,
	sum(case when PropertyAddress is null then 1 else 0 end) d, -- 29 null values
	sum(case when SaleDate is null then 1 else 0 end) e,
	sum(case when SalePrice is null then 1 else 0 end) f,
	sum(case when LegalReference is null then 1 else 0 end) g,
	sum(case when SoldAsVacant is null then 1 else 0 end) h,
	sum(case when OwnerName is null then 1 else 0 end) i, -- 31216 null values
	sum(case when OwnerAddress is null then 1 else 0 end) j, -- 30462 null values
	sum(case when Acreage is null then 1 else 0 end) k, -- 30462 null values
	sum(case when TaxDistrict is null then 1 else 0 end) l, -- 30462 null values
	sum(case when LandValue is null then 1 else 0 end) m, -- 30462 null values
	sum(case when BuildingValue is null then 1 else 0 end) n, -- 30462 null values
	sum(case when TotalValue is null then 1 else 0 end) o, -- 30462 null values
	sum(case when YearBuilt is null then 1 else 0 end) p, -- 32314 null values
	sum(case when Bedrooms is null then 1 else 0 end) q, -- 32320 null values
	sum(case when FullBath is null then 1 else 0 end) r, -- 32202 null values
	sum(case when HalfBath is null then 1 else 0 end) s -- 32333 null values
from dbo.Nashville$ as Nashville

					-- PropertyAddress null values

select *
from dbo.nashville$
where PropertyAddress is null

select parcelID, PropertyAddress
from dbo.Nashville$
order by ParcelID

-- PropertyAddress nulls can be filled in based on ParcelID
select t1.parcelID, t1. PropertyAddress AS PropertyAddressA, t2.PropertyAddress AS PropertyAddressB
into PropertyAddresstable
from dbo.Nashville$ t1
left join dbo.Nashville$ t2
on t1.[UniqueID ] <> t2.[UniqueID ]
and t1.ParcelID = t2.ParcelID

update PropertyAddresstable set PropertyAddressA = PropertyAddressB
where PropertyAddressA is null

update PropertyAddresstable set PropertyAddressA = PropertyAddressB
where PropertyAddressB is null

select dbo.Nashville$.*, PropertyAddresstable.PropertyAddressA
into Nashvilletable
from dbo.Nashville$
left join PropertyAddresstable
on dbo.Nashville$.ParcelID = PropertyAddresstable.ParcelID

update Nashvilletable set PropertyAddress = PropertyAddressA
where PropertyAddress is null

-- checking to see if null values are setup to be filled
select * from Nashvilletable
where PropertyAddress is null

-- transferring addresses into PropertyAddress to fill in null values
update Nashvilletable set PropertyAddress = PropertyAddressA
where PropertyAddress is null

					-- Splitting up address into street, city, state

-- Splitting Property Addres into Address, City, and State
select [UniqueID ],
	left(PropertyAddress, charindex(',', PropertyAddress)) as address,
	right(PropertyAddress, charindex(',', reverse(PropertyAddress)) -1 ) as city
into splittable1
from Nashvilletable

select Nashvilletable.*, splittable1.address, splittable1.city
into Nashvilletable2
from Nashvilletable
left join splittable1
on Nashvilletable.[UniqueID ] = splittable1.[UniqueID ]

-- Splitting owner address into street, city, state
select [UniqueID ],
	Parsename(Replace(OwnerAddress, ',', '.') ,3) as ownerstreet
	,Parsename(Replace(OwnerAddress, ',', '.') ,2) as ownercity
	,Parsename(Replace(OwnerAddress, ',', '.') ,1) as ownerState
into splitowner
from Nashvilletable2

select nashvilletable2.*, splitowner.ownerstreet, splitowner.ownercity, splitowner.ownerState
into Nashvilletable3
from Nashvilletable2
left join splitowner
on Nashvilletable2.[UniqueID ] = splitowner.[UniqueID ]

-- format Landuse, vacant residential land, greenbelt,
select Distinct(Landuse) from Nashvilletable3

update Nashvilletable3
set Landuse =
	case when Landuse = 'GREENBELT/RES  GRRENBELT/RES' then 'GREENBELT'
		 when Landuse = 'VACANT RESIENTIAL LAND' then 'VACANT RESIDENTIAL LAND'
		 when Landuse = 'VACANT RES LAND' then 'VACANT RESIDENTIAL LAND'
		 when Landuse = 'VACANT RURAL LAND' then 'VACANT RESIDENTIAL LAND'
		 else LandUse
		 end

select distinct(SoldAsVacant)
from Nashvilletable3

update Nashvilletable3 
set SoldAsVacant =
	case when SoldAsVacant = 'Y' then 'Yes'
		 when SoldAsVacant = 'N' then 'No'
		 else SoldAsVacant
		 end
from Nashvilletable3

update Nashvilletable3
set SaleDate = convert(date, saledate)

alter table Nashvilletable3
add NewSaleDate Date;

update Nashvilletable3
set NewSaleDate = convert(date, Saledate)

					-- Deleting duplicates

select [UniqueID ], count([UniqueID ]) 
from Nashvilletable3
group by [UniqueID ]
having count([UniqueID ]) > 1

-- creating duplicate table to test on
select *
into duptable
from Nashvilletable3

-- deleting duplicates
)
with cte as (
	select
		[UniqueID ],
		ROW_NUMBER() Over (
			Partition by
				[UniqueID ]
			Order By
				[UniqueID] ) Row_num
			from
				duptable
)
Delete from cte
where row_num > 1;

alter table duptable drop column PropertyAddress, SaleDate, OwnerAddress, owncity, OwnState, PropertyAddressA, OwnAddress, LegalReference

-- finishing up
select *
into Nashville_Housing
from duptable

