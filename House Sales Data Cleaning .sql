---------------------------------------------- DATA CLEANING PROJECT ----------------------------------------------------------

Select * 
From project1.dbo.House_Sales$

----------- Standadize Date Formate ----------------------

Select SaleDate
From project1.dbo.House_Sales$

Alter table project1.dbo.House_Sales$
add Sale_Date date

Update project1.dbo.House_Sales$
set Sale_Date = CONVERT(Date,SaleDate,1)

Select SaleDate,Sale_Date
From project1.dbo.House_Sales$


------------ Populate Property Address Data ---------------

Select PropertyAddress
From project1.dbo.House_Sales$

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
From project1.dbo.House_Sales$ as a
join project1.dbo.House_Sales$ as b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.propertyAddress is null

Update a
set a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From project1.dbo.House_Sales$ as a
join project1.dbo.House_Sales$ as b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.propertyAddress is null



------------ Breaking Address -----------------------------------------------

Select PropertyAddress
From project1.dbo.House_Sales$

Select PropertyAddress,Substring(PropertyAddress,1,charindex(',',PropertyAddress,1)-1),
Substring(PropertyAddress,charindex(',',PropertyAddress,1)+1,len(PropertyAddress))
From project1.dbo.House_Sales$

Alter Table project1.dbo.House_Sales$
Add Addressline1 varchar(200)

Update project1.dbo.House_Sales$
set Addressline1 = Substring(PropertyAddress,1,charindex(',',PropertyAddress,1)-1)
From project1.dbo.House_Sales$ 

Alter Table project1.dbo.House_Sales$
Add Addressline2 varchar(200)

Update project1.dbo.House_Sales$
set Addressline2 = Substring(PropertyAddress,charindex(',',PropertyAddress,1)+1,len(PropertyAddress))
From project1.dbo.House_Sales$ 

Select PropertyAddress,Addressline1,Addressline2
From project1.dbo.House_Sales$ 


Select OwnerAddress
From project1.dbo.House_Sales$

Select OwnerAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From project1.dbo.House_Sales$

Alter table project1.dbo.House_Sales$
Add Owneraddressline1 varchar(200)

Update project1.dbo.House_Sales$
set Owneraddressline1 = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
From project1.dbo.House_Sales$

Alter table project1.dbo.House_Sales$
Add Owneraddressline2 varchar(200)

Update project1.dbo.House_Sales$
set Owneraddressline2 = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
From project1.dbo.House_Sales$

Alter table project1.dbo.House_Sales$
Add OwnerState varchar(200)

Update project1.dbo.House_Sales$
set OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From project1.dbo.House_Sales$

Select OwnerAddress, Owneraddressline1,Owneraddressline2,OwnerState
From project1.dbo.House_Sales$



---------- Change Y to Yes and N to No in Sold as Vacent ---------------------

Select SoldAsVacant, count(SoldAsVacant)
From project1.dbo.House_Sales$
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
From project1.dbo.House_Sales$
Where SoldAsVacant = 'Y'
or SoldAsVacant = 'N'

Update project1.dbo.House_Sales$
Set SoldAsVacant = Replace(SoldAsVacant,'Y','Yes')
From project1.dbo.House_Sales$
Where SoldAsVacant = 'Y'

Update project1.dbo.House_Sales$
Set SoldAsVacant = Replace(SoldAsVacant,'N','No')
From project1.dbo.House_Sales$
Where SoldAsVacant = 'N'

--Select SoldAsVacant,
--Case 
--     when SoldAsVacant='Y' then SoldAsVacant='Yes'
--     when SoldAsVacant='N' then SoldAsVacant='No'
--	 Else SoldAsVacant
--	 End
--From project1.dbo.House_Sales$



--------------- Remove Duplicates ---------------------------------

Select * 
From project1.dbo.House_Sales$

WITH RowCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
					) row_num

From project1.dbo.House_Sales$)

Delete
From RowCTE
where row_num>1


---------------- Delete Unused Columns -----------------------------

Select * 
From project1.dbo.House_Sales$


Alter table project1.dbo.House_Sales$
Drop column PropertyAddress,SaleDate,OwnerAddress






