require "rake"
require_relative 'app'

@db = SQLite3::Database.new('useraccounts.sqlite')
@db_menu = SQLite3::Database.new('menu.sqlite')
@db_orders = SQLite3::Database.new('orders.sqlite')
@db_stats = SQLite3::Database.new('statistics.sqlite')

desc "Create User Database"
task :createUsers do
    puts "Creating the Users Database"
    @db.execute(
        'CREATE TABLE info (
              id INTEGER PRIMARY KEY,
              username TEXT NOT NULL,
              password TEXT NOT NULL,
              twitter TEXT NOT NULL,
              Admin INTEGER NOT NULL,
              Location INTEGER NOT NULL
              );')
    
    @db.execute(
        'CREATE TABLE address (
            id INTEGER NOT NULL PRIMARY KEY,
            twitter TEXT NOT NULL,
            house_name TEXT,
            house_number INTEGER,
            street TEXT,
            postcode TEXT
        );')
    
end

desc "Create Menu Database"
task :createMenu do
  puts "Creating the Menu Database"
  @db_menu.execute(
      'CREATE TABLE menu(
        id INTEGER NOT NULL,
        name TEXT NOT NULL,
        twitter_code TEXT NOT NULL,
        description TEXT NOT NULL,
        price REAL NOT NULL,
        location INTEGER NOT NULL
    );')
end

desc "Create Order Database"
task :createOrders do
    puts "Creating the Orders Database"
    @db_orders.execute(
        'CREATE TABLE orders(
            id INTEGER NOT NULL,
            date TEXT NOT NULL,
            sender TEXT NOT NULL,
            text TEXT,
            status INTEGER
    );')
end

#status : 0 = received
# 1 = accepted
# 2 = declined
# 3 = out of range

desc "Create Statistics Database"
task :createStats do
    @db_stats.execute('CREATE TABLE stats(
        id INTEGER NOT NULL PRIMARY KEY,
        year INTEGER NOT NULL,
        month INTEGER NOT NULL,
        day INTEGER NOT NULL,
        UniqueUsers INTEGER,
        TwitterFollowers INTEGER
    );')
end


desc "Display Users"
task :displayUsers do
    puts "Display Users"
     puts @db.execute('SELECT*FROM info;')
end

desc "Display Menu Contents"
task :displayMenu do
    puts "Display Menu"
    puts @db_menu.execute('SELECT*FROM menu;')
end

desc "Display Orders"
task :displayOrders do
    puts "Display Orders"
    puts @db_orders.execute('SELECT*FROM orders;')
end

desc "Insert start Users"
task :insertUsers do
   @db.execute(' INSERT INTO info VALUES (
  1, "bob", "bob", "bob", "0", "0"
);')

  @db.execute('INSERT INTO address VALUES (
  1, "bob", "bob", "48", "bob", "bob"
);')

  @db.execute('INSERT INTO info VALUES (
      2, "Leon", "password", "LeonSingleton", "0", "0"
    );')
    
    @db.execute('INSERT INTO address VALUES (
      2, "LeonSingleton", "farm house", "48", "curzon street", "S3 7LG"
    );')

  @db.execute('INSERT INTO info VALUES (
      3, "orders", "orders", "@orders", "2", "1"
    );')

  @db.execute('INSERT INTO info VALUES (
      4, "admin", "admin", "@admin", "1", "1"
    );')

  @db.execute('INSERT INTO info VALUES (
      5, "marketing", "marketing", "@marketing", "3", "1"
    );')

end

desc "Insert start Menu values"
task :insertMenuValues do
    puts "Adding random Menu values"
    @db_menu.execute(
        'INSERT INTO menu VALUES(
            1, "Margherita", "MARGHERITA", "Lovely pizza for the whole family", 10.99, 3
        );')
     @db_menu.execute(
         'INSERT INTO menu VALUES(
            2, "Bolognese", "BOLOGNESE", "A London Exclusive", 15.99, 2
        );')
    
     @db_menu.execute(
        'INSERT INTO menu VALUES(
            3, "Elementary", "ELEMENTARY", "For your Sherlock cravings", 10.99, 3
        );')
    
     @db_menu.execute(
        'INSERT INTO menu VALUES(
            4, "Quattro Stagioni", "4STAGIONI", "Perfect to share with friends", 9.99, 3
        );')
end

desc "Insert Orders" 
task :insertOrders do
    @db_orders.execute(
        'INSERT INTO orders VALUES(
        1, "2017-04-23", "RuxandraMindru", "@SignOffPizza #MARGHERITA #DELIVERY", 0);')
end

desc "Insert Statistics"
task :insertStats do
    @db_stats.execute(
        'INSERT INTO stats VALUES(
         1, 2017, 04, 11, 4, 1
    );')
    
    @db_stats.execute(
        'INSERT INTO stats VALUES(
         2, 2017, 04, 25, 4, 2
    );')
end

desc "Delete the Menu Database"
task :deleteMenu do
    puts "Deleting existing menu"
    @db_menu.execute(
        'DELETE FROM menu;')
end

desc "Delete the Orders DB"
task :deleteOrders do
    @db_orders.execute(
         'DELETE FROM orders;')
end

desc "Delete statistics"
task :deleteStats do
    @db_stats.execute(
        'DELETE FROM stats;')
end