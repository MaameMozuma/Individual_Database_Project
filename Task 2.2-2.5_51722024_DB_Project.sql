-- creating a database
DROP DATABASE IF EXISTS Digital_Music_Store_51722024;
CREATE DATABASE Digital_Music_Store_51722024;
USE Digital_Music_Store_51722024;


-- creating tables
CREATE TABLE Country(
	countryID INT PRIMARY KEY AUTO_INCREMENT,
    country_name VARCHAR (30),
    geographic_location VARCHAR (50)
);

CREATE TABLE Genre(
	genreID INT PRIMARY KEY AUTO_INCREMENT,
    genre_name VARCHAR (30),
    genre_description VARCHAR (200)
);

CREATE TABLE Artiste(
	artisteID INT PRIMARY KEY AUTO_INCREMENT,
    artiste_stagename VARCHAR(30),
    artiste_description VARCHAR (300) NOT NULL,
    dob DATE,
    gender CHAR(1),
    countryID INT,
    genreID INT,
    musician_type ENUM ('solo', 'group'),
    CHECK (gender in ('F', 'M')),
    FOREIGN KEY (genreID) REFERENCES Genre(genreID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (countryID) REFERENCES Country (countryID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Employee(
	employeeID INT PRIMARY KEY AUTO_INCREMENT,
    employee_fname VARCHAR (30),
    employee_lname VARCHAR(30),
    phone VARCHAR (15) UNIQUE,
    email VARCHAR(30) UNIQUE NOT NULL,
    address VARCHAR (100) NOT NULL,
    gender CHAR (1),
    dob DATE,
    countryID INT,
    CHECK (gender in ('F', 'M')),
    FOREIGN KEY (countryID) REFERENCES Country (countryID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Customer(
	customerID INT PRIMARY KEY AUTO_INCREMENT,
    customer_fname VARCHAR (30),
    customer_lname VARCHAR (30),
    phone VARCHAR (15) UNIQUE, 
    email VARCHAR (30) UNIQUE NOT NULL,
    address VARCHAR (100) NOT NULL,
    gender CHAR (1),
    dob DATE,
    date_registered DATE DEFAULT(CURRENT_DATE),
    countryID INT,
    friendID INT,
    employeeID INT, 
    CHECK (gender in ('F', 'M')),
    FOREIGN KEY (countryID) REFERENCES Country (countryID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (friendID) REFERENCES Customer (customerID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (employeeID) REFERENCES Employee (employeeID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Family (
customerID INT,
member_on_plan INT UNIQUE,
relationship ENUM ('parent', 'grandparent', 'grandchild', 'sibling', 'cousin', 'aunty', 'uncle', 'child', 'wife', 'husband'),
date_switched DATE DEFAULT (CURRENT_DATE),
FOREIGN KEY (customerID) REFERENCES Customer (customerID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Student (
	customerID INT PRIMARY KEY AUTO_INCREMENT,
    school_name VARCHAR (50) NOT NULL,
    school_email VARCHAR (30) UNIQUE NOT NULL,
    date_switched DATE DEFAULT (CURRENT_DATE),
    FOREIGN KEY (customerID) REFERENCES Customer (customerID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Invoice (
	invoiceID INT PRIMARY KEY AUTO_INCREMENT,
    invoice_date DATE,
    amount_billed FLOAT,
    payment_method ENUM ('PayPal', 'Credit/Debit Card', 'Mobile Money'),
    subscription_plan ENUM ('Family', 'Individual', 'Student'),
    customerID INT,
    CHECK (subscription_plan IN ('Family', 'Individual', 'Student')),
    FOREIGN KEY (customerID) REFERENCES Customer (customerID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Advertisement (
	advertisementID INT PRIMARY KEY AUTO_INCREMENT,
    company_name VARCHAR (40),
    target_num INT,
    advertisement_title VARCHAR (30),
    advertisement_description VARCHAR (300),
    duration_in_months  FLOAT
);

CREATE TABLE Playlist (
	playlistID INT PRIMARY KEY AUTO_INCREMENT,
    playlist_name VARCHAR (30),
    playlist_description VARCHAR (400),
    last_date_updated DATE DEFAULT (CURRENT_DATE),
    playlist_length TIME,
    total_tracks INT,
    genreID INT,
    customerID INT,
    FOREIGN KEY (genreID) REFERENCES Genre (genreID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (customerID) REFERENCES Customer (customerID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Album (
	albumID INT PRIMARY KEY AUTO_INCREMENT,
    album_name VARCHAR (50),
    album_length TIME,
    released_date DATE DEFAULT (CURRENT_DATE),
    total_tracks INT,
    record_label VARCHAR (40),
    genreID INT,
    FOREIGN KEY (genreID) REFERENCES Genre (genreID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Song (
	songID INT PRIMARY KEY AUTO_INCREMENT,
    song_title VARCHAR (50),
    song_length TIME,
    year_released YEAR,
    albumID INT,
    genreID INT,
    FOREIGN KEY (albumID) REFERENCES Album (albumID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (genreID) REFERENCES Genre (genreID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Lyric (
	lyricsID INT PRIMARY KEY AUTO_INCREMENT,
    lyrics_description VARCHAR (500),
    lyrics_source VARCHAR (30),
    songID INT,
    FOREIGN KEY (songID) REFERENCES Song (songID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Artiste_Song (
	artisteID INT,
    songID INT,
    FOREIGN KEY (artisteID) REFERENCES Artiste (artisteID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (songID) REFERENCES Song (songID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Album_Artiste (
	albumID INT,
	artisteID INT,
    FOREIGN KEY (albumID) REFERENCES Album (albumID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (artisteID) REFERENCES Artiste (artisteID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Song_Playlist (
	songID INT,
    playlistID INT,
    FOREIGN KEY (playlistID) REFERENCES Playlist (playlistID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (songID) REFERENCES Song (songID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Customer_Song (
	customerID INT,
    songID INT,
    FOREIGN KEY (customerID) REFERENCES Customer (customerID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (songID) REFERENCES Song (songID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Customer_Playlist (
	customerID INT,
    playlistID INT,
    FOREIGN KEY (customerID) REFERENCES Customer (customerID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (playlistID) REFERENCES Playlist (playlistID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Advertisement_Customer (
	advertisementID INT,
	customerID INT,
    FOREIGN KEY (customerID) REFERENCES Customer (customerID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (advertisementID) REFERENCES Advertisement (advertisementID) ON DELETE CASCADE ON UPDATE CASCADE
);

-- creating indexes

-- creating an index on the artiste stagename because the customers should be able to look up
-- music by artiste name; thus to make the search faster, the stagename should have indexes
CREATE INDEX index_artiste_name ON Artiste (artiste_stagename);

-- creating an index on these columns because we need to be able to get customer demographics in order
-- to determine which advertisements to target to them. Also, we need to identify new customers and 
-- when their free subscription ends based on a certain date
CREATE INDEX index_customer ON Customer (phone, address, dob, date_registered);

-- creating an index on these columns so that a user can quickly get feedback on the songs they
-- can listen to based on the title they entered or if they want songs from a particular year
CREATE INDEX index_song ON Song (song_title, year_released);

-- creating an index on the genre_name because we want our platform to be able to give us 
-- songs from a particular genre when a user searches 
CREATE INDEX index_genre ON Genre (genre_name);

-- creating an index on the country_name because we want users to quickly get songs that are from
-- a particular country
CREATE INDEX index_country ON Country (country_name);

-- creating an index on the playlist_name because in case a user wants a playlist that has a particular
-- word or name in it, it should be able to quickly return it. There is a possibility for the playlists 
-- to be more than 1000 hence faster search can be obtained by using indexes
CREATE INDEX index_playlist ON Playlist (playlist_name);


-- inserting into tables
INSERT INTO Country VALUES (1, 'Afghanistan', 'South-Central Asia');
INSERT INTO Country VALUES (2, 'Argentina', 'Southern South America');
INSERT INTO Country VALUES (3, 'Belgium', 'Western Europe');
INSERT INTO Country VALUES (4, 'Benin', 'West Africa');
INSERT INTO Country VALUES (5, 'Comoros', 'Eastern Africa');
INSERT INTO Country VALUES (6, 'Cuba', 'Greater Antilles, Caribbean');
INSERT INTO Country VALUES (7, 'Denmark', 'Northern Europe');
INSERT INTO Country VALUES (8, 'Egypt', 'Africa, Middle East');
INSERT INTO Country VALUES (9, 'El Salvador', 'Central America');
INSERT INTO Country VALUES (10, 'Trinidad and Tobago', 'Northern South America, Caribbean');
INSERT INTO Country VALUES (11, 'United States of America', 'North America');

INSERT INTO Genre VALUES (1, 'Blues', 'It is usually played with a guitar or banjo and and has a 12 bar blues structure.');
INSERT INTO Genre VALUES (2, 'Classical', 'It usually refers to most ochestral styles between 1750 and 1820.');
INSERT INTO Genre VALUES (3, 'Country', 'This genre has its roots in the south of the USA. \n
It takes its cues from Irish and Celtic folk, traditional English ballads and cowboy songs.');
INSERT INTO Genre VALUES (4, 'Dance', 'It can be broadly categorised as electronic music. \n
 It has its roots in disco music combined with the evolution of pop music.');
INSERT INTO Genre VALUES (5, 'Drill', 'It is an aggressive music form taking its cues from grime, rap and dance music.');
INSERT INTO Genre VALUES (6, 'Drum and Bass (Jungle)', 'It is a direct result of the dance music scene and it is characterised by high BPM drums and heavy bass lines; \n
 it also borrows heavily from other genres.');
INSERT INTO Genre VALUES (7, 'Easy Listening', 'This genre is based on mood rather than any particular musical traits. \n
 It tends to omit vocal performances in favour of easy-going re-workings of popular pop and rock hits.');
INSERT INTO Genre VALUES (8, 'Emo', 'It has its roots in rock, pop, heavy metal and punk and has a specific goal to have emotive or emotional resonance.');
INSERT INTO Genre VALUES (9, 'Funk', 'It uses a syncopated beat and heavy bass lines and distinctive grooves. It takes it cues from Soul, Jazz and R&B');
INSERT INTO Genre VALUES (10, 'Hip Hop', 'It features vinyl records mixed on turntables and incorporating the rap genre along with heavy bass-lines and samples.');
INSERT INTO Genre VALUES (11, 'Jazz', 'Jazz features a mix of rythms and tempos as well as a focus on soloing; \n
 it also has a range of potential instrumental structures and setups.');
INSERT INTO Genre VALUES (12, 'Pop Rock', 'It originated in the late 1950s as an alternative to rock and roll 
and is influenced by the beat, arrangements and original style of rock and roll.');

INSERT INTO Artiste VALUES (1, 'Demi Lovato', 'Demetria Devonne Lovato was born on August 20, 1992, 
in Albuquerque, New Mexico.Lovato rose to prominence for playing Mitchie Torres in the musical television
 film Camp Rock (2008) and its sequel Camp Rock 2: The Final Jam (2010).', '1992-08-20', 'F', 11, 12, 'solo');
 INSERT INTO Artiste VALUES (2, 'Los Chalchaleros', 'An Argentine folk ensemble established in 1998 
 still haunts the alleys and smoky bars of Argentina and Buenos Aires’ version of honky-tonks. Formed in the northern province, 
 Salta, the musicians took their name from a local songbird — the chacarero.', '1998-05-02', 'M', 2, 2, 'group');
 INSERT INTO Artiste VALUES (3, 'Christian Winther', 'Danish-American tenor saxophonist and 
 composer Christian Winther has been based in New Orleans since 1997. He has established himself 
 as a voice demanding attention on the jazz scene through his soulful sound and a style of
 composing that exudes an expressive melodious quality. ', '1989-05-08', 'M', 7, 11, 'solo');
 INSERT INTO Artiste VALUES (4, 'OneRepublic', 'OneRepublic is an American pop rock band. Formed in Colorado Springs,
 Colorado in 2002 by lead singer Ryan Tedder and guitarist Zach Filkins, the band achieved commercial 
 success on Myspace as an unsigned act.', '2002-01-02', 'M', 11, 12, 'group');
 INSERT INTO Artiste VALUES (5, 'BadApple', 'Combining original and covers, rock tunes and all-time-favorites;
 the band’s genre diversity leaves no one unsatisfied, regardless of age or musical preference.',
 '2008-09-05', 'M', 8, 12, 'group');
 INSERT INTO Artiste VALUES (6, 'Alvaro Torres', 'Álvaro Torres was born on April 9, 1954 in Usulután, El Salvador.
 Torres moved to Guatemala and started a solo career recording his first album, "Algo especial"
 (Something Special) in 1976.', '1954-04-09', 'M', 9, 3, 'solo');
 
 
 INSERT INTO Employee VALUES (401, 'Adele', 'Hashford', '+222 5230-8394', 'adele.hayford@gmail.com',
 '444988 Turner Track, Hodh Ech Chargui', 'F', '1989-07-07', 4);
  INSERT INTO Employee VALUES (402, 'Smith', 'Williamson', '+222 2343-2342', 'smithwill@gmail.com',
 '400 Franecki Lakes, Tiris Zemmour', 'M', '1996-12-12', 3);
  INSERT INTO Employee VALUES (403, 'Dorothie', 'Brown', '+222 2343-4594', 'dotty.brown@gmail.com',
 '46250 Janie Overpass, Tagant', 'F', '1996-03-18', 6);
  INSERT INTO Employee VALUES (404, 'Lorem', 'Ipsum', '+222 5567-9854', 'lorem.ipsum@gmail.com',
 '73661 Bell Creek, Trarza', 'M', '1997-07-22', 11);
  INSERT INTO Employee VALUES (405, 'Henry', 'Fringers', '+222 2349-3294', 'hfingers@gmail.com',
 '6278 Zita Praire, Adrar', 'M', '1998-05-17', 7);
  INSERT INTO Employee VALUES (406, 'Mikko', 'Kaspersky', '+222 2374-9128', 'mikko.kaspersky@gmail.com',
 '4614 Kunze View, Tiris Zemmour', 'F', '1999-06-21', 1);

INSERT INTO Customer VALUES (501, 'Joella', 'Nyameye', '+239 5267-98018', 'jKye@gmail.com', '710 Mikayla Road, Tiris Zemmour', 'F', '2002-06-07', '2022-05-06', 4, null, 401);
INSERT INTO Customer VALUES (502, 'John', 'Nyameye', '+239 5267-98019', 'johnKye@gmail.com', '710 Mikayla Road, Tiris Zemmour', 'M', '2002-06-07', '2022-05-06', 4,501, 402);
INSERT INTO Customer VALUES (503, 'Madinka', 'Nyameye', '+239 526-98718', 'madsKye@gmail.com', '710 Mikayla Road, Tiris Zemmour', 'M', '1975-05-08', '2022-04-11', 4,501, 402);
INSERT INTO Customer VALUES (504, 'Mariem', 'Sy', '+20 5267-98998', 'mimiSy@gmail.com', '73661 Bell Creek, Trarza', 'F', '2001-10-12', '2022-04-18', 10, 503, 403);
INSERT INTO Customer VALUES (505, 'Ratifafa', 'M\'Bareck', '+239 5267-76445', 'fafaB@gmail.com', '400 Franecki Lakes, Tiris Zemmour', 'F', '1999-03-29', '2022-09-21', 8, 502, 404);
INSERT INTO Customer VALUES (506, 'Angie', 'Mi\'k', '+239 5587-98418', 'angelMi@gmail.com', '46250 Janie Overpass, Tagant', 'F', '1999-05-07', '2022-06-02', 11,505, 405);
INSERT INTO Customer VALUES (507, 'Mohammed', 'Salem', '+239 0967-86718', 'salah123@gmail.com', '6278 Zita Praire,Adrar', 'M', '2003-09-08', '2022-02-01', 1, 506, 401);
INSERT INTO Customer VALUES (508, 'Chus', 'Yaking', '+239 3267-99018', 'chus.yaking@gmail.com', '94054 Marks Street, Assaba', 'M', '1998-12-04', '2022-02-07', 11, null, 406);
INSERT INTO Customer VALUES (509, 'Obe', 'Yom', '+1 5267-33018', 'obe.yom@gmail.com', '73 Kaesler Road, Krongkart', 'M', '2000-05-06', '2022-03-09', 4, 507, 404);
INSERT INTO Customer VALUES (510, 'David', 'Agyeman', '+1 5267-98014', 'david.agyeman@gmail.com', '42 Delan Road, Bungadoo', 'M', '1999-11-03', '2022-04-19', 4, 509, 403);
INSERT INTO Customer VALUES (511, 'Jena', 'Man', '+1 5257-9218', 'jena.man@gmail.com', '31 Halsey Road, Encounter Bay', 'F', '2002-09-04', '2022-05-10', 10, 507, 402);
INSERT INTO Customer VALUES (512, 'Khal', 'Drogo', '+239 6567-98068', 'khal.drogo@gmail.com', '91 Shadforth Street, Gonn Crossing', 'M', '1985-11-11', '2022-05-20', 8, 510, 406);
INSERT INTO Customer VALUES (513, 'Lisa', 'Drogo', '+239 2358-84618', 'lisa.drogo@gmail.com', '91 Shadforth Street, Gonn Crossing', 'F', '1986-02-03', '2022-06-12', 8, 511, 403);
INSERT INTO Customer VALUES (514, 'Jim', 'Shrute', '+239 5222-58028', 'jimShr@gmail.com', '7 Duff Street, North Tyraning', 'M', '2001-10-04', '2022-07-13', 3, 511, 405);
INSERT INTO Customer VALUES (515, 'Pam', 'Jackson', '+239 5297-98066', 'pam.jackson@gmail.com', '1 Gralow Court, Alligator Creel', 'F', '1957-04-16', '2022-02-08', 2, 501, 401);
INSERT INTO Customer VALUES (516, 'Greg', 'Daniels', '+239 3456-98013', 'greg.daniels@gmail.com', '17 Alfred Street, Lort River', 'M', '1999-06-07', '2022-09-15', 5, 505, 406);
INSERT INTO Customer VALUES (517, 'Michael', 'Scott', '+239 5267-9359', 'michael.scott@gmail.com', '1 Gralow Court, Alligator Creel', 'M', '2012-07-08', '2022-03-16', 2, 506, 402);
INSERT INTO Customer VALUES (518, 'Anthony', 'Farrell', '+868 5267-97838', 'ant.farrel@gmail.com', '34 Millicent Drive, Munni', 'M', '1999-08-29', '2022-10-05', 7, 503, 402);
INSERT INTO Customer VALUES (519, 'Melora', 'Hardin', '+094 5267-92618', 'melHardin@gmail.com', '61 Treasure Island Avenue, Robina DC', 'F', '1982-12-09', '2022-11-10', 9, 504, 405);
INSERT INTO Customer VALUES (520, 'Leslie', 'Hardin', '+094 5857-98066', 'leslie.hardin@gmail.com', '61 Treasure Island Avenue, Robina DC', 'F', '2012-05-22', '2022-11-23', 9, 507, 403);
INSERT INTO Customer VALUES (521, 'Creed', 'Hardin', '+094 5367-98012', 'creed.harding@gmail.com', '61 Treasure Island Avenue, Robina DC', 'M', '1980-09-13', '2022-12-20', 9, 512, 401);
INSERT INTO Customer VALUES (522, 'Mindy', 'Kaling', '+233 5248-89109', 'min.kaling@gmail.com', '1 Gralow Court, Alligator Creel', 'F', '1959-05-01', '2022-04-28', 2, 512, 402);
INSERT INTO Customer VALUES (523, 'Oscar', 'Nunez', '+239 5267-67018', 'oscar.nun@gmail.com', '32 Marion Street, Ludmilla', 'M', '1990-09-13', '2022-03-22', 2, 513, 403);
INSERT INTO Customer VALUES (524, 'John', 'Ingle', '+239 4268-22335', 'john.ingle@gmail.com', '74 Jones Street, Dairy Plains', 'M', '1992-06-23', '2022-04-13', 1, 514, 406);
INSERT INTO Customer VALUES (525, 'Kevin', 'Dorff', '+232 6467-11111', 'kevin.dorff@gmail.com', '74 Jones Street, Dairy Plains', 'M', '1997-10-19', '2022-10-24', 1, 514, 401);
INSERT INTO Customer VALUES (526, 'Janine', 'Poreba', '+232 2255-98018', 'janine.poreba@gmail.com', '89 Mackie Street, Bomaderry', 'F', '2003-04-15', '2022-08-25', 2, 516, 402);
INSERT INTO Customer VALUES (527, 'Lyanne', 'Zager', '+239 5887-98357', 'lyanne.zager@gmail.com', '18 Elizabeth Street, Paterson', 'F', '1990-07-22', '2022-02-27', 9, 518, 405);
INSERT INTO Customer VALUES (528, 'Perry', 'Smith', '+1 5357-9228', 'perry.smith@gmail.com', '58 Kintyre Street, Daisy Hill', 'M', '1995-03-26', '2022-09-06', 7, 520, 403);
INSERT INTO Customer VALUES (529, 'Angela', 'Kinsey', '+239 5275-98368', 'angela.kinsey@gmail.com', '94 Inglewood Street, MetCalfe', 'F', '2003-06-08', '2022-05-28', 5, 521, 402);
INSERT INTO Customer VALUES (530, 'David', 'Krasinski', '+239 7532-63355', 'david.krasinski@gmail.com', '32 Marion Street, Ludmilla', 'M', '1967-06-30', '2022-09-30', 6, 522, 405);
INSERT INTO Customer VALUES (531, 'Peter', 'Cavinsky', '+233 5748-98373', 'peter.cavinsky@gmail.com', '58 Kintyre Street, Daisy Hill', 'M', '1969-05-11', '2022-09-27', 7, 523, 406);
INSERT INTO Customer VALUES (532, 'Lena', 'Lenry', '+239 0977-98000', 'lena.lenry@gmail.com', '18 Elizabeth Street, Paterson', 'F', '1990-08-24', '2022-07-14', 9, 523, 401);
INSERT INTO Customer VALUES (533, 'Owusu', 'Gyamfi', '+229 5267-93788', 'owusu.gyamfi@gmail.com', '62 Frencham Street, Lankeys Creek', 'M', '1989-07-19', '2022-06-24', 6, 527, 404); 
INSERT INTO Customer VALUES (534, 'Betty', 'Plankton', '+229 8287-99311', 'betty.plankton@gmail.com', '89 Horsington Street, Wattle Park', 'F', '1990-03-08', '2022-08-15', 3, 529, 404);

INSERT INTO Family VALUES (503,501, 'child', '2022-05-11');
INSERT INTO Family VALUES (503,502, 'child', '2022-05-11');
INSERT INTO Family VALUES (512,513, 'wife', '2022-05-28');
INSERT INTO Family VALUES (515,517, 'grandchild', '2022-02-13');
INSERT INTO Family VALUES (519,520, 'child', '2022-12-14');
INSERT INTO Family VALUES (519,521, 'husband', '2022-12-15');
INSERT INTO Family VALUES (515,522, 'cousin', '2022-05-16');
INSERT INTO Family VALUES (524,525, 'sibling', '2022-05-17');
INSERT INTO Family VALUES (528,531, 'uncle', '2022-09-18');
INSERT INTO Family VALUES (527,532, 'cousin', '2022-04-19');
INSERT INTO Family VALUES (523,530, 'parent', '2022-08-29');

INSERT INTO Student VALUES (504, 'Ashesi University', 'mimi.sy@ashesi.edu.gh', '2022-04-18');
INSERT INTO Student VALUES (505, 'Green Sprout University', 'fafa.mbarek@greensprout.co.za', '2022-09-30');
INSERT INTO Student VALUES (506, 'Monarch University', 'angelMi@monarch.edu.za', '2022-07-02');
INSERT INTO Student VALUES (507, 'Ashesi University', 'mohammed.salem@ashesi.edu.gh', '2022-02-16');
INSERT INTO Student VALUES (529, 'Ashesi University', 'angie.kinsey@ashesi.edu.gh', '2022-06-28');
INSERT INTO Student VALUES (526, 'Central Technical University', 'janine.poreba@central.edu.za', '2022-08-30');
INSERT INTO Student VALUES (518, 'Tulip Tree University', 'ant.farrell@tulip.tree.edu.uk', '2022-10-25');
INSERT INTO Student VALUES (516, 'Central Technical University', 'greg.daniels@central.edu.za', '2022-11-15');
INSERT INTO Student VALUES (514, 'Monarch University', 'jim.shrute@monarch.edu.za', '2022-08-13');
INSERT INTO Student VALUES (511, 'Ashesi University', 'jena.man@ashesi.edu.gh', '2022-05-19');

INSERT INTO Invoice VALUES (57388, '2022-06-11', 35.99, 'PayPal', 'Family', 503);
INSERT INTO Invoice VALUES (57389, '2022-03-13', 35.99, 'Credit/Debit Card', 'Family', 515);
INSERT INTO Invoice VALUES (57390, '2022-12-14', 35.99, 'Mobile Money', 'Family', 519);
INSERT INTO Invoice VALUES (57391, '2022-09-29', 35.99, 'Mobile Money', 'Family', 523);
INSERT INTO Invoice VALUES (57392, '2022-11-25', 10.99, 'Credit/Debit Card', 'Student', 518);
INSERT INTO Invoice VALUES (57393, '2022-04-09', 20.99, 'PayPal', 'Individual', 509);
INSERT INTO Invoice VALUES (57394, '2022-06-19', 10.99, 'PayPal', 'Student', 511);
INSERT INTO Invoice VALUES (57395, '2022-08-30', 10.99, 'Mobile Money', 'Student', 526);
INSERT INTO Invoice VALUES (57396, '2022-03-07', 20.99, 'Credit/Debit Card', 'Individual', 508);
INSERT INTO Invoice VALUES (57397, '2022-07-28', 20.99, 'Mobile Money', 'Student', 529);

INSERT INTO Advertisement VALUES (123, 'Dunder Mifflin', 30, 'Share a Coke', '‘Share a Coke’ campaign from Coca Cola that started in 2011 went viral 
and Coke gained a large fan base due to this particular campaign. Here the customers were
 allowed to print the desired name on their coke bottle.', 3);
INSERT INTO Advertisement VALUES (124, 'MagicBox', 15, 'Just Do It', 'Nike launched this campaign in the 1980s, 
 and its sales increased by more than $8 billion within 10 years. This campaign was to fill the customers
 with motivation to exercise. Nike did it emotionally, and it was a hit.', 2.5);
INSERT INTO Advertisement VALUES (125, 'DigiTec', 23, '#LikeaGirl', 'The #LikeaGirl campaign from Always was live in 2015,
 and it was a hit.', 1.5);
INSERT INTO Advertisement VALUES (126, 'Anaconda Glass', 21, 'Break gender stereotypes', 'The company targets the myth of the gender gap
 in our society and raising awareness through this campaign. In this advertisement, the brand has explained how girls 
 are as fit as boys to play any sport.', 1);
INSERT INTO Advertisement VALUES (127, 'Heaven Dust', 12, 'Think Small', 'People in America are more intended for buying bigger cars.
 Volkswagen came with this campaign to aware them of the essence of smaller cars. Yes, it completely changed how the car lovers in 
 America were thinking.', 2);
 INSERT INTO Advertisement VALUES (128, 'Dust', 60, 'Think Small', 'People in America are more intended for buying bigger cars.
 Volkswagen came with this campaign to aware them of the essence of smaller cars. Yes, it completely changed how the car lovers in 
 America were thinking.', 1);
 INSERT INTO Advertisement VALUES (129, 'Beauty for Ashes', 50, 'Think Small', 'People in America are more intended for buying bigger cars.
 Volkswagen came with this campaign to aware them of the essence of smaller cars. Yes, it completely changed how the car lovers in 
 America were thinking.', 6);
 INSERT INTO Advertisement VALUES (130, 'Highways', 90, 'Think Small', 'People in America are more intended for buying bigger cars.
 Volkswagen came with this campaign to aware them of the essence of smaller cars. Yes, it completely changed how the car lovers in 
 America were thinking.', 9);
 INSERT INTO Advertisement VALUES (131, 'Don\'t Drink and Drive', 100, 'Think Small', 'People in America are more intended for buying bigger cars.
 Volkswagen came with this campaign to aware them of the essence of smaller cars. Yes, it completely changed how the car lovers in 
 America were thinking.', 2.6);
 INSERT INTO Advertisement VALUES (132, 'Say No to Teenage Pregnancy', 45, 'Think Small', 'People in America are more intended for buying bigger cars.
 Volkswagen came with this campaign to aware them of the essence of smaller cars. Yes, it completely changed how the car lovers in 
 America were thinking.', 4.7);
 
INSERT INTO Playlist VALUES (601, 'Rap Life', 'Who knows how many Young Thug verses have made listeners draw back incredulously, but few will have been as affecting as hearing him rap on Metro Boomin’s “Metro Spider”, released while Thug sits in jail awaiting trial for his alleged involvement 
in Atlanta’s ground-shaking YSL Records RICO case.', '2022-03-06', '04:35:00', 2, 5, 508);
INSERT INTO Playlist VALUES (602, 'Lee\'s Jams', 'This playlist features gospel music to calm your soul, body and spirit', '2022-05-06', '04:35:01', 0, 9, 503);
INSERT INTO Playlist VALUES (603, 'In My Room', 'There\'s nothing wrong with taking a little me-time. Close the door,
 find a comfy corner and get in your feelings with these moody, downtempo pop tunes. We update this playlist regularly.
 If you like a track, add it to your library.', '2022-08-10', '08:35:02', 1, 10, 518);
INSERT INTO Playlist VALUES (604, 'Feeling Blue', 'Hey Siri, play the feeling blue playlist', '2022-05-13', '01:35:03', 1, 6, 513);
INSERT INTO Playlist VALUES (605, 'Heartbreak Pop', 'There\'s no point denying it: Having your heart broken really, really sucks. 
Sometimes, during those moments, music is the only thing that can make sense of it all. So we\'ve assembled a set of moving ballads, 
classic tear-jerkers and recent pop hits to help you through it. Our editors regularly refresh this playlist.
 If you like a song, add it to your library.', '2022-11-11', '03:20:00', 1, 3, 525);
INSERT INTO Playlist VALUES (606, 'Breakup Songs', 'There’s a moment in the 2015 Amy Winehouse documentary Amy in which the singer, 
finishing up a demo vocal of the existentially bleak “Back to Black,” looks up from her mic with a giant grin 
spreading across her face and says, as though the song had come from someone else’s mouth, “Oh, it’s a bit upsetting at the end, isn’t it?” 
It is.', '2022-07-25', '00:39:00', 0, 1, 524);
INSERT INTO Playlist VALUES (607, 'Summer Waves', 'This is a big (summer) mood. The ideal ☀ soundtrack to BBQing, poolside lounging,
 top-down cruising, and everything in-between.', '2022-03-01', '00:25:00', 1, 7, 527);
INSERT INTO Playlist VALUES (608, 'Midnight Mood', 'The bottle’s half empty, the lamp is low; the world’s asleep, 
but you’re still here. No drama, no despair—just mulling over the shape of it all, how you got where you are, how it might pan out.',
 '2022-02-07', '06:40:07', 2, 8, 507);
INSERT INTO Playlist VALUES (609, 'Sad Songs', 'Sad Songs - Add this playlist to your library and get the best songs to cry to for any 
occasion. With music from Adele, Ed Sheeran, Johnny Cash, James Bay and more.', '2022-12-03', '02:20:08', 1, 9, 530);
INSERT INTO Playlist VALUES (610, 'Safe for Work', 'Hey Siri, play the feeling safe for work playlist', '2022-11-28', '01:32:00', 1, 1, 534);
   

INSERT INTO Album VALUES (701, '3 (The Purple Album)', '00:33:00', '2018-05-06', 10, 'Warner Records', 12); 
INSERT INTO Album VALUES (702, 'Issa Album', '00:57:00', '2017-11-01', 14, 'Slaughter Gang', 10);                 
INSERT INTO Album VALUES (703, 'Not All Heros Wear Capes', '00:44:00', '2018-11-02', 13, 'UMG Recordings', 10);                 
INSERT INTO Album VALUES (704, 'Slime & B', '00:47:00', '2020-05-05', 13, 'RCA Records', 1);                 
INSERT INTO Album VALUES (705, 'The 50 Greatest Pieces of Classical Music', '00:23:00', '2009-12-01', 50, 'Warner Music Group', 2);
INSERT INTO Album VALUES (706, 'Parado no Bailao', '00:03:00', '2018-07-23', 1, 'Funk Episode', 9);                 
INSERT INTO Album VALUES (707, 'Kenny G Essentials', '01:55:00', '2016-05-12', 24, 'XML', 8);                 
INSERT INTO Album VALUES (708, 'The Black Album', '00:56:00', '2003-01-01', 14, 'Carter Enterprises', 11);                 
INSERT INTO Album VALUES (709, 'City on Lock', '00:36:00', '2020-06-20', 15, 'Motown Records', 3);                 
INSERT INTO Album VALUES (710, 'Tremaine the Album', '00:58:00', '2017-03-24', 15, 'Atlantic Recording Corporation', 4);   

INSERT INTO Song VALUES (801,'Love Someone', '00:03:26', 2018, 701, 12);
INSERT INTO Song VALUES (802,'Lullaby', '00:03:12', 2018, 710, 12);
INSERT INTO Song VALUES (803,'Bank Account', '00:03:40', 2017, 702, 10);
INSERT INTO Song VALUES (804,'Space Cadet', '00:03:23', 2018, 703, 10);
INSERT INTO Song VALUES (805,'Peng Black Girls', '00:02:55', 2020, 704, 8);
INSERT INTO Song VALUES (806,'Flewed Out', '00:03:11', 2020, 709, 3);
INSERT INTO Song VALUES (807,'Sentimental', '00:06:35', 2016, 707, 8);
INSERT INTO Song VALUES (808,'Deja Vu', '00:03:00', 2021, 706, 4);
INSERT INTO Song VALUES (809,'Attack', '00:03:00', 2022, 708, 5);
INSERT INTO Song VALUES (810,'Carmen: Ouverture', '00:02:15', 2009, 705, 2);

INSERT INTO Lyric VALUES (901, 'Ogiso is the title given to the earliest kings that once ruled the Benin Kingdom. 
Ogiso means the king with wisdom from above. Igodo- Ogiso was a ruler of the Benin Kingdom who 
first established the Benin kinship. He was a great ruler who yielded so much power.', 'Warner Records', 808);
INSERT INTO Lyric VALUES (902, 'Enkheshon is a concept in Maasai marriage which means to be favoured with many sons and 
daughters and therefore become rich. Thus, a Maasai woman asks God for enkheshon so that her own children will look after her. ',
 'Slaughter Gang', 803); 
INSERT INTO Lyric VALUES (903, 'This descent is established through both parents; that is, one traces their descent through both the mother’s side and father’s side. 
This type of descent is popular in the United States of America although the Americans usually take their father’s name.',
 'Warner Records', 809); 
INSERT INTO Lyric VALUES (904, 'The unilineal descent is where a group of people trace its descent through one side only, namely the mother’s side or father’s side. Tracing from the mother’s side is known as matrilineal descent whilst tracing from the father’s side is patrilineal descent.
 The Nzema people of Ghana practice matrilineal descent.', 'Warner Records', 802); 
INSERT INTO Lyric VALUES (905, 'The patrilineal descent is the most common method of tracing one’s descent through one’s 
father and other male ancestors. This type of descent is commonly found in African societies. 
The Gas in Ghana, for example, practice patrilineal descent
', 'Warner Records', 810); 
INSERT INTO Lyric VALUES (906, 'Blood relationships are called consanguine. Consanguine forms a kinship relationship between people. 
They raise the question of one’s ancestry or descent and how it is determined through generations. In consanguine relationships, descent is 
determined through the patrilineal descent, the matrilineal descent, the unilineal descent, bilineal descent, or bilateral descent.',
 'Warner Records', 801); 
INSERT INTO Lyric VALUES (907, 'Aside from retraining, we hope that by including the contents of the email
 and its subject to retrain the model, it will perform much better in predicting the samples tested. 
 For better accuracy, we would also implement the bidirectional LSTM and compare it with the traditional LSTM to see which gives better results.',
 'Warner Records', 807); 
INSERT INTO Lyric VALUES (908, 'Next, we made each sequence the same length to improve the model’s 
efficiency by padding with pad_sequences. The padding comes after the sequence and the maximum length 
of these sequences is 100. If the sequence is longer than the max length, the tokenizer will truncate the remaining values.',
 'Warner Records', 805); 
INSERT INTO Lyric VALUES (909, 'Neural networks are a subset of machine learning and forms the foundation of deep learning.
 Inspired by the human brain, these neural networks comprise of layers of neurons, containing an input layer, one or more hidden layers and an output layer. ', 
 'Warner Records', 804); 
INSERT INTO Lyric VALUES (910, 'They are a Berber-speaking people who live in southern Algeria, Mali, Niger, Burkina Faso, and the southwestern part of Libya.
 They are a predominantly Muslim, semi-nomadic group of people whose primary meal is wheat, millet, and dates.', 'Warner Records', 806);  
 
INSERT INTO Artiste_Song VALUES (1,801);
INSERT INTO Artiste_Song VALUES (1,802);
INSERT INTO Artiste_Song VALUES (2,803);
INSERT INTO Artiste_Song VALUES (3,804);
INSERT INTO Artiste_Song VALUES (4,805);
INSERT INTO Artiste_Song VALUES (5,806);
INSERT INTO Artiste_Song VALUES (1,807);
INSERT INTO Artiste_Song VALUES (6,808);
INSERT INTO Artiste_Song VALUES (4,809);
INSERT INTO Artiste_Song VALUES (5,810);


INSERT INTO Album_Artiste VALUES (701, 1);
INSERT INTO Album_Artiste VALUES (702, 2);
INSERT INTO Album_Artiste VALUES (703, 3);
INSERT INTO Album_Artiste VALUES (704, 4);
INSERT INTO Album_Artiste VALUES (705, 5);
INSERT INTO Album_Artiste VALUES (706, 6);
INSERT INTO Album_Artiste VALUES (707, 1);
INSERT INTO Album_Artiste VALUES (708, 4);
INSERT INTO Album_Artiste VALUES (709, 5);
INSERT INTO Album_Artiste VALUES (710, 1);

INSERT INTO Song_Playlist VALUES (801, 601);
INSERT INTO Song_Playlist VALUES (802, 601);
INSERT INTO Song_Playlist VALUES (803, 603);
INSERT INTO Song_Playlist VALUES (804, 610);
INSERT INTO Song_Playlist VALUES (805, 605);
INSERT INTO Song_Playlist VALUES (806, 608);
INSERT INTO Song_Playlist VALUES (807, 607);
INSERT INTO Song_Playlist VALUES (808, 608);
INSERT INTO Song_Playlist VALUES (809, 609);
INSERT INTO Song_Playlist VALUES (810, 604);

INSERT INTO Customer_Song VALUES (501,801);
INSERT INTO Customer_Song VALUES (502, 802);
INSERT INTO Customer_Song VALUES (503, 803);
INSERT INTO Customer_Song VALUES (504, 804);
INSERT INTO Customer_Song VALUES (505, 805);
INSERT INTO Customer_Song VALUES (506, 806);
INSERT INTO Customer_Song VALUES (507, 807);
INSERT INTO Customer_Song VALUES (508, 808);
INSERT INTO Customer_Song VALUES (509, 809);
INSERT INTO Customer_Song VALUES (510, 805);
INSERT INTO Customer_Song VALUES (501, 805);
INSERT INTO Customer_Song VALUES (512, 802);
INSERT INTO Customer_Song VALUES (513, 801);
INSERT INTO Customer_Song VALUES (514, 803);
INSERT INTO Customer_Song VALUES (515, 805);
INSERT INTO Customer_Song VALUES (516, 807);
INSERT INTO Customer_Song VALUES (517, 810);
INSERT INTO Customer_Song VALUES (518, 802);
INSERT INTO Customer_Song VALUES (519, 803);
INSERT INTO Customer_Song VALUES (520, 805);
INSERT INTO Customer_Song VALUES (521, 807);
INSERT INTO Customer_Song VALUES (520, 808);
INSERT INTO Customer_Song VALUES (523, 805);
INSERT INTO Customer_Song VALUES (524, 803);
INSERT INTO Customer_Song VALUES (525, 802);
INSERT INTO Customer_Song VALUES (526, 807);
INSERT INTO Customer_Song VALUES (523, 806);
INSERT INTO Customer_Song VALUES (528, 807);
INSERT INTO Customer_Song VALUES (529, 803);
INSERT INTO Customer_Song VALUES (530, 809);
INSERT INTO Customer_Song VALUES (531, 810);
INSERT INTO Customer_Song VALUES (532, 803);
INSERT INTO Customer_Song VALUES (533, 806);
INSERT INTO Customer_Song VALUES (534, 810);
INSERT INTO Customer_Song VALUES (511, 802);
INSERT INTO Customer_Song VALUES (521, 804);
INSERT INTO Customer_Song VALUES (527, 806);

INSERT INTO Customer_Playlist VALUES (501,601);
INSERT INTO Customer_Playlist VALUES (502, 602);
INSERT INTO Customer_Playlist VALUES (503, 603);
INSERT INTO Customer_Playlist VALUES (504, 604);
INSERT INTO Customer_Playlist VALUES (505, 605);
INSERT INTO Customer_Playlist VALUES (506, 606);
INSERT INTO Customer_Playlist VALUES (507, 607);
INSERT INTO Customer_Playlist VALUES (508, 608);
INSERT INTO Customer_Playlist VALUES (509, 609);
INSERT INTO Customer_Playlist VALUES (510, 610);
INSERT INTO Customer_Playlist VALUES (501, 608);
INSERT INTO Customer_Playlist VALUES (512, 609);
INSERT INTO Customer_Playlist VALUES (513, 601);
INSERT INTO Customer_Playlist VALUES (514, 603);
INSERT INTO Customer_Playlist VALUES (515, 603);
INSERT INTO Customer_Playlist VALUES (516, 603);
INSERT INTO Customer_Playlist VALUES (517, 609);
INSERT INTO Customer_Playlist VALUES (518, 608);
INSERT INTO Customer_Playlist VALUES (519, 602);
INSERT INTO Customer_Playlist VALUES (520, 601);
INSERT INTO Customer_Playlist VALUES (521, 604);
INSERT INTO Customer_Playlist VALUES (520, 605);
INSERT INTO Customer_Playlist VALUES (523, 606);
INSERT INTO Customer_Playlist VALUES (524, 607);
INSERT INTO Customer_Playlist VALUES (525, 607);
INSERT INTO Customer_Playlist VALUES (526, 608);
INSERT INTO Customer_Playlist VALUES (523, 605);
INSERT INTO Customer_Playlist VALUES (528, 604);
INSERT INTO Customer_Playlist VALUES (529, 609);
INSERT INTO Customer_Playlist VALUES (530, 608);
INSERT INTO Customer_Playlist VALUES (531, 607);
INSERT INTO Customer_Playlist VALUES (532, 606);
INSERT INTO Customer_Playlist VALUES (533, 605);
INSERT INTO Customer_Playlist VALUES (534, 601);
INSERT INTO Customer_Playlist VALUES (511, 603);
INSERT INTO Customer_Playlist VALUES (521, 604);
INSERT INTO Customer_Playlist VALUES (527, 602);

INSERT INTO Advertisement_Customer VALUES (123, 501);
INSERT INTO Advertisement_Customer VALUES (124, 502);
INSERT INTO Advertisement_Customer VALUES (125, 503);
INSERT INTO Advertisement_Customer VALUES (126, 504);
INSERT INTO Advertisement_Customer VALUES (127, 505);
INSERT INTO Advertisement_Customer VALUES (128, 506);
INSERT INTO Advertisement_Customer VALUES (129, 507);
INSERT INTO Advertisement_Customer VALUES (130, 508);
INSERT INTO Advertisement_Customer VALUES (131, 509);
INSERT INTO Advertisement_Customer VALUES (132, 510);
INSERT INTO Advertisement_Customer VALUES (123, 501);
INSERT INTO Advertisement_Customer VALUES (125, 514);
INSERT INTO Advertisement_Customer VALUES (126, 515);
INSERT INTO Advertisement_Customer VALUES (130, 517);
INSERT INTO Advertisement_Customer VALUES (123, 519);
INSERT INTO Advertisement_Customer VALUES (132, 520);
INSERT INTO Advertisement_Customer VALUES (129, 520);
INSERT INTO Advertisement_Customer VALUES (124, 524);

-- writing queries

-- this query selects songs based on genre, country and artiste name using union
SELECT song.song_title, Song.song_length, Song.year_released
FROM Song 
WHERE Song.songID IN (SELECT songID 
FROM Artiste_Song
WHERE Artiste_Song.artisteID = (SELECT Artiste.artisteID 
FROM Artiste 
WHERE artiste_stagename LIKE 'Demi%'))
UNION
SELECT song.song_title, Song.song_length, Song.year_released
FROM Song 
WHERE Song.songID IN (SELECT songID 
FROM Artiste_Song
WHERE Artiste_Song.artisteID IN (SELECT Artiste.artisteID 
FROM Artiste 
WHERE Artiste.countryID = (SELECT countryID FROM Country WHERE country_name LIKE 'United%')))
UNION 
SELECT song.song_title, Song.song_length, Song.year_released
FROM Song 
WHERE Song.songID IN (SELECT songID 
FROM Artiste_Song
WHERE Artiste_Song.artisteID IN (SELECT Artiste.artisteID 
FROM Artiste 
WHERE Song.genreID = (SELECT genreID FROM Genre WHERE genre_name LIKE 'Hip%')));

-- this query returns the friends of a customer, Ratifafa using self join
SELECT CustomerA.customer_fname, CustomerA.customer_lname, CustomerB.customer_fname, CustomerB.customer_lname
FROM Customer CustomerA, Customer CustomerB
WHERE CustomerB.CustomerID IN (
SELECT customerID FROM Customer WHERE Customer.friendID = (SELECT customerID FROM Customer WHERE customer_fname = 'Ratifafa'))
AND CustomerA.customerID = (SELECT customerID FROM Customer WHERE customer_fname = 'Ratifafa');

-- this query returns a list of customers who are still on their free tier subscription plan
-- and have not been utilising the platform
-- utility of the platform is measured in terms of the number of songs you have listened to
SELECT count(Customer_Song.customerID) AS Number_of_songs_listened_to, Customer_Song.customerID, customer_fname, customer_lname, email
FROM Customer_Song
INNER JOIN Customer
ON Customer_Song.customerID = Customer.customerID
WHERE Customer_Song.customerID NOT IN (SELECT Invoice.customerID FROM Invoice)
GROUP BY customerID
HAVING COUNT(Customer_Song.customerID) < 2
ORDER BY count(Customer_Song.customerID);

-- this query gets all customers who are below 18 years or live in El Salvador to target
-- the advertisement about teenage pregnancy to them
-- to target this advertisement, I used address and date of birth to target our customers
SELECT customer_fname, customer_lname, Customer.email, Customer.phone, Customer.address, DATE_FORMAT(FROM_DAYS(DATEDIFF(NOW(), Customer.dob)), '%Y') + 0 AS Age
FROM Customer
WHERE DATE_FORMAT(FROM_DAYS(DATEDIFF(NOW(), Customer.dob)), '%Y') + 0 < 18 OR Customer.countryID =
(SELECT countryID FROM Country WHERE country_name LIKE '%Salvador');

-- this query is a full outer join that returns all customers who have paid for their subscription plans 
-- and those who have not paid at all since they joined the platform
-- through this, we can be able to reach out to them to find out if they want to continue
-- their subscription plan, whether they want to switch plans, etc
SELECT Customer.customerID, customer_fname, customer_lname, Customer.email, Customer.address, Invoice.invoiceID, Invoice.invoice_date,
Invoice.amount_billed, Invoice.payment_method, Invoice.subscription_plan
FROM Customer
RIGHT JOIN Invoice
ON Customer.customerID = Invoice.customerID
UNION
SELECT Customer.customerID, customer_fname, customer_lname, Customer.email, Customer.address, Invoice.invoiceID, Invoice.invoice_date,
Invoice.amount_billed, Invoice.payment_method, Invoice.subscription_plan
FROM Customer
LEFT JOIN Invoice
ON Customer.customerID = Invoice.customerID
WHERE Customer.customerID NOT IN (SELECT Customer.customerID FROM Customer
WHERE Customer.customerID IN (SELECT member_on_plan FROM Family));

-- this query gets all the customers in our database who have registered but have not made
-- any payment yet for their subscription plan
SELECT customer_fname, customer_lname, Customer.email, date_registered, DATE_ADD(date_registered, INTERVAL 2 MONTH) AS date_for_payment
FROM Customer
WHERE Customer.customerID NOT IN (SELECT customerID FROM Invoice) 
AND Customer.customerID NOT IN (SELECT member_on_plan FROM Family);


-- this query returns the all the customers on the different subscription plan
-- and their next payment date
SELECT customerID, customer_fname, customer_lname, date_registered, DATE_ADD(date_registered, INTERVAL 1 MONTH) AS date_for_payment
FROM Customer
WHERE Customer.customerID IN (SELECT Invoice.customerID FROM Invoice WHERE subscription_plan = 'Individual')
UNION
SELECT DISTINCT Family.customerID, customer_fname, customer_lname, date_switched AS date_registered,
DATE_ADD(Family.date_switched, INTERVAL 1 MONTH) AS date_for_payment
FROM Family
INNER JOIN Customer
ON Customer.customerID = Family.customerID
WHERE Customer.customerID IN (SELECT Invoice.customerID FROM Invoice WHERE subscription_plan = 'Family')
GROUP BY Family.customerID
UNION
SELECT DISTINCT Student.customerID, customer_fname, customer_lname, date_switched AS date_registered, 
DATE_ADD(Student.date_switched, INTERVAL 1 MONTH) AS date_for_payment
FROM Student
INNER JOIN Customer
ON Customer.customerID = Student.customerID
WHERE Customer.customerID IN (SELECT Invoice.customerID FROM Invoice WHERE subscription_plan = 'Student')
GROUP BY Student.customerID;
