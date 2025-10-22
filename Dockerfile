FROM node:24-alpine AS builder

WORKDIR /app

# Copia arquivos de dependências e as instala
COPY package*.json ./
RUN npm ci

# Copia o restante para a etapa de build 
COPY . .

### Etapa final (menor imagem runtime)
FROM node:24-alpine AS runtime

WORKDIR /app

# Copia apenas o que é necessário da etapa builder
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/server.js ./
COPY --from=builder /app/package.json ./

# Cria um usuário não-root para rodar a aplicação
RUN addgroup -S appgroup \
	&& adduser -S appuser -G appgroup

# Ajusta permissões (caso tenha diretórios que precisem)
RUN chown -R appuser:appgroup /app

EXPOSE 80

USER appuser

CMD ["npm", "start"]
