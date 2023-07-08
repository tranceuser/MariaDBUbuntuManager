# MariaDB Management Script for Ubuntu

This shell script provides a simple way to manage MariaDB on Ubuntu 22.04 or newer. The script allows you to perform the following tasks:

- Manage Users: Create, delete, and flush all users.
- Manage Databases: Create, delete, and update a database.
- Import and Export SQL files.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine.

### Prerequisites

- Ubuntu 22.04 or newer
- MariaDB server installed

### Permissions
The script must have execute permissions to be run. After you have cloned the repository, you can add these permissions with the following command:
```
chmod +x manage_mariadb.sh
```

Running the Script
You can run the script as root:
```
sudo ./manage_mariadb.sh
```

You will be prompted to enter your MariaDB root password, then you will be given options to manage users, databases, and SQL files.