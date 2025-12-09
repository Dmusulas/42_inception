This file explains how to use the project from an end-user perspective

# User Documentation

## Services Provided
This stack provides a fully functional **WordPress** website running on a secure **Nginx** server, backed by a **MariaDB** database.
- **Website:** Securely accessible via HTTPS.
- **Database:** Persistent storage for all site content.

## How to Start and Stop the Project
**Start:**
Run the following command at the root of the project:
```bash
    make all
```

**Stop:**
To stop the services without deleting data:

```bash
    make down
```

## Accessing the Website

1.  Ensure `dmusulas.42.fr` is mapped to `127.0.0.1` in your `/etc/hosts` file.
2.  Open your web browser.
3.  Navigate to: **`https://dmusulas.42.fr`**
      - *Note: You will see a security warning because the SSL certificate is self-signed. This is expected. Click "Advanced" -\> "Proceed" to access the site.*

## Managing Credentials

Credentials are stored securely and are not visible in the environment settings.

  - **Database Passwords:** Located in `secrets/db_password.txt` and `secrets/db_root_password.txt`.
  - **WordPress Admin:**
      - **Username:** `wp_root` (defined in `.env` as `WP_ADMIN_USER`).
      - **Password:** Located in `secrets/wp_admin_password.txt`.
  - **WordPress User:**
      - **Username:** `wp_user`.
      - **Password:** Located in `secrets/wp_user_password.txt`.

## Checking Service Status

To verify that all containers are running correctly:

```bash
    docker ps
```

You should see three containers (`nginx`, `wordpress`, `mariadb`) with the status **"Up"**.

To view real-time logs for troubleshooting:

```bash
    make logs
```