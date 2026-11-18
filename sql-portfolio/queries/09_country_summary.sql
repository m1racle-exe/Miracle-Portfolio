-- Project 2 | Exercise 4: customers, employees, suppliers per country (cursor)
-- Database: smallnorthwind

create table CountryData(
	Country varchar(50) primary key,
    NumOfCustomers int(11),
    NumOfEmployees int(11),
    NumOfSuppliers int(11)
);

drop procedure if exists uspInsertCountryData;
delimiter //
create procedure uspInsertCountryData()
begin
	declare v_country varchar(50);
    declare v_numOfCustomers int(11);
	declare v_numOfEmployees int(11);
    declare v_numOfSuppliers int(11);
    
    declare EndData bool default false;
    declare curCountry cursor for   
		select Country from customers where Country is not null
        union
        select Country from employees where Country is not null
        union
        select Country from suppliers where Country is not null;
    declare continue handler for not found set EndData = true;
    
    open curCountry;
    fetch curCountry into v_country;
    while (EndData = false) do
		
        set v_numOfCustomers = (select count(CustomerID) from customers where Country = v_country);
        set v_numOfEmployees = (select count(EmployeeID) from employees where Country = v_country);
        set v_numOfSuppliers = (select count(SupplierID) from suppliers where Country = v_country);
        
        insert into CountryData (Country, NumOfCustomers, NumOfEmployees, NumOfSuppliers)
        values (v_country, v_numOfCustomers, v_numOfEmployees, v_numOfSuppliers);

        fetch curCountry into v_country;
	end while;
    close curCountry;
end //
delimiter ;

call uspInsertCountryData();

select * from CountryData;
