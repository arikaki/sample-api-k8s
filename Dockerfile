# Build stage
FROM golang:alpine AS build-env

# Create app directory and install dependencies
RUN mkdir /go/src/app && apk update && apk add git

# Add the Go modules and source files
WORKDIR /go/src/app
ADD go.mod go.sum ./
RUN go mod download
ADD . .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags '-extldflags "-static"' -o app .

# Final stage
FROM scratch

# Set working directory in the final container
WORKDIR /app

# Copy the built application from the build stage
COPY --from=build-env /go/src/app/app .
COPY --from=build-env /go/src/app/config.json .

# Expose port 3000 (optional)
EXPOSE 3000

# Set entry point
ENTRYPOINT ["./app"]

