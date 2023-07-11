/*Cleaning Data in SQL Queries*/
SELECT *
FROM ProtifolioProjects.dbo.NashvilleHousing

--Standardize Data Format
SELECT SaleDate,CONVERT(date,SaleDate)
FROM ProtifolioProjects.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


SELECT SaleDateConverted,CONVERT(date,SaleDate) 
FROM [ProtifolioProjects].[dbo].[NashvilleHousing]


--Populate property address data

SELECT PropertyAddress
FROM [ProtifolioProjects].[dbo].NashvilleHousing
WHERE PropertyAddress is NULL


SELECT *
FROM [ProtifolioProjects].[dbo].NashvilleHousing
WHERE PropertyAddress is NULL

SELECT *
FROM [ProtifolioProjects].[dbo].NashvilleHousing
ORDER BY ParcelID



--SELF Join to look at the duplication in columns

SELECT a.ParcelID,a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [ProtifolioProjects].[dbo].NashvilleHousing a
JOIN [ProtifolioProjects].[dbo].NashvilleHousing b
	ON a.ParcelID =b.ParcelID
	and a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [ProtifolioProjects].[dbo].NashvilleHousing a
JOIN [ProtifolioProjects].[dbo].NashvilleHousing b
	ON a.ParcelID =b.ParcelID
	and a.UniqueID <> b.UniqueID

WHERE a.PropertyAddress is NULL

--Breaking out address into individual columns(Address, City,State)

SELECT PropertyAddress
FROM ProtifolioProjects.dbo.NashvilleHousing
ORDER BY ParcelID

--character index (searching for specific value), substring to split PropertyAddress

SELECT PropertyAddress,
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as Address
FROM ProtifolioProjects.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255) ;

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

SELECT *
FROM ProtifolioProjects.dbo.NashvilleHousing


-- split the OwnerAddress using parse name

SELECT OwnerAddress
FROM ProtifolioProjects.dbo.NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM ProtifolioProjects.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255) ;

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT *
FROM ProtifolioProjects.dbo.NashvilleHousing


--Change Y and N to Yes and No "Sold as Vacant" Field

SELECT Distinct (SoldAsVacant),COUNT(SoldAsVacant)
FROM ProtifolioProjects.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

--using the case statment to change the Y and N

SELECT SoldAsVacant
,CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
	  WHEN SoldAsVacant ='N' THEN 'No'
	  Else SoldAsVacant
	  End
FROM ProtifolioProjects.dbo.NashvilleHousing

update NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
	  WHEN SoldAsVacant ='N' THEN 'No'
	  Else SoldAsVacant
	  End
FROM ProtifolioProjects.dbo.NashvilleHousing



--Remove the duplicates 
--write CTE doing windows function to find where there are duplicate values
WITH RowNumCTE AS(
SELECT *, ROW_NUMBER() OVER (PARTITION BY ParcelID,
										  PropertyAddress,
										  SalePrice,
										  SaleDate,
										  LegalReference
										  ORDER BY
											UniqueID
											) row_num
										 
FROM ProtifolioProjects.dbo.NashvilleHousing
)

SELECT *
FROM RowNumCTE
WHERE row_num >1
--Delete them 
WITH RowNumCTE AS(
SELECT *, ROW_NUMBER() OVER (PARTITION BY ParcelID,
										  PropertyAddress,
										  SalePrice,
										  SaleDate,
										  LegalReference
										  ORDER BY
											UniqueID
											) row_num
										 
FROM ProtifolioProjects.dbo.NashvilleHousing
)

Delete 
FROM RowNumCTE
WHERE row_num >1


--Delete un used Columns

SELECT *
FROM ProtifolioProjects.dbo.NashvilleHousing

ALTER TABLE ProtifolioProjects.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress,TaxDistrict

ALTER TABLE ProtifolioProjects.dbo.NashvilleHousing
DROP COLUMN SaleDate

