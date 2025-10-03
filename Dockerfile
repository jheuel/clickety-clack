# Stage 1: Build the Svelte frontend
FROM denoland/deno:2.5.3@sha256:0487a6a8ee181078b777349988d38d92cd21cb9d66dc0d8f3b6db223db6700b4 as frontend-builder

WORKDIR /app/frontend
COPY ./frontend .
RUN deno install
RUN deno task build

# Stage 2: Build the Go backend
FROM golang:1.25.1@sha256:ab1f5c47de0f2693ed97c46a646bde2e4f380e40c173454d00352940a379af60 as backend-builder

WORKDIR /app/backend
COPY ./backend .
RUN go mod download
RUN CGO_ENABLED=0 GOOS=linux go build -o server

# Stage 3: Final image
FROM alpine:3.22@sha256:4bcff63911fcb4448bd4fdacec207030997caf25e9bea4045fa6c8c44de311d1

WORKDIR /app
COPY --from=backend-builder /app/backend/server .
COPY --from=backend-builder /app/backend/words.txt .
COPY --from=frontend-builder /app/frontend/build ../frontend/build/

EXPOSE 3000

# Run the server
CMD ["./server"]
