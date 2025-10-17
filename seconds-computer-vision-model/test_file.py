import keras
import tensorflow as tf
from tensorflow.keras.preprocessing.image import load_img
import os
import numpy as np
import json


def rescale_image(image):
    # Rescale pixels from [0, 255] to [0, 1]
    resized_image = tf.image.resize(image, size=(224, 224), method='bilinear')
    image = tf.expand_dims(resized_image, axis=0)
    return image


with open('class_indices.json', 'r') as f:
    class_indices = json.load(f)

class_labels = {v: k for k, v in class_indices.items()}

model_path = "./models/efficientnet_epoch_05.keras"

food_model = keras.models.load_model(model_path)

image = load_img("./IMG_9093.png")
image = rescale_image(image)

pred = food_model(image)
predicted_class_index = np.argmax(pred, axis=1)[0]
predicted_class_label = class_labels[predicted_class_index]

print(f"Predicted class: {predicted_class_label}")

if "Rotten" in predicted_class_label:
    print("The food is rotten.")
else:
    print("The food is not rotten.")