# 🐳 Dockerize a React Application

 This guide walks through the process of creating a React application with Vite, Dockerizing it, running it locally, enabling live code changes with Docker volumes, and publishing the image to Docker Hub.

---

 ## 1\. Create the React Application

 First, create a new Vite React application:

```
npm create vite@latest
```

 When prompted:

 1. Enter `react-docker` as the project name.
2. Select **React** as the framework.
3. Select your preferred variant, such as **TypeScript**.

 Then move into the project directory:

```
cd react-docker
```

 > **Note:** There is no need to run `npm install` locally. The dependencies will be installed inside the Docker container.

---

 ## 2\. Open the Project in VS Code

 From inside the `react-docker` directory, open the project in VS Code:

```
code .
```

 Your project should look similar to:

```
react-docker/
├── public/
├── src/
├── .gitignore
├── index.html
├── package.json
├── tsconfig.json
└── vite.config.ts
```

---

 ## 3\. Create a Dockerfile

 Create a file called:

```
Dockerfile
```

 Add the following:

```
# Set the base image for the React application
FROM node:22-alpine

# Create a non-root user and group
# -S creates a system user/group
# Running the application as a non-root user improves security
RUN addgroup -S app && adduser -S app -G app

# Set the working directory
WORKDIR /app

# Copy package files first
# This allows Docker to cache the dependency installation layer
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application files
COPY . .

# Change ownership of the application files
# so the non-root user can access them
RUN chown -R app:app /app

# Run the application as the non-root user
USER app

# Expose the Vite development server port
EXPOSE 5173

# Start the Vite development server
# --host makes the application accessible outside the container
CMD ["npm", "run", "dev", "--", "--host"]
```

 ### Why use a non-root user?

 Running applications as `root` inside containers is generally discouraged. If the application contains a vulnerability, running it as a non-root user helps reduce the potential impact.

---

 ## 4\. Create a `.dockerignore` File

 Create another file in the root of the project:

```
.dockerignore
```

 Add:

```
node_modules/
dist/
.git/
```

 This prevents unnecessary files from being copied into the Docker image.

---

 ## 5\. Build the Docker Image

 Build the Docker image with:

```
sudo docker build -t react-docker .
```

 The `.` at the end tells Docker to use the **current directory** as the build context.

 You can verify that the image was created:

```
sudo docker images
```

 You should see an image named:

```
react-docker
```

---

 ## 6\. Run the Docker Container

 Run the container:

```
sudo docker run react-docker
```

 At this point, the Vite application is running inside the container.

 However, you will not yet be able to access it from your browser because the container's port has not been mapped to your host machine.

 Press:

```
Ctrl + C
```

 to stop the container.

---

 ## 7\. Access the Application on localhost

 To make the application available on your local machine, map port `5173` on your computer to port `5173` inside the container:

```
sudo docker run -p 5173:5173 react-docker
```

 The format is:

```
-p HOST_PORT:CONTAINER_PORT
```

 Open your browser and go to:

```
http://localhost:5173
```

 You should now see your React application.

---

 ## 8\. Enable Live Changes with a Docker Volume

 When developing the application, you may want changes made to your source code to appear immediately without rebuilding the Docker image.

 For example, you might modify:

```
src/App.tsx
```

 To allow Docker to access your local project files, create a volume with:

```
sudo docker run \
  -p 5173:5173 \
  -v "$(pwd):/app" \
  -v /app/node_modules \
  react-docker
```

 ### What do these options do?

 #### Port mapping

```
-p 5173:5173
```

 Makes the application available at:

```
http://localhost:5173
```

 #### Application volume

```
-v "$(pwd):/app"
```

 Maps your current project directory to `/app` inside the container.

 This means changes you make locally are available inside the container.

 #### Node modules volume

```
-v /app/node_modules
```

 Keeps the container's `node_modules` directory separate from your local project directory.

 This is important because your `.dockerignore` excludes `node_modules`.

---

 ## 9\. Publish the Image to Docker Hub

 Once your Docker image is ready, you can publish it to Docker Hub.

 First, log in to Docker Hub:

```
sudo docker login
```

 Then tag your image:

```
sudo docker tag react-docker techwithjean/react-docker
```

 Push the image:

```
sudo docker push techwithjean/react-docker
```

 Your image will then be available on Docker Hub as:

```
techwithjean/react-docker
```

 Other users can download the image with:

```
docker pull techwithjean/react-docker
```

 And run it with:

```
docker run -p 5173:5173 techwithjean/react-docker
```

 Then open:

```
http://localhost:5173
```

---

 ## 🚀 Quick Command Summary

 ### Create the project

```
npm create vite@latest
cd react-docker
code .
```

 ### Build the image

```
sudo docker build -t react-docker .
```

 ### Run the container

```
sudo docker run -p 5173:5173 react-docker
```

 ### Run with live code changes

```
sudo docker run \
  -p 5173:5173 \
  -v "$(pwd):/app" \
  -v /app/node_modules \
  react-docker
```

 ### Log in to Docker Hub

```
sudo docker login
```

 ### Tag the image

```
sudo docker tag react-docker techwithjean/react-docker
```

 ### Push to Docker Hub

```
sudo docker push techwithjean/react-docker
```

---

 ## 🌐 Access the Application

 After starting the container, open:

 **http://localhost:5173**

 Your React application is now running inside Docker! 🐳⚛️
