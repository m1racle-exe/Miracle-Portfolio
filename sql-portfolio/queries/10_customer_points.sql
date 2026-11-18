-- Project 2 | Exercise 5: loyalty points per customer (cursor)
-- Database: smallnorthwind

create table CustomerPoints(
	CustomerID char(10) primary key,
    NumOfOrders int(11),
    TotalTransaction int(11),
    Points int(11)
);

drop procedure if exists uspInsertCustomerPoints;
delimiter //
create procedure uspInsertCustomerPoints()
begin
	declare v_custId varchar(50);
    declare v_numOfOrders int(11);
	declare v_totalTransaction int(11);
    declare v_points int(11);
    
    declare EndData bool default false;
    declare curCustomer cursor for select CustomerID from customers;
    declare continue handler for not found set EndData = true;
    
    open curCustomer;
    fetch curCustomer into v_custId;
    while (EndData = false) do
		
        set v_numOfOrders = (select count(*) from orders where CustomerID = v_custId);
        set v_totalTransaction = (select coalesce(sum(Total), 0) 
									from orders 
                                    where CustomerID = v_custId);
        set v_points = floor(v_totalTransaction / 1000);
        
        insert into CustomerPoints (CustomerID, NumOfOrders, TotalTransaction, Points)
        values (v_custId, v_numOfOrders, v_totalTransaction, v_points);

        fetch curCustomer into v_custId;
	end while;
    close curCustomer;
end //
delimiter ;

call uspInsertCustomerPoints();

select * from CustomerPoints;
