/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 2 of the case study, which means that there'll be less guidance for you about how to setup
your local SQLite connection in PART 2 of the case study. This will make the case study more challenging for you: 
you might need to do some digging, aand revise the Working with Relational Databases in Python chapter in the previous resource.

Otherwise, the questions in the case study are exactly the same as with Tier 1. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

SELECT name
FROM Facilities
WHERE membercost > 0;



/* Q2: How many facilities do not charge a fee to members? */

-- 4 facilities
-- SQL Query Below:

SELECT COUNT(*)
FROM Facilities
WHERE membercost = 0;



/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name, membercost, monthlymaintenance
FROM Facilities
WHERE membercost < (0.2 * monthlymaintenance);



/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

SELECT *
FROM Facilities
WHERE facid IN (1,5);



/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

SELECT facid, monthlymaintenance, 
	CASE WHEN monthlymaintenance > 100 THEN 'expensive'
		ELSE 'cheap' END AS 'maintenance_cost_category'
FROM Facilities;



/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

SELECT firstname, surname
FROM Members
WHERE joindate = 
	(SELECT MAX(joindate)
     FROM Members);



/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT f.name AS court_name, CONCAT_WS(' ',m.firstname, m.surname) AS full_member_name

FROM Bookings AS b
LEFT JOIN Facilities AS f
	ON b.facid = f.facid
LEFT JOIN Members AS m
	ON b.memid = m.memid

WHERE b.facid IN
	(SELECT facid
     FROM Facilities
     WHERE name LIKE 'Tennis Court%')

GROUP BY full_member_name, court_name; -- Note: for some reason, including an ORDER BY function generates a 403 error, so used GROUP BY instead



/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT b.bookid, f.name AS facility, CONCAT_WS(' ',m.firstname, m.surname) AS full_member_name, 
	CASE WHEN m.firstname = 'GUEST' THEN (slots * guestcost)
		ELSE (slots * membercost) END AS cost

FROM Bookings AS b
LEFT JOIN Facilities AS f
	ON b.facid = f.facid
LEFT JOIN Members AS m
	ON b.memid = m.memid

WHERE DATE(starttime) = '2012-09-14'
AND CASE WHEN m.firstname = 'GUEST' THEN (slots * guestcost)
		ELSE (slots * membercost) END > 30

ORDER BY cost DESC;



/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT sub.bookid, sub.facility, sub.full_member_name, sub.cost

FROM
	(SELECT b.bookid, f.name AS facility, CONCAT_WS(' ',m.firstname, m.surname) AS full_member_name, 
		CASE WHEN m.firstname = 'GUEST' THEN (slots * guestcost)
			ELSE (slots * membercost) END AS cost

	FROM Bookings AS b
	LEFT JOIN Facilities AS f
		ON b.facid = f.facid
	LEFT JOIN Members AS m
		ON b.memid = m.memid

	WHERE DATE(starttime) = '2012-09-14') AS sub

WHERE sub.cost > 30

ORDER BY sub.cost DESC;



/* PART 2: SQLite

Export the country club data from PHPMyAdmin, and connect to a local SQLite instance from Jupyter notebook 
for the following questions.  

QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

query = '''SELECT sub.facility, SUM(sub.revenue) AS total_revenue
        
        FROM
            (SELECT b.bookid, f.name AS facility, 
    		CASE WHEN m.firstname = 'GUEST' THEN (slots * guestcost)
    			ELSE (slots * membercost) END AS revenue

        	FROM Bookings AS b
        	LEFT JOIN Facilities AS f
        		ON b.facid = f.facid
        	LEFT JOIN Members AS m
        		ON b.memid = m.memid) AS sub

        
        GROUP BY sub.facility
        HAVING SUM(sub.revenue) < 1000
        ORDER BY total_revenue
        
        '''

    df = pd.read_sql_query(query, connection)
    df

result: 

Facility	total_revenue
Table Tennis	180
Snooker Table	240
Pool Table	    270





/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

query = '''SELECT m1.surname||','|| ' ' || m1.firstname AS member_name, m2.surname||','|| ' ' ||m2.firstname AS recommendedby_name
        FROM Members AS m1
        LEFT JOIN Members AS m2 ON m1.recommendedby = m2.memid
        ORDER BY m1.surname;'''
df = pd.read_sql_query(query, connection)
df

result:

member_name	      recommendedby_name
Bader, Florence	     Stibbons, Ponder
Baker, Anne	         Stibbons, Ponder
Baker, Timothy	     Farrell, Jemima
Boothe, Tim	         Rownam, Tim
Butters, Gerald	     Smith, Darren
Coplin, Joan	     Baker, Timothy
Crumpet, Erica	     Smith, Tracy
Dare, Nancy	         Joplette, Janice
Farrell, Jemima	     None
Farrell, David	     None
GUEST, GUEST	     None
Genting, Matthew	 Butters, Gerald
Hunt, John	         Purview, Millicent
Jones, David	     Joplette, Janice
Jones, Douglas	     Jones, David
Joplette, Janice	 Smith, Darren
Mackenzie, Anna	     Smith, Darren
Owen, Charles	     Smith, Darren
Pinker, David	     Farrell, Jemima
Purview, Millicent	 Smith, Tracy
Rownam, Tim	         None
Rumney, Henrietta	 Genting, Matthew
Sarwin, Ramnaresh	 Bader, Florence
Smith, Darren	     None
Smith, Tracy	     None
Smith, Jack	         Smith, Darren
Smith, Darren	     None
Stibbons, Ponder	 Tracy, Burton
Tracy, Burton	        None
Tupperware, Hyacinth	None
Worthington-Smyth, Henry	Smith, Tracy 





/* Q12: Find the facilities with their usage by member, but not guests */

query = '''SELECT m.surname, m.firstname, 
            	SUM(CASE WHEN m.memid = b.memid AND b.facid = 0 THEN slots ELSE 0 END) AS num_slots_booked_tennis_court_1,
                SUM(CASE WHEN m.memid = b.memid AND b.facid = 1 THEN slots ELSE 0 END) AS num_slots_booked_tennis_court_2,
                SUM(CASE WHEN m.memid = b.memid AND b.facid = 2 THEN slots ELSE 0 END) AS num_slots_booked_badminton_court,
                SUM(CASE WHEN m.memid = b.memid AND b.facid = 3 THEN slots ELSE 0 END) AS num_slots_booked_table_tennis,
                SUM(CASE WHEN m.memid = b.memid AND b.facid = 4 THEN slots ELSE 0 END) AS num_slots_booked_massage_1,
                SUM(CASE WHEN m.memid = b.memid AND b.facid = 5 THEN slots ELSE 0 END) AS num_slots_booked_massage_2,
                SUM(CASE WHEN m.memid = b.memid AND b.facid = 6 THEN slots ELSE 0 END) AS num_slots_booked_squash_court,
                SUM(CASE WHEN m.memid = b.memid AND b.facid = 7 THEN slots ELSE 0 END) AS num_slots_booked_snooker_table,
                SUM(CASE WHEN m.memid = b.memid AND b.facid = 8 THEN slots ELSE 0 END) AS num_slots_booked_pool_table
                
FROM Bookings AS b
LEFT JOIN Members AS m ON b.memid = m.memid
WHERE m.surname <> 'GUEST'
GROUP BY m.surname, m.firstname;'''

df = pd.read_sql_query(query, connection)
df

Note - result is too large to paste here


/* Q13: Find the facilities usage by month, but not guests */

query = '''SELECT f.name AS facility, 
            	SUM(CASE WHEN b.facid = f.facid AND strftime('%m', b.starttime) = '01' THEN slots ELSE 0 END) AS num_slots_booked_jan,
                SUM(CASE WHEN b.facid = f.facid AND strftime('%m', b.starttime) = '02' THEN slots ELSE 0 END) AS num_slots_booked_feb,
                SUM(CASE WHEN b.facid = f.facid AND strftime('%m', b.starttime) = '03' THEN slots ELSE 0 END) AS num_slots_booked_mar,
                SUM(CASE WHEN b.facid = f.facid AND strftime('%m', b.starttime) = '04' THEN slots ELSE 0 END) AS num_slots_booked_apr,
                SUM(CASE WHEN b.facid = f.facid AND strftime('%m', b.starttime) = '05' THEN slots ELSE 0 END) AS num_slots_booked_may,
                SUM(CASE WHEN b.facid = f.facid AND strftime('%m', b.starttime) = '06' THEN slots ELSE 0 END) AS num_slots_booked_jun,
                SUM(CASE WHEN b.facid = f.facid AND strftime('%m', b.starttime) = '07' THEN slots ELSE 0 END) AS num_slots_booked_jul,
                SUM(CASE WHEN b.facid = f.facid AND strftime('%m', b.starttime) = '08' THEN slots ELSE 0 END) AS num_slots_booked_aug,
                SUM(CASE WHEN b.facid = f.facid AND strftime('%m', b.starttime) = '09' THEN slots ELSE 0 END) AS num_slots_booked_sep,
                SUM(CASE WHEN b.facid = f.facid AND strftime('%m', b.starttime) = '10' THEN slots ELSE 0 END) AS num_slots_booked_oct,
                SUM(CASE WHEN b.facid = f.facid AND strftime('%m', b.starttime) = '11' THEN slots ELSE 0 END) AS num_slots_booked_nov,
                SUM(CASE WHEN b.facid = f.facid AND strftime('%m', b.starttime) = '12' THEN slots ELSE 0 END) AS num_slots_booked_dec
FROM Bookings AS b
LEFT JOIN Facilities AS f ON b.facid = f.facid
LEFT JOIN Members AS m ON b.memid = m.memid AND m.surname <> 'GUEST'
GROUP BY facility;'''

df = pd.read_sql_query(query, connection)
df

Note - result is too large to paste here


