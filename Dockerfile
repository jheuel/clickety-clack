# Stage 1: Build the Svelte frontend
FROM denoland/deno:2.5.0@sha256:3373fa94f2a9295041f35ec617d13ef5a84eec944235729ec10b5c167a891688 as frontend-builder

WORKDIR /app/frontend
COPY ./frontend .
RUN deno install
RUN deno task build

# Stage 2: Build the Go backend
FROM golang:1.25.1@sha256:bb979b278ffb8d31c8b07336fd187ef8fafc8766ebeaece524304483ea137e96 as backend-builder

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
