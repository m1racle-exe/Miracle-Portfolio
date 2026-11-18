-- Project 2 | Exercise 3: order total, VAT, grand total, due date (cursor)
-- Database: smallnorthwind

alter table orders
add column(Total int(11), PPN int(11), GrandTotal int(11), DueDate datetime);

drop procedure if exists uspUpdateTotal;
delimiter //
create procedure uspUpdateTotal()
begin
	declare v_ordId int;
    declare v_ordDate datetime;
    declare v_total int(11);
	declare v_ppn int(11);
    declare v_grandTotal int(11);
    declare v_dueDate datetime;
    
    declare EndData bool default false;
    declare curOrdId cursor for select OrderID, OrderDate from orders;
    declare continue handler for not found set EndData = true;
    
    open curOrdId;
    fetch curOrdId into v_ordId, v_ordDate;
    while (EndData = false) do
		
        set v_total = (select coalesce(sum(UnitPrice * Quantity * (1 - Discount)),0) 
						from orderdetails 
						where OrderID = v_ordId);
        set v_ppn = v_total * 0.11;
        set v_grandTotal = v_total + v_ppn;
        -- set v_dueDate = v_ordDate + 10day;
        set v_dueDate = date_add(v_ordDate, interval 10 day);
        
        update orders
        set Total = v_total, 
			PPN = v_ppn, 
            GrandTotal = v_grandTotal, 
            DueDate = v_dueDate
		where OrderID = v_ordId;
        
        fetch curOrdId into v_ordId, v_ordDate;
	end while;
    close curOrdId;
end //
delimiter ;

call uspUpdateTotal();

select OrderID, OrderDate, Total, PPN, GrandTotal, DueDate from orders;
