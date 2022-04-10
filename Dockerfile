FROM telesoftdevops/devops:telesoft-parkings-app-base

COPY . /opt/parkings/
COPY ./temp/env.conf /opt/parkings/env/.env
COPY ./temp/nginx.conf /etc/nginx/sites-enabled/default
COPY ./temp/filebeat.yml /etc/filebeat/filebeat.yml

WORKDIR /opt/parkings
RUN rm -rf temp
RUN chmod go-w /etc/filebeat/filebeat.yml

CMD bash -C 'runner.sh';'bash'
