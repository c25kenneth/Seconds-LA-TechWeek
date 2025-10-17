import certifi
import os
os.environ['SSL_CERT_FILE'] = certifi.where()
import tensorflow as tf

from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras import layers, models, optimizers
from tensorflow.keras.callbacks import ModelCheckpoint
import numpy as np

data_dir = "./Fruit And Vegetable Diseases Dataset/"
test_dir = "./test/"

train_datagen = ImageDataGenerator(
    rescale=1./255,
    rotation_range=40,
    width_shift_range=0.2,
    height_shift_range=0.2,
    shear_range=0.2,
    zoom_range=0.2,
    horizontal_flip=True,
    fill_mode='nearest',
    validation_split=0.25
)

validation_datagen = ImageDataGenerator(rescale=1./255, validation_split=0.25)
test_datagen = ImageDataGenerator(rescale=1./255)

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

valid_data = validation_datagen.flow_from_directory(
    data_dir,
    target_size=img_size,
    batch_size=batch_size,
    class_mode="categorical",
    shuffle=False, # No need to shuffle validation data
    subset="validation"
)

test_data = test_datagen.flow_from_directory(
    test_dir,
    target_size=img_size,
    batch_size=batch_size,
    class_mode="categorical",
    shuffle=False
)

base_model = tf.keras.applications.MobileNetV2(
    include_top=False, 
    input_shape=(224, 224, 3),
    pooling='avg',
    weights='imagenet'
)

base_model.trainable = False

inputs = layers.Input(shape=(224, 224, 3))

x = base_model(inputs, training=False)
x = layers.Dense(512, activation='relu')(x)
x = layers.Dropout(0.3)(x)  
outputs = layers.Dense(28, activation='softmax')(x)

model = models.Model(inputs, outputs)

model.compile(
    loss='categorical_crossentropy',
    optimizer=optimizers.AdamW(learning_rate=5e-5),
    metrics=['accuracy']
)

model.summary()

if not os.path.exists('./models'):
    os.makedirs('./models')

checkpoint_callback = ModelCheckpoint(
    filepath='./models/efficientnet_epoch_{epoch:02d}.keras',
    save_weights_only=False,
    save_best_only=True, 
    monitor='val_loss',
    mode='min',
    verbose=1
)

history = model.fit(train_data, validation_data=valid_data, epochs=5, callbacks=[checkpoint_callback])

best_epoch = np.argmin(history.history['val_loss']) + 1
best_model_path = f"./models/efficientnet_epoch_{best_epoch:02d}.keras"

print(f"\nLoading best model from epoch {best_epoch}: {best_model_path}")
model.load_weights(best_model_path)

print("\n--- Evaluating on Test Set ---")
test_loss, test_accuracy = model.evaluate(test_data)
print(f"Test Loss: {test_loss}")
print(f"Test Accuracy: {test_accuracy}")