# Stage 1: Build the Svelte frontend
FROM denoland/deno:2.5.6@sha256:3ea71953ff50e3ff15c377ead1a8521f624e2f43d27713675a8bed7b33f166aa as frontend-builder

WORKDIR /app/frontend
COPY ./frontend .
RUN deno install
RUN deno task build

# Stage 2: Build the Go backend
FROM golang:1.25.5@sha256:a22b2e6c5e753345b9759fba9e5c1731ebe28af506745e98f406cc85d50c828e as backend-builder

WORKDIR /app/backend
COPY ./backend .
RUN go mod download
RUN CGO_ENABLED=0 GOOS=linux go build -o server

# Stage 3: Final image
FROM alpine:3.23@sha256:51183f2cfa6320055da30872f211093f9ff1d3cf06f39a0bdb212314c5dc7375

WORKDIR /app
COPY --from=backend-builder /app/backend/server .
COPY --from=backend-builder /app/backend/words.txt .
COPY --from=frontend-builder /app/frontend/build ../frontend/build/

EXPOSE 3000

# Run the server
CMD ["./server"]
