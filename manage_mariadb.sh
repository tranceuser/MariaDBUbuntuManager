#!/bin/bash

# Function to display error messages
error() {
  echo "Error: $1" >&2
  exit 1
}

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
  error "This script must be run as root"
fi

# Get the root MySQL user password
read -s -p "Enter the MySQL root user password: " root_password
echo ""

while true; do
    # Check if the MySQL root password is correct
    if ! mysql -u root -p"$root_password" -e ";" ; then
        echo "Incorrect password. Please try again."
        read -s -p "Enter the MySQL root user password: " root_password
        echo ""
        continue
    fi

    echo "1. Manage Users"
    echo "2. Manage Databases"
	echo "3. Import SQL file"
	echo "4. Export SQL file"
    echo "5. Exit"

    read -p "Choose an option (1-3): " main_option

    case $main_option in
        1)
            # Display the list of users and their hosts
            echo "List of users and their hosts:"
            mysql -u root -p"$root_password" -e "SELECT User, Host FROM mysql.user"
            echo "1. Create new user"
            echo "2. Delete a user"
            echo "3. Flush all users (except root)"
            read -p "Choose an option (1-3): " user_option
            case $user_option in
                1)
                    read -p "Enter new username: " user_name
                    read -p "Enter the user's host (e.g., 'localhost' or '192.168.1.%'): " user_host
                    read -s -p "Enter the user's password: " user_password
                    echo ""
                    mysql -u root -p"$root_password" -e "CREATE USER '$user_name'@'$user_host' IDENTIFIED BY '$user_password'"
                    ;;
                2)
					read -p "Enter username to delete: " user_name
					read -p "Enter the host of the user to delete (e.g., 'localhost' or '192.168.1.%'): " user_host
					mysql -u root -p"$root_password" -e "DROP USER '$user_name'@'$user_host'"
                    ;;
                3)
                    mysql -u root -p"$root_password" -e "DELETE FROM mysql.user WHERE User NOT IN ('root') OR Host NOT IN ('localhost')"
                    mysql -u root -p"$root_password" -e "FLUSH PRIVILEGES"
                    ;;
                *) echo "Invalid option.";;
            esac
            ;;
        2)
            echo "List of databases:"
            mysql -u root -p"$root_password" -e "SHOW DATABASES"
            echo "1. Create new database"
            echo "2. Delete a database"
            echo "3. Update a database"
            read -p "Choose an option (1-3): " db_option
            case $db_option in
                1)
                    read -p "Enter new database name: " db_name
                    mysql -u root -p"$root_password" -e "CREATE DATABASE $db_name"
                    ;;
                2)
                    read -p "Enter the name of the database to delete: " db_name
                    mysql -u root -p"$root_password" -e "DROP DATABASE $db_name"
                    ;;
                3)
                    read -p "Enter database name to update: " db_name
                    echo "1. Update users for the database: $db_name"
                    echo "2. Update privileges for the database: $db_name"
                    read -p "Choose an option (1-2): " update_option
                    case $update_option in
                        1)
							echo "List of users and their privileges for the database $db_name:"
							mysql -u root -p"$root_password" -e "SELECT user, host, Db, Select_priv, Insert_priv, Update_priv, Delete_priv FROM mysql.db WHERE Db = '$db_name'"
							read -p "Enter user to grant access to the database: " user_name
							read -p "Enter the user's host (e.g., 'localhost' or '192.168.1.%'): " user_host
							mysql -u root -p"$root_password" -e "GRANT ALL PRIVILEGES ON $db_name.* TO '$user_name'@'$user_host'"
							mysql -u root -p"$root_password" -e "FLUSH PRIVILEGES"
							;;
                        2)
							echo "List of users and their privileges for the database $db_name:"
							mysql -u root -p"$root_password" -e "SELECT user, host, Db, Select_priv, Insert_priv, Update_priv, Delete_priv FROM mysql.db WHERE Db = '$db_name'"
							read -p "Enter user to update privileges for: " user_name
							read -p "Enter the privileges to be granted (e.g., SELECT, INSERT, DELETE, UPDATE): " privileges
							mysql -u root -p"$root_password" -e "GRANT $privileges ON $db_name.* TO '$user_name'@'localhost'"
							mysql -u root -p"$root_password" -e "FLUSH PRIVILEGES"
							;;
						*) echo "Invalid option.";;
                    esac
                    ;;
                *) echo "Invalid option.";;
            esac
            ;;
		3)
            read -p "Enter the path to the SQL file (e.g., /home/ubuntu/backup.sql): " sql_file
            if [ -f "$sql_file" ]; then
                read -p "Enter the name of the database to import to: " db_name
                mysql -u root -p"$root_password" "$db_name" < "$sql_file"
                if [ $? -eq 0 ]; then
                    echo "Import completed successfully"
                else
                    echo "Failed to import SQL file"
                fi
            else
                echo "File not found: $sql_file"
            fi
            ;;
		4)
			read -p "Enter the name of the database to export: " db_name
			read -p "Enter the path to save the SQL file (e.g., /home/ubuntu/backup.sql): " export_file
			mysqldump -u root -p"$root_password" "$db_name" > "$export_file"
			if [ $? -eq 0 ]; then
				echo "Export completed successfully"
			else
				echo "Failed to export SQL file"
			fi
			;;
        5)
            echo "Exiting..."
            break
            ;;
        *)
            echo "Invalid option. Please choose a valid number."
            ;;
    esac
done
