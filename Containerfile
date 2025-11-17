FROM placeholder:latest

RUN bootc container lint || true
