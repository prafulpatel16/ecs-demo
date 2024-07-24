# Use an official nginx image as the base image
FROM nginx:alpine

# Copy the HTML file to the nginx directory
COPY index.html /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start nginx when the container launches
CMD ["nginx", "-g", "daemon off;"]
