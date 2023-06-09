FROM ubuntu

RUN apt-get update
RUN apt-get install python3 -y

RUN apt install python3-pip -y
RUN pip install flask-mysql

COPY . /opt/source-code

ENTRYPOINT FLASK_APP=/opt/source-code/app.py flask run
