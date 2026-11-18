-- phpMyAdmin SQL Dump
-- version 4.7.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Feb 02, 2018 at 09:28 AM
-- Server version: 5.7.18-log
-- PHP Version: 5.6.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `employee`
--

-- --------------------------------------------------------

--
-- Table structure for table `department`
--

CREATE TABLE `department` (
  `dnumber` int(11) NOT NULL,
  `dname` varchar(50) DEFAULT NULL,
  `mgrssn` varchar(50) DEFAULT NULL,
  `mgrstartdate` datetime(6) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `department`
--

INSERT INTO `department` (`dnumber`, `dname`, `mgrssn`, `mgrstartdate`) VALUES
(1, 'Headquartes', '888665555', '1971-06-19 00:00:00.000000'),
(4, 'Administration', '987654321', '1985-01-01 00:00:00.000000'),
(5, 'Research', '333445555', '1978-05-22 00:00:00.000000');

-- --------------------------------------------------------

--
-- Table structure for table `dependent`
--

CREATE TABLE `dependent` (
  `essn` varchar(50) NOT NULL DEFAULT '',
  `dependent_name` varchar(50) NOT NULL DEFAULT '',
  `sex` varchar(50) DEFAULT NULL,
  `bdate` datetime(6) DEFAULT NULL,
  `relationship` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `dependent`
--

INSERT INTO `dependent` (`essn`, `dependent_name`, `sex`, `bdate`, `relationship`) VALUES
('123456789', 'Alicia', 'F', '1978-12-31 00:00:00.000000', 'Daughter'),
('123456789', 'Elizabeth', 'F', '1957-05-05 00:00:00.000000', 'Spouse'),
('123456789', 'Michael', 'M', '1978-01-01 00:00:00.000000', 'Son'),
('333445555', 'Alice', 'F', '1976-05-04 00:00:00.000000', 'Daughter'),
('333445555', 'Joy', 'F', '1948-03-05 00:00:00.000000', 'Spouse'),
('333445555', 'Theodore', 'M', '1973-10-25 00:00:00.000000', 'Son'),
('987654321', 'Abner', 'M', '1932-02-29 00:00:00.000000', 'Spouse');

-- --------------------------------------------------------

--
-- Table structure for table `dloc`
--

CREATE TABLE `dloc` (
  `dnumber` int(11) NOT NULL,
  `dlocation` varchar(50) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `dloc`
--

INSERT INTO `dloc` (`dnumber`, `dlocation`) VALUES
(1, 'Houston'),
(4, 'Stafford'),
(5, 'Bellaire'),
(5, 'Houston'),
(5, 'Sugarland');

-- --------------------------------------------------------

--
-- Table structure for table `employee`
--

CREATE TABLE `employee` (
  `ssn` varchar(50) NOT NULL DEFAULT '',
  `fname` varchar(50) DEFAULT NULL,
  `midname` varchar(50) DEFAULT NULL,
  `lname` varchar(50) DEFAULT NULL,
  `bdate` datetime(6) DEFAULT NULL,
  `address` varchar(50) DEFAULT NULL,
  `sex` varchar(50) DEFAULT NULL,
  `salary` int(11) DEFAULT NULL,
  `superssn` varchar(50) DEFAULT NULL,
  `dno` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `employee`
--

INSERT INTO `employee` (`ssn`, `fname`, `midname`, `lname`, `bdate`, `address`, `sex`, `salary`, `superssn`, `dno`) VALUES
('123456789', 'John', 'B', 'Smith', '1985-09-01 00:00:00.000000', 'Rungkut', 'M', 30000, NULL, 5),
('333445555', 'Franklin', 'T', 'Wong', '1995-08-12 00:00:00.000000', 'Kutisari', 'M', 40000, '123456789', 5),
('453453450', 'Joyce', 'A', 'English', '1982-07-31 00:00:00.000000', 'Darmawangsa', 'F', 25000, '333445555', 5),
('666884444', 'Ramesh', 'K', 'Narayan', '1992-09-15 00:00:00.000000', 'Siwalan', 'M', 38000, '123456789', 5),
('888665555', 'James', 'E', 'Borg', '1987-10-11 00:00:00.000000', 'Darmo', 'M', 55000, '999887777', 1),
('987654321', 'Jenifer', 'S', 'Wallace', '1971-06-20 00:00:00.000000', 'Ngagel', 'F', 43000, '999887777', 4),
('987987987', 'Ahmad', 'V', 'Jabbar', '1989-03-29 00:00:00.000000', 'Darmahusada', 'M', 25000, '123456789', 4),
('999887777', 'Alicia', 'J', 'Zelaya', '1978-07-19 00:00:00.000000', 'Tenggilis', 'F', 25000, '123456789', 4),
('999999999', 'Carrie', 'D', 'Underwood', '1985-07-09 00:00:00.000000', 'Krian', 'F', 45000, NULL, 4);

-- --------------------------------------------------------

--
-- Table structure for table `project`
--

CREATE TABLE `project` (
  `pnumber` int(11) NOT NULL,
  `dnum` int(11) NOT NULL,
  `pname` varchar(50) DEFAULT NULL,
  `plocation` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `project`
--

INSERT INTO `project` (`pnumber`, `dnum`, `pname`, `plocation`) VALUES
(1, 1, 'Productx', 'Bellaire'),
(2, 1, 'Producty', 'Sugarland'),
(3, 1, 'Productz', 'Houston'),
(10, 4, 'Computeriza', 'Stafford'),
(20, 4, 'Reorganizati', 'Houston'),
(30, 5, 'Newbenefits', 'Stafford');

-- --------------------------------------------------------

--
-- Table structure for table `works_on`
--

CREATE TABLE `works_on` (
  `ssn` varchar(50) NOT NULL DEFAULT '',
  `pno` int(11) NOT NULL,
  `hours` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `works_on`
--

INSERT INTO `works_on` (`ssn`, `pno`, `hours`) VALUES
('123456789', 1, 32),
('123456789', 2, 8),
('333445555', 2, 10),
('333445555', 3, 10),
('333445555', 10, 10),
('333445555', 20, 10),
('453453450', 1, 20),
('453453450', 2, 20),
('666884444', 3, 40),
('888665555', 20, 0),
('987654321', 20, 15),
('987654321', 30, 20),
('987987987', 10, 35),
('987987987', 30, 5),
('999887777', 10, 10),
('999887777', 30, 30);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `department`
--
ALTER TABLE `department`
  ADD PRIMARY KEY (`dnumber`),
  ADD KEY `fk_department_has_manager` (`mgrssn`);

--
-- Indexes for table `dependent`
--
ALTER TABLE `dependent`
  ADD PRIMARY KEY (`essn`,`dependent_name`);

--
-- Indexes for table `dloc`
--
ALTER TABLE `dloc`
  ADD PRIMARY KEY (`dnumber`,`dlocation`);

--
-- Indexes for table `employee`
--
ALTER TABLE `employee`
  ADD PRIMARY KEY (`ssn`),
  ADD KEY `fk_employee_employee1_idx` (`superssn`);

--
-- Indexes for table `project`
--
ALTER TABLE `project`
  ADD PRIMARY KEY (`pnumber`),
  ADD KEY `fk_project_department1_idx` (`dnum`);

--
-- Indexes for table `works_on`
--
ALTER TABLE `works_on`
  ADD PRIMARY KEY (`ssn`,`pno`),
  ADD KEY `fk_project_has_employee` (`pno`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `department`
--
ALTER TABLE `department`
  MODIFY `dnumber` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;
--
-- AUTO_INCREMENT for table `project`
--
ALTER TABLE `project`
  MODIFY `pnumber` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41;
--
-- Constraints for dumped tables
--

--
-- Constraints for table `department`
--
ALTER TABLE `department`
  ADD CONSTRAINT `fk_department_has_manager` FOREIGN KEY (`mgrssn`) REFERENCES `employee` (`ssn`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `dependent`
--
ALTER TABLE `dependent`
  ADD CONSTRAINT `fk_employee_has_dependent` FOREIGN KEY (`essn`) REFERENCES `employee` (`ssn`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `dloc`
--
ALTER TABLE `dloc`
  ADD CONSTRAINT `fk_department_has_location` FOREIGN KEY (`dnumber`) REFERENCES `department` (`dnumber`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `employee`
--
ALTER TABLE `employee`
  ADD CONSTRAINT `fk_employee_employee1` FOREIGN KEY (`superssn`) REFERENCES `employee` (`ssn`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `project`
--
ALTER TABLE `project`
  ADD CONSTRAINT `fk_project_department1` FOREIGN KEY (`dnum`) REFERENCES `department` (`dnumber`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `works_on`
--
ALTER TABLE `works_on`
  ADD CONSTRAINT `fk_employee_has_project` FOREIGN KEY (`ssn`) REFERENCES `employee` (`ssn`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_project_has_employee` FOREIGN KEY (`pno`) REFERENCES `project` (`pnumber`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
