FROM alpine
MAINTAINER farwayer <farwayer@gmail.com>

ARG password

RUN apk update && apk add gnupg
COPY secret /secret
COPY decrypt /bin
RUN tar cvC secret . | gpg -c --verbose --batch --passphrase "$password"\
 -o secret.tar.gpg && rm -rf secret
