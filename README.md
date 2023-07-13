# sql-s3-object-integration

This repository is derived from Anthony Nocentino's [excellent examples of running SQL Server with S3 object 
storage integration](https://github.com/nocentino/sql-s3-object-integration).  It is a trimmed-down and reorganized 
version of his work that provides a light-weight SQL Server container running alongside a minio S3 server.  This allows 
the user to do makeshift analyses of the file formats (e.g., parquet, csv) 
that are supported by SQL Server's Polybase data virtualization technology. 

To get started, build and run up the containers with something like:

`BUILDKIT_PROGRESS=plain docker-compose up --build -d`

Once the containers are running, you can upload files into the S3 service by aiming you web browser at 
port 9000 over an HTTPS connection on the host where the containers are running.  For example, if 
you are running the browser on the same host where the containers are running, you can navigate to:

`https://localhost:9000`

The default username for the minio service is `MYROOTUSER` and the default password is `MYROOTPASSWORD`.

The ports, passwords, etc., can be modified by editing `compose.yaml` and `Containers/SqlServerPolybase.Dockerfile`.

The default password for the `sa` account on SQL Server is `yourStrong(!)Password`.

You can connect to the SQL Server instance using any of the standard management / query tools (Azure Data Studio, SQL Server Management Studio, etc.).

See `Demo/demo.sql` for an example query against a small CSV file that gets loaded into the S3 container at build time.