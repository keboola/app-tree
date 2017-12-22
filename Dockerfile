FROM python:3.6.3-alpine3.6
RUN apk add --no-cache git
RUN pip3 install --no-cache-dir --upgrade pytest flake8
RUN pip3 install --no-cache-dir --upgrade --force-reinstall git+git://github.com/keboola/python-docker-application.git@2.0.0

WORKDIR /code

# Initialize the tree runner
COPY . /code/

# Run the application
CMD python3 -u ./src/main.py --data=/data
