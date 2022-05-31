CREATE TABLE wallets (
    id int auto_increment,
    amount int default 0 not null,
    constraint data_pk primary key (id)
) ENGINE=InnoDB;

TRUNCATE wallets;

INSERT INTO wallets (id, amount) VALUES (1, 10);
INSERT INTO wallets (id, amount) VALUES (2, 10);

SELECT * FROM wallets;

SET autocommit=0;

SELECT @@transaction_ISOLATION;

SHOW FULL PROCESSLIST;

SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;

# Dirty reads ==========================================

# Session 1
START TRANSACTION;

SELECT amount FROM wallets WHERE id = 1; # Step 1

SELECT amount FROM wallets WHERE id = 1; # Step 3

COMMIT;

# Session 2
START TRANSACTION;

UPDATE wallets SET amount = 15 WHERE id = 1; # Step 2

ROLLBACK; # Step 4


# Lost updates =========================================

# Session 1
START TRANSACTION;
UPDATE wallets SET amount = amount + 5 WHERE id = 1; # Step 1
COMMIT; # Step 3

# Session 2
START TRANSACTION;
UPDATE wallets SET amount = amount + 10 WHERE id = 1; # Step 2
COMMIT; # Step 4


# Non-repeatable reads =================================

# Session 1
START TRANSACTION;

SELECT * FROM wallets WHERE id = 1; # Step 1

SELECT * FROM wallets WHERE id = 1; # Step 4
COMMIT; # Step 5

# Session 2
START TRANSACTION;

UPDATE wallets SET amount = 15 WHERE id = 1; # Step 2
COMMIT; # Step 3


# Phantom reads ========================================

# Session 1
START TRANSACTION;

SELECT * FROM wallets WHERE amount BETWEEN 10 AND 25; # Step 1

SELECT * FROM wallets WHERE amount BETWEEN 10 AND 25; # Step 4
COMMIT; # Step 5

# Session 2
START TRANSACTION;

INSERT INTO wallets (id, amount) VALUES (3, 20); # Step 2
COMMIT; # Step 3

