# Project Setup and Deployment

This project consists of a Go backend and a Svelte frontend, containerized using Docker. Follow these instructions to build and run the application.

## Prerequisites

- Docker installed on your system
- Git (optional, for cloning the repository)

## Project Structure

- `/backend`: Go server code
- `/frontend`: Svelte frontend code using Deno
- `Dockerfile`: Multi-stage build configuration

## Building the Docker Image

1. Clone the repository (if not already done):

``` bash
git clone <repository-url>
```

2. Navigate to the project root directory:

``` bash
cd <project-directory>
```

3. Build the Docker image:

``` bash
docker build -t clickety-clack .
```

This command creates an image named "clickety-clack" using the multi-stage Dockerfile, which:

- Builds the Svelte frontend using Deno
- Compiles the Go backend using Go
- Creates a lightweight Alpine-based final image

## Running the Container

Run the container with:

```bash
docker run -p 3000:3000 clickety-clack
```

- `-p 3000:3000`: Maps port 3000 on your host to port 3000 in the container
- `clickety-clack`: The name of the image built in the previous step

## Accessing the Application

Once the container is running:

- Open your browser to `http://localhost:3000`
- The Go server will serve the static files from the Svelte build

## Troubleshooting

If the container fails to start:

- Check that port 3000 is not in use by another process
