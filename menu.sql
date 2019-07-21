CREATE TABLE menu(
    id INTEGER NOT NULL,
    name TEXT NOT NULL,
    twitter_code TEXT NOT NULL,
    description TEXT NOT NULL,
    price REAL NOT NULL,
    location INTEGER NOT NULL
);

INSERT INTO menu VALUES(
    1, "Margherita", "MARGHERITA", "Lovely pizza for the whole family", 10.99, 3
);

INSERT INTO menu VALUES(
    2, "Bolognese", "BOLOGNESE", "A London Exclusive", 15.99, 2
);

INSERT INTO menu VALUES(
    3, "Elementary", "ELEMENTARY", "For your Sherlock cravings", 10.99, 3
);

INSERT INTO menu VALUES(
    4, "Quattro Stagioni", "4STAGIONI", "Perfect to share with friends", 9.99, 3
);

sheffield =1
London = 2
Both = 3