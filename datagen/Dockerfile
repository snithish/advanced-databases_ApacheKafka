FROM python:3.7-slim
RUN pip install pipenv
WORKDIR /usr/src/app
COPY Pipfile ./
COPY Pipfile.lock ./
RUN set -ex && pipenv install --deploy --system
COPY . ./
EXPOSE 5000
CMD ["waitress-serve", "--port", "5000", "--call", "data_gen_service:create_app"]