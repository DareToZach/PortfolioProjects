/*

Cleaning Data in SQL Queries

*/

SELECT * 
FROM PortfolioProjects.dbo.NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDate, CONVERT(date,SaleDate)
FROM PortfolioProjects.dbo.NashvilleHousing

update NashvilleHousing
set SaleDate = CONVERT(date,SaleDate) -- didn't work

SELECT SaleDateConverted
FROM PortfolioProjects.dbo.NashvilleHousing

Alter TABLE NashvilleHousing
add SaleDateConverted date;

update NashvilleHousing
set SaleDateConverted = CONVERT(date,SaleDate)

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT *
FROM PortfolioProjects.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProjects.dbo.NashvilleHousing a
JOIN PortfolioProjects.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


Update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProjects.dbo.NashvilleHousing a
JOIN PortfolioProjects.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null
--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


SELECT PropertyAddress
FROM PortfolioProjects.dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

FROM PortfolioProjects.dbo.NashvilleHousing


Alter TABLE NashvilleHousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

Alter TABLE NashvilleHousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select *
FROM PortfolioProjects.dbo.NashvilleHousing




Select OwnerAddress
FROM PortfolioProjects.dbo.NashvilleHousing


-- Address, City, And State broken out accross three columns
Select PARSENAME(Replace(OwnerAddress,',','.'), 3), 
	PARSENAME(Replace(OwnerAddress,',','.'), 2), 
	PARSENAME(Replace(OwnerAddress,',','.'), 1)
FROM PortfolioProjects.dbo.NashvilleHousing

--Adding the new columns
Alter TABLE NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'), 3)

Alter TABLE NashvilleHousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'), 2)

Alter TABLE NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'), 1)


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), count(SoldAsVacant)
FROM PortfolioProjects.dbo.NashvilleHousing
group by SoldAsVacant
order by 2


Select SoldAsVacant,
	case when SoldAsVacant = 'Y' then 'Yes'
		 when SoldAsVacant = 'N' then 'No'
		 ELSE SoldAsVacant
		 END
FROM PortfolioProjects.dbo.NashvilleHousing


Update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
		 when SoldAsVacant = 'N' then 'No'
		 ELSE SoldAsVacant
		 END



-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
WITH RowNumCTE as (
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
FROM PortfolioProjects.dbo.NashvilleHousing
)
Select * 
FROM RowNumCTE
WHERE row_num > 1
Order by PropertyAddress

/*
WITH RowNumCTE as (
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
FROM PortfolioProjects.dbo.NashvilleHousing
)
DELETE 
FROM RowNumCTE
WHERE row_num > 1
*/


Select *
FROM PortfolioProjects.dbo.NashvilleHousing



---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
FROM PortfolioProjects.dbo.NashvilleHousing

ALTER Table PortfolioProjects.dbo.NashvilleHousing
DROP COLUMN SaleDate

--OwnerAddress, TaxDistrict, PropertyAddress








-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO


















