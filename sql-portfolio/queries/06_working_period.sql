-- Project 2 | Exercise 1: employee length of service (cursor)
-- Database: smallnorthwind

ALTER TABLE employees
ADD COLUMN WorkingPeriod int;

drop procedure if exists uspUpdateWorkingDate;
delimiter //
create procedure uspUpdateWorkingDate()
begin	
	declare v_empId int;
    declare v_hireDate date;
    declare v_workPeriod int;
   	
	declare endData int default false; 	
	declare curEmpId cursor for select EmployeeID, HireDate from employees; 	
	declare continue handler for not found set endData = true; 
      	    	
	open curEmpId;    
	fetch curEmpId into v_empId, v_hireDate;    
	while (endData = false) do    	
		
		set v_workPeriod = timestampdiff(year, v_hireDate, now());
        
		update employees	
		set WorkingPeriod = v_workPeriod	
		where EmployeeID = v_empId;              

		fetch curEmpId into v_empId, v_hireDate;	
	end while;    
	close curEmpId;
end //
delimiter ;

call uspUpdateWorkingDate();

select EmployeeID, FirstName, HireDate, WorkingPeriod from employees;
