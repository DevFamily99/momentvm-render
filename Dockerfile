# Build image
FROM vapor/swift:5.2 as build
RUN apt-get -qq update && apt-get -qq upgrade
RUN apt-get install -yq libssl-dev zlib1g-dev libcurl4-gnutls-dev
WORKDIR /build
COPY ./Package.* ./
RUN swift package resolve
COPY . .
RUN swift build -c release -Xswiftc -g

# Run image
FROM vapor/ubuntu:18.04
WORKDIR /run
COPY --from=build /build/.build/release /run
COPY --from=build /usr/lib/swift/ /usr/lib/swift/
COPY --from=build /build/Public /run/Public
ENTRYPOINT ["./Run"]
CMD ["serve", "--env", "development", "--hostname", "0.0.0.0"]