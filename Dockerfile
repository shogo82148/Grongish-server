FROM public.ecr.aws/lambda/python:3.14 AS builder

ENV MECAB_VERSION=0.996.13
ENV GRONGISH_VERSION=0.0.5

RUN dnf install -y tar gzip

# the wheel bundles libmecab, so MeCab itself doesn't need to be built
RUN pip install --target /opt/task "mecab==${MECAB_VERSION}"

RUN curl -o /tmp/Grongish.tar.gz -fsSL "https://github.com/shogo82148/Grongish/releases/download/v${GRONGISH_VERSION}/Grongish.tar.gz" \
    && tar zxvf /tmp/Grongish.tar.gz -C /opt/task --strip-components=1

FROM public.ecr.aws/lambda/python:3.14

COPY --from=builder /opt/task/ "${LAMBDA_TASK_ROOT}/"
COPY app.py "${LAMBDA_TASK_ROOT}/"

CMD ["app.lambda_handler"]
