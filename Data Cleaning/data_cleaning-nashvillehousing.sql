/* Cleaning data in SQL */
USE PortfolioProject;
SELECT* 
FROM PortfolioProject..nashvillehousing;

-- Change SaleDate to Date format

ALTER TABLE nashvillehousing
ALTER COLUMN SaleDate Date;

SELECT 
	SaleDate 
FROM PortfolioProject..nashvillehousing;

------------------------------------------------------------------------------------------------------------------------------------------
 -- Populate Property Address data
 
 
SELECT 
	nh1.ParcelID, nh1.PropertyAddress, nh2.ParcelID, nh2.PropertyAddress
FROM PortfolioProject..nashvillehousing nh1
JOIN PortfolioProject..nashvillehousing nh2
		ON  nh1.ParcelID = nh2.ParcelID
		AND nh1.[UniqueID ] <> nh2.[UniqueID ]
WHERE nh1.PropertyAddress IS NULL ;

-- We have NULLs in the PropertyAddress column, we can associate address
-- with the ParcelID as every unique ParcelID has an address AND the UniqueID 
-- is not equal. 

UPDATE nh1
SET PropertyAddress = ISNULL(nh1.PropertyAddress,nh2.PropertyAddress)	
FROM PortfolioProject..nashvillehousing nh1
JOIN PortfolioProject..nashvillehousing nh2
	ON  nh1.ParcelID = nh2.ParcelID
	AND nh1.[UniqueID ] <> nh2.[UniqueID ]
WHERE nh1.PropertyAddress IS NULL ;

-- Now, separate the address, city, state into individual columns

SELECT
	PropertyAddress 
FROM nashvillehousing
ORDER BY ParcelID;

SELECT
	SUBSTRING(PropertyAddress, 1 ,CHARINDEX(',',PropertyAddress)-1)  AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))  AS City
FROM PortfolioProject..nashvillehousing
ORDER BY ParcelID;

ALTER TABLE  nashvillehousing
ADD PropertyStreetAddress nvarchar(255);

UPDATE nashvillehousing
SET PropertyStreetAddress  = SUBSTRING(PropertyAddress, 1 ,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE  nashvillehousing
ADD PropertyCity nvarchar(255);

UPDATE nashvillehousing
SET PropertyCity  = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

------------------------------------------------------------------------------------------------------------------------------------------
-- Check OwnerAddress

SELECT 
	OwnerAddress 
FROM nashvillehousing;


-- extract street address, city AND state FROM OwnerAddress using PARSENAME AND REPLACE
SELECT
	PARSENAME(Replace(OwnerAddress,',','.'),1) AS State,
	PARSENAME(Replace(OwnerAddress,',','.'),2) AS City,
	PARSENAME(Replace(OwnerAddress,',','.'),3) AS StreetAddress
FROM nashvillehousing;

--Add these columns to the table
ALTER TABLE  nashvillehousing
ADD OwnerStreetAddress nvarchar(255);

UPDATE nashvillehousing
SET OwnerStreetAddress  = PARSENAME(Replace(OwnerAddress,',','.'),3)


ALTER TABLE  nashvillehousing
ADD OwnerCity nvarchar(255);

UPDATE nashvillehousing
SET OwnerCity  = PARSENAME(Replace(OwnerAddress,',','.'),2)

ALTER TABLE  nashvillehousing
ADD OwnerState nvarchar(255);

UPDATE nashvillehousing
SET OwnerState  = PARSENAME(Replace(OwnerAddress,',','.'),1);

------------------------------------------------------------------------------------------------------------------------------------------
-- Change Y AND N to Yes AND No in SoldAsVacant Column
 
SELECT
	CASE WHEN SoldAsVacant ='Y'  THEN 'Yes'
	WHEN SoldAsVacant ='N'  THEN 'No'
	ELSE SoldAsVacant
	END AS SoldAsVacant
FROM nashvillehousing;

UPDATE nashvillehousing
SET SoldAsVacant = (CASE WHEN SoldAsVacant ='Y'  THEN 'Yes'
WHEN SoldAsVacant ='N'  THEN 'No'
ELSE SoldAsVacant
END);

------------------------------------------------------------------------------------------------------------------------------------------
--Remove Duplicates
WITH row_num_cte AS (
SELECT* ,
	ROW_NUMBER() OVER (
	PARTITION  BY ParcelID,
				 PropertyAddress, 
				 SalePrice, 
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
	) AS row_num
FROM nashvillehousing
)
DELETE
FROM row_num_cte
WHERE row_num >1;

------------------------------------------------------------------------------------------------------------------------------------------
-- Delete unused columns

ALTER TABLE  nashvillehousing
DROP COLUMN PropertyAddress,OwnerAddress;

SELECT 
* 
FROM nashvillehousing;