-- Project 1 | Exercise 5: generate / refresh a salary slip with position allowance
CREATE TABLE SalarySlip (
    SlipNumber        INT(11) NOT NULL PRIMARY KEY,
    LastUpdate        DATETIME,
    Ssn               VARCHAR(50),
    BasicSalary       INT(11),
    NumOfStaff        INT,
    PositionAllowance INT(11),
    GrossSalary       INT(11),
    IncomeTax         INT(11),
    NettIncome        INT(11)
);

DROP PROCEDURE IF EXISTS uspSalarySlip;
DELIMITER //
CREATE PROCEDURE uspSalarySlip(p_ssn VARCHAR(50))
proc: BEGIN
    DECLARE v_slipNumber        INT;
    DECLARE v_basicSalary       INT;
    DECLARE v_numOfStaff        INT;
    DECLARE v_positionAllowance INT DEFAULT 0;
    DECLARE v_grossSalary       INT;
    DECLARE v_incomeTax         INT;
    DECLARE v_nettIncome        INT;

    IF NOT EXISTS (SELECT 1 FROM employee WHERE ssn = p_ssn) THEN
        SELECT 'Employee SSN not found.' AS Info;
        LEAVE proc;
    END IF;

    SELECT salary INTO v_basicSalary FROM employee WHERE ssn = p_ssn;
    SELECT COUNT(*) INTO v_numOfStaff FROM employee WHERE superssn = p_ssn;

    -- position allowance only for people who manage staff
    IF v_numOfStaff > 0 THEN
        SET v_positionAllowance = 0.3 * v_basicSalary * v_numOfStaff;
    END IF;

    SET v_grossSalary = v_basicSalary + v_positionAllowance;
    SET v_incomeTax   = 0.1 * v_grossSalary;
    SET v_nettIncome  = v_grossSalary - v_incomeTax;

    IF EXISTS (SELECT 1 FROM SalarySlip WHERE Ssn = p_ssn) THEN
        UPDATE SalarySlip
        SET LastUpdate = NOW(), BasicSalary = v_basicSalary, NumOfStaff = v_numOfStaff,
            PositionAllowance = v_positionAllowance, GrossSalary = v_grossSalary,
            IncomeTax = v_incomeTax, NettIncome = v_nettIncome
        WHERE Ssn = p_ssn;
    ELSE
        SELECT COALESCE(MAX(SlipNumber), 0) + 1 INTO v_slipNumber FROM SalarySlip;
        INSERT INTO SalarySlip
        VALUES (v_slipNumber, NOW(), p_ssn, v_basicSalary, v_numOfStaff,
                v_positionAllowance, v_grossSalary, v_incomeTax, v_nettIncome);
    END IF;
END //
DELIMITER ;

CALL uspSalarySlip('123456789');
CALL uspSalarySlip('333445555');
CALL uspSalarySlip('987654321');
CALL uspSalarySlip('999999999');
CALL uspSalarySlip('123456789');   -- second call updates the same slip instead of duplicating it
SELECT * FROM SalarySlip ORDER BY SlipNumber;
