FROM python:3.5-alpine as base

########################################
# Setup libray for development
########################################
FROM base as extension-builder

# Setup spatialite extension for SQLite3
RUN echo "@edge http://nl.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories
RUN echo "@edge-testing http://nl.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories
RUN apk update

RUN apk add wget gcc make libc-dev sqlite-dev zlib-dev libxml2-dev "proj4-dev@edge-testing" "geos-dev@edge-testing" "gdal-dev@edge-testing" "gdal@edge-testing" expat-dev readline-dev ncurses-dev ncurses-static libc6-compat

RUN wget "http://www.gaia-gis.it/gaia-sins/freexl-1.0.5.tar.gz" && tar zxvf freexl-1.0.5.tar.gz && cd freexl-1.0.5 && ./configure && make && make install && cd ../
RUN wget "http://www.gaia-gis.it/gaia-sins/libspatialite-4.3.0a.tar.gz" && tar zxvf libspatialite-4.3.0a.tar.gz && cd libspatialite-4.3.0a && ./configure && make && make install && cd ../
RUN wget "http://www.gaia-gis.it/gaia-sins/readosm-1.1.0.tar.gz" && tar zxvf readosm-1.1.0.tar.gz && cd readosm-1.1.0 && ./configure && make && make install && cd ../
RUN wget "http://www.gaia-gis.it/gaia-sins/spatialite-tools-4.3.0.tar.gz" && tar zxvf spatialite-tools-4.3.0.tar.gz && cd spatialite-tools-4.3.0 && ./configure && make && make install && cd ../

RUN cp -R /usr/local/lib/* /usr/lib/
RUN cp /usr/local/bin/* /usr/bin/


FROM base as dependencies-builder
# Install build tools for psycopg2 and flask-bcrypt
RUN apk add --no-cache bash \ 
    && apk --no-cache add build-base libffi-dev postgresql-dev \
    && apk --no-cache add python3-dev linux-headers pcre-dev
RUN mkdir /install
WORKDIR /install


####################################################
# Setup third party libs for project
####################################################

FROM dependencies-builder as local-builder
# Install python lib for project
COPY requirements/* /requirements/
RUN pip install --prefix=/install -r /requirements/local.txt

FROM dependencies-builder as prod-builder
# Install python lib for project
COPY requirements/* /requirements/
RUN pip install --prefix=/install -r /requirements/prod.txt

####################################################
# Setup images for local and prod environement
####################################################

FROM base as local-stage
RUN apk add --no-cache bash
COPY --from=local-builder /install /usr/local
COPY --from=local-builder /usr/lib/ /usr/lib/
COPY --from=extension-builder /usr/lib/ /usr/lib/

# Staging and Production
FROM base
RUN apk add --no-cache bash
COPY --from=prod-builder /install /usr/local
# TODO: Try to remove this line and test on AWS
COPY --from=prod-builder /usr/lib/ /usr/lib/
