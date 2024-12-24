CREATE DATABASE JOURNAL;
USE JOURNAL;

CREATE TABLE USERS (
    USERNAME VARCHAR(64),
    USERPASS VARCHAR(128) UNIQUE,
    PRIMARY KEY (USERNAME)
);
CREATE TABLE SESSION_TOKENS (
    USERNAME VARCHAR(64),
    DOB DATETIME,
    TOKEN VARCHAR(256) UNIQUE,
    PRIMARY KEY (USERNAME, DOB),
    FOREIGN KEY (USERNAME) REFERENCES USERS(USERNAME)
);
CREATE TABLE ENTRIES (
    USERNAME VARCHAR(64),
    ENTRY_TIME DATETIME,
    ENTRY_TEXT VARCHAR(512),
    PRIMARY KEY (USERNAME, ENTRY_TIME),
    FOREIGN KEY (USERNAME) REFERENCES USERS(USERNAME)
);

DELIMITER $$
CREATE PROCEDURE ADD_USER(IN PASSED_USERNAME VARCHAR(64), IN PASSED_USERPASS VARCHAR(512))
BEGIN
SET @TEMP_USERNAME = NULL;
SELECT USERNAME INTO @TEMP_USERNAME FROM USERS WHERE USERNAME = PASSED_USERNAME;
IF (@TEMP_USERNAME IS NULL) THEN
INSERT INTO USERS (USERNAME, USERPASS) VALUES (PASSED_USERNAME, SHA2(PASSED_USERPASS, 512));
SELECT USERNAME INTO @TEMP_USERNAME FROM USERS WHERE USERNAME = PASSED_USERNAME;
IF (@TEMP_USERNAME = PASSED_USERNAME) THEN
SELECT 1 AS VALID;
ELSE
SELECT 0 AS VALID;
END IF ;
ELSE
SELECT 0 AS VALID;
END IF;
END
$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE LOGIN_USER(IN PASSED_USERNAME VARCHAR(64), PASSED_USERPASS VARCHAR(512))
BEGIN
SET @TEMP_USERNAME = NULL;
SELECT USERNAME INTO @TEMP_USERNAME FROM USERS WHERE USERNAME = PASSED_USERNAME AND USERPASS = SHA2(PASSED_USERPASS, 512);
IF (@TEMP_USERNAME = PASSED_USERNAME) THEN
SET @TEMP_TOKEN = CONCAT(SHA2(@TEMP_USERNAME, 512), SHA2(CONCAT('R:', RAND()), 512));
INSERT INTO SESSION_TOKENS (USERNAME, DOB, TOKEN) VALUES (@TEMP_USERNAME, NOW(), @TEMP_TOKEN);
SELECT 1 AS VALID, @TEMP_TOKEN AS TOKEN;
ELSE
SELECT 0 AS VALID, 'ERROR' AS TOKEN;
END IF;
END
$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE ADD_ENTRY(IN PASSED_TOKEN VARCHAR(256), IN PASSED_TEXT VARCHAR(512))
BEGIN
SET @TEMP_USERNAME = NULL;
SET @TEMP_DOB = NULL;
SELECT USERNAME, DOB INTO @TEMP_USERNAME, @TEMP_DOB FROM SESSION_TOKENS WHERE TOKEN = PASSED_TOKEN;
IF (@TEMP_USERNAME IS NOT NULL AND @TEMP_DOB IS NOT NULL) THEN
SET @MAX_DOB = NULL;
SELECT MAX(DOB) INTO @MAX_DOB FROM SESSION_TOKENS WHERE USERNAME = @TEMP_USERNAME;
IF (@MAX_DOB = @TEMP_DOB AND TIMESTAMPDIFF(SECOND, NOW(), DATE_ADD(@TEMP_DOB, INTERVAL 8 HOUR)) > 0) THEN
INSERT INTO ENTRIES (USERNAME, ENTRY_TIME, ENTRY_TEXT) VALUES (@TEMP_USERNAME, NOW(), PASSED_TEXT);
SELECT 1 AS VALID;
ELSE
SELECT 0 AS VALID;
END IF;
ELSE
SELECT 0 AS VALID;
END IF;
END
$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE DELETE_ENTRY(IN PASSED_TOKEN VARCHAR(256), IN PASSED_USERNAME VARCHAR(512), IN PASSED_TIME DATETIME)
BEGIN
SET @TEMP_USERNAME = NULL;
SET @TEMP_DOB = NULL;
SELECT USERNAME, DOB INTO @TEMP_USERNAME, @TEMP_DOB FROM SESSION_TOKENS WHERE TOKEN = PASSED_TOKEN;
IF (@TEMP_USERNAME IS NOT NULL AND @TEMP_DOB IS NOT NULL) THEN
SET @MAX_DOB = NULL;
SELECT MAX(DOB) INTO @MAX_DOB FROM SESSION_TOKENS WHERE USERNAME = @TEMP_USERNAME;
IF (@MAX_DOB = @TEMP_DOB AND TIMESTAMPDIFF(SECOND, NOW(), DATE_ADD(@TEMP_DOB, INTERVAL 8 HOUR)) > 0) THEN
DELETE FROM ENTRIES WHERE USERNAME = PASSED_USERNAME AND ENTRY_TIME = PASSED_TIME;
SELECT 1 AS VALID;
ELSE
SELECT 0 AS VALID;
END IF;
ELSE
SELECT 0 AS VALID;
END IF;
END
$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE GET_ENTRIES(IN PASSED_TOKEN VARCHAR(256))
BEGIN
SET @TEMP_USERNAME = NULL;
SET @TEMP_DOB = NULL;
SELECT USERNAME, DOB INTO @TEMP_USERNAME, @TEMP_DOB FROM SESSION_TOKENS WHERE TOKEN = PASSED_TOKEN;
IF (@TEMP_USERNAME IS NOT NULL AND @TEMP_DOB IS NOT NULL) THEN
SET @MAX_DOB = NULL;
SELECT MAX(DOB) INTO @MAX_DOB FROM SESSION_TOKENS WHERE USERNAME = @TEMP_USERNAME;
IF (@MAX_DOB = @TEMP_DOB AND TIMESTAMPDIFF(SECOND, NOW(), DATE_ADD(@TEMP_DOB, INTERVAL 8 HOUR)) > 0) THEN
SELECT COUNT(*) INTO @ENTRY_COUNT FROM ENTRIES ORDER BY ENTRY_TIME;
IF (@ENTRY_COUNT > 0) THEN
SELECT 1 AS VALID, USERNAME, ENTRY_TIME, ENTRY_TEXT FROM ENTRIES ORDER BY ENTRY_TIME;
ELSE
SELECT 1 AS VALID, 'No Entries' USERNAME, 'No Entries' ENTRY_TIME, 'No Entries' ENTRY_TEXT;
END IF;
ELSE
SELECT 0 AS VALID, 'ERROR' USERNAME, 'ERROR' ENTRY_TIME, 'ERROR' ENTRY_TEXT FROM ENTRIES;
END IF;
ELSE
SELECT 0 AS VALID, 'ERROR' USERNAME, 'ERROR' ENTRY_TIME, 'ERROR' ENTRY_TEXT FROM ENTRIES;
END IF;
END;
$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE GET_USERS(IN PASSED_TOKEN VARCHAR(256))
BEGIN
SET @TEMP_USERNAME = NULL;
SET @TEMP_DOB = NULL;
SELECT USERNAME, DOB INTO @TEMP_USERNAME, @TEMP_DOB FROM SESSION_TOKENS WHERE TOKEN = PASSED_TOKEN;
IF (@TEMP_USERNAME IS NOT NULL AND @TEMP_DOB IS NOT NULL) THEN
SET @MAX_DOB = NULL;
SELECT MAX(DOB) INTO @MAX_DOB FROM SESSION_TOKENS WHERE USERNAME = @TEMP_USERNAME;
IF (@MAX_DOB = @TEMP_DOB AND TIMESTAMPDIFF(SECOND, NOW(), DATE_ADD(@TEMP_DOB, INTERVAL 8 HOUR)) > 0) THEN
SELECT 1 AS VALID, USERNAME FROM USERS;
ELSE
SELECT 0 AS VALID, 'ERROR' USERNAME;
END IF;
ELSE
SELECT 0 AS VALID, 'ERROR' USERNAME;
END IF;
END
$$
DELIMITER ;

CALL ADD_USER('Kohki Taniguchi', 'pass1');
CALL ADD_USER('John Doe', 'pass2');