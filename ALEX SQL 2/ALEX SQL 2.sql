/*Cleaning Data in SQL Queries*/
-- Initialize Data
SELECT *
FROM nashvhousing n 

-- Converting Datetime to Date

ALTER TABLE nashvhousing 
Add SaleDateConverted Date;

Update nashvhousing 
SET SaleDateConverted = CONVERT(Date,SaleDate)


-- Populate Property Address data

SELECT *
FROM nashvhousing n 
ORDER BY ParcelID 



SELECT  n.ParcelID, n.PropertyAddress, n2.ParcelID, n2.PropertyAddress, ISNULL(n.PropertyAddress,n2.PropertyAddress)
FROM nashvhousing n 
JOIN nashvhousing n2 on n.ParcelID = n2.ParcelID AND n.[UniqueID ] <> n2.[UniqueID ]
WHERE n.PropertyAddress IS NULL 


Update n
SET PropertyAddress = ISNULL(n.PropertyAddress,n2.PropertyAddress)
FROM nashvhousing n
JOIN nashvhousing n2 on n.ParcelID = n2.ParcelID AND n.[UniqueID ] <> n2.[UniqueID ]
WHERE  n.PropertyAddress IS NULL 



-- Breaking out Address into Individual Columns (Address, City, State)


SELECT PropertyAddress
FROM nashvhousing n 

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
FROM nashvhousing n 


ALTER TABLE nashvhousing 
Add PropertySplitAddress Nvarchar(255);

Update nashvhousing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE nashvhousing 
Add PropertySplitCity Nvarchar(255);

Update nashvhousing 
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

SELECT  *
FROM  nashvhousing n 





SELECT OwnerAddress
FROM nashvhousing n 


select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
from nashvhousing n 



ALTER TABLE nashvhousing 
Add OwnerSplitAddress Nvarchar(255);

Update nashvhousing 
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE nashvhousing 
Add OwnerSplitCity Nvarchar(255);

Update nashvhousing 
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE  nashvhousing
Add OwnerSplitState Nvarchar(255);

Update nashvhousing 
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From nashvhousing n 




--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From nashvhousing n 
Group by SoldAsVacant
order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From nashvhousing n 


Update nashvhousing 
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END






-----------------------------------------------------------------------------------------------------------------------------------------------------------

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

From nashvhousing n 
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From nashvhousing n 




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From nashvhousing n 


ALTER TABLE nashvhousing 
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate