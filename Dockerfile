# Use Node.js 22 Alpine as the base image

FROM node:22-alpine

# Create a non-root user and group
# This improves security by preventing the application from running as root

RUN addgroup -S app && adduser -S app -G app

# Set the working directory

WORKDIR /app

# Copy package files first to take advantage of Docker layer caching

COPY package*.json ./

# Install dependencies

RUN npm install

# Copy the rest of the application files

COPY . .

# Give the app user ownership of the application files

RUN chown -R app:app /app

# Run the application as the non-root user

USER app

# Vite development server runs on port 5173

EXPOSE 5173

# Start the Vite development server
# --host makes the server accessible outside the container

CMD ["npm", "run", "dev", "--", "--host"]