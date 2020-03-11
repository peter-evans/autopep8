FROM python:3.8.2-alpine3.10

LABEL maintainer="Peter Evans <mail@peterevans.dev>"
LABEL repository="https://github.com/peter-evans/autopep8"
LABEL homepage="https://github.com/peter-evans/autopep8"

LABEL com.github.actions.name="autopep8"
LABEL com.github.actions.description="Automatically formats Python code to conform to the PEP 8 style guide."
LABEL com.github.actions.icon="code"
LABEL com.github.actions.color="blue"

COPY LICENSE README.md /

COPY requirements.txt /tmp/
RUN pip install --requirement /tmp/requirements.txt
RUN apk add git
RUN apk add bash

COPY setup.cfg /setup.cfg
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["--help"]