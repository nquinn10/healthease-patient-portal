'''
CS 5200 
Final Project
Group: QuinnNSaslowKQuachL

This program establishes a connection to the MySQL server of the user and 
interacts with the health_ease database. This is the Controller of our 
database application.
'''

import pymysql
import getpass
import datetime
import re

import matplotlib.pyplot as plt
import seaborn as sns

def create_connection():
    '''
    This function establishes a connection with the mysql server
    by taking username/password as user input
    '''

    credentials_valid = False

    while not credentials_valid:
        username = input("Please enter your MySQL username: ")
        pw = getpass.getpass("Please enter your MySQL password: ")
    
        try: # establish connection
            connection = pymysql.connect(host='localhost', user=username,
                            password=pw,
                            db='health_ease', charset='utf8mb4',
                            cursorclass=pymysql.cursors.DictCursor)
            
            connection.autocommit(True)
            credentials_valid = True
            print("\nConnection made successfully. \n")
    
        except pymysql.err.OperationalError:
            
            print("\nConnection failed. Please try entering your username and password again")
    
    return connection

def home_page(cnx):
    print("\t\t\t\t╔══════════════════════════════════════╗")
    print("\t\t\t\t║ Welcome to HealthEase Patient Portal ║")
    print("\t\t\t\t╚══════════════════════════════════════╝ \n")
    print("1. Create Account")
    print("2. Log-in to Account")
    print("Q. Quit")
    return input("Enter your choice: ")

def main_menu():
    print("\t\t\t\t╔══════════════════════════════════════╗")
    print("\t\t\t\t║              Main Menu               ║")
    print("\t\t\t\t╚══════════════════════════════════════╝ \n")
    menu = (
        "\t\t\t1. View Profile                 9. Schedule Appointment",
        "\t\t\t2. Update Profile               10. Reschedule Appointment",
        "\t\t\t3. Update Insurance             11. Cancel Appointment",
        "\t\t\t4. Find Doctor                  12. View Your Prescriptions",
        "\t\t\t5. View Doctor Reviews          13. Refill a Prescription",
        "\t\t\t6. Write Doctor Reviews         14. View Your Bills",
        "\t\t\t7. Delete Doctor Reviews        15. Pay Your Bills",
        "\t\t\t8. View Appointments            Q. Quit"
    )

    for option in menu:
        print(option)
    return input("Enter your choice: ")

def admin_main_menu():
    print("\t\t\t\t╔══════════════════════════════════════╗")
    print("\t\t\t\t║              Main Menu               ║")
    print("\t\t\t\t╚══════════════════════════════════════╝ \n")
    print("1. View Patients")
    print("2. Update Patient Username")
    print("3. Update Patient Password")
    print("4. Delete Patient")
    print("5. View Doctors")
    print("6. Add Doctor")
    print("7. Delete Doctor")
    print("Q. Quit")
    return input("Enter your choice: ")

def check_admin_status(cnx, patient_id):
    '''
    Admin status check - this function retrieves the is_admin field value from the
    patient_profile table for the specific user that is logged in. is_admin is stored
    as a boolean (0 for non-admin, 1 for admin) in the datbase. It will return their
    admin status to main to determine which menu should be shown for the current user.
    '''
    try:
        with cnx.cursor() as cursor:
            query = "SELECT is_admin FROM patient_profile WHERE patient_id = %s"
            cursor.execute(query, (patient_id,))
            result = cursor.fetchone()

            if result:
                return result['is_admin']
            else:
                return False

    except pymysql.Error as e:
        raise  

def execute_procedure(cnx, procedure_name, args, is_read_op=False):
    try:
        with cnx.cursor() as cursor:
            cursor.callproc(procedure_name, args)
 
            # for READ operations, fetch and return result set
            if is_read_op:
                result = cursor.fetchall()
                return result  # Return the result set for successful execution
            
            cnx.commit()
            return True
    except pymysql.Error as e:
        raise


def create_account(connection): 
    '''
    '''

    # print("\nCreate Account")
    first_name = input("First Name: ")
    last_name = input("Last Name: ")
    dob = input("Date of Birth (YYYY-MM-DD): ")
    email = input("Email: ")
    password = input("Password: ")

    try:
        with connection.cursor() as cursor:
            params = [0, first_name, last_name, dob, email, password]  # 0 is a placeholder for the OUT parameter

            cursor.callproc('create_account', params)

            # Fetch the output parameter (patient_id)
            cursor.execute('SELECT @_create_account_0')
            result = cursor.fetchone()
            patient_id = result['@_create_account_0']

            print(f"Account created successfully! Your Patient ID is: {patient_id}")
            return patient_id
    
    except pymysql.Error as e:
        error_message = e.args[1]
        print("An error occurred:", error_message)
        # return None
    

def login(cnx):
    '''
    If the user already exists in the portal: login to view options.
    To get the users already in the account, make a dictionary of users, username/pw?
    Return: patient_id of the patient, will be used for all procedures the user does
    '''
    while True:
        email = input("Please enter your email: ").lower()
        password = input("Please enter your password: ")

        cur = cnx.cursor()

        # Use a parameterized query to avoid SQL injection
        stmt_select = "SELECT * FROM patient_profile WHERE email = %s AND user_password = %s"
        cur.execute(stmt_select, (email, password))

        row = cur.fetchone()

        # close cursor
        cur.close()

        if row:
            # If a row is returned, login is successful
            print("\nLogin successful!\n")
            return row['patient_id']
        else:
            # If no row is returned, login failed
            print("\nInvalid email or password. Please try again or sign up now!\n")
            
            # Ask the user if they want to try again
            retry = input("Do you want to try again? (yes/no): ").lower()
            if retry != 'yes':
                break  # Exit the loop if the user chooses not to retry

    return None

def view_profile(connection, patient_id):
    '''
    '''
    result = execute_procedure(connection, 'view_profile', (patient_id,), is_read_op=True)
    if result and len(result) > 0:
        print("\nProfile Information:\n")
        row = result[0]  # Assuming the stored procedure returns a single tuple
        
        # reformat phone numbers to print to screen
        unformatted_phone = row['phone_no']
        if unformatted_phone and len(unformatted_phone) == 11:
            formatted_phone = f"{unformatted_phone[0]}-{unformatted_phone[1:4]}-{unformatted_phone[4:7]}-{unformatted_phone[7:]}"        
        else: 
            formatted_phone = "None"
        
        unformatted_phone_e = row['emergency_contact_no']
        if unformatted_phone_e and len(unformatted_phone_e) == 11:
            formatted_phone_e = f"{unformatted_phone_e[0]}-{unformatted_phone_e[1:4]}-{unformatted_phone_e[4:7]}-{unformatted_phone_e[7:]}"
        else:
            formatted_phone_e = "None"
            
        print(f"First Name: {row['first_name']} \n" +
                f"Last Name: {row['last_name']} \n" +
                f"Date of Birth: {row['date_of_birth']} \n" +
                f"Gender: {row['gender']} \n" +
                f"Email: {row['email']} \n" +
                f"Phone Number: {formatted_phone} \n" +
                f"Credit Card: {row['credit_card_no']} \n" +
                f"Emergency Contact: {row['emergency_contact_name']} \n" +
                f"Emergency Contact Phone: {formatted_phone_e} \n" +
                f"Insurance Policy Number: {row['policy_no']} \n" +
                f"_______________________________________________________ \n")
    else:
        print("Unable to view profile.")


def update_profile(connection, patient_id):
    '''
    This function allows the user to update their profile information. After creating their
    account, they need to add gender/phone_no/credit_card_no/emergency contact/
        emergency contact phone/policy_no
    '''
    
    # first have the procedure view the user's profile. 
    view = execute_procedure(connection, 'view_profile', (patient_id,), is_read_op=True)
    
    # capture old values and save in dict:
    values = dict()

    if view and len(view) > 0:
        row = view[0]
        values['gender_old'] = row.get('gender')
        values['phone_no_old'] = row.get('phone_no')
        
        unformatted_old_phone = values['phone_no_old']
        if unformatted_old_phone and len(unformatted_old_phone) == 11:
            formatted_old_phone = f"{unformatted_old_phone[0]}-{unformatted_old_phone[1:4]}-{unformatted_old_phone[4:7]}-{unformatted_old_phone[7:]}"
        else: 
            formatted_old_phone = "None"
        values['cc_old'] = row.get("credit_card_no")
        values['emerg_name_old'] = row.get("emergency_contact_name")
        values['emerg_no_old'] = row.get("emergency_contact_no")
        
        unformatted_emerg_phone_old = values['emerg_no_old']
        if unformatted_emerg_phone_old and len(unformatted_emerg_phone_old) == 11:
            formatted_emerg_phone_old = f"{unformatted_emerg_phone_old[0]}-{unformatted_emerg_phone_old[1:4]}-{unformatted_emerg_phone_old[4:7]}-{unformatted_emerg_phone_old[7:]}"
        else:
            formatted_emerg_phone_old = "None"
    
    print("Want to update your profile?\n\nGo ahead and enter through the fields until the field you want to update!\n")
    gender = input(f"Gender currently on file: {values['gender_old']} \nGender: ")
    if gender == "":
        gender = values['gender_old']

    temp = input(f"Your current number on file: {formatted_old_phone} \n" +
                 "Phone number (use format: x-xxx-xxx-xxxx): ")
    temp_no_hyphen = temp.split('-')
    phone_no = ''.join(temp_no_hyphen)
    if phone_no == "":
        phone_no = values['phone_no_old']

    credit_card = input(f"Your current credit card on file: {values['cc_old']} \n" +
                        "Credit card (must be valid 16 characters): " )
    if credit_card == "":
        credit_card = values['cc_old']

    emergency_contact_name = input(f"Your emergency contact on file: {values['emerg_name_old']} \n" +
                                   "Emergency contact: ")
    if emergency_contact_name == "":
        emergency_contact_name = values['emerg_name_old']

    temp = input(f"Your emergency contact's phone number on file: {formatted_emerg_phone_old} \n" +
                 "Emergency contact phone number (use format: x-xxx-xxx-xxxx): ")
    temp_no_hyphen = temp.split('-')
    emergency_contact_phone = ''.join(temp_no_hyphen)
    if emergency_contact_phone == "":
        emergency_contact_phone = values["emerg_no_old"]

    patient_id = patient_id

    try:
        # Execute the SQL procedure
        result = execute_procedure(
        connection,
        'update_account',
        (patient_id, gender, phone_no, credit_card, emergency_contact_name, emergency_contact_phone), is_read_op=False)   
        if result:
            print("\nProfile updated successfully.\n" +
                  f"_______________________________________________________ \n")
    except pymysql.Error as e:
            error_message = e.args[1]
            print("\nAn error occurred:", error_message +
                  f"_______________________________________________________ \n")


def update_insurance(connection, patient_id):
    '''
    This functions allows a user to update/add an insurance policy
    to their portal. When they create an account, their policy number will
    be NULL. They then need to actively add their insurance information to 
    the portal. This will call the DB procedure to update their insurance, 
    which will add a new tuple to the insurance_policy table.
    '''
    print("Want to update your insurance?\nWe just need some more information ... \n")
    insurance_policy = input("What is your policy number? (Should be 12 characters) ")
    insurance_provider = input("Who is your insurance provider? ")
    account_holder = input("Who is the account holder? ")

    try:
        # execute procedure
        result = execute_procedure(
        connection,
        'add_insurance_policy',
        (patient_id,insurance_policy, insurance_provider, account_holder), is_read_op=False
    )
        if result:
            print("Great, insurance updated successfully!")
    except pymysql.Error as e:
            error_message = e.args[1]
            print("An error occurred:", error_message)



def user_find_doctor(cnx):
    '''
    This function takes the user's connection with mysql server and
    lists all the specialties of doctors available in the database.
    The function then prompts the user to enter the specialty that they
    need and prints all doctors who have that specialty.
    '''
    while True:
        search_option = input("Would you like to search by\n" +
                                          "(1) Specialty or (2) Doctor Name?: " )
        
        if search_option == '1':
            # search by specialty
 
            cur = cnx.cursor()
            stmt_select = "select * from doctor"
 
            cur.execute(stmt_select)
            rows = cur.fetchall()
 
            specialties_in_db = []
            for row in rows:
                specialties_in_db.append(row['specialty'].lower())
 
            # close cursor
            cur.close()
 
            # print specialties in db
            print("These are the specialties offered by our doctors: \n")
            for spec in specialties_in_db:
                print(f"\t{spec.title()}")
 
            # ask user to select specialty
            specialty = input("\nPlease enter the type of doctor you want to find: ")
            specialty = specialty.lower()
 
            if specialty == 'exit':
                return None, None
 
            # if user input invalid, keep prompting until valid
            while specialty not in specialties_in_db:
                specialty = input("\nSorry! There are no doctors with that specialty.\n" +
                            "Is there a different doctor you might like to see? (or 'exit' to go back) ")
                specialty = specialty.lower()
 
                if specialty == 'exit':
                    break
 
            print(f"\nYour choice is: {specialty.title()}\n")
            return specialty, None
    
        elif search_option == '2':
            # search by specialty
 
            cur = cnx.cursor()
            stmt_select = "select * from doctor"
 
            cur.execute(stmt_select)
            rows = cur.fetchall()
            
            # list comprehension to allow for partial name search
            doctors_in_db = [name for row in rows for name in row['full_name'].lower().split()]
                
            # close cursor
            cur.close()
  
            # search by doctor name
            doctor_name = input("Enter the doctor's first or last name: ")
            doctor_name = doctor_name.lower()
            if doctor_name.lower() == 'exit':
                return None, None
            
            # if user input invalid, keep prompting until valid
            while doctor_name not in doctors_in_db:
                doctor_name = input("\nSorry! There are no doctors with that name.\n" +
                            "Is there a different doctor you might like to see? (or 'exit' to go back) ")
                doctor_name = doctor_name.lower()
 
                if doctor_name == 'exit':
                    break
 
            print(f"\nYour choice is: {doctor_name.title()}\n")
            return None, doctor_name
        
        else:
            print("Invalid option. Please try again.")



def find_doc(cnx, specialty, doctor_name):
    '''
    '''
    result = execute_procedure(cnx, 'find_doctor', (specialty, doctor_name), is_read_op=True)
    if result and len(result) > 0:
        print("\nDoctors in our network: ")
        for row in result:
            print(f"NPI: {row['npi']} \n" +
                    f"Doctor's Name: {row['full_name']} \n" +
                    f"Photo: {row['photo']} \n" +
                    f"Gender: {row['doctor_gender']} \n" +
                    f"Provider Type: {row['provider_type']} \n" +
                    f"Specialty: {row['specialty']} \n" +
                    f"Medical Office: {row['office_name']} \n" +
                    f"Average Star Rating: {row['avg_rating']} \n")
        print(f"_______________________________________________________ \n\n")
    else:
        print("Unable to find doctors. \n" +
              f"_______________________________________________________ \n")


def show_doctors_db(cnx):
    '''
    This function takes the user's connection with mysql server and 
    lists all the doctors in the database. This allows the user to 
    type a doctor's name to read their reviews or view a visualization
    of all doctor reviews.
    '''
    cur = cnx.cursor()
    stmt_select = "SELECT * FROM doctor"
    cur.execute(stmt_select)
    rows = cur.fetchall()

    doctors_in_db = []
    for row in rows:
        doctors_in_db.append(row['full_name'].lower())

    # close cursor
    cur.close()

    # print doctors in db
    print("These are the doctors in our portal: \n")
    for doc in doctors_in_db:
        print(f"\t{doc.title()}")

    while True:
        # Ask user for action
        action = input("\nWould you like to (1) view a specific doctor's reviews or (2) visualize all reviews? (Type '1' or '2' or 'exit' to go back): ")

        if action == '1':
            # Process for viewing specific doctor's reviews
            doctor = input("Whose reviews would you like to see?: ").lower()
            while doctor not in doctors_in_db and doctor != 'exit':
                doctor = input("\nSorry! There are no doctors with that name.\n" +
                               "Is there a different doctor whose reviews you'd like to see? (or 'exit' to go back) ").lower()
            if doctor != 'exit':
                return doctor

        elif action == '2':
            # visualizing all reviews
            visualize_doctor_reviews(cnx)
            # After visualization, prompt to return to the main menu or continue
            input("Press Enter to return to the main menu.")
            doctor = 'exit'
            return doctor

        elif action == 'exit':
            print("Returning to main menu.")
            doctor = 'exit'
            return doctor


def view_reviews(cnx, doctor): # update for partial reviews
    '''
    This functions takes the connection to the mysql server and the doctor
    input by the user and runs a procedure stored in the database to print out all
    reviews of that doctor in the db. 
    The function will also extract the doctor's average star rating by using a
    stored function from the database (using a multi-table join) and display it.
    Args:
    - cnx: SQL connection
    - doctor: doctor whose reviews should be displayed
    '''
    
    result = execute_procedure(cnx, 'view_reviews', (doctor,), is_read_op=True)
    
    # create new cursor to display avg_star_rating from DB function:
    cur = cnx.cursor()
    temp = cur.execute("SELECT doc_avg_star_rating(%s)", (doctor,))
    temp = cur.fetchone()
    avg_star_rating = list(temp.values())[0] # extracting value from dictionary
    if avg_star_rating is not None:
        print(f"\nDoctor {doctor.title()} has an average star rating of: {avg_star_rating}")
    elif doctor == 'exit':
        print("")
    else:
        print(f"\nDoctor {doctor.title()} has no star rating yet")

    if result and len(result) > 0:
        print(f"\nReviews for: {doctor.title()} \n")
        for row in result:
            print(f"Review ID: {row['review_id']} \n" +
                    f"NPI: {row['npi']} \n" +
                    f"Doctor's Name: {row['full_name']} \n" +
                    f"Star Rating: {row['star_rating']} \n" +
                    f"Comments: {row['comments']} \n" +
                    f"Review Date: {row['review_date']} \n")
        print(f"_______________________________________________________ \n\n")
    elif doctor == 'exit':
        print("")
    else:
        print(f"\nNo reviews found for: {doctor.title()}\n" +
              f"_______________________________________________________ \n")
        

def write_review(cnx, patient_id):
    '''
    This function allows the user to create a review for a doctor they has seen
    by appointments.
    '''

    cur = cnx.cursor()
    # potential multi-join to SQL side?
    stmt_select = '''
        SELECT DISTINCT d.npi, d.full_name
        FROM doctor AS d
        JOIN appointment AS a 
            ON d.npi = a.npi
        JOIN patient_has_doctor AS phd 
            ON d.npi = phd.npi
        WHERE phd.patient_id = %s
        '''
    cur.execute(stmt_select, (patient_id,))
    rows = cur.fetchall()

    if not rows:
        print("You have not seen a doctor in any previous appointments.")
        print(f"_______________________________________________________ \n")
        print("\nReturning to the main menu.\n")
        print(f"_______________________________________________________ \n")
        return

    # store docs in db patient has seen
    doctors_in_db = []
    print("These are the doctors you have had an appointment with: \n")
    for row in rows:
        doctor_info = f'NPI: {row["npi"]} | Doctor: {row["full_name"]}'
        doctors_in_db.append((row["full_name"]).lower())
        print(doctor_info)
    print(f"_______________________________________________________ \n")

    # validate doctor's name
    while True:
        doctor_full_name = input("Doctor's Full Name: ").strip().lower()
        if doctor_full_name in doctors_in_db:
            break  # valid doctor name found
        else:
            exit = input("\nInvalid doctor name. Would you like to enter your doctor's name again? \n" +
                              "Press enter continue, or 'exit' to return to the main menu: ").strip().lower()
            print(f"_______________________________________________________ \n")
            
            if exit == 'exit':
                print("\nReturning to the main menu.\n")
                print(f"_______________________________________________________ \n")
                return

    # validate star rating
    star_rating = 0
    while star_rating not in range(1, 6):
        try:
            star_rating = int(input("Star Rating (1-5): "))
            if star_rating not in range(1, 6):
                print("Invalid input. Please enter a star rating between 1 and 5.")
        except ValueError:
            print("Invalid input. Please enter a number between 1 and 5.")
    comments = input("Comments: ")
    review_date = datetime.datetime.now().strftime("%Y-%m-%d")  # 'YYYY-MM-DD' format timestamp
    
    try:
        with cnx.cursor() as cursor:
            params = [patient_id, doctor_full_name, star_rating, comments, review_date]
            cursor.callproc('create_review', params)
            cnx.commit()
            print("Review created successfully! \n" +
                  f"_______________________________________________________ \n")

    except pymysql.Error as e:
        error_message = e.args[1]
        print("An error occurred:", error_message)


def view_patient_reviews(cnx, patient_id):
    '''
    This function is a helper to retrieve and view all of the patient's reviews
    they have left for doctors, if any.
    '''
    try:
        with cnx.cursor() as cursor:
            cursor.callproc('get_patient_reviews', [patient_id])
            reviews = cursor.fetchall()
            if reviews:
                print("These are the reviews you've left for your doctors: \n")
                for review in reviews:
                    print(f"Review ID: {review['review_id']} \n" +
                          f"Star Rating: {review['star_rating']} \n" +
                          f"Date: {review['review_date']} \n" +
                          f"Comments: {review['comments']} \n" +
                          f"_______________________________________________________ \n")
                return True
                    
            else:
                print("No reviews found were found. ")
                return False
    except pymysql.Error as e:
        error_message = e.args[1]
        print("\nAn error occurred: ", error_message)
        print(f"_______________________________________________________ \n")

def delete_review(cnx, patient_id):
    '''
    This function displays reviews that have been left by a patient, and allows
    the patient to select a review to delete, if any.
    '''
    result = view_patient_reviews(cnx, patient_id)
    if result == True:
        while True:
            review_id_input = input("Enter Review ID to delete, \nor type 'exit' to return to the main menu: ").strip()

            if review_id_input.lower() == 'exit':
                print("\nReturning to the main menu.\n")
                print(f"_______________________________________________________ \n")
                break

            try:
                review_id_input = int(review_id_input)
                with cnx.cursor() as cursor:
                    params = [patient_id, review_id_input]
                    cursor.callproc('delete_review', params)
                    cnx.commit()
                    print("Review deleted successfully! \n")
                    print(f"_______________________________________________________ \n")
                    print("\nReturning to the main menu.\n")
                    break
            except ValueError:
                print("\nInvalid input. Please enter a numeric Review ID.")
                print(f"\n_______________________________________________________ \n")
            except pymysql.Error as e:
                error_message = e.args[1]
                print("\nAn error occurred:", error_message)
                print(f"\n_______________________________________________________ \n")
    
    elif result == False:
        print("Please leave a review for a doctor you've had an appointment with, before attempting to delete a review.")
        print(f"_______________________________________________________ \n")
        print("\nReturning to the main menu.\n")
        return
    
def view_appointments(cnx, patient_id): 
    '''
        This function takes the user's connection with mysql server and 
        the patient id and calls the view appointments procedure in MySQL.
        This will print all appointments for the current patient user.
        It returns apt_id_only set so that it can be used to validate appointment
        IDs in reschedule and cancel appointment functions.   
    '''
    try:
        result = execute_procedure(cnx, 'view_appointments', (patient_id,), is_read_op=True)
        appointments = []
        apt_id_only = set()
        if not result:
            print("Looks like you don't have any appointments yet!\n")
            print("Please select option 9 from the main menu to schedule an appointment.\n")
            return apt_id_only
        else:  
            for row in result:
                apt_info = f'Apt ID: {row["appointment_id"]} | Appointment Time: {row["appointment_date_time"]}| Doctor Name: {row["full_name"]}'
                appointments.append(apt_info)

                # extract and store the apt IDs in the set
                appointment = row["appointment_id"]
                apt_id_only.add(appointment)

            # print appointments
            print("Here are your appointments: \n")
            for apt in appointments:
                print(apt)
                print(f"_______________________________________________________ \n")
        return apt_id_only

    except pymysql.Error as e:
        error_message = e.args[1]
        print("An error occurred:", error_message)
    
def show_doctors_npi_to_schedule(cnx):
        '''
        This function takes the user's connection with mysql server and 
        lists all the doctors in the database. This allows the user to 
        find a doctor's NPI to schedule an appointment. This function prompts
        the user to enter in the NPI number of the doctor they would like to 
        schedule with after being provided with the list of doctors in the network.
        The function validates that the NPI entered corresponds to a valid doctor before
        returning the doctor to be used in the schedule appointment function. 
        Helper function to schedule appointment. 
        '''
        cur = cnx.cursor()
        stmt_select = "select * from doctor"

        cur.execute(stmt_select)
        rows = cur.fetchall()

        npis_only = set() 
        doctors_in_db = []
        for row in rows:
            doctor_info = f'NPI: {row["npi"]} | Full Name: {row["full_name"]}'
            doctors_in_db.append(doctor_info)

            # extract and store the NPI in the set
            npi = row["npi"]
            npis_only.add(npi)

        # close cursor
        cur.close()

        # print doctors in db
        print("These are the doctors in our portal: \n")
        for doc in doctors_in_db:
            print(doc)

        # ask user to enter NPI
        doctor = input("\nWhich doctor would you like to schedule with? Please enter the NPI: ")

        # if NPI input invalid, keep prompting until valid 
        while doctor not in npis_only:
            print("\nSorry! There are no doctors with that NPI.\n")
            # ask the user if they want to try again
            doctor = input("Is there a different doctor who you would like to schedule with? Please enter the NPI (or 'exit' to go back): ").lower()
            doctor = doctor.lower()
            if doctor == 'exit':
                break
        return doctor

def schedule_appointment(cnx, doctor, patient_id):
    '''
    This functions takes the connection to the mysql server, the doctor
    input by the user, and the patient ID and runs a procedure stored in the 
    database to collect necessary information to schedule an appointment.
    Date and time formatting is validated prior to executing the procedure in addition 
    to the apointment type. 
    Appointments cannot be in the past, they cannot conflict with existing patient appointments, 
    they cannot conflict with an appointment that the doctor already has, it must be between 
    8AM - 5PM, and it must be on the top of the hour or half hour. These checks are performed in
    the SQL procedure.  
    '''
    if doctor == 'exit':
        return
    # validation for date input
    date_pattern = re.compile(r'^\d{4}-\d{2}-\d{2}$')
    while True:
        apt_date = input("Please enter the date that you would like to schedule (YYYY-MM-DD): \n")
        if date_pattern.match(apt_date):
            break
        else:
            print("Invalid date format. Please enter a valid date.")

    # validation for time input
    time_pattern = re.compile(r'^[0-2][0-9]:[0-5][0-9]:[0-5][0-9]$')
    while True:
        apt_time = input("Please enter the time that you would like to schedule (Military - HH:MM:SS): \n")
        if time_pattern.match(apt_time):
            break
        else:
            print("Invalid time format. Please enter a valid time.")
    apt_datetime = apt_date + " " + apt_time
    # display menu for appointment types
    print("\nPlease select the appointment type:")
    print("1. Office Visit")
    print("2. Routine Checkup")
    print("3. Specialist Consultation")

    # map the user's choice to the actual appointment type
    appointment_types = {1: 'office visit', 2: 'routine checkup', 3: 'specialist consultation'}

    while True:
        # get user input for appointment type
        choice = input("Enter the number corresponding to your choice: ")

        # check if the user's choice is valid
        if choice.isdigit() and 1 <= int(choice) <= len(appointment_types):
            apt_type = appointment_types[int(choice)]
            break  # exit the loop if a valid choice is entered
        else:
            print("Invalid choice. Please enter a valid number.")
    try:
        result = execute_procedure(cnx, 'schedule_appointment', (apt_datetime, apt_type, patient_id, doctor), is_read_op=False)
        if result:
            print("Appointment successfully scheduled on", apt_date, "at", apt_time, "!")
    except pymysql.Error as e:
            error_message = e.args[1]
            print("\nAn error occurred:", error_message)

    
def get_apt_id(apt_id_only):
    '''
    Helper function that takes in the set returned by the view_appointments
    function to prompt the user to enter in a user ID of the appointment they
    would like to modify. The input is then validated to ensure the ID belongs to
    one of their existing appointments. The apt_id is then returned to be utilized
    in both the reschedule and cancel appointment functions.  
    '''
    if not apt_id_only:
        return
    else:
        apt_id = 0
        while True:
            try:
                user_input = input("Please enter Appointment ID of the appointment you would like to modify (or 'exit' to go back): ")
                if user_input.lower() == 'exit':
                    apt_id = 'exit'
                    return apt_id 
                apt_id = int(user_input)
                if apt_id in apt_id_only:
                    break  # exit the loop if the input is a valid ID
                else:
                    print("\nSorry! There are no appointments with that ID.")
            except ValueError:
                print("\nInvalid input. Appointment ID must be a number.")
        return apt_id    
      
    

def reschedule_appointment(cnx, apt_id):
    '''
    This functions takes the connection to the mysql server and the apt id
    of the appointment they would like to reschedule. The get_apt_id is called within main
    to first prompt the user to enter in a valid apt ID. Once a valid ID is entered, 
    they must enter in a valid date and time to reschedule the appointment to. 
    Date and time formatting is validated prior to executing the procedure.
    Appointments cannot be in the past, they cannot conflict with existing patient appointments, 
    they cannot conflict with an appointment that the doctor already has, it must be between 
    8AM - 5PM, and it must be on the top of the hour or half hour. These checks are performed in
    the SQL procedure. 
    '''
    if apt_id is None or apt_id == 'exit':
        return
    # Validation for date input
    date_pattern = re.compile(r'^\d{4}-\d{2}-\d{2}$')
    while True:
        apt_date = input("Please enter the date that you would like to schedule (YYYY-MM-DD): \n")
        if date_pattern.match(apt_date):
            break
        else:
            print("Invalid date format. Please enter a valid date.")

    # Validation for time input
    time_pattern = re.compile(r'^[0-2][0-9]:[0-5][0-9]:[0-5][0-9]$')
    while True:
        apt_time = input("Please enter the time that you would like to schedule (Military - HH:MM:SS): \n")
        if time_pattern.match(apt_time):
            break
        else:
            print("Invalid time format. Please enter a valid time.")
    apt_datetime = apt_date + " " + apt_time

    try:
        result = execute_procedure(cnx, 'reschedule_appointment', (apt_id, apt_datetime,), is_read_op=False)
        if result:
            print("\nAppointment successfully rescheduled on", apt_date, "at", apt_time, "!")

    except pymysql.Error as e:
        error_message = e.args[1]
        print("\nAn error occurred:", error_message)

def cancel_appointment(cnx, patient_id ,apt_id):
    '''
    This functions takes the connection to the mysql server, patient id, and the apt id
    of the appointment they would like to cancel. The get_apt_id is called within main
    to first prompt the user to enter in a valid apt ID. Once a valid ID is entered, 
    the appointment will be cancelled.  
    '''
    if apt_id is None or apt_id == 'exit':
        return
    try:
        result = execute_procedure(cnx, 'delete_appointment', (patient_id, apt_id,), is_read_op=False)
        if result:
            print("Appointment was successfully was successfully deleted.")

    except pymysql.Error as e:
        error_message = e.args[1]
        print("\nAn error occurred:", error_message)


def view_rx(cnx, patient_id):
    '''
    This function allows the user to view any prescriptions they have in their portal
    '''
    result = execute_procedure(cnx, 'view_rx', (patient_id,), is_read_op=True)
    if result and len(result) > 0:
        print("\nYour prescriptions:")
        for row in result:
            for key, value in row.items():
                print(f"{key}: {value}")
            print() # add newline between
    elif len(result) == 0:
        print("\nLooks like you don't have any prescriptions yet!")
    else:
        print("\nUnable to find any prescriptions.")


def refill_rx(cnx, patient_id):
    '''
    This function allows the user to view all their prescriptions, see how many refills they
    have remaining, and choose to refill a prescription based on the rx_id displayed in the
    result set
    Args:
    - cnx
    - patient_id
    - rx_id
    Pre-conditions:
    - user must have prescriptions to refill, otherwise break, go back to menu
    - user must enter valid rx_id of a prescription displayed in their result set
    - user must have existing refills for the rx_id
    '''
    # first view all the user's prescriptions:
    view_rx(cnx, patient_id)

    # if user has no prescriptions, go back to menu, don't prompt them to refill any:
    user_rxs = execute_procedure(cnx, 'view_rx', (patient_id,), is_read_op=True)
    if len(user_rxs) == 0:
        print("\nIf you need a new prescription, please make an appointment with one of our doctors.\n")
        return None
    
    rx = input("Which prescription would you like to refill? Enter the rx_id (or 'exit' to go back:) ")
    
    # ensure user enters number as rx_id to refill
    while True:
        try:
            rx = int(rx)
            break # break out of while loop and return rx if conversion successful
        except ValueError: 
            rx = input("Oops, something went wrong! Please enter a valid rx_id (number" +
                        "or 'exit' to go back): ")
            if rx == 'exit':
                break
        
    # allow them to go back to main menu
    if rx == 'exit':
        return None
    
    # execute refill_rx procedure
    try:
        result = execute_procedure(cnx, 'refill_rx', (patient_id, rx), is_read_op=False)
        
        if result:
            # show user how many refills remaining:
            temp = execute_procedure(cnx, 'view_rx', (patient_id,), is_read_op=True)
            
            refills = [row['patient_refill_count'] for row in temp if row['rx_id'] == rx]

            if refills:
                print(f"\nPrescription refilled! We will send the prescription to the pharmacy on file!\n" +
                        f"\nRefills remaining: {refills[0]}")
                        
        elif refills[0] == 0:
            print(f"\nNo refills for that prescription remaining." +
                    "\nMake another appointment with the doctor if you need more!\n")
        else:
            print("\nSomething went wrong, prescription unable to be refilled at this time.")
    
    except pymysql.Error as e:
        error_message = e.args[1]
        print("\nAn error occurred:", error_message)
        print("\nIf you need a new prescription or more refills, please make an appointment " +
              "with your doctor today!")


def view_bills(cnx, patient_id):
    '''
    This functions allows users to view any bils they have in their portal.
    '''
    result = execute_procedure(cnx, 'view_bills', (patient_id,), is_read_op=True)
    if result is not None:
        if len(result) > 0:
            print(f"\n_______________________________________________________ \n")
            print("\nYour billing history: \n")
            for row in result:
                for key, value in row.items():
                    print(f"{key}: {value}")
                print(f"\n_______________________________________________________ \n")
            return True, result
        elif len(result) == 0:
            print("\nLooks like you don't have any bills yet!")
            print(f"\n_______________________________________________________ \n")
            return False, []
        else:
            print("\nUnable to find any bills on your account.")
            print(f"\n_______________________________________________________ \n")
            return False, []


def pay_bill(cnx, patient_id):
    '''
    This function allows a user to select a bill, if any, in order to make a
    payment amount on the bill.
    '''
    result, bills = view_bills(cnx, patient_id)
    if result == True:
        bill_ids = [bill['bill_id'] for bill in bills] 
        
        while True:
            bill_id = input("Select a bill ID to pay, \nor type 'exit' to return to the main menu: ").strip()
            if bill_id.lower() == 'exit':
                print("\nReturning to the main menu.\n")
                print(f"_______________________________________________________ \n")
                return
            
            payment_amount = input("Enter amount to pay (xx.xx), \nor type 'exit' to return to the main menu: ").strip()
            if payment_amount.lower() == 'exit':
                print("\nReturning to the main menu.\n")
                print(f"_______________________________________________________ \n")
                return
            
            try:
                bill_id = int(bill_id)
                payment_amount = float(payment_amount)
                
                # ensure patient only pays their own bills
                if bill_id not in bill_ids:
                    print("\nInvalid bill ID. Please select a valid bill ID.")
                    print(f"\n_______________________________________________________ \n")
                    continue

                with cnx.cursor() as cursor:
                    cursor.callproc('pay_bill', [patient_id, bill_id, payment_amount])
                    cnx.commit()
                    print("\nPayment accepted successfully! \n")
                    break
            except ValueError:
                print("\nInvalid input. Please enter a numeric amounts for bill ID and payment amounts.")
                print(f"\n_______________________________________________________ \n")
            except pymysql.Error as e:
                error_message = e.args[1]
                print("\nAn error occurred:", error_message)
                print(f"\n_______________________________________________________ \n")
                
    elif result == False: # no bills yet
        print("\nReturning to the main menu.\n")
        return
    # leave this box, as it is a reprint after a bill has been paid
    print("\t\t\t\t╔══════════════════════════════════════╗")
    print("\t\t\t\t║                Bills                 ║")
    print("\t\t\t\t╚══════════════════════════════════════╝ \n")
    view_bills(cnx, patient_id)

    current_bills = execute_procedure(cnx, 'view_bills', [patient_id], is_read_op=True)
    for bill in current_bills:
        print(f"Bill ID: {bill['bill_id']}, Balance Remaining: {bill['balance_remaining']} \n")
        
def colors_from_values(values, palette_name):
    '''
    Helper function to visualize_doctor_reviews
    '''
    # normalize the values to range [0, 1]
    min_val = min(values)
    max_val = max(values)
    normalized = [(val - min_val) / (max_val - min_val) for val in values]
    # convert to indices and get colors
    palette = sns.color_palette(palette_name, len(values))
    return [palette[int(round(norm * (len(values) - 1)))] for norm in normalized]

def visualize_doctor_reviews(cnx):
    '''
    This function allows for a data visualization of the doctor's average star
    rating from reviews left by patients. It is an alternative view for patients
    who would like to see a visual representation extended from "View Doctor Reviews".
    '''
    # SQL query to calculate average star rating for each doctor
    query = '''
        SELECT d.full_name, AVG(r.star_rating) as avg_rating
        FROM doctor AS d
        JOIN review AS r ON d.npi = r.npi
        GROUP BY d.npi
    '''

    try:
        with cnx.cursor() as cursor:
            cursor.execute(query)
            result = cursor.fetchall()

            # Preparing data for plotting
            doctors = [row['full_name'] for row in result]
            avg_ratings = [float(row['avg_rating']) for row in result]

            sns.set_style("darkgrid", {"grid.color": "white"})

            plt.figure(figsize=(5, 5))

            # Creating the bar chart with dynamic colors and skinnier bars
            colors = colors_from_values(avg_ratings, "YlOrRd")
            bar_width = 0.4  # Adjust this value to make bars skinnier
            plt.bar(doctors, avg_ratings, color=colors, width=bar_width)

            # Adding data labels to each bar
            for i, bar in enumerate(plt.gca().patches):
                plt.text(bar.get_x() + bar.get_width() / 2, bar.get_height(), round(avg_ratings[i], 2),
                         va='bottom', ha='center', fontsize=9)

            # Setting labels and title
            plt.xlabel('Doctor', fontsize=11)
            plt.ylabel('Average Star Rating', fontsize=11)
            plt.title('Average Doctor Reviews', fontsize=14)
            plt.ylim(0, 5)  # Assuming star ratings are out of 5
            plt.xticks(rotation=45, ha='right', fontsize=10)

            # Displaying the plot
            plt.tight_layout()
            plt.show()

    except pymysql.Error as e:
        print(f"An error occurred while fetching data: {e}")

def view_patients(cnx, patient_id):
    '''
    Admin function - This function allows the portal admin to view all patients
    in the database.
    '''
    try:
        result = execute_procedure(cnx, 'view_all_patients', (patient_id,), is_read_op=True)
        patient_id_only = set()
        if result and len(result) > 0:
            print("Patients in database: \n")
            for row in result:
                for key, value in row.items():
                    print(f"{key}: {value}")
                    p_id = row["patient_id"]
                    patient_id_only.add(p_id)
                print(f"_______________________________________________________ \n")
                print()
            return patient_id_only
        else:
            print("No patients found.")
            return patient_id_only

    except pymysql.Error as e:
        error_message = e.args[1]
        print("\nAn error occurred:", error_message)

def get_patient_id(patient_id_only):
    '''
    Helper function that takes in the set returned by the view_patients
    function to prompt the admin to enter in a user ID of the patient they
    would like to modify. The input is then validated to ensure the ID belongs to
    an existing patient. The p_id is then returned to be utilized
    in both the update and delete patient functions.  
    '''
    if not patient_id_only:
        return
    else:
        p_id = 0
        while True:
            try:
                user_input = input("Please enter Patient ID of the patient you would like to modify (or 'exit' to go back): ")
                if user_input.lower() == 'exit':
                    p_id = 'exit'
                    return p_id 
                p_id = int(user_input)
                if p_id in patient_id_only:
                    break  # exit the loop if the input is a valid ID
                else:
                    print("\nSorry! There are no patients with that ID.")
            except ValueError:
                print("\nInvalid input. Patient ID must be a number.")
        return p_id

def update_patient_username(cnx, patient_id, p_id):
    '''
    Admin function - This function allows the portal admin to edit the patient's 
    username. Validation on the patient id is done in the get_patient_id 
    helper function. Must be a valid email format and cannot be the same 
    as an existing email in the database. Admin cannot change their own username. 
    '''
    if p_id is None or p_id == 'exit':
        return
    p_email = ''
    try: 
        user_input = input("Please enter new patient email (or 'exit' to go back): ")
        if user_input.lower() == 'exit':
            return 
        else:
            p_email = user_input
            result = execute_procedure(cnx, 'update_patient_username', (patient_id, p_id, p_email), is_read_op=False)
            if result:
                print("Patient email was successfully updated.")

    except pymysql.Error as e:
        error_message = e.args[1]
        print("\nAn error occurred:", error_message)   

def update_patient_password(cnx, patient_id, p_id):
    '''
    Admin function - This function allows the portal admin to edit the patient's 
    password. Validation on the patient id is done in the get_patient_id 
    helper function. Must be a 6-12 characters. Admin cannot change their own password. 
    '''
    if p_id is None or p_id == 'exit':
        return
    p_password = ''
    try: 
        user_input = input("Please enter new patient password (or 'exit' to go back): ")
        if user_input.lower() == 'exit':
            p_password = 'exit'
            return 
        else:
            p_password = user_input
            result = execute_procedure(cnx, 'update_patient_password', (patient_id, p_id, p_password), is_read_op=False)
            if result:
                print("Patient password was successfully updated.")

    except pymysql.Error as e:
        error_message = e.args[1]
        print("\nAn error occurred:", error_message) 


def delete_patient(cnx, patient_id, p_id):
    '''
    Admin function - This function allows the portal admin to delete the patient
    from the database. This would come from a specific request from the patient. Validation 
    on the patient id is done in the get_patient_id helper function. Admin cannot 
    delete themselves. 
    '''
    if p_id is None or p_id == 'exit':
        return
    try:
        result = execute_procedure(cnx, 'delete_patient', (patient_id, p_id,), is_read_op=False)
        if result:
            print("Patient was successfully deleted.")

    except pymysql.Error as e:
        error_message = e.args[1]
        print("\nAn error occurred:", error_message)
    

def view_doctors(cnx):
    '''
    Admin function - This function allows the portal admin to view all doctors
    in the database.
    '''
    try:
        npi_only = set()
        result = execute_procedure(cnx, 'view_all_doctors', (), is_read_op=True)
        if result and len(result) > 0:
            print("Doctors in database: \n")
            for row in result:
                for key, value in row.items():
                    print(f"{key}: {value}")
                    npi = row["npi"]
                    npi_only.add(npi)
                print(f"_______________________________________________________ \n")  
                print()
            return npi_only
        else:
            print("No doctors found.")
            return npi_only

    except pymysql.Error as e:
        error_message = e.args[1]
        print("\nAn error occurred:", error_message)

def get_npi(npi_only):
    '''
    Helper function that takes in the set returned by the view_doctors
    function to prompt the admin to enter in NPI of the doctor they
    would like to delete. The input is then validated to ensure the NPI belongs to
    an existing doctor. The NPI is then returned to be utilized
    in the delete doctor function.  
    '''
    if not npi_only:
        return
    else:
        npi = ''
        while True:
            user_input = input("Please enter NPI of the doctor you would like to delete (or 'exit' to go back): ")
            if user_input.lower() == 'exit':
                npi = 'exit'
                return npi 
            if user_input in npi_only:
                npi = user_input
                break  # exit the loop if the input is a valid npi
            else:
                print("\nSorry! There are no doctors with that NPI.")
        return npi

def add_doctor(cnx):
    '''
    Admin function - This function allows the portal admin to add a doctor
    to the database. Admin has all required information to add a new doctor. Validation 
    on the NPI, full name, gender, provider type, specialty, and office name is 
    added to make sure field inputs are correct and not blank. Additional validation 
    in SQL.
    '''
    # validation for NPI
    npi_pattern = re.compile(r'^\d{10}$')
    while True:
        npi = input("Please enter the doctor's NPI (10 digits): \n")
        if npi_pattern.match(npi):
            break
        else:
            print("Invalid NPI format. Please enter a 10-digit number.")

    # validation for full name
    while True:
        full_name = input("Please enter the doctor's full name: \n")
        if full_name:
            break
        else:
            print("Full name cannot be empty. Please enter a valid name.")

    # validation for gender
    gender_options = ['male', 'female', 'other']
    while True:
        gender = input("Please enter the doctor's gender (male/female/other): \n").lower()
        if gender in gender_options:
            break
        else:
            print("Invalid gender. Please enter 'male', 'female', or 'other'.")

    # validation for provider type
    provider_options = ['MD', 'DO', 'NP', 'PA']
    while True:
        provider_type = input("Please enter the doctor's provider type (MD/DO/NP/PA): \n").upper()
        if provider_type in provider_options:
            break
        else:
            print("Invalid provider type. Please enter 'MD', 'DO', 'NP', or 'PA'.")

    # validation for specialty
    while True:
        specialty = input("Please enter the doctor's specialty: \n")
        if specialty:
            break
        else:
            print("Specialty cannot be empty. Please enter a valid specialty.")

    # validation for office name
    while True:
        office_name = input("Please enter the doctor's office name: \n")
        if office_name:
            break
        else:
            print("Office name cannot be empty. Please enter a valid office name.")

    try:
        result = execute_procedure(cnx, 'create_doctor', (npi, full_name, gender, provider_type, specialty, office_name), is_read_op=False)
        if result:
            print("Doctor successfully added!\n")
    except pymysql.Error as e:
        error_message = e.args[1]
        print("\nAn error occurred:", error_message)

def delete_doctor(cnx, npi):
    '''
    Admin function - This function allows the portal admin to delete a doctor
    from the database. This would come from a specific request from a medical office. 
    Validation on the NPI is done in the get_npi helper function.
    '''
    if npi is None or npi == 'exit':
        return
    try:
        result = execute_procedure(cnx, 'delete_doctor', (npi,), is_read_op=False)
        if result:
            print("Doctor was successfully deleted.")

    except pymysql.Error as e:
        error_message = e.args[1]
        print("\nAn error occurred:", error_message)

def main():
    '''
    This function is the main driver of the application.
    '''

    try: 
        cnx = create_connection()
        patient_id = 0 

        start = False
        while not start:
            homepage = home_page(cnx)
            if homepage == '1':
                print("\t\t\t\t╔══════════════════════════════════════╗")
                print("\t\t\t\t║            Create Account            ║")
                print("\t\t\t\t╚══════════════════════════════════════╝ \n")
                patient_id = create_account(cnx)
                if patient_id:
                    start = True
            elif homepage == '2':
                print("\t\t\t\t╔══════════════════════════════════════╗")
                print("\t\t\t\t║                Log-in                ║")
                print("\t\t\t\t╚══════════════════════════════════════╝ \n")
                patient_id = login(cnx)
                if patient_id:
                    start = True
            elif homepage.lower() == 'q' or homepage.lower() == 'quit':
                print("Exiting the HealthEase Patient Portal.")
                start = False
                return
        
        while start:
            is_admin = check_admin_status(cnx, patient_id)
            if is_admin:
                admin_choice = admin_main_menu() # admin specific functions
                if admin_choice == '1':
                    print("\t\t\t\t╔══════════════════════════════════╗")
                    print("\t\t\t\t║           View Patients          ║")
                    print("\t\t\t\t╚══════════════════════════════════╝ \n")
                    if patient_id:
                        view_patients(cnx, patient_id)
                elif admin_choice == '2':
                    print("\t\t\t\t╔══════════════════════════════════╗")
                    print("\t\t\t\t║      Update Patient Username     ║")
                    print("\t\t\t\t╚══════════════════════════════════╝ \n")
                    if patient_id:
                        patient_id_only = view_patients(cnx, patient_id)
                        p_id = get_patient_id(patient_id_only)
                        update_patient_username(cnx, patient_id, p_id)
                elif admin_choice == '3':
                    print("\t\t\t\t╔══════════════════════════════════╗")
                    print("\t\t\t\t║      Update Patient Password     ║")
                    print("\t\t\t\t╚══════════════════════════════════╝ \n")
                    if patient_id:
                        patient_id_only = view_patients(cnx, patient_id)
                        p_id = get_patient_id(patient_id_only)
                        update_patient_password(cnx, patient_id, p_id)
                elif admin_choice == '4':
                    print("\t\t\t\t╔══════════════════════════════════╗")
                    print("\t\t\t\t║          Delete Patient          ║")
                    print("\t\t\t\t╚══════════════════════════════════╝ \n")
                    if patient_id:
                        patient_id_only = view_patients(cnx, patient_id)
                        p_id = get_patient_id(patient_id_only)
                        delete_patient(cnx, patient_id, p_id)
                elif admin_choice == '5':
                    print("\t\t\t\t╔══════════════════════════════════╗")
                    print("\t\t\t\t║           View Doctors           ║")
                    print("\t\t\t\t╚══════════════════════════════════╝ \n")
                    if patient_id:
                        view_doctors(cnx)
                elif admin_choice == '6':
                    print("\t\t\t\t╔══════════════════════════════════╗")
                    print("\t\t\t\t║            Add Doctors           ║")
                    print("\t\t\t\t╚══════════════════════════════════╝ \n")
                    if patient_id:
                        add_doctor(cnx)
                elif admin_choice == '7':
                    print("\t\t\t\t╔══════════════════════════════════╗")
                    print("\t\t\t\t║          Delete Doctor           ║")
                    print("\t\t\t\t╚══════════════════════════════════╝ \n")
                    if patient_id:
                        npi_only = view_doctors(cnx)
                        npi = get_npi(npi_only)
                        delete_doctor(cnx, npi)
                elif admin_choice == 'Q' or admin_choice == 'q':
                    print("Exiting the admin portal...")
                    break
                else:
                    print("Invalid admin option. Please try again.")
            else:

                choice = main_menu()
                if choice == '1':
                    print("\t\t\t\t╔══════════════════════════════════════╗")
                    print("\t\t\t\t║             Your Profile             ║")
                    print("\t\t\t\t╚══════════════════════════════════════╝ \n")
                    if patient_id:
                        view_profile(cnx, patient_id)
                    else:
                        print("Please log-in or create an account first.")
                elif choice == '2':
                    print("\t\t\t\t╔══════════════════════════════════════╗")
                    print("\t\t\t\t║          Update Your Profile         ║")
                    print("\t\t\t\t╚══════════════════════════════════════╝ \n")
                    if patient_id: 
                        update_profile(cnx, patient_id)
                    else:
                        print("Please log-in or create an account first.")
                elif choice == '3':
                    print("\t\t\t\t╔══════════════════════════════════════╗")
                    print("\t\t\t\t║         Update Your Insurance        ║")
                    print("\t\t\t\t╚══════════════════════════════════════╝ \n")
                    if patient_id:
                        update_insurance(cnx, patient_id)
                    else:
                        print("Please log-in or create an account first.")
                elif choice == '4':
                    print("\t\t\t\t╔══════════════════════════════════════╗")
                    print("\t\t\t\t║             Find A Doctor            ║")
                    print("\t\t\t\t╚══════════════════════════════════════╝ \n")
                    if patient_id:
                        specialty, doctor_name = user_find_doctor(cnx)
                        find_doc(cnx, specialty, doctor_name)
                    else:
                        print("Please log-in or create an account first.")
                elif choice == '5':
                    print("\t\t\t\t╔══════════════════════════════════════╗")
                    print("\t\t\t\t║          View Doctor Reviews         ║")
                    print("\t\t\t\t╚══════════════════════════════════════╝ \n")
                    if patient_id:
                        doctor = show_doctors_db(cnx)
                        view_reviews(cnx, doctor)
                    else:
                        print("Please log-in or create an account first.")
                elif choice == '6':
                    print("\t\t\t\t╔══════════════════════════════════════╗")
                    print("\t\t\t\t║            Write A Review            ║")
                    print("\t\t\t\t╚══════════════════════════════════════╝ \n")
                    if patient_id:
                        write_review(cnx, patient_id)
                    else:
                        print("Please log-in or create an account first.")
                elif choice == '7':
                    print("\t\t\t\t╔══════════════════════════════════════╗")
                    print("\t\t\t\t║            Delete A Review           ║")
                    print("\t\t\t\t╚══════════════════════════════════════╝ \n")
                    if patient_id:
                        delete_review(cnx, patient_id)
                    else:
                        print("Please log-in or create an account first.")
                elif choice == '8':
                    print("\t\t\t\t╔══════════════════════════════════════╗")
                    print("\t\t\t\t║           View Appointments          ║")
                    print("\t\t\t\t╚══════════════════════════════════════╝ \n")
                    if patient_id:
                        apt_id_only = view_appointments(cnx, patient_id)
                    else:
                        print("Please log-in or create an account first.")
                elif choice == '9':
                    print("\t\t\t\t╔══════════════════════════════════════╗")
                    print("\t\t\t\t║         Schedule Appointment         ║")
                    print("\t\t\t\t╚══════════════════════════════════════╝ \n")
                    if patient_id:
                        doctor_npi = show_doctors_npi_to_schedule(cnx)
                        schedule_appointment(cnx, doctor_npi,  patient_id)
                        
                    else:
                        print("Please log-in or create an account first.")
                elif choice == '10':
                    print("\t\t\t\t╔══════════════════════════════════════╗")
                    print("\t\t\t\t║        Reschedule Appointment        ║")
                    print("\t\t\t\t╚══════════════════════════════════════╝ \n")
                    if patient_id:
                        apt_id_only = view_appointments(cnx, patient_id)
                        apt_id = get_apt_id(apt_id_only)
                        reschedule_appointment(cnx, apt_id)
                    else:
                        print("Please log-in or create an account first.")
                elif choice == '11':
                    print("\t\t\t\t╔══════════════════════════════════════╗")
                    print("\t\t\t\t║          Cancel Appointment          ║")
                    print("\t\t\t\t╚══════════════════════════════════════╝ \n")
                    if patient_id:
                        apt_id_only = view_appointments(cnx, patient_id)
                        apt_id = get_apt_id(apt_id_only)
                        cancel_appointment(cnx, patient_id, apt_id)
                elif choice == '12':
                    print("\t\t\t\t╔══════════════════════════════════════╗")
                    print("\t\t\t\t║          View Prescriptions          ║")
                    print("\t\t\t\t╚══════════════════════════════════════╝ \n")
                    if patient_id:
                        view_rx(cnx, patient_id)
                    else:
                        print("Please log-in or create an account first.")
                elif choice == '13':
                    print("\t\t\t\t╔══════════════════════════════════════╗")
                    print("\t\t\t\t║         Refill A Prescription        ║")
                    print("\t\t\t\t╚══════════════════════════════════════╝ \n")
                    if patient_id:
                        refill_rx(cnx, patient_id)
                    else:
                        print("Please log-in or create an account first.")
                elif choice == '14':
                    print("\t\t\t\t╔══════════════════════════════════════╗")
                    print("\t\t\t\t║           View Your Bills            ║")
                    print("\t\t\t\t╚══════════════════════════════════════╝ \n")
                    if patient_id:
                        view_bills(cnx, patient_id)
                    else:
                        print("Please log-in or create an account first.")
                elif choice == '15':
                    print("\t\t\t\t╔══════════════════════════════════════╗")
                    print("\t\t\t\t║              Pay A Bill              ║")
                    print("\t\t\t\t╚══════════════════════════════════════╝ \n")
                    if patient_id:
                        pay_bill(cnx, patient_id)
                    else:
                        print("Please log-in or create an account first.")
                elif choice == 'Q' or choice == 'q':
                    print("Exiting the portal...")
                    break
                else:
                    print("Invalid option. Please try again.")
        print("\nThanks! Closing connection ...\n")
        cnx.close

    except AttributeError:
        print("\nSomething went wrong. Please try again")

    finally:
        cnx.close()
        print("Connection closed.")
    
if __name__ == "__main__":
    main()
