CREATE TABLE info (
  id INTEGER PRIMARY KEY,
  username TEXT NOT NULL,
  password TEXT NOT NULL,
  twitter TEXT NOT NULL,
  Admin INTEGER NOT NULL,
  Location INTEGER NOT NULL
);

Address field will also be necessary

CREATE TABLE address (
    id INTEGER NOT NULL PRIMARY KEY,
    twitter TEXT NOT NULL,
    house_name TEXT,
    house_number INTEGER,
    street TEXT,
    postcode TEXT
);

INSERT INTO info VALUES (
  1, "bob", "bob", "bob", "0", "0"
);

INSERT INTO address VALUES (
  1, "bob", "bob", "48", "bob", "bob"
);

INSERT INTO info VALUES (
  2, "Leon", "password", "LeonSingleton", "0", "0"
);

INSERT INTO info VALUES (
  3, "orders", "orders", "@orders", "2", "1"
);

INSERT INTO info VALUES (
  4, "admin", "admin", "@admin", "1", "1"
);

INSERT INTO info VALUES (
  5, "marketing", "marketing", "@marketing", "3", "1"
);

INSERT INTO address VALUES (
  2, "LeonSingleton", "farm house", "48", "curzon street", "S3 7LG"
);


Location 
1 = sheffield
2=london
0 =customer



#customer has admin of 0
#admin has admin of 1
#order staff has admin of 2
#marketing staff has admin of 3

logins

orders orders
marketing marketing
admin1 admin1
Leon Password