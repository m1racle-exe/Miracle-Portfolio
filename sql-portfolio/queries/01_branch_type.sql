-- Project 1 | Exercise 1: classify each department as single or multi-branch
-- Database: employee
ALTER TABLE department ADD COLUMN BranchType VARCHAR(15);

DROP PROCEDURE IF EXISTS uspUpdateBranchType;
DELIMITER //
CREATE PROCEDURE uspUpdateBranchType(p_dnum INT)
BEGIN
    DECLARE v_loc INT;

    IF NOT EXISTS (SELECT 1 FROM department WHERE dnumber = p_dnum) THEN
        SELECT 'Department number not found' AS Info;
    ELSE
        SELECT COUNT(*) INTO v_loc FROM dloc WHERE dnumber = p_dnum;

        UPDATE department
        SET BranchType = IF(v_loc > 1, 'Multi Branches', 'Single Branch')
        WHERE dnumber = p_dnum;
    END IF;
END //
DELIMITER ;

CALL uspUpdateBranchType(1);
CALL uspUpdateBranchType(4);
CALL uspUpdateBranchType(5);
SELECT dnumber, dname, BranchType FROM department;
