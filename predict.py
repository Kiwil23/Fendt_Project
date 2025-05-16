# loads a pretrained model and predicts on the selected data

from ultralytics import YOLO
from pathlib import Path
import cv2
import glob

# load pretrained model
model_path = Path().resolve()
#TODO hier nach bedarf Pfad noch genau anpassen
model_path = model_path.joinpath("runs\\detect\\train_4_original-only\\weights\\best.pt")
model = YOLO(model_path)

# CV2
images = glob.glob("Datasets\\Expanded_4_original-only\\val\\images\\*")
imgList = []

print(images)

for img in images:
    temp = cv2.imread(img)
    imgList.append(temp)


results = model.predict(source=imgList, save=True, save_txt=True, conf=0.5, show_labels=False)

for result in results:
    boxes = result.boxes
    print(boxes.conf)
    masks = result.masks  # Masks object for segmentation masks outputs
    keypoints = result.keypoints  # Keypoints object for pose outputs
    probs = result.probs  # Probs object for classification outputs
    obb = result.obb  # Oriented boxes object for OBB outputs