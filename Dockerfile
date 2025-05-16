# # Use the official Node.js image as a base image
# FROM node:20-alpine

# # Set the working directory inside the container
# WORKDIR /app

# # Copy package.json and package-lock.json files
# COPY package*.json ./

# # Install dependencies
# RUN npm install

# # Copy the rest of the application code
# COPY . .

# # Build the Next.js application
# RUN npm run build

# # Expose the port the app runs on
# EXPOSE 3000

# # Command to start the application
# CMD ["npm", "start"]


# 1) BUILD STAGE
FROM node:20-alpine AS builder

# Create app directory
WORKDIR /app

# Only copy package files first for better caching
COPY package.json package-lock.json ./

# Install all deps (including dev)
RUN npm ci

# Copy source code & build
COPY . .
RUN npm run build

# 2) PRODUCTION STAGE
FROM node:20-alpine AS runner

WORKDIR /app

# Copy only production node_modules from builder
# - prune removes devDependencies
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./

# Copy built Next.js output
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public

# Set NODE_ENV to production (npm will skip dev modules)
ENV NODE_ENV=production

# Expose and run
EXPOSE 3000
CMD ["node_modules/.bin/next", "start"]
