-- Project 1 | Exercise 2: flag departments below a minimum headcount
ALTER TABLE department
    ADD COLUMN RecruitmentStatus BOOL,
    ADD COLUMN NumToRecruit INT;

DROP PROCEDURE IF EXISTS uspUpdateRecruitment;
DELIMITER //
CREATE PROCEDURE uspUpdateRecruitment(p_dnum INT, p_min INT)
BEGIN
    DECLARE v_emp INT;

    IF NOT EXISTS (SELECT 1 FROM department WHERE dnumber = p_dnum) THEN
        SELECT 'Department number not found' AS Info;
    ELSE
        SELECT COUNT(*) INTO v_emp FROM employee WHERE dno = p_dnum;

        UPDATE department
        SET RecruitmentStatus = (v_emp < p_min),
            NumToRecruit      = GREATEST(p_min - v_emp, 0)
        WHERE dnumber = p_dnum;
    END IF;
END //
DELIMITER ;

-- minimum headcount of 4 per department
CALL uspUpdateRecruitment(1, 4);
CALL uspUpdateRecruitment(4, 4);
CALL uspUpdateRecruitment(5, 4);
SELECT dnumber, dname, RecruitmentStatus, NumToRecruit FROM department;
