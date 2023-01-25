# Assessment DB
To Create and populate the database, Create a new database named Assessment
edit the appsettings file under the dbUpdater project and point the connection string at the new DB you just created
run the dbUpdater project

The solution uses the mediator pattern extensively with CQRS for the database queries.
The Api project contains all of the endpoints and the Application project contains all of the methods and queries
The Infrastructure project facilitates some of the setup required for Entity Framework


## Problem
1.	Create a REST API using ASP.NET MVC and write a method to return a sorted list of these by Publisher, Author (last, first), then title.

Endpoint is located at https://localhost:7053/api/Books/SortP

2.	Write another API method to return a sorted list by Author (last, first) then title.

Endpoint is located at https://localhost:7053/api/Books/SortA

3.	If you had to create one or more tables to store the Book data in a MS SQL database, outline the table design along with fields and their datatypes. 

The DbUpdater project will create the database from scratch, the table create method is in the Migrations Folder
The sample data is in the PostDeployment Folder

4.	Write stored procedures in MS SQL Server for steps 1 and 2, and use them in separate API methods to return the same results.
the Stored Procedure create method is in the Migrations Folder

Endpoint is located at https://localhost:7053/api/Books/SortP/UseSp
Endpoint is located at https://localhost:7053/api/Books/SortA/UseSp

5.	Write an API method to return the total price of all books in the database.

Endpoint is located at https://localhost:7053/api/Books/Price

6.	If you have a large list of these in memory and want to save the entire list to the MS SQL Server database, what is the most efficient way to save the list with only one call to the DB server?

Ideally we would use one of the many Bulk Inserty extensions
Here I have a sample that uses the base functionallity AddRange
Location is in the Application project under Commands

7.	Add a property to the Book class that outputs the MLA (Modern Language Association) style citation as a string (https://images.app.goo.gl/YkFgbSGiPmie9GgWA). Please add whatever additional properties the Book class needs to generate the citation.

8.	Add another property to generate a Chicago style citation (Chicago Manual of Style) (https://images.app.goo.gl/w3SRpg2ZFsXewdAj7).