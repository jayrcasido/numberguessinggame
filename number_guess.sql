-- Create the game tables if they do not already exist.
CREATE TABLE IF NOT EXISTS users (
  user_id SERIAL PRIMARY KEY,
  username VARCHAR(22) UNIQUE NOT NULL
);

-- Enforce the 22-character limit on an existing database.
ALTER TABLE users
ALTER COLUMN username TYPE VARCHAR(22);

CREATE TABLE IF NOT EXISTS games (
  game_id SERIAL PRIMARY KEY,
  user_id INT REFERENCES users(user_id),
  guesses INT NOT NULL
);
