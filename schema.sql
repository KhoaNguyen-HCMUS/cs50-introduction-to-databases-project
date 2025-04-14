-- Represent books in the system
CREATE TABLE "books" (
    "id" INTEGER,
    "title" TEXT NOT NULL,
    "isbn" TEXT UNIQUE,
    "year_published" INTEGER,
    "publisher_id" INTEGER,
    "description" TEXT,
    "language" TEXT,
    "page_count" INTEGER,
    "status" TEXT NOT NULL DEFAULT 'available' CHECK("status" IN ('available', 'borrowed', 'maintenance')),
    "added_date" NUMERIC NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY("id"),
    FOREIGN KEY("publisher_id") REFERENCES "publishers"("id")
);

-- Represent authors
CREATE TABLE "authors" (
    "id" INTEGER,
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    "birth_year" INTEGER,
    "death_year" INTEGER,
    "biography" TEXT,
    "nationality" TEXT,
    PRIMARY KEY("id")
);

-- Represent publishers
CREATE TABLE "publishers" (
    "id" INTEGER,
    "name" TEXT NOT NULL,
    "location" TEXT,
    "founded_year" INTEGER,
    "website" TEXT,
    PRIMARY KEY("id")
);

-- Represent book genres
CREATE TABLE "genres" (
    "id" INTEGER,
    "name" TEXT NOT NULL UNIQUE,
    "description" TEXT,
    PRIMARY KEY("id")
);

-- Represent book borrowers
CREATE TABLE "borrowers" (
    "id" INTEGER,
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    "email" TEXT NOT NULL UNIQUE,
    "phone" TEXT,
    "address" TEXT,
    "registration_date" NUMERIC NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY("id")
);

-- Junction table between books and authors (many-to-many relationship)
CREATE TABLE "book_authors" (
    "book_id" INTEGER,
    "author_id" INTEGER,
    PRIMARY KEY("book_id", "author_id"),
    FOREIGN KEY("book_id") REFERENCES "books"("id"),
    FOREIGN KEY("author_id") REFERENCES "authors"("id")
);

-- Junction table between books and genres (many-to-many relationship)
CREATE TABLE "book_genres" (
    "book_id" INTEGER,
    "genre_id" INTEGER,
    PRIMARY KEY("book_id", "genre_id"),
    FOREIGN KEY("book_id") REFERENCES "books"("id"),
    FOREIGN KEY("genre_id") REFERENCES "genres"("id")
);

-- Represent book borrowing history
CREATE TABLE "loans" (
    "id" INTEGER,
    "book_id" INTEGER,
    "borrower_id" INTEGER,
    "loan_date" NUMERIC NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "due_date" NUMERIC NOT NULL,
    "return_date" NUMERIC,
    "status" TEXT NOT NULL DEFAULT 'active' CHECK("status" IN ('active', 'returned', 'overdue')),
    PRIMARY KEY("id"),
    FOREIGN KEY("book_id") REFERENCES "books"("id"),
    FOREIGN KEY("borrower_id") REFERENCES "borrowers"("id")
);

-- Represent book reviews and ratings
CREATE TABLE "reviews" (
    "id" INTEGER,
    "book_id" INTEGER,
    "borrower_id" INTEGER,
    "rating" INTEGER NOT NULL CHECK("rating" BETWEEN 1 AND 5),
    "review_text" TEXT,
    "review_date" NUMERIC NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY("id"),
    FOREIGN KEY("book_id") REFERENCES "books"("id"),
    FOREIGN KEY("borrower_id") REFERENCES "borrowers"("id")
);

-- Create view showing all available books
CREATE VIEW "available_books" AS
SELECT
    b.id, b.title, b.isbn,
    GROUP_CONCAT(DISTINCT a.first_name || ' ' || a.last_name) AS authors,
    GROUP_CONCAT(DISTINCT g.name) AS genres,
    p.name AS publisher,
    b.year_published,
    b.language,
    b.page_count
FROM
    books b
LEFT JOIN
    book_authors ba ON b.id = ba.book_id
LEFT JOIN
    authors a ON ba.author_id = a.id
LEFT JOIN
    book_genres bg ON b.id = bg.book_id
LEFT JOIN
    genres g ON bg.genre_id = g.id
LEFT JOIN
    publishers p ON b.publisher_id = p.id
WHERE
    b.status = 'available'
GROUP BY
    b.id;

-- Create view showing all overdue loans
CREATE VIEW "overdue_loans" AS
SELECT
    l.id AS loan_id,
    b.title AS book_title,
    br.first_name || ' ' || br.last_name AS borrower_name,
    br.email AS borrower_email,
    br.phone AS borrower_phone,
    l.loan_date,
    l.due_date,
    julianday('now') - julianday(l.due_date) AS days_overdue
FROM
    loans l
JOIN
    books b ON l.book_id = b.id
JOIN
    borrowers br ON l.borrower_id = br.id
WHERE
    l.status = 'active' AND
    l.return_date IS NULL AND
    l.due_date < CURRENT_TIMESTAMP;

-- Create indexes to speed up common searches
CREATE INDEX "book_title_search" ON "books" ("title");
CREATE INDEX "book_status_search" ON "books" ("status");
CREATE INDEX "author_name_search" ON "authors" ("first_name", "last_name");
CREATE INDEX "genre_name_search" ON "genres" ("name");
CREATE INDEX "borrower_name_search" ON "borrowers" ("first_name", "last_name");
CREATE INDEX "borrower_email_search" ON "borrowers" ("email");
CREATE INDEX "loan_status_search" ON "loans" ("status");
CREATE INDEX "loan_borrower_search" ON "loans" ("borrower_id");
CREATE INDEX "loan_book_search" ON "loans" ("book_id");
