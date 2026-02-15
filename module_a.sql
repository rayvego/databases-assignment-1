-- Course Project: Track 1 (Database Driven Software System)
-- Assignment 1: Database and UML Development
-- Module A: Database Design and Implementation
-- Project Name: CheckInOut - Hostel Management System
-- Group Member: Mohit Kamlesh Panchal (Roll Number: 23110208)
-- Date: 7th February 2026

-- 1. Member Table (Superclass Entity)
-- Stores common attributes for all system users (Students, Staff, Wardens)
CREATE TABLE Member (
    MemberID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    ContactNumber VARCHAR(15) NOT NULL,
    Age INT NOT NULL CHECK (Age >= 16),
    Gender ENUM('Male', 'Female', 'Other') NOT NULL,
    Address TEXT,
    ProfileImage VARCHAR(255), -- Stores path to image
    UserType ENUM('Student', 'Staff', 'Admin') NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Staff Table (Subclass of Member)
-- Stores specific details for staff members (Wardens, Security, Cleaners)
CREATE TABLE Staff (
    StaffID INT PRIMARY KEY,
    Designation VARCHAR(50) NOT NULL,
    ShiftStart TIME NOT NULL,
    ShiftEnd TIME NOT NULL,
    IsActive BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (StaffID) REFERENCES Member(MemberID) ON DELETE CASCADE ON UPDATE CASCADE
);

-- 3. Student Table (Subclass of Member)
-- Stores specific details for students living in the hostel
CREATE TABLE Student (
    StudentID INT PRIMARY KEY,
    EnrollmentNo VARCHAR(20) NOT NULL UNIQUE,
    Course VARCHAR(50) NOT NULL,
    BatchYear INT NOT NULL,
    GuardianName VARCHAR(100) NOT NULL,
    GuardianContact VARCHAR(15) NOT NULL,
    FOREIGN KEY (StudentID) REFERENCES Member(MemberID) ON DELETE CASCADE ON UPDATE CASCADE
);

-- 4. HostelBlock Table
-- Represents physical hostel buildings
CREATE TABLE HostelBlock (
    BlockID INT PRIMARY KEY AUTO_INCREMENT,
    BlockName VARCHAR(50) NOT NULL UNIQUE,
    Type ENUM('Boys', 'Girls', 'Mixed') NOT NULL,
    TotalFloors INT NOT NULL CHECK (TotalFloors > 0),
    WardenID INT,
    FOREIGN KEY (WardenID) REFERENCES Staff(StaffID) ON DELETE SET NULL ON UPDATE CASCADE
);

-- 5. Room Table
-- Represents individual rooms within a hostel block
CREATE TABLE Room (
    RoomID INT PRIMARY KEY AUTO_INCREMENT,
    BlockID INT NOT NULL,
    RoomNumber VARCHAR(10) NOT NULL,
    FloorNumber INT NOT NULL,
    Capacity INT NOT NULL CHECK (Capacity > 0),
    CurrentOccupancy INT DEFAULT 0 CHECK (CurrentOccupancy >= 0),
    Type ENUM('AC', 'Non-AC') NOT NULL DEFAULT 'Non-AC',
    Status ENUM('Available', 'Full', 'Maintenance') DEFAULT 'Available',
    FOREIGN KEY (BlockID) REFERENCES HostelBlock(BlockID) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT UQ_Block_Room UNIQUE (BlockID, RoomNumber)
);

-- 6. Allocation Table
-- Tracks which student is assigned to which room
CREATE TABLE Allocation (
    AllocationID INT PRIMARY KEY AUTO_INCREMENT,
    StudentID INT NOT NULL,
    RoomID INT NOT NULL,
    CheckInDate DATE NOT NULL,
    CheckOutDate DATE,
    Status ENUM('Active', 'Completed', 'Cancelled') DEFAULT 'Active',
    FOREIGN KEY (StudentID) REFERENCES Student(StudentID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (RoomID) REFERENCES Room(RoomID) ON DELETE CASCADE ON UPDATE CASCADE,
    CHECK (CheckOutDate IS NULL OR CheckOutDate >= CheckInDate)
);

-- 7. GatePass Table
-- Logs student entry and exit from the hostel premises
CREATE TABLE GatePass (
    PassID INT PRIMARY KEY AUTO_INCREMENT,
    StudentID INT NOT NULL,
    OutTime DATETIME NOT NULL,
    ExpectedInTime DATETIME NOT NULL,
    ActualInTime DATETIME,
    Reason TEXT NOT NULL,
    Status ENUM('Pending', 'Approved', 'Rejected', 'Closed') DEFAULT 'Pending',
    ApproverID INT,
    FOREIGN KEY (StudentID) REFERENCES Student(StudentID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (ApproverID) REFERENCES Staff(StaffID) ON DELETE SET NULL ON UPDATE CASCADE,
    CHECK (ExpectedInTime > OutTime)
);

-- 8. Visitor Table
-- Stores details of external visitors
CREATE TABLE Visitor (
    VisitorID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    ContactNumber VARCHAR(15) NOT NULL,
    GovtIDProof VARCHAR(50),
    RelationToStudent VARCHAR(50) NOT NULL
);

-- 9. VisitLog Table
-- Tracks actual visits to students
CREATE TABLE VisitLog (
    VisitID INT PRIMARY KEY AUTO_INCREMENT,
    VisitorID INT NOT NULL,
    StudentID INT NOT NULL,
    CheckInTime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CheckOutTime DATETIME,
    Purpose VARCHAR(255),
    FOREIGN KEY (VisitorID) REFERENCES Visitor(VisitorID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (StudentID) REFERENCES Student(StudentID) ON DELETE CASCADE ON UPDATE CASCADE,
    CHECK (CheckOutTime IS NULL OR CheckOutTime >= CheckInTime)
);

-- 10. MaintenanceRequest Table
-- Tracks facility issues reported by residents
CREATE TABLE MaintenanceRequest (
    RequestID INT PRIMARY KEY AUTO_INCREMENT,
    RoomID INT,
    ReportedBy INT NOT NULL,
    Title VARCHAR(100) NOT NULL,
    Description TEXT NOT NULL,
    Priority ENUM('Low', 'Medium', 'High', 'Emergency') DEFAULT 'Medium',
    Status ENUM('Open', 'In_Progress', 'Resolved') DEFAULT 'Open',
    ReportedDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    ResolvedDate DATETIME,
    ResolvedBy INT,
    FOREIGN KEY (RoomID) REFERENCES Room(RoomID) ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (ReportedBy) REFERENCES Member(MemberID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (ResolvedBy) REFERENCES Staff(StaffID) ON DELETE SET NULL ON UPDATE CASCADE
);

-- 11. FeePayment Table
-- Tracks payments related to hostel fees
CREATE TABLE FeePayment (
    PaymentID INT PRIMARY KEY AUTO_INCREMENT,
    StudentID INT NOT NULL,
    Amount DECIMAL(10, 2) NOT NULL CHECK (Amount > 0),
    PaymentDate DATE NOT NULL,
    PaymentType ENUM('Hostel_Fee', 'Mess_Fee', 'Fine', 'Security_Deposit') NOT NULL,
    TransactionID VARCHAR(50) UNIQUE,
    Status ENUM('Success', 'Failed', 'Pending') DEFAULT 'Pending',
    FOREIGN KEY (StudentID) REFERENCES Student(StudentID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX idx_student_enrollment ON Student(EnrollmentNo);
CREATE INDEX idx_allocation_room ON Allocation(RoomID);
CREATE INDEX idx_gatepass_student ON GatePass(StudentID);
CREATE INDEX idx_maintenance_status ON MaintenanceRequest(Status);

-- 1. Insert Members (Mix of Staff and Students)
INSERT INTO Member (Name, Email, ContactNumber, Age, Gender, Address, UserType) VALUES
('Ramesh Kumar', 'ramesh@hostel.com', '9876543210', 45, 'Male', 'Delhi, India', 'Staff'),
('Sita Devi', 'sita@hostel.com', '9876543211', 40, 'Female', 'Mumbai, India', 'Staff'),
('Amit Sharma', 'amit@student.com', '9123456780', 20, 'Male', 'Jaipur, India', 'Student'),
('Priya Singh', 'priya@student.com', '9123456781', 19, 'Female', 'Lucknow, India', 'Student'),
('Rahul Verma', 'rahul@student.com', '9123456782', 21, 'Male', 'Patna, India', 'Student'),
('Sneha Gupta', 'sneha@student.com', '9123456783', 20, 'Female', 'Bhopal, India', 'Student'),
('Vikram Rathore', 'vikram@hostel.com', '9876543212', 50, 'Male', 'Udaipur, India', 'Staff'),
('Anjali Mehta', 'anjali@student.com', '9123456784', 22, 'Female', 'Indore, India', 'Student'),
('Karan Johar', 'karan@student.com', '9123456785', 18, 'Male', 'Mumbai, India', 'Student'),
('Suresh Raina', 'suresh@hostel.com', '9876543213', 35, 'Male', 'Chennai, India', 'Staff'),
('Pooja Hegde', 'pooja@student.com', '9123456786', 20, 'Female', 'Hyderabad, India', 'Student'),
('Arjun Kapoor', 'arjun@student.com', '9123456787', 21, 'Male', 'Delhi, India', 'Student'),
('Neha Kakkar', 'neha@student.com', '9123456788', 19, 'Female', 'Chandigarh, India', 'Student'),
('Rajesh Koothrappali', 'rajesh@student.com', '9123456789', 23, 'Male', 'Bangalore, India', 'Student'),
('Manish Malhotra', 'manish@hostel.com', '9876543214', 42, 'Male', 'Kolkata, India', 'Staff');

-- 2. Insert Staff Details (Linking to MemberIDs 1, 2, 7, 10, 15)
INSERT INTO Staff (StaffID, Designation, ShiftStart, ShiftEnd, IsActive) VALUES
(1, 'Chief Warden', '08:00:00', '16:00:00', TRUE),
(2, 'Girls Warden', '08:00:00', '16:00:00', TRUE),
(7, 'Security Guard', '20:00:00', '08:00:00', TRUE),
(10, 'Maintenance Supervisor', '09:00:00', '17:00:00', TRUE),
(15, 'Mess Manager', '06:00:00', '22:00:00', TRUE);

-- 3. Insert Student Details (Linking to remaining MemberIDs)
INSERT INTO Student (StudentID, EnrollmentNo, Course, BatchYear, GuardianName, GuardianContact) VALUES
(3, 'CS2023001', 'B.Tech CSE', 2023, 'Raj Sharma', '8888888801'),
(4, 'CS2023002', 'B.Tech CSE', 2023, 'Vijay Singh', '8888888802'),
(5, 'ME2022001', 'B.Tech ME', 2022, 'Ajay Verma', '8888888803'),
(6, 'EE2023005', 'B.Tech EE', 2023, 'Sanjay Gupta', '8888888804'),
(8, 'CS2021009', 'M.Tech CSE', 2021, 'Alok Mehta', '8888888805'),
(9, 'CV2024001', 'B.Tech Civil', 2024, 'Yash Johar', '8888888806'),
(11, 'EC2023010', 'B.Tech ECE', 2023, 'Ravi Hegde', '8888888807'),
(12, 'ME2022045', 'B.Tech ME', 2022, 'Boney Kapoor', '8888888808'),
(13, 'CS2024022', 'B.Tech CSE', 2024, 'Tony Kakkar', '8888888809'),
(14, 'PH2020003', 'PhD Physics', 2020, 'V. Koothrappali', '8888888810');

-- 4. Insert Hostel Blocks
INSERT INTO HostelBlock (BlockName, Type, TotalFloors, WardenID) VALUES
('Himalaya', 'Boys', 4, 1),
('Ganga', 'Girls', 3, 2),
('Vindhya', 'Boys', 5, 1),
('Yamuna', 'Girls', 4, 2);

-- 5. Insert Rooms
-- Block 1 (Himalaya - Boys)
INSERT INTO Room (BlockID, RoomNumber, FloorNumber, Capacity, CurrentOccupancy, Type) VALUES
(1, '101', 1, 2, 2, 'Non-AC'),
(1, '102', 1, 2, 1, 'Non-AC'),
(1, '201', 2, 1, 1, 'AC'),
(1, '202', 2, 2, 0, 'AC');

-- Block 2 (Ganga - Girls)
INSERT INTO Room (BlockID, RoomNumber, FloorNumber, Capacity, CurrentOccupancy, Type) VALUES
(2, 'G-101', 1, 3, 3, 'Non-AC'),
(2, 'G-102', 1, 2, 1, 'AC'),
(2, 'G-201', 2, 2, 0, 'AC');

-- Block 3 (Vindhya - Boys)
INSERT INTO Room (BlockID, RoomNumber, FloorNumber, Capacity, CurrentOccupancy, Type) VALUES
(3, 'V-301', 3, 1, 1, 'AC'),
(3, 'V-302', 3, 1, 0, 'AC');

-- Block 4 (Yamuna - Girls)
INSERT INTO Room (BlockID, RoomNumber, FloorNumber, Capacity, CurrentOccupancy, Type) VALUES
(4, 'Y-101', 1, 2, 0, 'Non-AC');

-- 6. Insert Allocations (Active and Completed)
INSERT INTO Allocation (StudentID, RoomID, CheckInDate, CheckOutDate, Status) VALUES
(3, 1, '2023-08-01', NULL, 'Active'), -- Amit in 101
(5, 1, '2023-08-01', NULL, 'Active'), -- Rahul in 101
(9, 2, '2024-01-15', NULL, 'Active'), -- Karan in 102
(14, 3, '2020-07-20', NULL, 'Active'), -- Rajesh in 201
(4, 5, '2023-08-01', NULL, 'Active'), -- Priya in G-101
(6, 5, '2023-08-01', NULL, 'Active'), -- Sneha in G-101
(8, 5, '2021-08-01', NULL, 'Active'), -- Anjali in G-101
(11, 6, '2023-08-10', NULL, 'Active'), -- Pooja in G-102
(12, 8, '2022-08-01', NULL, 'Active'), -- Arjun in V-301
(13, 2, '2023-01-01', '2023-12-31', 'Completed'); -- Neha checked out

-- 7. Insert GatePasses
INSERT INTO GatePass (StudentID, OutTime, ExpectedInTime, ActualInTime, Reason, Status, ApproverID) VALUES
(3, '2024-02-01 10:00:00', '2024-02-01 18:00:00', '2024-02-01 17:30:00', 'Shopping', 'Closed', 1),
(4, '2024-02-02 09:00:00', '2024-02-02 20:00:00', NULL, 'Family Function', 'Approved', 2),
(5, '2024-02-03 14:00:00', '2024-02-03 16:00:00', '2024-02-03 16:15:00', 'Library', 'Closed', 1),
(6, '2024-02-04 08:00:00', '2024-02-05 08:00:00', NULL, 'Night Stay at Relative', 'Pending', NULL),
(14, '2024-02-01 22:00:00', '2024-02-01 23:00:00', '2024-02-01 23:30:00', 'Dinner', 'Closed', 7),
(9, '2024-02-05 10:00:00', '2024-02-05 12:00:00', NULL, 'Doctor Visit', 'Rejected', 1),
(12, '2024-02-06 15:00:00', '2024-02-06 19:00:00', NULL, 'Movie', 'Approved', 1),
(8, '2024-02-01 10:00:00', '2024-02-01 12:00:00', '2024-02-01 11:55:00', 'Market', 'Closed', 2),
(3, '2024-02-07 08:00:00', '2024-02-07 09:00:00', NULL, 'Morning Walk', 'Pending', NULL),
(11, '2024-01-20 10:00:00', '2024-01-25 10:00:00', '2024-01-25 09:00:00', 'Vacation', 'Closed', 2);

-- 8. Insert Visitors
INSERT INTO Visitor (Name, ContactNumber, GovtIDProof, RelationToStudent) VALUES
('Raj Sharma', '8888888801', 'AADHAR-1234', 'Father'),
('Sanjay Gupta', '8888888804', 'PAN-5678', 'Father'),
('Rohan Das', '9999999999', 'DL-9012', 'Friend'),
('Amazon Delivery', '1111111111', 'EmpID-001', 'Delivery'),
('Meera Patel', '7777777701', 'AADHAR-2345', 'Mother'),
('Vijay Kumar', '7777777702', 'PAN-8901', 'Brother'),
('Anita Reddy', '7777777703', 'DL-3456', 'Aunt'),
('Rahul Sharma', '7777777704', 'AADHAR-4567', 'Cousin'),
('Priya Courier', '6666666666', 'EmpID-002', 'Delivery'),
('Dr. Suresh', '5555555555', 'REG-001', 'Doctor'),
('Neha Parents', '7777777705', 'AADHAR-5678', 'Parents'),
('Food Delivery', '4444444444', 'EmpID-003', 'Delivery');

-- 9. Insert VisitLogs
INSERT INTO VisitLog (VisitorID, StudentID, CheckInTime, CheckOutTime, Purpose) VALUES
(1, 3, '2024-01-15 10:00:00', '2024-01-15 14:00:00', 'Meeting Warden'),
(2, 6, '2024-02-01 16:00:00', '2024-02-01 17:00:00', 'Dropping Luggage'),
(3, 14, '2024-02-02 18:00:00', '2024-02-02 19:00:00', 'Group Study'),
(4, 5, '2024-02-03 11:00:00', '2024-02-03 11:10:00', 'Package Delivery'),
(1, 3, '2024-02-05 09:00:00', NULL, 'Urgent Work'),
(5, 4, '2024-01-20 14:00:00', '2024-01-20 16:00:00', 'Health Checkup'),
(6, 9, '2024-02-10 11:00:00', '2024-02-10 13:00:00', 'Birthday Celebration'),
(7, 11, '2024-02-11 15:00:00', '2024-02-11 18:00:00', 'Family Visit'),
(8, 12, '2024-02-12 10:00:00', '2024-02-12 12:00:00', 'Breakfast Visit'),
(9, 3, '2024-02-13 17:00:00', '2024-02-13 17:30:00', 'Parcel Delivery'),
(10, 14, '2024-02-14 09:00:00', '2024-02-14 10:00:00', 'Regular Checkup'),
(11, 6, '2024-02-15 12:00:00', '2024-02-15 14:00:00', 'Parents Meeting'),
(12, 8, '2024-02-16 18:00:00', NULL, 'Dinner Delivery');

-- 10. Insert MaintenanceRequests
INSERT INTO MaintenanceRequest (RoomID, ReportedBy, Title, Description, Priority, Status, ResolvedBy) VALUES
(1, 3, 'Fan not working', 'Ceiling fan making noise', 'Medium', 'Resolved', 10),
(2, 9, 'Tap leaking', 'Bathroom tap constantly dripping', 'Low', 'Open', NULL),
(5, 4, 'Window broken', 'Window glass cracked due to cricket ball', 'High', 'In_Progress', 10),
(NULL, 1, 'Corridor Light', '2nd Floor Corridor light flickering', 'Low', 'Open', NULL),
(8, 12, 'AC not cooling', 'AC running but no cooling', 'High', 'Resolved', 10),
(6, 11, 'Door lock jammed', 'Cannot lock room from inside', 'Emergency', 'In_Progress', 10),
(3, 14, 'Internet Slow', 'LAN port not working', 'Medium', 'Open', NULL),
(1, 5, 'Switch broken', 'Switch board loose', 'Low', 'Resolved', 10),
(5, 6, 'Water logging', 'Balcony water not draining', 'Medium', 'Open', NULL),
(NULL, 2, 'Water cooler dirty', 'Common area cooler needs cleaning', 'High', 'Resolved', 10);

-- 11. Insert FeePayments
INSERT INTO FeePayment (StudentID, Amount, PaymentDate, PaymentType, TransactionID, Status) VALUES
(3, 50000.00, '2023-07-15', 'Hostel_Fee', 'TXN1001', 'Success'),
(4, 50000.00, '2023-07-16', 'Hostel_Fee', 'TXN1002', 'Success'),
(5, 25000.00, '2023-07-20', 'Mess_Fee', 'TXN1003', 'Success'),
(6, 500.00, '2023-12-01', 'Fine', 'TXN1004', 'Pending'),
(8, 50000.00, '2021-07-10', 'Hostel_Fee', 'TXN1005', 'Success'),
(9, 25000.00, '2024-01-10', 'Mess_Fee', 'TXN1006', 'Failed'),
(11, 50000.00, '2023-07-18', 'Hostel_Fee', 'TXN1007', 'Success'),
(12, 1000.00, '2023-11-15', 'Security_Deposit', 'TXN1008', 'Success'),
(13, 50000.00, '2024-01-05', 'Hostel_Fee', 'TXN1009', 'Success'),
(14, 500.00, '2024-02-01', 'Fine', 'TXN1010', 'Success');
