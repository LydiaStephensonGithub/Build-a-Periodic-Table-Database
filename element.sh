#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"

DELETE_TYPE_FROM_PROPERTIES=$($PSQL "ALTER TABLE properties DROP COLUMN IF EXISTS type")
DELETE_NON_EXISTENT_PROPERTIES=$($PSQL "DELETE FROM properties WHERE atomic_number = 1000")
DELETE_NON_EXISTENT_ELEMENT=$($PSQL "DELETE FROM elements WHERE atomic_number = 1000")

if [[ ! $1 ]]
then
  echo "Please provide an element as an argument."
else
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    ATOMIC_NUMBER=$1
  else 
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol = '$1'")

    if [[ -z $ATOMIC_NUMBER ]]
    then
      ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name = '$1'")
    fi 
  fi 

  if [[ ! -z $ATOMIC_NUMBER ]]
  then
    ELEMENT_NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number = $ATOMIC_NUMBER")
    SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number = $ATOMIC_NUMBER")
    ELEMENT_TYPE=$($PSQL "SELECT types.type FROM types JOIN properties USING (type_id) WHERE atomic_number = $ATOMIC_NUMBER")
    ATOMIC_MASS=$($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number = $ATOMIC_NUMBER")
    MELTING_POINT=$($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number = $ATOMIC_NUMBER")
    BOILING_POINT=$($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number = $ATOMIC_NUMBER")
  
    echo "The element with atomic number $(echo $ATOMIC_NUMBER is $ELEMENT_NAME | sed -E 's/^ +| +$//g') ($(echo $SYMBOL | sed -E 's/^ +| +$//g')). It's a $(echo $ELEMENT_TYPE, with a mass of $ATOMIC_MASS amu. $ELEMENT_NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT | sed -E 's/^ +| +$//g') celsius."
  else 
    echo "I could not find that element in the database."
  fi
fi

