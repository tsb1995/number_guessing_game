#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=number_guess -t --tuples-only -c"

#generate secret number
SECRET_NUMBER=$((1 + $RANDOM % 1000))

#get username
echo -e "\nEnter your username:"
read USERNAME

#grab user info from database
USER_INFO=$($PSQL "SELECT username, games_played, best_game FROM users WHERE username='$USERNAME'")

#if no such user
if [[ -z $USER_INFO ]]
then
  #create user
  CREATE_USER_RESULTS=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')");
  USER_INFO=$($PSQL "SELECT username, games_played, best_game FROM users WHERE username='$USERNAME'")
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
else
  echo "$USER_INFO" | while read USERNAME BAR GAMES_PLAYED BAR BEST_GAME
    do
      echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
    done
fi

#get first guess
echo -e "\nGuess the secret number between 1 and 1000:"
NUMBER_OF_GUESSES=0

CHECK_GUESS() {
  read GUESS
  let "NUMBER_OF_GUESSES+=1"
  if [[ "$GUESS" =~ ^[0-9]+$ ]]
  then
    if [[ $GUESS > $SECRET_NUMBER ]]
    then
      echo -e "\nIt's lower than that, guess again:"
      CHECK_GUESS
    elif [[ $GUESS < $SECRET_NUMBER ]]
    then
      echo -e "\nIt's higher than that, guess again:"
      CHECK_GUESS
    else
      echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
      
      #update the table for best game and games played
      UPDATE_USER_RESULTS=$($PSQL "UPDATE users SET best_game=$NUMBER_OF_GUESSES, games_played=games_played + 1 WHERE username='$USERNAME'")
    fi
  else
    echo -e "\nThat is not an integer, guess again:"
    CHECK_GUESS
  fi
}

CHECK_GUESS

