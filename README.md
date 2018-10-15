### What is Flask Alpine?

Flask Alpine is an distribution for Flask application stack built based on Alpine. This image has to 2 tags:

* Prod: Production purpose - 166MB which contains the following packages and python libs:
  * flask==1.0.2
  * flask-sqlalchemy==2.3.2
  * flask-migrate==2.2.1
  * flask-restful==0.3.6
  * flask-bcrypt==0.7.1
  * flask-jwt-extended==3.12.1
  * psycopg2==2.7.5
  * gunicorn==19.9.0
  * geoalchemy2==0.5.0

* Local: Development purpose - 423MB which add more packages for development and unit testing:
  * pylint==2.1.1
  * pytest==3.8.2
  * coverage==4.5.1
  * Faker==0.9.1
  * requests==2.19.1
  * Spatialite extension which support GIS for Sqlite3.
