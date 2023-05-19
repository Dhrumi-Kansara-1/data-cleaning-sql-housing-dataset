/* Cleaning data using SQL queries */

/*overview of Data*/
SELECT *
FROM HousingData

SELECT count(*) Total_rows
FROM HousingData

 /* ---------------------------Null values in PropertyAddress--------------------------- */

SELECT *
FROM HousingData
WHERE PropertyAddress is null

-- same ParcelID will have same address 

SELECT *
FROM HousingData
ORDER BY ParcelID


-- Same ParcelID's have same PropertyAddress -
-- We will populate PropertyAddress of same ParcelID to fill the null PropertyAddress


-- checking for one ParcelID

SELECT *
FROM HousingData
WHERE ParcelID='025 07 0 031.00'
ORDER BY ParcelID


-- checking this for all the Null values in PropertyAddress

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) NewPropertyAddress
FROM HousingData a
JOIN HousingData b
	ON a.ParcelID=b.ParcelID
	AND a.UniqueID<>b.UniqueID
WHERE a.PropertyAddress is null

-- updating null values

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM HousingData a
JOIN HousingData b
	ON a.ParcelID=b.ParcelID
	AND a.UniqueID<>b.UniqueID
WHERE a.PropertyAddress is null

-- checking if any null values are remaing
SELECT count(*) TotalNullPropertyAddress
FROM HousingData
WHERE PropertyAddress is null

 /* ---------------------------Diving PropertyAddress into street and city columns--------------------------- */


-- checking the issue
SELECT PropertyAddress
FROM HousingData

-- seprating using substirng and using CHARINDEX to find index of ","
SELECT 
	PropertyAddress, 
	SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) as Address, 
	SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
FROM HousingData

-- creating two new columns 

ALTER TABLE HousingData
ADD PropertyAddressStreet Nvarchar(255)

ALTER TABLE HousingData
ADD PropertyAddressCity Nvarchar(255)

-- updating columns 

UPDATE HousingData
SET PropertyAddressStreet=SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1)

UPDATE HousingData
SET PropertyAddressCity=SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

-- checking result

select PropertyAddress, PropertyAddressStreet, PropertyAddressCity
FROM HousingData


 /* ---------------------------Diving OwnerAddress into street and city and state columns--------------------------- */

SELECT OwnerAddress
FROM HousingData

-- using slect to check 
SELECT OwnerAddress,
	PARSENAME(REPLACE(OwnerAddress,',','.'),3) street,
	PARSENAME(REPLACE(OwnerAddress,',','.'),2) city,
	PARSENAME(REPLACE(OwnerAddress,',','.'),1) state
FROM HousingData

-- creating 3 new columns

ALTER TABLE HousingData
ADD OwnerAddressStreet Nvarchar(255)

ALTER TABLE HousingData
ADD OwnerAddressCity Nvarchar(255)

ALTER TABLE HousingData
ADD OwnerAddressState Nvarchar(255)

-- updating columns

UPDATE HousingData
SET OwnerAddressStreet=PARSENAME(REPLACE(OwnerAddress,',','.'),3)

UPDATE HousingData
SET OwnerAddressCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2)


UPDATE HousingData
SET OwnerAddressState=PARSENAME(REPLACE(OwnerAddress,',','.'),1)

-- checking results

SELECT OwnerAddress, OwnerAddressStreet, OwnerAddressCity, OwnerAddressState
FROM HousingData

 /* ---------------------------Removing Duplicates--------------------------- */
SELECT *
FROM HousingData

-- viewing duplicate rows using CTE 

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY UniqueID
					 ) row_num
FROM HousingData
)
SELECT ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference, row_num 
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress
 
-- deleting rows using CTE


WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY UniqueID
					 ) row_num
FROM HousingData
)
DELETE
FROM RowNumCTE
WHERE row_num > 1 