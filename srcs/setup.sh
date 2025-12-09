#!/bin/bash

# Create the secrets folder if it doesn't exist
mkdir -p secrets

# Function to generate a random password if the file doesn't exist
generate_secret() {
    file="secrets/$1"
    if [ ! -f "$file" ]; then
        echo "Generating $file..."
        # Generate a random 12-char password
        openssl rand -base64 12 > "$file"
    else
        echo "$file already exists."
    fi
}

generate_secret "db_password.txt"
generate_secret "db_root_password.txt"
generate_secret "wp_admin_password.txt"
generate_secret "wp_user_password.txt"

echo "Secrets generated successfully!"