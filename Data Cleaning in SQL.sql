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
  FROM [PortfolioProject].[dbo].[NashvilleHousing]


  -- Cleaning Data

  -- 1) Converting the SaleDate Column in proper Date format

  select *
  from PortfolioProject..NashvilleHousing;

  Update NashvilleHousing
  Set SaleDate = CONVERT(date,SaleDate);


  Alter Table NashvilleHousing
  Add SaleDateConverted Date;

  Update NashvilleHousing
  Set SaleDateConverted = CONVERT(date,SaleDate);

  select SaleDateConverted
  from PortfolioProject..NashvilleHousing;

  -- 2) Populate Property Address Data

 select a.ParcelID, b.ParcelID, a.PropertyAddress,b.PropertyAddress, Isnull(a.PropertyAddress,b.PropertyAddress)
 from PortfolioProject..NashvilleHousing a
 join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID 
	and a.[UniqueID ] <> b.[UniqueID ]
 where a.PropertyAddress is null

 Update a
 set PropertyAddress= Isnull(a.PropertyAddress,b.PropertyAddress)
 from PortfolioProject..NashvilleHousing a
 join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID 
	and a.[UniqueID ] <> b.[UniqueID ]
 where a.PropertyAddress is null



 --3 Breaking down Address into Individual Column (Address, City, State)

  select PropertyAddress
  from PortfolioProject..NashvilleHousing;

  select 
  SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
   SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, len(PropertyAddress)) as Address

   from PortfolioProject..NashvilleHousing

 Alter Table PortfolioProject..NashvilleHousing
  Add PropertySplitAddress varchar(255);

Update PortfolioProject..NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);

 Alter Table PortfolioProject..NashvilleHousing
 Add PropertySplitCity  varchar(255);

  Update PortfolioProject..NashvilleHousing
  Set PropertySplitCity =  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, len(PropertyAddress));

  
  select *
  from PortfolioProject..NashvilleHousing;


  select 
  PARSENAME(replace(OwnerAddress,',','.'),3),
  PARSENAME(replace(OwnerAddress,',','.'),2),
  PARSENAME(replace(OwnerAddress,',','.'),1)

  from PortfolioProject..NashvilleHousing

 Alter Table PortfolioProject..NashvilleHousing
	Add OwnerSplitAddress  varchar(255);

 Alter Table PortfolioProject..NashvilleHousing
	Add OwnerSplitCity  varchar(255);

 Alter Table PortfolioProject..NashvilleHousing
	Add OwnerSplitState  varchar(255);

Update PortfolioProject..NashvilleHousing
Set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3)

Update PortfolioProject..NashvilleHousing
Set OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'),2)

Update PortfolioProject..NashvilleHousing
Set OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1)



-- Change Y and N to Yes and No in SoldAsVacant Field

select SoldAsVacant,

Case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
	 End
from PortfolioProject..NashvilleHousing

Update PortfolioProject..NashvilleHousing
set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
	 End;


-- Remove Duplicates


WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


-- Delete Unused Columns



Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate