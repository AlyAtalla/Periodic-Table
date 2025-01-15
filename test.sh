#!/bin/bash

# Database connection function
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Generate a secret number between 1 and 1000
SECRET_NUMBER=$((RANDOM % 1000 + 1))

# Ask the user for their username
echo "Enter your username:"
read USERNAME

# Check username length
if [[ ${#USERNAME} -gt 22 ]]; then
  echo "Your username must be 22 characters or fewer."
  exit 1
fi

# Fetch user data from the database
USER_DATA=$($PSQL "SELECT username, games_played, best_game FROM users WHERE username = '$USERNAME'")

# Check if the user exists
if [[ -z $USER_DATA ]]; then
    # New user
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    $PSQL "INSERT INTO users (username, games_played, best_game) VALUES ('$USERNAME', 0, 0)"
else
    # Existing user
    IFS='|' read USERNAME GAMES_PLAYED BEST_GAME <<< "$USER_DATA"
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Start the guessing game
echo "Guess the secret number between 1 and 1000:"
NUMBER_OF_GUESSES=0

while true; do
    read GUESS
    ((NUMBER_OF_GUESSES++))

    # Validate integer input
    if ! [[ "$GUESS" =~ ^[0-9]+$ ]]; then
        echo "That is not an integer, guess again:"
        continue
    fi

    # Compare guess with secret number
    if (( GUESS > SECRET_NUMBER )); then
        echo "It's lower than that, guess again:"
    elif (( GUESS < SECRET_NUMBER )); then
        echo "It's higher than that, guess again:"
    else
        echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

        # Update user statistics
        if [[ $GAMES_PLAYED -eq 0 || $NUMBER_OF_GUESSES -lt $BEST_GAME ]]; then
            BEST_GAME=$NUMBER_OF_GUESSES
        fi

        $PSQL "UPDATE users SET games_played = games_played + 1, best_game = LEAST(best_game, $NUMBER_OF_GUESSES) WHERE username = '$USERNAME'"

        break
    fi
done