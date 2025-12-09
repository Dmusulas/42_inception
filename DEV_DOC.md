This file explains technical details for developers working on the stack.

# Developer Documentation
## Environment Setup
To set up the development environment from scratch:

1. **Virtual Machine:** Ensure you are running a Linux VM (Debian/Ubuntu recommended).
2. **Dependencies:** Install `docker`, `docker-compose-plugin`, and `make`.
3. **Domain Configuration:**
   Add the following line to `/etc/hosts`:
```
127.0.0.1 dmusulas.42.fr
```
4. **Directory Structure:**
The project requires a specific folder structure for data persistence. This is handled automatically by the Makefile, which creates:
- `/home/dmusulas/data/wordpress`
- `/home/dmusulas/data/mysql`

## Building and Launching
The build process is automated via `Makefile` and `docker-compose`.

- **Build and Run (Detached):**
```bash
make all
```

This builds the images from `srcs/requirements/*/Dockerfile` and starts the network.

  - **Rebuild specific service:**
    To rebuild only one service (e.g., nginx) after changes:
    ```bash
    docker compose -f srcs/docker-compose.yml up -d --build nginx
    ```

## Managing Containers and Volumes

  - **List active containers:** `docker ps`
  - **Inspect network:** `docker network inspect inception_network`
  - **View Logs:** `docker compose -f srcs/docker-compose.yml logs -f`
  - **Clean Environment:**
    To remove all containers, networks, and images created by this project:
    ```bash
    make fclean
    ```

## Data Storage and Persistence
Data persistence is achieved using **Bind Mounts** to the host machine.

  - **WordPress Files:**

      - **Container Path:** `/var/www/html`
      - **Host Path:** `/home/dmusulas/data/wordpress`
      - *Mechanism:* Defined in `docker-compose.yml` under the `wordpress` service volumes.

  - **Database Files:**

      - **Container Path:** `/var/lib/mysql`
      - **Host Path:** `/home/dmusulas/data/mysql`
      - *Mechanism:* Defined in `docker-compose.yml` under the `mariadb` service volumes.

**Note:** If you delete the folders in `/home/dmusulas/data/`, the website setup and database content will be lost. The `make clean` command removes Docker resources but **preserves** this data. Use `sudo rm -rf /home/dmusulas/data` manually (or add a custom rule) if you need a hard reset.