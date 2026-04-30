FROM golang:1.24-alpine AS build
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -o /out/server .

FROM alpine:3.20
RUN adduser -D -u 1000 rpg
USER rpg
COPY --from=build /out/server /usr/local/bin/server
EXPOSE 7777
ENTRYPOINT ["/usr/local/bin/server"]
