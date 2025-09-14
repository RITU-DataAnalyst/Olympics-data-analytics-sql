--TABLE events of Athletes
CREATE TABLE athlete_events (
    id INTEGER,
    name TEXT,
    sex CHAR(1),
    age INTEGER,
    height INTEGER,
    weight INTEGER,
    team TEXT,
    noc CHAR(3),
    games TEXT,
    year INTEGER,
    season TEXT,
    city TEXT,
    sport TEXT,
  	  event TEXT,
    medal TEXT
);
 

 
 
-- Table NOC Region 
create TABLE noc_regions (
    noc CHAR(3),
    region TEXT,
    notes TEXT
);


