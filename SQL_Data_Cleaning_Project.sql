

--Cleaning SQL Query Data

SELECT *
FROM ..[NashvilleHousing]

--Date Formatting

SELECT SaleDateConverted
FROM ..[NashvilleHousing]

UPDATE [NashvilleHousing]
SET SaleDateConverted = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE [NashvilleHousing]
SET SaleDateConverted = CONVERT(Date,SaleDate)



--Populate Property Address data


SELECT one.ParcelID, one.PropertyAddress,two.ParcelID,two.PropertyAddress,ISNULL(one.PropertyAddress, two.PropertyAddress)
FROM ..NashvilleHousing AS one
Join NashvilleHousing AS two
	ON one.ParcelID=two.ParcelID AND one.[UniqueID ] != two.[UniqueID ]
WHERE one.PropertyAddress is null

UPDATE one
SET one.PropertyAddress = two.PropertyAddress
FROM ..NashvilleHousing AS one
Join NashvilleHousing AS two
	ON one.ParcelID=two.ParcelID AND one.[UniqueID ] != two.[UniqueID ]
WHERE one.PropertyAddress is null

-- Chunking Address into Seperate Columns by Address, City, State

SELECT PropertyAddress, SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS 'Address',
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM ..NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertyAddressSplit nvarchar(255);

UPDATE [NashvilleHousing]
SET PropertyAddressSplit = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) 

ALTER TABLE NashvilleHousing
Add PropertyCitySplit nvarchar(255);

UPDATE [NashvilleHousing]
SET PropertyCitySplit = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))


-- Owner Address split. Parsename is simpler than substrings :)


SELECT 
PARSENAME( Replace(OwnerAddress, ',','.'),3),
PARSENAME( Replace(OwnerAddress, ',','.'),2),
PARSENAME( Replace(OwnerAddress, ',','.'),1)
FROM ..NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerAddressSplit  nvarchar(255);

UPDATE [NashvilleHousing]
SET OwnerAddressSplit = PARSENAME( Replace(OwnerAddress, ',','.'),3)

ALTER TABLE NashvilleHousing
Add OwnerCitySplit nvarchar(255);

UPDATE [NashvilleHousing]
SET OwnerCitySplit = PARSENAME( Replace(OwnerAddress, ',','.'),2)

ALTER TABLE NashvilleHousing
Add OwnerStateSplit nvarchar(255);

UPDATE [NashvilleHousing]
SET OwnerStateSplit = PARSENAME( Replace(OwnerAddress, ',','.'),1)



-- Modify SoldAsVacant Column: Y and N to Yes and No

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) AS vacant
FROM ..NashvilleHousing
GROUP BY SoldAsVacant


SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM ..NashvilleHousing



UPDATE NashvilleHousing
SET SoldAsVacant =
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END



-- Remove Duplicates

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID
				) row_num

FROM ..NashvilleHousing
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1


--Delete Unused Columns

ALTER TABLE ..NashvilleHousing
DROP COLUMN OwnerAddress,TaxDistrict, PropertyAddress,SaleDate


