-- 1. Location of User 
SELECT * FROM post
WHERE location IN ('agra' ,'maharashtra','west bengal');


-- 2. Most Followed Hashtag
SELECT 
	hashtag_name AS 'Hashtags', COUNT(hashtag_follow.hashtag_id) AS 'Total Follows' 
FROM hashtag_follow, hashtags 
WHERE hashtags.hashtag_id = hashtag_follow.hashtag_id
GROUP BY hashtag_follow.hashtag_id
ORDER BY COUNT(hashtag_follow.hashtag_id) DESC LIMIT 5;

-- 3. Most Used Hashtags
SELECT 
	hashtag_name AS 'Trending Hashtags', 
    COUNT(post_tags.hashtag_id) AS 'Times Used'
FROM hashtags,post_tags
WHERE hashtags.hashtag_id = post_tags.hashtag_id
GROUP BY post_tags.hashtag_id
ORDER BY COUNT(post_tags.hashtag_id) DESC LIMIT 10;


-- 4. Most Inactive User
SELECT user_id, username AS 'Most Inactive User'
FROM users
WHERE user_id NOT IN (SELECT user_id FROM post);

 
-- 5. Most Likes Posts
SELECT post_likes.user_id, post_likes.post_id, COUNT(post_likes.post_id) 
FROM post_likes, post
WHERE post.post_id = post_likes.post_id 
GROUP BY post_likes.post_id
ORDER BY COUNT(post_likes.post_id) DESC ;

-- 6. Average post per user
SELECT ROUND((COUNT(post_id) / COUNT(DISTINCT user_id) ),2) AS 'Average Post per User' 
FROM post;

-- 7. no. of login by per user
SELECT user_id, email, username, login.login_id AS login_number
FROM users 
NATURAL JOIN login;


-- 8. User who liked every single post (CHECK FOR BOT)
SELECT username, Count(*) AS num_likes 
FROM users 
INNER JOIN post_likes ON users.user_id = post_likes.user_id 
GROUP  BY post_likes.user_id 
HAVING num_likes = (SELECT Count(*) FROM   post); 

-- 9. User Never Comment 
SELECT user_id, username AS 'User Never Comment'
FROM users
WHERE user_id NOT IN (SELECT user_id FROM comments);

-- 10. User who commented on every post (CHECK FOR BOT)
SELECT username, Count(*) AS num_comment 
FROM users 
INNER JOIN comments ON users.user_id = comments.user_id 
GROUP  BY comments.user_id 
HAVING num_comment = (SELECT Count(*) FROM comments); 


-- 11. User Not Followed by anyone
SELECT user_id, username AS 'User Not Followed by anyone'
FROM users
WHERE user_id NOT IN (SELECT followee_id FROM follows);

-- 12. User Not Following Anyone
SELECT user_id, username AS 'User Not Following Anyone'
FROM users
WHERE user_id NOT IN (SELECT follower_id FROM follows);

-- 13. Posted more than 5 times
SELECT user_id, COUNT(user_id) AS post_count FROM post
GROUP BY user_id
HAVING post_count > 5
ORDER BY COUNT(user_id) DESC;


-- 14. Followers > 40
SELECT followee_id, COUNT(follower_id) AS follower_count FROM follows
GROUP BY followee_id
HAVING follower_count > 40
ORDER BY COUNT(follower_id) DESC;


-- 15. Any specific word in comment
SELECT * FROM comments
WHERE comment_text REGEXP'good|beautiful';


-- 16. Longest captions in post
SELECT user_id, caption, LENGTH(post.caption) AS caption_length FROM post
ORDER BY caption_length DESC LIMIT 5;

--17. View for Most Followed Hashtag
CREATE VIEW MostFollowedHashtags AS
SELECT 
    hashtag_name AS Hashtags, 
    COUNT(hashtag_follow.hashtag_id) AS TotalFollows
FROM hashtag_follow 
JOIN hashtags ON hashtags.hashtag_id = hashtag_follow.hashtag_id
GROUP BY hashtag_follow.hashtag_id
ORDER BY COUNT(hashtag_follow.hashtag_id) DESC;

--18. View for Most Liked Posts
CREATE VIEW MostLikedPosts AS
SELECT post_likes.post_id, COUNT(post_likes.post_id) AS LikesCount
FROM post_likes
GROUP BY post_likes.post_id
ORDER BY LikesCount DESC;

--19. Index for faster search on hashtag_follow table
CREATE INDEX idx_hashtag_follow_hashtag_id ON hashtag_follow(hashtag_id);

--20. Index for faster search on post table by location
CREATE INDEX idx_post_location ON post(location);

--21. Index on post_likes for faster counting of likes per post
CREATE INDEX idx_post_likes_post_id ON post_likes(post_id);

--22. To get users posts count
DELIMITER //

CREATE FUNCTION GetUserPostCount(userId INT) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE postCount INT;
    SELECT COUNT(post_id) INTO postCount
    FROM post
    WHERE user_id = userId;
    RETURN postCount;
END //

DELIMITER ;

--23. Procedure to insert a new user
DELIMITER //

CREATE PROCEDURE AddNewUser(IN username VARCHAR(50), IN email VARCHAR(50), IN age INT)
BEGIN
    INSERT INTO users (username, email, age) VALUES (username, email, age);
END //

DELIMITER ;

--24. Procedure to delete inactive users who have no posts
DELIMITER //

CREATE PROCEDURE DeleteInactiveUsers()
BEGIN
    DELETE FROM users 
    WHERE user_id NOT IN (SELECT user_id FROM post);
END //

DELIMITER ;

--25. Procedure to get top 5 most followed hashtags
DELIMITER //

CREATE PROCEDURE GetTopHashtags()
BEGIN
    SELECT 
        hashtag_name AS Hashtags, 
        COUNT(hashtag_follow.hashtag_id) AS TotalFollows
    FROM hashtag_follow 
    JOIN hashtags ON hashtags.hashtag_id = hashtag_follow.hashtag_id
    GROUP BY hashtag_follow.hashtag_id
    ORDER BY TotalFollows DESC
    LIMIT 5;
END //

DELIMITER ;

--26. Trigger to update a count of posts in the user table after insert on post
DELIMITER //

CREATE TRIGGER after_post_insert
AFTER INSERT ON post
FOR EACH ROW
BEGIN
    UPDATE users 
    SET post_count = post_count + 1
    WHERE user_id = NEW.user_id;
END //

DELIMITER ;

--27. Trigger to check for banned words in comments before insert
DELIMITER //

CREATE TRIGGER before_comment_insert
BEFORE INSERT ON comments
FOR EACH ROW
BEGIN
    IF NEW.comment_text REGEXP 'bad|offensive|spam' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Comment contains banned words.';
    END IF;
END //

DELIMITER ;

--28. Trigger to log follower count after a follow
DELIMITER //

CREATE TRIGGER after_follow_insert
AFTER INSERT ON follows
FOR EACH ROW
BEGIN
    UPDATE users 
    SET follower_count = follower_count + 1
    WHERE user_id = NEW.followee_id;
END //

DELIMITER ;



