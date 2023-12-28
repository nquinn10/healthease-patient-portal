# HealthEase Patient Portal

***Introduction*** 


This program is a healthcare management app, designed to provide patients with a unified platform to access and manage their health-related information and services. 


***File Structure*** 

* SQL: 
    * self-contained database dump: "HealthEaseDBDump-FINAL.sql"
    * table creation: "HealthEaseDBCreate.sql"
    * test data insertion: "HealthEaseDB-DataCreation.sql"
    * stored procedures/triggers/functions: "HealthEaseDB-ProgrammingObjects.sql"

* Python: 
    * "health_ease_CLI.py" (our script for the CLI and running the program) 

* README.md 
* Final Report: "QuinnNSaslowKQuachL_final_report.pdf"


***Model***

The model behind the project is a database called "health_ease" built in MySQLWorkbench. The database represents a patient portal, where patients can view and interact with their healthcare team. The database also supports a second user role of system administrator. Patients have access to their doctors, their appointment history, prescriptions and billing, and system administrators can manage patients in the database (their accounts and credentials), doctors (add/delete doctors from the system),  prescriptions, etc.  

 
***Command Line Interface*** 

The controller and textual view of our project were built in Python. The python script can be found at "health_ease_CLI.py". Once the script is run, the user will be prompted through the program via the CLI, and can choose to interact with the program according to the main menu and command-line prompts.  
 

***Technical Specifications*** 

To successfully import the database, the instructor will need to have MySQL (version 8.0 or later, download from MySQL's official download page here: https://dev.mysql.com/downloads/mysql/), and Python (version 3.7 or later, download from Python's official site here: https://www.python.org/downloads/). 

To import the database, you will need the database dump, which can be found in the uploads as "HealthEaseDBDump-FINAL.sql". In MySQLWorkbench, establish a connection, navigate to the toolbar at the top of the screen. Go to Server → Data Import → select import From Self-Contained File → choose “HealthEaseDBDump-FINAL.sql” from the drop-down menu → and at the bottom select Dump Structure and Data. 

Though not necessary if the data is imported and dumped from a self-contained file, the following files are also available to see the database (table) creation (“HealthEaseDBCreate.sql”), the test-data insertion (“HealthEaseDB-DataCreation.sql”), and the stored procedures/triggers/functions (“HealthEaseDB-ProgrammingObjects.sql”).  Once the database has been imported, the instructor can interact with our program via the terminal using our command line interface. 

To use and interact with the command line interface (CLI) of our application, the instructor will need to download Python and open up a Python environment. Please install the following packages to ensure successful execution of the following imports in the Python script: 


* install ```pymysql``` - establish a connection to a MySQL server and interact with database 

* install ```getpass``` - library for secure password input 

* install ```datetime``` - library for manipulating dates and times 

* install ```re``` - library for regular expressions operations and string matching 

* install ```matplotlib.pyplot``` - package for data visualization 

* install ```seaborn``` - package for data visualization 

 
Should any of these not already be installed and used by the instructor, ```pip install <package_name>``` can be run in the terminal so that the imports at the top of the Python script run successfully.  

  
To execute our script, please navigate in the terminal to the directory where the files are stored, and run: ```python3 health_ease_CLI.py```. This will launch our program and prompt the user to establish a connection with the MySQL server. Note: with the Python version suggested above, “python3” must be used. If an earlier version of Python is already installed by the instructor, the correct command to launch our application may be ```python health_ease_CLI.py```. 

  
Upon launching the script, the instructor will be prompted to enter their SQL server credentials to establish a connection with the database. One a connection to the MySQL server is established successfully, the homepage of our patient portal HealthEase will be displayed and the user can get started.  


For testing operations that require a pre-existing prescription or bill, the instructor can log-in to the patient portal of John Doe or Jane Smith: 

  

**John Doe**

username: john.doe@email.com 
password: password123$ 

  

**Jane Smith**

username: jane.smith@email.com 
password: howdy123$ 

  
With either of these users, the instructor can view/refill prescriptions, view/pay bills and create/view/delete reviews that the user left for doctors. The instructor can also create an account and schedule/modify appointments, find doctors, and use the full application functionality (except prescription and bill administration, as these would have required an appointment to have already happened). 


For testing the system administrator role of the application, the instructor can log-in to the portal with the following information: 


**Portal Admin**

username: portaladmin@healthease.com 
password: strongpass! 


A different menu will appear which will expose the functionality of the program from the system administrator's side, where you can view/delete patients, update patient accounts, and view/add doctors.    

***Interacting with the Application*** 

Once all necessary Python libraries are installed, the CLI will guide the instructor through our database application. Depending on whether the instructor chooses to log-in to the portal as a patient or administrator, the menu that appears will be different. At each step of the program, the instructor will be guided and prompted with clear instructions for what to do/what information to enter. If information is entered incorrectly or an operation is not supported by the specific menu item selected, there are clear and descriptive error messages printed to the terminal so that the user can either try again, or select a different action from the menu.  

***Exiting the Program*** 

At any time, the user can “exit” and navigate back to the main menu, where either “Q” or “q” can be typed in order to exit the program, which will terminal upon quitting.  
