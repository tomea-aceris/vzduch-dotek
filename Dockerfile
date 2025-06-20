FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /source

COPY *.csproj .
RUN dotnet restore

COPY . .
RUN dotnet publish -c release -o /app -r linux-arm64 --self-contained true --no-restore /p:PublishReadyToRun=true

# final stage/image
FROM mcr.microsoft.com/dotnet/runtime:3.1.12-bullseye-slim-arm64v8

LABEL Tome <tome@aceris.com.au>

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl locales \
    && rm -rf /var/lib/apt/lists/*

RUN sed -i -e 's/# en_AU.UTF-8 UTF-8/en_AU.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV TZ=Australia/Sydney
ENV LANG en_AU.utf8
ENV LANGUAGE ${LANG}
ENV LC_ALL ${LANG}

WORKDIR /app
COPY --from=build /app .

ENTRYPOINT ["/app/VzduchDotek.Net"]
