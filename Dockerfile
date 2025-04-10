# Stage 1: Build the Svelte frontend
FROM denoland/deno:2.2.8@sha256:be4255d1837e2ce89ca893c1a0c7700854ab760fb7d861f353103a9181403b6d as frontend-builder

WORKDIR /app/frontend
COPY ./frontend .
RUN deno install
RUN deno task build

# Stage 2: Build the Go backend
FROM golang:1.24.2@sha256:1ecc479bc712a6bdb56df3e346e33edcc141f469f82840bab9f4bc2bc41bf91d as backend-builder

WORKDIR /app/backend
COPY ./backend .
RUN go mod download
RUN CGO_ENABLED=0 GOOS=linux go build -o server

# Stage 3: Final image
FROM alpine:3.21@sha256:a8560b36e8b8210634f77d9f7f9efd7ffa463e380b75e2e74aff4511df3ef88c

WORKDIR /app
COPY --from=backend-builder /app/backend/server .
COPY --from=backend-builder /app/backend/words.txt .
COPY --from=frontend-builder /app/frontend/build ../frontend/build/

EXPOSE 3000

# Run the server
CMD ["./server"]