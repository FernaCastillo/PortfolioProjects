-- New Query for the Nashville House Information

-----------------------------------------------------------------------------

-- This command is for seeing the number of Columns
-- of a table

SELECT COUNT(*) AS No_of_Columns
FROM INFORMATION_SCHEMA.columns
WHERE table_name = 'Nashvillehousecleaning'

-----------------------------------------------------------------------------

-- This command is for seeing the number of Rows
-- of a table

SELECT COUNT(*) AS No_of_Rows
FROM PortfolioProject..Nashvillehousecleaning

-----------------------------------------------------------------------------

-- Here we see all the information contained in the table of
-- Nashville Houses

SELECT *
FROM PortfolioProject..Nashvillehousecleaning nash
ORDER BY 5

-----------------------------------------------------------------------------

/*

Cleaning Data in SQL Queries

*/

-----------------------------------------------------------------------------

-- Standardize Date Format --

SELECT SaleDate, CONVERT(date, SaleDate) AS ConvertedDate
FROM PortfolioProject..Nashvillehousecleaning

-- Here we upate the column SaleDate just with
-- the day not with the hour

UPDATE  PortfolioProject..Nashvillehousecleaning
SET SaleDate = CONVERT(date, SaleDate)

SELECT *
FROM PortfolioProject..Nashvillehousecleaning

-- This command is to add a new column called SaleDateConverted

ALTER TABLE PortfolioProject..Nashvillehousecleaning
ADD SaleDateConverted Date

-- Here we add the date format converted into the new table
-- created

UPDATE  PortfolioProject..Nashvillehousecleaning
SET SaleDateConverted = CONVERT(date, SaleDate)

-- Let's see the complete table

SELECT *
FROM PortfolioProject..Nashvillehousecleaning

-- Remember that you can delete a column that you do not want with this command

ALTER TABLE PortfolioProject..Nashvillehousecleaning
DROP COLUMN SaleDate

SELECT * 
FROM PortfolioProject..Nashvillehousecleaning

-----------------------------------------------------------------------------

-- Populate Property Address data

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, 
b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..Nashvillehousecleaning a
JOIN PortfolioProject..Nashvillehousecleaning b
	ON	a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL

-- We are going to update the duplicated values into the table
-- to the corresponding null values

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..Nashvillehousecleaning a
JOIN PortfolioProject..Nashvillehousecleaning b
	ON	a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL

-- Another alternative could be this commands in case we do not have
-- the information for the null values

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,'No Adress')
FROM PortfolioProject..Nashvillehousecleaning a
JOIN PortfolioProject..Nashvillehousecleaning b
	ON	a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL

-----------------------------------------------------------------------------

-- Breaking out Address into individual columns (Address, City) the
-- column PropertyAdress

SELECT PropertyAddress
FROM PortfolioProject..Nashvillehousecleaning
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

-- Let's use a subtring to brak out the column PropertyAddress in order to
-- obtain the Addrees and the City in different columns

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address -- Here we obtain the first parte before the comma
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM PortfolioProject..Nashvillehousecleaning

-- Once we have the two results we are going to obtain the two columns
-- but we have to create them first

ALTER TABLE PortfolioProject..Nashvillehousecleaning
ADD PropertySplitAddress Nvarchar(255)

UPDATE PortfolioProject..Nashvillehousecleaning
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE PortfolioProject..Nashvillehousecleaning
ADD PropertySplitCity Nvarchar(255)

UPDATE PortfolioProject..Nashvillehousecleaning
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


-- Let's see the complete table with the new columns

SELECT *
FROM PortfolioProject..Nashvillehousecleaning


-- Let's break out into three different columns (Adress, City, Sate) the column
-- OwnerAddress

/*

-- This code is just for fun

SELECT CHARINDEX(',', OwnerAddress),CHARINDEX('.', OwnerAddress), OwnerAddress
FROM PortfolioProject..Nashvillehousecleaning

*/


-- The function PARSENAME() works backwards (with the index)

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3) AS Address,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) AS City,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) AS State
FROM PortfolioProject..Nashvillehousecleaning

-- Now let's create the new tables and add the new columns to them

ALTER TABLE PortfolioProject..Nashvillehousecleaning
ADD OwnerSplitAddress Nvarchar(255)

UPDATE PortfolioProject..Nashvillehousecleaning
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE PortfolioProject..Nashvillehousecleaning
ADD OwnerSplitCity Nvarchar(255)

UPDATE PortfolioProject..Nashvillehousecleaning
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE PortfolioProject..Nashvillehousecleaning
ADD OwnerSplitState Nvarchar(255)

UPDATE PortfolioProject..Nashvillehousecleaning
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

-- Let's see our new table

SELECT *
FROM PortfolioProject..Nashvillehousecleaning

-----------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" column

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..Nashvillehousecleaning
GROUP BY SoldAsVacant
ORDER BY 2

-- We can use a Case Statement to change the column "Sold as Vacant"

SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM PortfolioProject..Nashvillehousecleaning
ORDER BY 1

-- Here we are updating the column with the new values

UPDATE PortfolioProject..Nashvillehousecleaning
SET SoldAsVacant =
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END

-- Let´s see the complete table

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) AS No_Yes_Or_No
FROM PortfolioProject..Nashvillehousecleaning
GROUP BY SoldAsVacant
ORDER BY 2

-----------------------------------------------------------------------------

-- Remove Duplicate


-- Here we are counting the rows that have the same information regarding
-- the columns we are chosing

SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID) AS row_num
FROM PortfolioProject..Nashvillehousecleaning
--ORDER BY ParcelID

-- Let´s create a CTE to delete the duplicated rows

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID) AS row_num
FROM PortfolioProject..Nashvillehousecleaning
--ORDER BY ParcelID
)

DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress

-- Let´s see the same CTE to see that the duplicated values are deleted

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID) AS row_num
FROM PortfolioProject..Nashvillehousecleaning
--ORDER BY ParcelID
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

-----------------------------------------------------------------------------


-- Delete Unused Columns

SELECT *
FROM PortfolioProject..Nashvillehousecleaning

ALTER TABLE PortfolioProject..Nashvillehousecleaning
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

SELECT *
FROM PortfolioProject..Nashvillehousecleaning