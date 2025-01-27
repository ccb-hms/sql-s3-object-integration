/*
     Example Transact-SQL script for querying CSV, Parquet, etc in S3.
     Polybase is configured at container build-time.  
     
     Originally created by Anthony Nocentino.
*/

--Create a database to hold objects for the demo
CREATE DATABASE [PolybaseDemo];

--Switch into the database context
USE PolybaseDemo

--Create a database master key, this is use to protect the credentials you're about to create
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'yourStrong(!)Password';  

--Create a database scoped credential, this should have at minimum ReadOnly and ListBucket access to the s3 bucket
CREATE DATABASE SCOPED CREDENTIAL s3_dc WITH IDENTITY = 'S3 Access Key', SECRET = 'miniouser:miniopassword' ;

--Create your external datasource on your s3 compatible object storage, referencing where it is on the network (LOCATION) and the credential you just defined
CREATE EXTERNAL DATA SOURCE s3_ds
WITH
(    LOCATION = 's3://s3.example.com:9000/'
,    CREDENTIAL = s3_dc
)

--First we can access data in the s3 bucket and for a simple test, let's start with CSV. During the docker compose up, the build copied a csv into the bucket it created.
--This should output Hello World! several times.
SELECT  * 
FROM OPENROWSET
(    BULK '/sqldatavirt/helloworld.csv'
,    FORMAT       = 'CSV'
,    DATA_SOURCE  = 's3_ds'
) 
WITH ( c1 int, c2 varchar(20) )
AS   [Test1]

--OPENROWSET is cool for infrequent access, but if you want to layer on sql server security or use statistics on the data in the external data source,
--create let's create an external table. This first requires defining an external file format. In this example its CSV
CREATE EXTERNAL FILE FORMAT CSVFileFormat
WITH
(    FORMAT_TYPE = DELIMITEDTEXT
,    FORMAT_OPTIONS  ( FIELD_TERMINATOR = ','
,                      STRING_DELIMITER = '"'
,                      FIRST_ROW = 1 )
);

--Next we define the table's structure. The CSV here is mega simple, just a single row with a single column
--When defining the external table where the data lives on our network with DATA_SOURCE, the LOCATION within that DATA_SOURCE and the FILE_FORMAT
CREATE EXTERNAL TABLE HelloWorld ( c1 int, c2 varchar(20) )
WITH (
     DATA_SOURCE = s3_ds
,    LOCATION = '/sqldatavirt/helloworld.csv'
,    FILE_FORMAT = CSVFileFormat
);

--Now we can access the data just like any other table in sql server. 
SELECT * FROM [HelloWorld];
