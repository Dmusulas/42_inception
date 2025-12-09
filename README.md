*This project has been created as part of the 42 curriculum by dmusulas.*

# Inception

## Description
This project aims to broaden knowledge of system administration by using Docker. It involves virtualizing several Docker images to create a personal virtual machine infrastructure. The goal is to set up a small infrastructure composed of different services (Nginx, WordPress, MariaDB) under specific rules, running in dedicated containers.

## Instructions

### Prerequisites
- Docker and Docker Compose must be installed on the machine.
- Make must be available.
- The host URL `dmusulas.42.fr` must point to `127.0.0.1` in `/etc/hosts`.

### Installation & Execution
1. Clone the repository:
```bash
   git clone <repository_url> Inception
   cd Inception
```

2.  Build and start the infrastructure:

```bash
    make all
 ```

This will create the required data directories at `/home/dmusulas/data`, build the Docker images for Nginx, MariaDB, and WordPress, and start the containers in detached mode.

3.  Stop the services:

```bash
    make down
```

4.  Clean up (removes containers, networks, images, and volumes):

```bash
    make fclean
```

## Project Description & Design Choices

### Overview

The stack consists of three separate containers sharing a custom Docker network:

1.  **Nginx:** The entry point, listening only on port 443 (TLSv1.2/TLSv1.3).
2.  **WordPress:** Running PHP-FPM, connected to the database containers.
3.  **MariaDB:** Storing the website's data.

### Comparisons

#### Virtual Machines vs Docker

  - **Virtual Machines (VMs):** Emulate a full hardware stack and run a complete Guest OS on top of a Hypervisor. They are heavy, resource-intensive, and slow to boot, but offer strong isolation.
  - **Docker:** Uses containerization to share the Host OS kernel. Containers are lightweight, start almost instantly, and package the application with its dependencies, making them portable and efficient.

#### Secrets vs Environment Variables

  - **Environment Variables:** Useful for configuration settings (domain name, paths) but insecure for sensitive data because they can be easily inspected via `docker inspect`.
  - **Docker Secrets:** The secure standard for managing sensitive data (passwords, keys). In this project, passwords are stored in files within `secrets/` and mounted securely into containers, keeping them out of environment variables. **Note: Usually secrets shouldn't be pushed to git repos but in this case we do**

#### Docker Network vs Host Network

  - **Host Network:** The container shares the host's networking namespace. It offers high performance but poor isolation; port conflicts are common.
  - **Docker Network:** Creates an isolated network for containers. Services communicate via internal DNS names (e.g., `wordpress:9000`), and only specific ports (443) are exposed to the outside world, enhancing security.

#### Docker Volumes vs Bind Mounts

  - **Docker Volumes:** Managed completely by Docker (usually in `/var/lib/docker/volumes`). Good for persistence but harder to access from the host.
  - **Bind Mounts:**  map a specific directory on the host (`/home/dmusulas/data`) to a path inside the container. This meets the project requirement to have data available at a specific host location.

## Resources

  - [Docker Documentation](https://docs.docker.com/)
  - [Nginx Documentation](https://nginx.org/en/docs/)
  - [MariaDB Knowledge Base](https://mariadb.com/kb/en/)

### AI Usage

**Tasks:**

  - Debugging Docker volume permission errors during the setup of `/home/dmusulas/data`.
  - Explaining the difference between `ENTRYPOINT` and `CMD` in Dockerfiles.
  - Generating the initial directory structure ideas.
