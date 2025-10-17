from fastapi import FastAPI, File, UploadFile
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
import numpy as np
from PIL import Image
import tensorflow as tf
import io
import json

app = FastAPI()

# Add CORS middleware to allow all origins
# For production, you should restrict this to your web app's domain
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Load the best performing model
model_path = "models/epoch_04.keras"
model = tf.keras.models.load_model(model_path)

# Load the class indices from the file created during training
with open('class_indices.json', 'r') as f:
    class_indices = json.load(f)

# Create a reverse mapping from index to class name
class_labels = {v: k for k, v in class_indices.items()}

def preprocess_image(image: Image.Image) -> np.ndarray:
    """
    Preprocesses the image for the CNN model.
    - Converts image to RGB to handle alpha channels.
    - Resizes the image to (224, 224).
    - Converts the image to a numpy array.
    - Rescales the pixel values to be in the range [0, 1].
    - Adds a batch dimension.
    """
    # Ensure image is in RGB format
    image = image.convert('RGB')
    image = image.resize((224, 224))
    image_array = np.array(image)
    
    # Scale the pixel values to the [0, 1] range
    image_array = image_array / 255.0
    
    return np.expand_dims(image_array, axis=0)

@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    """
    Accepts an image file, preprocesses it, and returns the model's prediction.
    """
    try:
        # Read the image file
        contents = await file.read()
        image = Image.open(io.BytesIO(contents))

        # Preprocess the image
        processed_image = preprocess_image(image)

        # Make a prediction
        prediction = model.predict(processed_image)
        
        # Get the predicted class index
        predicted_class_index = np.argmax(prediction, axis=1)[0]

        # Get the predicted class label
        predicted_class_label = class_labels[predicted_class_index]

        return JSONResponse(content={"prediction": predicted_class_label})
    except Exception as e:
        return JSONResponse(content={"error": str(e)}, status_code=500)

@app.get("/")
def read_root():
    return {"message": "Welcome to the Food Waste API"}
