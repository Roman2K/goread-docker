FROM google/cloud-sdk:alpine

RUN gcloud components install app-engine-go
RUN apk update && apk add git go su-exec

ARG goapp_dir=/google-cloud-sdk/platform/google_appengine
ENV PATH=${goapp_dir}:$PATH
RUN chmod +x $goapp_dir/goapp

ARG goread_repo=github.com/mjibson/goread
ENV GOPATH=/go
RUN goapp get -d $goread_repo

WORKDIR $GOPATH/src/$goread_repo
RUN cp settings.go.dist settings.go

WORKDIR $GOPATH/src/$goread_repo/app
RUN cp app.sample.yaml app.yaml

EXPOSE 8000/tcp 8080/tcp
VOLUME /tmp/storage

ENV HOME=/home/goread
ENV PUID=1000 PGID=1000
RUN mkdir $HOME

CMD chown -R $PUID:$PGID $HOME && su-exec $PUID:$PGID \
  env HOME=$HOME \
    dev_appserver.py \
      --host=0.0.0.0 \
      --admin_host=0.0.0.0 \
      --enable_host_checking=false \
      --storage_path=/tmp/storage \
      app.yaml
