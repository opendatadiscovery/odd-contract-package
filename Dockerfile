FROM openapitools/openapi-generator:cli-v5.0.1 AS openapi_generator

COPY ./opendatadiscovery-specification/specification /spec
COPY ./openapi_generator/controller.mustache ./openapi_generator/__init__.mustache /templates/
RUN java -jar openapi-generator-cli.jar generate \
    -i /spec/odd_adapter.yaml \
    -g python-flask \
    -o /generated \
    -t /templates \
    --additional-properties=packageName=odd_contract

FROM python:3.9.1

ARG ODD_CONTRACT_VERSION
ENV ODD_CONTRACT_VERSION=$ODD_CONTRACT_VERSION

ARG TWINE_USERNAME
ENV TWINE_USERNAME=$TWINE_USERNAME

ARG TWINE_PASSWORD
ENV TWINE_PASSWORD=$TWINE_PASSWORD

WORKDIR package
COPY --from=openapi_generator  /generated/odd_contract odd_contract
COPY odd_contract/__init__.py odd_contract
COPY setup.py README.md ./

RUN pip install --user --upgrade twine && \
    python3 setup.py sdist bdist_wheel && \
    python3 -m twine upload --repository testpypi dist/*