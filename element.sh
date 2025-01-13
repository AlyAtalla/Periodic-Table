#!/bin/bash

# Check if an argument is provided
if [[ $# -eq 0 ]]; then
    echo "Please provide an element as an argument."
    exit 0
fi

# Database connection command
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Query to find element information
ELEMENT_INFO=$($PSQL "
SELECT e.atomic_number, e.name, e.symbol, t.type, 
       p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius
FROM elements e
JOIN properties p ON e.atomic_number = p.atomic_number
JOIN types t ON p.type_id = t.type_id
WHERE e.atomic_number::TEXT = '$1' 
   OR UPPER(e.symbol) = UPPER('$1')
   OR UPPER(e.name) = UPPER('$1')
")

# Check if element exists
if [[ -z $ELEMENT_INFO ]]; then
    echo "I could not find that element in the database."
    exit 0
fi

# Parse element information
IFS='|' read ATOMIC_NUMBER NAME SYMBOL TYPE MASS MELTING BOILING <<< "$ELEMENT_INFO"

# Output element details
echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."