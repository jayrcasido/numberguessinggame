#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -q -X -t --no-align -c"

printf "Enter your username: "
read -r username

clean_username=${username//\'/\'\'}
clean_username=${clean_username//\\/\\\\}
user_id=$($PSQL "SELECT user_id FROM users WHERE username = '$clean_username';")

if [[ -z $user_id ]]; then
  $PSQL "INSERT INTO users(username) VALUES('$clean_username');"
  user_id=$($PSQL "SELECT user_id FROM users WHERE username = '$clean_username';")
  echo "Welcome, $username! It looks like this is your first time here."
  games_played=0
  best_game=0
else
  games_played=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id = $user_id;")
  best_game=$($PSQL "SELECT COALESCE(MIN(guesses), 0) FROM games WHERE user_id = $user_id;")
  echo "Welcome back, $username! You have played $games_played games, and your best game took $best_game guesses."
fi

secret_number=$((1 + RANDOM % 1000))
guesses=0
previous_guess=0

while true; do
  printf "Guess the secret number between 1 and 1000: "
  read -r guess

  if [[ ! $guess =~ ^-?[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi

  ((guesses += 1))

  if (( guess == secret_number )); then
    $PSQL "INSERT INTO games(user_id, guesses) VALUES($user_id, $guesses);"
    echo "You guessed it in $guesses tries. The secret number was $secret_number. Nice job!"
    break
  fi

  if (( previous_guess != 0 )); then
    if (( previous_guess > secret_number )); then
      echo "It's lower than that, guess again:"
    else
      echo "It's higher than that, guess again:"
    fi
  elif (( guess < secret_number )); then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi

  previous_guess=$guess
done
