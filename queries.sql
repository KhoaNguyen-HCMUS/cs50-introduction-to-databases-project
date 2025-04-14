-- Find all books by title
SELECT b.id, b.title, b.isbn, GROUP_CONCAT(DISTINCT a.first_name || ' ' || a.last_name) AS authors
FROM books b
LEFT JOIN book_authors ba ON b.id = ba.book_id
LEFT JOIN authors a ON ba.author_id = a.id
WHERE b.title LIKE '%Harry Potter%'
GROUP BY b.id;

-- Find all books by author
SELECT b.id, b.title, b.isbn, b.year_published, b.status
FROM books b
JOIN book_authors ba ON b.id = ba.book_id
JOIN authors a ON ba.author_id = a.id
WHERE a.first_name = 'J.K.' AND a.last_name = 'Rowling';

-- Find all books by genre
SELECT b.id, b.title, GROUP_CONCAT(DISTINCT a.first_name || ' ' || a.last_name) AS authors
FROM books b
JOIN book_genres bg ON b.id = bg.book_id
JOIN genres g ON bg.genre_id = g.id
LEFT JOIN book_authors ba ON b.id = ba.book_id
LEFT JOIN authors a ON ba.author_id = a.id
WHERE g.name = 'Fantasy'
GROUP BY b.id;

-- Find book by ISBN
SELECT b.id, b.title, GROUP_CONCAT(DISTINCT a.first_name || ' ' || a.last_name) AS authors
FROM books b
LEFT JOIN book_authors ba ON b.id = ba.book_id
LEFT JOIN authors a ON ba.author_id = a.id
WHERE b.isbn = '9780747532743'
GROUP BY b.id;

-- Add a new book
INSERT INTO books (title, isbn, year_published, publisher_id, description, language, page_count)
VALUES ('The Hobbit', '9780618260300', 1937, 1, 'A fantasy novel by J.R.R. Tolkien', 'English', 310);

-- Add author information for a book
INSERT INTO book_authors (book_id, author_id)
VALUES (1, 1);

-- Add genre for a book
INSERT INTO book_genres (book_id, genre_id)
VALUES (1, 1);

-- Add a new author
INSERT INTO authors (first_name, last_name, birth_year, nationality)
VALUES ('J.R.R.', 'Tolkien', 1892, 'British');

-- Add a new publisher
INSERT INTO publishers (name, location, founded_year, website)
VALUES ('Allen & Unwin', 'Australia', 1914, 'https://www.allenandunwin.com');

-- Add a new genre
INSERT INTO genres (name, description)
VALUES ('Fantasy', 'Fiction with magical or supernatural elements');

-- Add a new borrower
INSERT INTO borrowers (first_name, last_name, email, phone, address)
VALUES ('John', 'Smith', 'johnsmith@example.com', '0123456789', 'New York, USA');

-- Register a book loan
INSERT INTO loans (book_id, borrower_id, due_date)
VALUES (1, 1, datetime('now', '+14 days'));

-- Update book status when borrowed
UPDATE books
SET status = 'borrowed'
WHERE id = 1;

-- Register a book return
UPDATE loans
SET return_date = CURRENT_TIMESTAMP, status = 'returned'
WHERE id = 1 AND status = 'active';

-- Update book status when returned
UPDATE books
SET status = 'available'
WHERE id = 1;

-- Add a book review
INSERT INTO reviews (book_id, borrower_id, rating, review_text)
VALUES (1, 1, 5, 'An excellent book, I loved it!');

-- Find all books currently on loan
SELECT b.id, b.title, br.first_name || ' ' || br.last_name AS borrower, l.due_date
FROM books b
JOIN loans l ON b.id = l.book_id
JOIN borrowers br ON l.borrower_id = br.id
WHERE l.status = 'active' AND l.return_date IS NULL;

-- Find all overdue books
SELECT *
FROM overdue_loans;

-- Show a borrower's loan history
SELECT b.title, l.loan_date, l.due_date, l.return_date, l.status
FROM loans l
JOIN books b ON l.book_id = b.id
WHERE l.borrower_id = 1
ORDER BY l.loan_date DESC;

-- Find highest rated books
SELECT b.id, b.title, AVG(r.rating) AS average_rating, COUNT(r.id) AS review_count
FROM books b
JOIN reviews r ON b.id = r.book_id
GROUP BY b.id
ORDER BY average_rating DESC, review_count DESC
LIMIT 10;

-- Update book information
UPDATE books
SET description = 'A classic work by J.R.R. Tolkien', page_count = 320
WHERE id = 1;

-- Update author information
UPDATE authors
SET biography = 'John Ronald Reuel Tolkien (1892-1973) was an English writer, poet, philologist, and academic.'
WHERE id = 1;

-- Delete a review
DELETE FROM reviews
WHERE id = 1;

-- Find all books available for borrowing
SELECT *
FROM available_books;
