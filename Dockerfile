# -- START WITH BUILD SECTION -- #
# DEFINE BASIC IMAGE
FROM python:3.13-alpine3.19 AS build

# DEFINE BASIC ENV
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1


RUN apk upgrade --no-cache
RUN apk add --no-cache gcc musl-dev python3-dev libffi-dev openssl-dev libstdc++

# DEFINE WORKDIR AND COPY FILES
WORKDIR /app
RUN mkdir -p /app/superduperpancake
COPY requirements.txt /app/

# CREATE PYTHON VIRTUAL ENVIRONMENT AND SETUP PREREQUISITES
RUN python3 -m venv /app/venv
RUN . /app/venv/bin/activate && \
    python3 -m ensurepip --upgrade && \
    python3 -m pip install -r /app/requirements.txt && \
    prisma generate
#RUN chmod +x entrypoint.sh
# -- START WITH APP SECTION -- #

# DEFINE BASIC IMAGE
FROM python:3.13-alpine3.19 AS final

# DEFINE FINAL IMAGE ATTRIBUTES / LABELS
LABEL org.opencontainers.image.authors="tbd@mail.tld"
LABEL org.opencontainers.image.description="This is the backend API container in super duper pancake deployment"
LABEL org.opencontainers.image.notice="This container requieres a postgres SQL DB backend"
LABEL org.opencontainers.image.version="1.0.0"
LABEL org.opencontainers.image.title="Super Duper Pancake API"

# UPDATE PACKAGES
RUN apk upgrade --no-cache

# DEFINE WORKDIR AND COPY FILES FROM build IMAGE
WORKDIR /app
COPY --from=build /app /app
COPY --from=build /root /root
COPY --from=build /usr/lib /usr/lib
#COPY --from=build / /

# COPY APP RESOURCES
COPY entrypoint.sh ./

# MAKE ENTRYPOINT EXECUTABLE
RUN chmod a+x /app/entrypoint.sh

# ENABLE VENV
RUN . /app/venv/bin/activate
ENV VIRTUAL_ENV=/app/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# EXPOSE PORT TO ACCESS CONTAINER
EXPOSE 8000

# DEFINE ENTRYPOINT
#ENTRYPOINT [ "uvicorn", "--host", "0.0.0.0", "main:app" ]
ENTRYPOINT ["/app/entrypoint.sh"]
