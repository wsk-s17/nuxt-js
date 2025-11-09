FROM node:lts-alpine AS deps
WORKDIR /app

COPY package*.json ./
RUN npm ci

FROM node:lts-alpine AS builder
WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY . .

RUN npm run build

FROM node:lts-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV NITRO_PORT=80
ENV NITRO_HOST=0.0.0.0

COPY package*.json ./
RUN npm ci --omit=dev

COPY --from=builder /app/.output ./.output

EXPOSE 80

CMD ["node", ".output/server/index.mjs"]