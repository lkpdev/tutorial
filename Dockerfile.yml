FROM python:3.11-slim as build


RUN pip install "poetry==$POETRY_VERSION" \
&& poetry install --no-root --no-ansi --no-interaction \
&& poetry export -f requirements.txt -o requirements.txt
  
  
  ### Final stage
FROM python:3.11-slim as final

WORKDIR /app

COPY --from=build /app/requirements.txt .

RUN pip install -r requirements.txt