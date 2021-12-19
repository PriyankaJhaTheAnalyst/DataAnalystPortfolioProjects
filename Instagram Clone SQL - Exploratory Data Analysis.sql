/*INSTAGRAM CLONE EXPLORATORY DATA ANALYSIS USING SQL*/

/*SQL SKILLS: joins, date manipulation, regular expressions, views, stored procedures, aggregate functions, string manipulation*/
 
-- --------------------------------------------------------------------------------------------------------------

/*Ques.1 The first 10 users on the platform*/

SELECT 
    *
FROM
    ig_clone.users
ORDER BY created_at asc
LIMIT 10;
-- --------------------------------------------------------------------------------------------------------------

/*Ques.2 Total number of registrations*/

SELECT 
    COUNT(*) AS 'Total Registration'
FROM
    ig_clone.users;
-- --------------------------------------------------------------------------------------------------------------

/*Ques.3 The day of the week most users register on*/

CREATE VIEW vwtotalregistrations AS
    SELECT 
        DATE_FORMAT(created_at, '%W') AS 'day of the week',
        COUNT(*) AS 'total number of registration'
    FROM
        ig_clone.users
    GROUP BY 1
    ORDER BY 2 DESC;
    
SELECT 
    *
FROM
    vwtotalregistrations;

/*Version 2*/

SELECT 
    DAYNAME(created_at) AS 'Day of the Week',
    COUNT(*) AS 'Total Registration'
FROM
    ig_clone.users
GROUP BY 1
ORDER BY 2 DESC;
-- --------------------------------------------------------------------------------------------------------------

/*Ques.4 The users who have never posted a photo*/

SELECT 
    u.username
FROM
    ig_clone.users u
        LEFT JOIN
    ig_clone.photos p ON p.user_id = u.id
WHERE
    p.id IS NULL;
-- --------------------------------------------------------------------------------------------------------------

/*Ques.5 The most likes on a single photo*/
	
SELECT 
     u.username, p.image_url, COUNT(*) AS total
FROM
    ig_clone.photos p
        INNER JOIN
    ig_clone.likes l ON l.photo_id = p.id
        INNER JOIN
    ig_clone.users u ON p.user_id = u.id
GROUP BY p.id
ORDER BY total DESC
LIMIT 1;

/*Version 2*/

SELECT 
    ROUND((SELECT 
                    COUNT(*)
                FROM
                    ig_clone.photos) / (SELECT 
                    COUNT(*)
                FROM
                    ig_clone.users),
            2) AS 'Average Posts by Users';
-- --------------------------------------------------------------------------------------------------------------

/*Ques.6 The number of photos posted by most active users*/

SELECT 
	u.username AS 'Username',
    COUNT(p.image_url) AS 'Number of Posts'
FROM
    ig_clone.users u
        JOIN
    ig_clone.photos p ON u.id = p.user_id
GROUP BY u.id
ORDER BY 2 DESC
LIMIT 5;
-- --------------------------------------------------------------------------------------------------------------

/*Ques.7 The total number of posts*/

SELECT 
    SUM(user_posts.total_posts_per_user) AS 'Total Posts by Users'
FROM
    (SELECT 
        u.username, COUNT(p.image_url) AS total_posts_per_user
    FROM
        ig_clone.users u
    JOIN ig_clone.photos p ON u.id = p.user_id
    GROUP BY u.id) AS user_posts;
-- --------------------------------------------------------------------------------------------------------------

/*Ques.8 The total number of users with posts*/

SELECT 
    COUNT(DISTINCT (u.id)) AS total_number_of_users_with_posts
FROM
    ig_clone.users u
        JOIN
    ig_clone.photos p ON u.id = p.user_id;
-- --------------------------------------------------------------------------------------------------------------

/*Ques.9 The usernames with numbers as ending*/

SELECT 
    id, username
FROM
    ig_clone.users
WHERE
    username REGEXP '[$0-9]';
-- --------------------------------------------------------------------------------------------------------------

/*Ques.10 The usernames with charachter as ending*/

SELECT 
    id, username
FROM
    ig_clone.users
WHERE
    username NOT REGEXP '[$0-9]';
-- --------------------------------------------------------------------------------------------------------------

/*Ques.11 The number of usernames that start with A*/

SELECT 
    count(id)
FROM
    ig_clone.users
WHERE
    username REGEXP '^[A]';
-- --------------------------------------------------------------------------------------------------------------

/*Ques.12 The most popular tag names by usage*/

SELECT 
    t.tag_name, COUNT(tag_name) AS seen_used
FROM
    ig_clone.tags t
        JOIN
    ig_clone.photo_tags pt ON t.id = pt.tag_id
GROUP BY t.id
ORDER BY seen_used DESC
LIMIT 10;
-- --------------------------------------------------------------------------------------------------------------

/*Ques.13 The most popular tag names by likes*/

SELECT 
    t.tag_name AS 'Tag Name',
    COUNT(l.photo_id) AS 'Number of Likes'
FROM
    ig_clone.photo_tags pt
        JOIN
    ig_clone.likes l ON l.photo_id = pt.photo_id
        JOIN
    ig_clone.tags t ON pt.tag_id = t.id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;
-- --------------------------------------------------------------------------------------------------------------

/*Ques.14 The users who have liked every single photo on the site*/

SELECT 
    u.id, u.username, COUNT(l.user_id) AS total_likes_by_user
FROM
    ig_clone.users u
        JOIN
    ig_clone.likes l ON u.id = l.user_id
GROUP BY u.id
HAVING total_likes_by_user = (SELECT 
        COUNT(*)
    FROM
        ig_clone.photos);
-- --------------------------------------------------------------------------------------------------------------

/*Ques.15 Total number of users without comments*/

SELECT 
    COUNT(*) AS total_number_of_users_without_comments
FROM
    (SELECT 
        u.username, c.comment_text
    FROM
        ig_clone.users u
    LEFT JOIN ig_clone.comments c ON u.id = c.user_id
    GROUP BY u.id , c.comment_text
    HAVING comment_text IS NULL) AS users;
-- --------------------------------------------------------------------------------------------------------------

/*Ques.16 The percentage of users who have either never commented on a photo or likes every photo*/

SELECT 
    tableA.total_A AS 'Number Of Users who never commented',
    (tableA.total_A / (SELECT 
            COUNT(*)
        FROM
            ig_clone.users u)) * 100 AS '%',
    tableB.total_B AS 'Number of Users who likes every photos',
    (tableB.total_B / (SELECT 
            COUNT(*)
        FROM
            ig_clone.users u)) * 100 AS '%'
FROM
    (SELECT 
        COUNT(*) AS total_A
    FROM
        (SELECT 
        u.username, c.comment_text
    FROM
        ig_clone.users u
    LEFT JOIN ig_clone.comments c ON u.id = c.user_id
    GROUP BY u.id , c.comment_text
    HAVING comment_text IS NULL) AS total_number_of_users_without_comments) AS tableA
        JOIN
    (SELECT 
        COUNT(*) AS total_B
    FROM
        (SELECT 
        u.id, u.username, COUNT(u.id) AS total_likes_by_user
    FROM
        ig_clone.users u
    JOIN ig_clone.likes l ON u.id = l.user_id
    GROUP BY u.id , u.username
    HAVING total_likes_by_user = (SELECT 
            COUNT(*)
        FROM
            ig_clone.photos p)) AS total_number_users_likes_every_photos) AS tableB;
-- --------------------------------------------------------------------------------------------------------------

/*Ques.17 Clean URLs of photos posted on the platform*/

SELECT 
    SUBSTRING(image_url,
        LOCATE('/', image_url) + 2,
        LENGTH(image_url) - LOCATE('/', image_url)) AS IMAGE_URL
FROM
    ig_clone.photos;
-- --------------------------------------------------------------------------------------------------------------

/*Ques.18 The average time on the platform */

SELECT 
    ROUND(AVG(DATEDIFF(CURRENT_TIMESTAMP, created_at)/360), 2) as Total_Years_on_Platform
FROM
    ig_clone.users;
-- --------------------------------------------------------------------------------------------------------------

/*CREATING STORED PROCEDURES */

/*Ques.1 Popular hashtags list*/

CREATE PROCEDURE `spPopularTags`()
BEGIN
SELECT 
    t.tag_name, COUNT(tag_name) AS 'HashtagCounts'
FROM
    ig_clone.tags t
        JOIN
    ig_clone.photo_tags pt ON t.id = pt.tag_id
GROUP BY t.id , 1
ORDER BY 2 DESC; 
END //

CALL `ig_clone`.`spPopularTags`();
-- --------------------------------------------------------------------------------------------------------------

/*Ques.2 Users who have engaged atleast one time on the platform*/

CREATE PROCEDURE `spEngagedUser`()
BEGIN
SELECT DISTINCT
    username
FROM
    ig_clone.users u
        INNER JOIN
    ig_clone.photos p ON p.user_id = u.id
        INNER JOIN
    ig_clone.likes l ON l.user_id = p.user_id
WHERE
    p.id IS NOT NULL
        OR l.user_id IS NOT NULL;
END //

CALL `ig_clone`.`spEngagedUser`();
-- --------------------------------------------------------------------------------------------------------------

/*Ques.3 Total number of comments by the users on the platform */

CREATE PROCEDURE `spUserComments`()
BEGIN
SELECT 
COUNT(*)  as 'Total Number of Comments'
FROM (
    SELECT 
        c.user_id, u.username
        FROM ig_clone.users u
	JOIN ig_clone.comments c ON u.id = c.user_idusers
    WHERE
        c.comment_text IS NOT NULL
    GROUP BY u.username , c.user_id) as Table1;
END //

CALL `ig_clone`.`spUserComments`();
-- --------------------------------------------------------------------------------------------------------------

/*Ques.4 The username, image posted, tags used and comments made by a specific user*/

CREATE PROCEDURE `spUserInfo`(IN userid INT(11))
BEGIN
SELECT 
    u.id, u.username, p.image_url, c.comment_text, t.tag_name
FROM
    ig_clone.users u
        INNER JOIN
    ig_clone.photos p ON p.user_id = u.id
        INNER JOIN
    ig_clone.comments c ON c.user_id = u.id
        INNER JOIN
    ig_clone.photo_tags pt ON pt.photo_id = p.id
        INNER JOIN
    ig_clone.tags t ON t.id = pt.tag_id
where u.id = userid;
END //

CALL `ig_clone`.`spUserInfo`(2);
-- --------------------------------------------------------------------------------------------------------------
