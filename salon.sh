#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Salon Appointment Scheduler ~~~~~\n"
echo -e "\nHow can we help you?"
#main menu
MAIN(){
  if [[ $1 ]]
  then
    echo -e "\n$1\n"
  fi
  SERVICES=$($PSQL "SELECT * FROM services;");
  #display menu
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE
  do
    echo "$SERVICE_ID) $SERVICE"
  done
  read SERVICE_ID_SELECTED
  #check that the input is a number in the options (Allow the database to grow)
  SERVICE_EXISTS=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
  if [[ -z $SERVICE_EXISTS ]]
  then
    MAIN "Select one of the options below"
  else
    BOOK
  fi
}

BOOK(){
  #get customer's phone number
  echo -e "\nOk, now what's your phone number"
  read CUSTOMER_PHONE
  echo $CUSTOMER_PHONE
  #check customer is registered
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';")
  if [[ -z $CUSTOMER_NAME ]]
  then
    #ask for name
    echo -e "\nHmm, I couldn't find your record. Could you tell me your name?"
    read CUSTOMER_NAME
    #register
    REGISTER_CUSTOMER=$($PSQL "INSERT INTO customers(name,phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE');")
    echo -e "\nNice! You are registered now."
  fi
  #ask the for the time they want to book
  echo -e "\nAt what time would you like to visit us? 9:00-19:00"
  read SERVICE_TIME
  #We should check if the time is already in the database but that requires more work
  #Get the service name selected
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
  #Get the customer id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")
  #Make the appointment
  BOOK_SERVICE=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME');")
  #Confirm the appointment
  if [[ $BOOK_SERVICE == "INSERT 0 1" ]]
  then
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

MAIN