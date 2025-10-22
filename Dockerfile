#Imagem oficial do Node
FROM node:24-alpine

#Definindo o diretório de trabalho
WORKDIR /app

#Copiando os arquivos de dependências
COPY package*.json ./

#Instalando as dependências
RUN npm ci

#Copiando o restante dos arquivos da aplicação
COPY . .

EXPOSE 80

#Comando para iniciar a aplicação
CMD ["npm", "start"]
