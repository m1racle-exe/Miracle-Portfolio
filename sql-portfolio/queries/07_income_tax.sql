-- Project 2 | Exercise 2: tiered income tax and net income (cursor)
-- Database: smallnorthwind

alter table employees
add column(IncomeTax int(11), NettIncome int(11));

drop procedure if exists uspUpdateIncome;
delimiter //
create procedure uspUpdateIncome()
begin
	declare v_empId int;
    declare v_salary int;
	declare v_incomeTax int(11);
    declare v_nettIncome int(11);
    
    declare EndData bool default false;
    declare curEmpId cursor for select EmployeeID, salary from employees;
    declare continue handler for not found set EndData = true;
    
    open curEmpId;
    fetch curEmpId into v_empId, v_salary;
    while (EndData = false) do
		
        if (v_salary < 50000) then
			set v_incomeTax = v_salary * 0.1;
		else
			set v_incomeTax = v_salary * 0.15;
		end if;
        
        set v_nettIncome = v_salary - v_incomeTax;
        
        update employees
        set IncomeTax = v_incomeTax,
			NettIncome = v_nettIncome
		where EmployeeID = v_empId;
        
        fetch curEmpId into v_empId, v_salary;
	end while;
    close curEmpId;
end //
delimiter ;

call uspUpdateIncome();

select EmployeeID, FirstName, Salary, IncomeTax, NettIncome from employees;
