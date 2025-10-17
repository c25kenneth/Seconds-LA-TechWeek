import keras
import tensorflow as tf
from tensorflow.keras.preprocessing.image import load_img
import os
import numpy as np
import json

def rescale_image(image):
    image = image / 255.0
    resized_image = tf.image.resize(image, size=(224, 224), method='bilinear')
    return resized_image

with open('class_indices.json', 'r') as f:
    class_indices = json.load(f)

class_labels = {v: k for k, v in class_indices.items()}

test_data_dir = "test/"
model_path = "./models/epoch_04.keras"

print(f"Loading best model: {model_path}")
model = keras.models.load_model(model_path)

correct_predictions = 0
total_predictions = 0

for class_name in sorted(os.listdir(test_data_dir)):
    if not class_name.startswith('.'):
        class_dir = os.path.join(test_data_dir, class_name)
        if os.path.isdir(class_dir):
            for image_file in sorted(os.listdir(class_dir)):
                img_path = os.path.join(class_dir, image_file)

                try:
                    img = load_img(img_path)
                    img_tensor = tf.convert_to_tensor(img, dtype=tf.float32)
                    image = rescale_image(img_tensor)
                    image = tf.expand_dims(image, axis=0)

                    pred = model(image)
                    predicted_class_index = np.argmax(pred, axis=1)[0]
                    predicted_class_label = class_labels[predicted_class_index]

                    total_predictions += 1
                    result = "INCORRECT"
                    if predicted_class_label == class_name:
                        correct_predictions += 1
                        result = "CORRECT"
                    
                    print(f"File: {img_path:<60} | Actual: {class_name:<25} | Predicted: {predicted_class_label:<25} | Result: {result}")

                except Exception as e:
                    print(f"Could not process image {img_path}: {e}")

accuracy = (correct_predictions / total_predictions) * 100 if total_predictions > 0 else 0
print(f"\nFinal Accuracy for {os.path.basename(model_path)} on test set: {accuracy:.2f}%")