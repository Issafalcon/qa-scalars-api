FROM node:gallium

WORKDIR /home/node
COPY package*.json ./
RUN npm ci

COPY public public
COPY *.js ./
RUN npm test

EXPOSE 8080/tcp
ENTRYPOINT ["npm"]
CMD ["start"]





