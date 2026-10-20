#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only --no-align -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo "Welcome to My Salon, how can I help you?"

# Show the available services
$PSQL "SELECT service_id || ') ' || name FROM services ORDER BY service_id"

# Get a valid service ID
read SERVICE_ID_SELECTED

while [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]] || [[ -z $($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED") ]]
do
  echo -e "\nI could not find that service. What would you like today?"
  $PSQL "SELECT service_id || ') ' || name FROM services ORDER BY service_id"
  read SERVICE_ID_SELECTED
done

# Get the service name
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

# Get the customer's phone number
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

# Find the customer by phone number
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

# Register the customer if they do not exist
if [[ -z $CUSTOMER_ID ]]
then
  echo -e "\nWhat's your name?"
  read CUSTOMER_NAME

  $PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')"

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
else
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID")
fi

# Ask for the appointment time
echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME

# Insert the appointment
$PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')"

# Confirm the appointment
echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."


