import os
import random
import shutil

data_dir = "Fruit And Vegetable Diseases Dataset/"
test_dir = "test/"

if not os.path.exists(test_dir):
    os.makedirs(test_dir)

for class_name in os.listdir(data_dir):
    if not class_name.startswith('.'):
        class_dir = os.path.join(data_dir, class_name)
        if os.path.isdir(class_dir):
            test_class_dir = os.path.join(test_dir, class_name)
            if not os.path.exists(test_class_dir):
                os.makedirs(test_class_dir)

            image_files = os.listdir(class_dir)
            num_images_to_move = int(len(image_files) * 0.2)
            images_to_move = random.sample(image_files, num_images_to_move)

            for image_file in images_to_move:
                src_path = os.path.join(class_dir, image_file)
                dest_path = os.path.join(test_class_dir, image_file)
                shutil.move(src_path, dest_path)
