FROM ubuntu:20.04 

#Create file layout for SQL and set permissions
RUN useradd -M -s /bin/bash -u 10001 -g 0 mssql
RUN mkdir -p -m 770 /var/opt/mssql/security/ca-certificates && chgrp -R 0 /var/opt/mssql/security/ca-certificates

# Installing system utilities
RUN apt-get update && \
    apt-get install -y apt-transport-https curl gnupg2

# Import the MS public repository GPG keys
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
    
# Register the Microsoft Ubuntu repositories
RUN curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list | tee /etc/apt/sources.list.d/msprod.list && \
    curl https://packages.microsoft.com/config/ubuntu/20.04/mssql-server-2022.list  > /etc/apt/sources.list.d/mssql-server-2022.list 


# Install SQL Server
RUN apt-get update && \
    apt-get install -y mssql-server-polybase && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists

# Install SQL Server command line tools
RUN apt-get update && \
    ACCEPT_EULA=Y apt-get install -y mssql-tools unixodbc-dev

# Configure traceflags (see https://learn.microsoft.com/en-us/answers/questions/1056607/create-external-data-source-not-working-on-sql-ser)
RUN /opt/mssql/bin/mssql-conf traceflag 13702 on

# Configure Polybase
# There are probably more elegant ways to wait for the DB server to start, but 
# sleeping for 30 seconds generally works
ARG ACCEPT_EULA=Y
ARG SA_PASSWORD=yourStrong(!)Password
RUN runuser -m -p  mssql -c '/opt/mssql/bin/sqlservr &' \
    && sleep 30 \
	&& /opt/mssql-tools/bin/sqlcmd -Slocalhost -Usa -P"yourStrong(!)Password" \
    -Q"exec sp_configure @configname = 'polybase enabled', @configvalue = 1; RECONFIGURE; exec sp_configure @configname = 'polybase enabled'"

# Run SQL Server process as non-root
USER mssql
CMD /opt/mssql/bin/sqlservr