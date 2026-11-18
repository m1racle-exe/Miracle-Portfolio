-- Project 1 | Exercise 3: categorise projects by team size and total hours
CREATE TABLE ProjectCategory (
    ProjectNo       INT(11) NOT NULL PRIMARY KEY,
    NumOfEmployee   INT,
    TotalHours      INT,
    ProjectCategory INT
);

DROP PROCEDURE IF EXISTS uspInsertProjectCategory;
DELIMITER //
CREATE PROCEDURE uspInsertProjectCategory(p_pno INT)
proc: BEGIN
    DECLARE v_emp   INT;
    DECLARE v_hours INT;
    DECLARE v_cat   INT;

    -- validate first, and stop so no bad row is written
    IF NOT EXISTS (SELECT 1 FROM project WHERE pnumber = p_pno) THEN
        SELECT 'Project number not found' AS Info;
        LEAVE proc;
    END IF;

    SELECT COUNT(DISTINCT ssn), COALESCE(SUM(hours), 0)
    INTO v_emp, v_hours
    FROM works_on
    WHERE pno = p_pno;

    IF v_emp >= 3 THEN
        IF v_hours > 50 THEN SET v_cat = 1;
        ELSEIF v_hours >= 30 THEN SET v_cat = 2;
        ELSE SET v_cat = 3;
        END IF;
    ELSE
        IF v_hours > 50 THEN SET v_cat = 4;
        ELSE SET v_cat = 5;
        END IF;
    END IF;

    -- upsert
    IF EXISTS (SELECT 1 FROM ProjectCategory WHERE ProjectNo = p_pno) THEN
        UPDATE ProjectCategory
        SET NumOfEmployee = v_emp, TotalHours = v_hours, ProjectCategory = v_cat
        WHERE ProjectNo = p_pno;
    ELSE
        INSERT INTO ProjectCategory (ProjectNo, NumOfEmployee, TotalHours, ProjectCategory)
        VALUES (p_pno, v_emp, v_hours, v_cat);
    END IF;
END //
DELIMITER ;

CALL uspInsertProjectCategory(1);
CALL uspInsertProjectCategory(2);
CALL uspInsertProjectCategory(3);
CALL uspInsertProjectCategory(10);
CALL uspInsertProjectCategory(20);
CALL uspInsertProjectCategory(30);
CALL uspInsertProjectCategory(99);   -- invalid: returns an error message, inserts nothing
SELECT * FROM ProjectCategory ORDER BY ProjectNo;
