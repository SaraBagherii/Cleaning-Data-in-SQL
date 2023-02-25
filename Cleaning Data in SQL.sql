/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [PortfolioProject2].[dbo].[NashvilleHausing]

  /*
  ---------------------------------------------
---Cleaning Data in SQL Queries
*/


select *
from PortfolioProject2.dbo.NashvilleHausing
 
-----------------------------------------------
---Standardize Date Format

select SaleDate
from NashvilleHausing

---Remove time which is null

select SaleDateConverted, Convert(Date,SaleDate)
from NashvilleHausing


Update NashvilleHausing
Set SaleDate = Convert(Date,SaleDate) 

--++ As we can't split one coulmn into two  coulmns:

Alter Table NashvilleHausing
Add SaleDateConverted Date;

Update NashvilleHausing
Set SaleDateConverted = Convert(Date,SaleDate)

-------------------------------------------------
--- Populate Property Address Data

select *
from NashvilleHausing
--where PropertyAddress is null
order by ParcelID

--+++ Cause somewhere ParcelID and PropertyAddress repeted by different UnicID
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, Isnull(a.PropertyAddress, b.PropertyAddress)
from NashvilleHausing a
join NashvilleHausing b
on a.ParcelID = b.ParcelID
And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set a.PropertyAddress = Isnull(a.PropertyAddress, b.PropertyAddress)
from NashvilleHausing a
join NashvilleHausing b
on a.ParcelID = b.ParcelID
And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

select * 
from NashvilleHausing
where PropertyAddress is null

-------------------------------------------------
--- Breaking out Address into individual columns (Address, City, State)

Select PropertyAddress
from NashvilleHausing

Select Substring(PropertyAddress, 1 , Charindex(',',PropertyAddress)-1) as Address
, Substring(PropertyAddress, Charindex(',',PropertyAddress)+1 , Len(PropertyAddress)) as Address
from NashvilleHausing 

--++ As we can't split one coulmn into two  coulmns:

Alter Table NashvilleHausing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHausing
Set PropertySplitAddress = Substring(PropertyAddress, 1 , Charindex(',',PropertyAddress)-1)

Alter Table NashvilleHausing
Add PropertySplitCity Nvarchar(255) ;

Update NashvilleHausing
Set PropertySplitCity = Substring(PropertyAddress, Charindex(',',PropertyAddress)+1 , Len(PropertyAddress))

Select *
from NashvilleHausing



Select OwnerAddress
from NashvilleHausing

Select Parsename(Replace(OwnerAddress,',', '.'), 3)
, Parsename(Replace(OwnerAddress,',', '.'), 2)
, Parsename(Replace(OwnerAddress,',', '.'), 1)
from NashvilleHausing

Alter Table NashvilleHausing
Add OwnerSplitAddress Nvarchar(255) ;

Update NashvilleHausing
Set OwnerSplitAddress = Parsename(Replace(OwnerAddress,',', '.'), 3)

Alter Table NashvilleHausing
Add OwnerSplitCity Nvarchar(255) ;

Update NashvilleHausing
Set OwnerSplitCity = Parsename(Replace(OwnerAddress,',', '.'), 2)

Alter Table NashvilleHausing
Add OwnerSplitState Nvarchar(255) ;

Update NashvilleHausing
Set OwnerSplitState = Parsename(Replace(OwnerAddress,',', '.'), 1)


Select *
from NashvilleHausing


-------------------------------------------------
--- Change Y and N to Yes and No in "Sold as Vacant" feild

Select Distinct(SoldAsVacant) , Count(SoldAsVacant)
from NashvilleHausing
Group by SoldAsVacant
order by Count(SoldAsVacant)



Update NashvilleHausing
Set SoldAsVacant =
Case When SoldAsVacant = 'Y' Then 'Yes'
     When SoldAsVacant = 'N' Then  'No'
	 Else SoldAsVacant
	 End

-------------------------------------------------
--- Remove Duplicates


With RowNumCTE As(
Select *,
   Row_Number() Over (
   Partition By ParcelID,
        PropertyAddress,
        SalePrice,
        SaleDate,
        LegalReference
        Order by 
          UniqueID 
          ) row_num
from NashvilleHausing
--Order by ParcelID
)

Delete
From RowNumCTE
Where row_num > 1


-------------------------------------------------
--- Delete Unused Columns

Select *
from NashvilleHausing

Alter Table NashvilleHausing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


