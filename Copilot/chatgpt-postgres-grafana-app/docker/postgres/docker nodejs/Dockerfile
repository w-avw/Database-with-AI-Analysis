
# Dockerfile for Node.js app container
FROM node:20

# 1. Set working directory
WORKDIR /app

# 2. Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# 3. Copy all source code into the container
COPY . .

# 4. Start the Node.js app
CMD ["node", "src/index.js"]