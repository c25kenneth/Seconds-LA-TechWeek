import certifi
import os
os.environ['SSL_CERT_FILE'] = certifi.where()
import tensorflow as tf

from tensorflow.keras.regularizers import l2
from tensorflow.keras.preprocessing.image import ImageDataGenerator, load_img, img_to_array
from tensorflow.keras.applications import EfficientNetB0, EfficientNetV2B0
from tensorflow.keras import layers, models, optimizers, Model
from tensorflow.keras.callbacks import ReduceLROnPlateau, ModelCheckpoint
import keras
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.metrics import confusion_matrix, classification_report
import os
import random
import json


data_dir = "./Fruit And Vegetable Diseases Dataset/"

train_datagen = ImageDataGenerator(
    rescale=1./255,
    validation_split=0.25
)

batch_size = 64
img_size = (224, 224)

train_data = train_datagen.flow_from_directory(
    data_dir,
    target_size=img_size,
    batch_size=batch_size,
    class_mode="categorical",
    shuffle=True,
    subset="training"
)

valid_data = train_datagen.flow_from_directory(
    data_dir,
    target_size=img_size,
    batch_size=batch_size,
    class_mode="categorical",
    shuffle=True,
    subset="validation"
)

valid_data.reset()
images, labels = next(valid_data)

# Obtain predictions
mobilenet_model = keras.models.load_model("models/efficientnet_epoch_05.keras")

predictions = mobilenet_model.predict(images)

# Convert outputs to predicted classes
predicted_classes = np.argmax(predictions, axis=1)
true_classes = np.argmax(labels, axis=1)

# Display images along with predictions
plt.figure(figsize=(10, 20))
for i in range(10):  # Display the first 10 images
    plt.subplot(2, 5, i + 1)
    plt.imshow(images[i])
    plt.axis('off')

    true_label = list(valid_data.class_indices.keys())[true_classes[i]]
    pred_label = list(valid_data.class_indices.keys())[predicted_classes[i]]

    color = "green" if true_label == pred_label else "red"
    plt.title(f"True: {true_label}\nPred: {pred_label}", color=color)

plt.show()