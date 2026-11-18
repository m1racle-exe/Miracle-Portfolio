-- Project 1 | Exercise 4: compute family allowances per employee
CREATE TABLE DependentAllowance (
    Ssn             VARCHAR(50) NOT NULL PRIMARY KEY,
    MarriageStatus  BOOL,
    NumOfChild      INT,
    HealthAllowance INT,
    ChildAllowance  INT,
    TotalAllowance  INT
);

DROP PROCEDURE IF EXISTS uspDependentAllowance;
DELIMITER //
CREATE PROCEDURE uspDependentAllowance(p_essn VARCHAR(50))
proc: BEGIN
    DECLARE v_salary          INT DEFAULT 0;
    DECLARE v_marriageStatus  BOOL DEFAULT FALSE;
    DECLARE v_numOfChild      INT DEFAULT 0;
    DECLARE v_healthAllowance INT DEFAULT 0;
    DECLARE v_childAllowance  INT DEFAULT 0;   -- default 0 so employees with no children get 0, not NULL
    DECLARE v_totalAllowance  INT;

    IF NOT EXISTS (SELECT 1 FROM employee WHERE ssn = p_essn) THEN
        SELECT 'Employee not found' AS Info;
        LEAVE proc;
    END IF;

    SELECT salary INTO v_salary FROM employee WHERE ssn = p_essn;

    IF EXISTS (SELECT 1 FROM dependent WHERE essn = p_essn AND relationship = 'Spouse') THEN
        SET v_marriageStatus  = TRUE;
        SET v_healthAllowance = 5000;
    END IF;

    SELECT COUNT(*) INTO v_numOfChild
    FROM dependent
    WHERE essn = p_essn AND relationship IN ('Son', 'Daughter');

    -- 10% of salary per child, capped at 2 children
    SET v_childAllowance = 0.1 * v_salary * LEAST(v_numOfChild, 2);
    SET v_totalAllowance = v_healthAllowance + v_childAllowance;

    IF EXISTS (SELECT 1 FROM DependentAllowance WHERE Ssn = p_essn) THEN
        UPDATE DependentAllowance
        SET MarriageStatus  = v_marriageStatus,
            NumOfChild      = v_numOfChild,
            HealthAllowance = v_healthAllowance,
            ChildAllowance  = v_childAllowance,
            TotalAllowance  = v_totalAllowance
        WHERE Ssn = p_essn;
    ELSE
        INSERT INTO DependentAllowance
        VALUES (p_essn, v_marriageStatus, v_numOfChild, v_healthAllowance, v_childAllowance, v_totalAllowance);
    END IF;
END //
DELIMITER ;

CALL uspDependentAllowance('123456789');
CALL uspDependentAllowance('333445555');
CALL uspDependentAllowance('987654321');
CALL uspDependentAllowance('453453450');   -- no dependents at all
SELECT * FROM DependentAllowance;
