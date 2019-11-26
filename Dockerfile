FROM kiwicom/black

LABEL maintainer="Jonathan Medwig"
LABEL repository="https://github.com/medwig/autoblack"
LABEL homepage="https://github.com/medwig/autoblack"

LABEL com.github.actions.name="autoblack"
LABEL com.github.actions.description="Automatically formats Python code with Black."
LABEL com.github.actions.icon="code"
LABEL com.github.actions.color="blue"

COPY LICENSE README.md /

COPY entrypoint.sh /entrypoint.sh
COPY example example
ENTRYPOINT ["/entrypoint.sh"]
CMD ["--help"]
