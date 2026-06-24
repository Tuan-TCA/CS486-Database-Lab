  # PROJECT: Campus Space Management System

  ## 1. Business Requirement Description

  The School of Computer Science manages several shared physical spaces used for teaching, seminars, examinations, workshops, student projects, research activities, and academic events. These spaces include auditoriums, classrooms, computer laboratories, project laboratories, meeting rooms, and student workspaces.

  Currently, requests to use these spaces are handled manually. Lecturers, teaching assistants, students, and staff usually contact the school office or facility staff by email, phone, or in person. Facility staff then check spreadsheets or shared calendars to determine whether a room is available, whether the requester is allowed to use it, whether special equipment is needed, and whether the room is under maintenance.

  As the number of classes, student projects, workshops, seminars, and academic events increases, the manual process has become difficult to manage. The School wants to build a database system to manage space booking, approval, usage sessions, maintenance, incident reporting, and facility utilization.

  The Facility Manager provides the following requirement summary:

  The School wants to develop a system to manage the booking and usage of shared campus spaces such as classrooms, computer laboratories, meeting rooms, and auditoriums.

  Each user must have a university account. The system stores basic user information, including:

  - User ID
  - Full Name
  - Email
  - Phone Number
  - Role
  - Department
  - Account Status

  A user may be:

  - Student
  - Lecturer
  - Teaching Assistant
  - Facility Staff
  - Department Administrator
  - Facility Manager

  The School manages many bookable spaces. For each space, the system stores:

  - Unique Space Code
  - Space Name
  - Space Type
  - Building
  - Floor
  - Room Number
  - Capacity
  - Current Status
  - Usage Policy

  A space may be:

  - Available
  - In Use
  - Under Maintenance
  - Temporarily Closed
  - Retired

  Each space may have several facilities, such as:

  - Projector
  - Whiteboard
  - Microphone
  - Computer
  - Livestreaming Equipment
  - Air Conditioner

  The system should store the list of facilities available in each space.

  Users can submit booking requests by selecting:

  - Space
  - Requested Start Time
  - Requested End Time
  - Purpose of Use
  - Expected Number of Participants

  A booking may be for:

  - Lecture
  - Examination
  - Seminar
  - Workshop
  - Meeting
  - Student Activity
  - Administrative Event

  Each booking request has a status, such as:

  - Pending
  - Approved
  - Rejected
  - Cancelled
  - Checked In
  - Completed
  - No-show

  The system must prevent conflicting bookings.
  The same space cannot have two approved bookings with overlapping time periods.
  A space that is under maintenance, closed, or retired cannot be booked.
  A booking request may require approval from a facility staff member or manager.
  When a booking is approved or rejected, the system records:

  - Staff Member Who Made the Decision
  - Decision Time
  - Decision Note

  If the booking is rejected, the rejection reason should be stored.
  When the requester arrives, facility staff can check in the booking. The system records:

  - Actual Start Time
  - Person Who Checked In the Booking
  - Initial Condition of the Space

  When the session ends, facility staff can complete the booking by recording:

  - Actual End Time
  - Final Condition of the Space
  - Usage Notes

  The system also supports basic maintenance management.
  A space may have maintenance records for problems such as:

  - Broken Projectors
  - Air-conditioning Failure
  - Damaged Furniture
  - Cleaning Issues
  - Network Problems

  Each maintenance record stores:

  - Related Space
  - Reporter
  - Assigned Staff Member
  - Problem Description
  - Start Time
  - Completion Time
  - Status
  - Result Note

  A space under maintenance cannot be booked.
  The system should keep historical records of bookings and maintenance activities.
  Staff should be able to view:

  - Booking History
  - Upcoming Bookings
  - Spaces Under Maintenance
  - No-show Bookings

  The main goal of the system is to help the School manage shared campus spaces fairly, avoid overlapping bookings, prevent the use of unavailable spaces, and preserve usage history.

  ---

  ## 2. Phase 1

  ### 1. Business Requirement Analysis

  Analyze the requirements to identify:

  - Business Purpose
  - Actors
  - Entities
  - Attributes
  - Relationships
  - Cardinalities
  - Business Rules

  ### 2. Conceptual Database Design

  Design an ERD showing:

  - Main Entities
  - Attributes
  - Relationships
  - Cardinalities
  - Participation Constraints

  ### 3. Logical Database Design

  Convert the ERD into a relational schema with:

  - Relations
  - Attributes
  - Primary Keys
  - Foreign Keys
  - Candidate Keys
  - Key Constraints

  ### 4. Database Design Validation

  Evaluate whether the relational schema:

  - Correctly Represents the ERD
  - Satisfies the Business Rules
  - Uses Appropriate Keys
  - Uses Appropriate Relationships
  - Uses Appropriate Constraints

  ### 5. Database Implementation

  Implement the database using SQL DDL with:

  - Tables
  - Keys
  - Constraints
  - Checks
  - Default Values (where appropriate)

  ### 6. Sample Data Preparation

  Insert realistic sample data to support testing of:

  - Normal Operations
  - Important Exceptional Cases

  ### 7. Query Design

  Each student must design and execute at least **5 meaningful SQL queries** that are valid for the database and useful for answering business questions in the given context.

  Each query must include:

  - Business Question
  - Target User(s)
  - Short Explanation of Why the Query is Useful
  - SQL Statement

  ---

  ## 3. Required Documents

  Each group must submit the following artifacts.

  ### 3.1 Group Report

  A PDF report named:

  ```text
  G<Group number>_Report.pdf
  ```

  Example:

  ```text
  G01_Report.pdf
  ```

  The report must include:

  - Student ID and Full Name of All Group Members.
  - The LLM Model(s) That the Group Used.
  - A Concise Description of the Group’s Agent Improvement Process, Including:
    - How the Agent’s Performance Was Evaluated at Each Step.
    - How the Group Refined or Improved the Agent Based on the Evaluation Results.

  ### 3.2 Group Agent Git Repository

  The group Git repository must include, but is not limited to, the following files and folders:

  ```text
  AGENT.md
  SKILL.md
  outputs/
  ```

  The `outputs` folder must contain the following deliverables:

  ```text
  01-business-req-analysis-G08.md
  02-erd-design-G08.md
  03-logical-design-G08.md
  04-design-validation-G08.md
  05-db-definition-G08.sql
  06-sample-data-G08.sql
  07-query-design-G08.sql
  ```

  Example for Group 01:

  ```text
  01-business-req-analysis-G01.md
  ```
