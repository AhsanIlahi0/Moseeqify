-- Create database
CREATE DATABASE moseeqify;
USE moseeqify;
-- Create User table
CREATE TABLE [User] (
    username VARCHAR(50) PRIMARY KEY,
    email VARCHAR(100) UNIQUE NOT NULL, -- Added UNIQUE constraint
    name VARCHAR(100) NOT NULL,
    password VARCHAR(100) NOT NULL,
    dob DATE NOT NULL,
    dateJoined DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT CHK_User_Age CHECK (DATEDIFF(YEAR, dob, GETDATE()) >= 18)
);
-- Create Artist table
CREATE TABLE Artist (
    artistID INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(100) UNIQUE NOT NULL, -- Added UNIQUE constraint
    bio TEXT,
    profilepiclink VARCHAR(500)
);

-- Create Genre table
CREATE TABLE Genre (
    genreName VARCHAR(50) PRIMARY KEY
);
-- Create Album table
CREATE TABLE Album (
    albumID INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(100) NOT NULL,
    artistID INT NOT NULL REFERENCES Artist(artistID), -- Added NOT NULL constraint
    releasedate DATETIME,
    coverimagelink VARCHAR(255) NOT NULL -- Added NOT NULL constraint
);
-- Create Song table
CREATE TABLE Song (
    songID INT PRIMARY KEY IDENTITY(1,1),
    title VARCHAR(100) NOT NULL,
    artistID INT NOT NULL REFERENCES Artist(artistID),
    albumID INT REFERENCES Album(albumID),
    genreName VARCHAR(50) REFERENCES Genre(genreName),
    duration TIME NOT NULL, -- Added NOT NULL constraint
    audiolink VARCHAR(500) NOT NULL,
    releaseDate DATETIME DEFAULT CURRENT_TIMESTAMP
);
-- Create AlbumSongs table
CREATE TABLE AlbumSongs (
    albumID INT REFERENCES Album(albumID) ,
    songID INT REFERENCES Song(songID),
    PRIMARY KEY (albumID, songID)
);
-- Create Playlist table
CREATE TABLE Playlist (
    playlistID INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(100) NOT NULL, -- Added NOT NULL constraint
    creationdate DATETIME DEFAULT CURRENT_TIMESTAMP,
    username VARCHAR(50) NOT NULL REFERENCES [User](username)
);
-- Create PlaylistSongs table
CREATE TABLE PlaylistSongs (
    playlistID INT REFERENCES Playlist(playlistID),
    songID INT REFERENCES Song(songID),
    PRIMARY KEY (playlistID, songID)
);
-- Create UserListeningHistory table
CREATE TABLE UserListeningHistory (
    username VARCHAR(50) NOT NULL REFERENCES [User](username),
    songID INT NOT NULL REFERENCES Song(songID),
    listeningDate DATETIME DEFAULT CURRENT_TIMESTAMP
);
    CREATE TABLE user_follows_artists (
        username VARCHAR(50) NOT NULL,
        artistID INT NOT NULL,
        PRIMARY KEY (username, artistID),
        FOREIGN KEY (username) REFERENCES [User](username),
        FOREIGN KEY (artistID) REFERENCES Artist(artistID)
    );

-- Add trigger to enforce age constraint for users
Create TRIGGER CheckUserAge
ON [User]
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE DATEDIFF(YEAR, inserted.dob, GETDATE()) < 18)
    BEGIN
        RAISERROR ('Users must be at least 18 years old.', 16, 1)
        ROLLBACK TRANSACTION
    END
END

DISABLE TRIGGER CheckUserAge ON [User];


select * from [user]
select * from playlist
insert into playlist (name, username) values ('I hate farhan sarwar','AmmadNew')