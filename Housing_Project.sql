-- Cleaning Data with SQL Queries
select *
from [Portfolio Project].dbo.[NashvilleHousing]

-- Standardize Date Format

ALTER TABLE NashvilleHousing
ADD SaledateConverted Date;

Update NashvilleHousing
SET SaledateConverted =  CONVERT(Date,SaleDate)

select SaledateConverted, Convert (date, SaleDate)
from [Portfolio Project].dbo.[NashvilleHousing]

-- Populate Property Address
select PropertyAddress
from [Portfolio Project].dbo.[NashvilleHousing]
where PropertyAddress is null

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from [Portfolio Project].dbo.[NashvilleHousing] as a
join [Portfolio Project].dbo.[NashvilleHousing] as b
on a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) 
from [Portfolio Project].dbo.[NashvilleHousing] as a
join [Portfolio Project].dbo.[NashvilleHousing] as b
on a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress) 
from [Portfolio Project].dbo.[NashvilleHousing] as a
join [Portfolio Project].dbo.[NashvilleHousing] as b
on a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null


-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress
from [Portfolio Project].dbo.[NashvilleHousing]

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
from [Portfolio Project].dbo.[NashvilleHousing]

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter Table NashvilleHousing
Add  PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

select *
from [Portfolio Project].dbo.[NashvilleHousing]

select OwnerAddress
from [Portfolio Project]..NashvilleHousing

select 
PARSENAME (REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME (REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME (REPLACE(OwnerAddress, ',', '.'), 1)
from [Portfolio Project].dbo.[NashvilleHousing]

Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 3)

Alter Table NashvilleHousing
Add  OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 2)

Alter Table NashvilleHousing
Add  OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 1)

select *
from [Portfolio Project].dbo.[NashvilleHousing]

-- Change Y and N to Yes and No in "Sold as Vacant" field

select Distinct (SoldAsVacant), COUNT(SoldAsVacant)
from [Portfolio Project]..NashvilleHousing
Group by SoldAsVacant
order by 2

select SoldAsVacant
,  CASE When SoldAsVacant = 'Y' Then 'Yes'
     When SoldAsVacant = 'N' Then 'No'
	 Else  SoldAsVacant
	 END
from [Portfolio Project].dbo.[NashvilleHousing]

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
     When SoldAsVacant = 'N' Then 'No'
	 Else  SoldAsVacant
	 END

-- Remove Duplicates

select *
from [Portfolio Project]..NashvilleHousing


WITH RowNumCTE AS(
select *,
    ROW_Number() OVER (
	PARTITION BY ParcelID,
	                       PropertyAddress,
				           SalePrice,
				           SaleDate,
				           LegalReference
				           Order by
				                   UniqueID
				                   ) row_num

from [Portfolio Project]..NashvilleHousing
)
DELETE
from RowNumCTE
where row_num > 1

-- Delete Unused Columns
select *
from [Portfolio Project].dbo.[NashvilleHousing]

Alter Table [Portfolio Project].dbo.[NashvilleHousing]
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table [Portfolio Project].dbo.[NashvilleHousing]
Drop Column SaleDate