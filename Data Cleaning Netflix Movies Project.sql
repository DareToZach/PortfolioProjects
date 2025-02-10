----------------------------------------------------------





----- Cleaning Netflix Movie Data Web Scraped from IMDB


-- Seeing what we are working with
SELECT * 
FROM PortfolioProjects.dbo.NetflixMovies

-- Adding an ID column to help with data cleaning by providing a unique identifier for each row, ensuring accurate updates, joins, and indexing.
ALTER TABLE NetflixMovies
ADD ID INT IDENTITY(1,1) PRIMARY KEY;

-- Separating the Stars Column into two: Directors, and Stars.

SELECT
	case	
		when CHARINDEX('|', Stars) > 0
		THEN REPLACE(substring(Stars, 1, Charindex('|', Stars) - 1), 'Director:', '')
		ELSE 'N/A'
	End as Directors
FROM PortfolioProjects.dbo.NetflixMovies

--adding directors column for parsed data
ALTER TABLE NetflixMovies
ADD Directors nvarchar(255)
--Directors Column didnt have enough characters for the data set
ALTER TABLE NetflixMovies
ALTER COLUMN Directors nvarchar(MAX);

--Addind the parsed data to the column
WITH ParsedData as (
	SELECT
		case	
			when CHARINDEX('|', Stars) > 0
			THEN REPLACE(substring(Stars, 1, Charindex('|', Stars) - 1), 'Director:', '')
			ELSE 'N/A'
		End as Directors,
		ID
	FROM PortfolioProjects.dbo.NetflixMovies
)
UPDATE nm
SET nm.directors = pd.Directors
FROM PortfolioProjects.dbo.NetflixMovies nm	
JOIN ParsedData pd ON nm.ID = pd.ID

-- trimming spaces -- DOESNT WORK???
UPDATE NetflixMovies
SET Directors = LTRIM(RTRIM(Directors))
WHERE Directors <> 'N/A';

SELECT Directors 
FROM PortfolioProjects.dbo.NetflixMovies
WHERE Directors <> 'N/A';
--Aftter looking through column movies with multiple directors still had the 'Directors:' at the front
--Updating
UPDATE PortfolioProjects.dbo.NetflixMovies
SET Directors = LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(Directors, CHAR(9), ''), CHAR(13), ''), CHAR(10), '')))
WHERE Directors <> 'N/A';
/*
The above SQL statement does the following:

REPLACE(Directors, CHAR(9), ''): Removes tab characters.

REPLACE(..., CHAR(13), ''): Removes carriage return characters.

REPLACE(..., CHAR(10), ''): Removes line feed characters.

LTRIM(RTRIM(...)): Removes leading and trailing spaces after the replacements.

The empty space before the name wasnt a space so i had to remove the other things that might be there
*/


--At this point i reordered the columns to make more sense


--Adding a nActors column to replace the stars column that still has directors

SELECT
    CASE
        WHEN CHARINDEX('|', Stars) > 0
        THEN LTRIM(RTRIM(REPLACE(SUBSTRING(Stars, CHARINDEX('|', Stars) + 1, LEN(Stars)), 'Stars:', '')))
        ELSE LTRIM(RTRIM(REPLACE(Stars, 'Stars:', '')))
    END AS Stars
FROM PortfolioProjects.dbo.NetflixMovies;

/*
ALTER TABLE PortfolioProjects.dbo.NetflixMovies
ADD  CleanStars nvarchar(MAX);
*/

UPDATE PortfolioProjects.dbo.NetflixMovies
SET CleanStars = CASE
        WHEN CHARINDEX('|', Stars) > 0
        THEN LTRIM(RTRIM(REPLACE(SUBSTRING(Stars, CHARINDEX('|', Stars) + 1, LEN(Stars)), 'Stars:', '')))
        ELSE LTRIM(RTRIM(REPLACE(Stars, 'Stars:', '')))
    END;

UPDATE PortfolioProjects.dbo.NetflixMovies
SET CleanStars = LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(CleanStars, CHAR(9), ''), CHAR(13), ''), CHAR(10), '')))
WHERE CleanStars <> 'N/A';

SELECT top(10) CleanStars 
FROM PortfolioProjects.dbo.NetflixMovies;


SELECT *
FROM PortfolioProjects.dbo.NetflixMovies;

USE PortfolioProjects;
GO


--Fixing the year column

ALTER TABLE PortfolioProjects.dbo.NetflixMovies
Alter Column ReleaseYear VARCHAR(50);

UPDATE PortfolioProjects.dbo.NetflixMovies
SET ReleaseYear = CASE
    -- Remove parentheses and extraneous characters
    WHEN [Year] LIKE '(%' THEN REPLACE(REPLACE(REPLACE(REPLACE([Year], '(', ''), ')', ''), '(I)', ''), '(II)', '')

    -- Handle ranges by taking the start year
    WHEN [Year] LIKE '%-%' THEN LEFT(REPLACE(REPLACE([Year], '(', ''), ')', ''), 4)

    -- Handle years with additional text (e.g., '(2016-2021)')
    WHEN [Year] LIKE '(%' AND [Year] LIKE '%)' THEN LEFT(REPLACE(REPLACE(REPLACE([Year], '(', ''), ')', ''), '-', ''), 4)
    
    -- Else keep the year as is
    ELSE [Year]
END;



