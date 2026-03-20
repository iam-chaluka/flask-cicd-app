FROM python:3.11-slim #python base image #slim is a stripped down version of the full Python image 

WORKDIR /app #setting the working directory inside the container. creates the directory if doesn't exist

COPY requirements.txt . #copying req.txt into container first. Before copying the rest of the code
RUN pip install --no-cache-dir -r requirements.txt #not caching inorder to keep the image smaller
 
COPY . . #copying all the application code into the container
EXPOSE 5000 #just documenting that this container listens on port 5000

CMD ["python", "app.py"] #CMD commands run when the container starts. 
#uses json array format
#run commands directly withput a shell wrapper.
