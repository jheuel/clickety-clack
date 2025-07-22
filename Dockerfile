# Stage 1: Build the Svelte frontend
FROM denoland/deno:2.4.2@sha256:467d41805c2f531a48f84dfcd1b4f9244b8ebdbd505f752011d6d1b7daacc489 as frontend-builder

WORKDIR /app/frontend
COPY ./frontend .
RUN deno install
RUN deno task build

# Stage 2: Build the Go backend
FROM golang:1.24.5@sha256:a98400bb38a9bd6de5a30c80dc9e2f4969510516cef343bb637f4dcdab71f20b as backend-builder

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
