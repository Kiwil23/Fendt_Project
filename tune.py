from ultralytics import YOLO
from pathlib import Path


# load pretrained model
path = Path().resolve()
path = path.joinpath("YOLO_models\yolo11n.pt")  #TODO der Buchstabe hinter der 11 gibt die Modellgröße an, verfügbar sind n, s, m, l, xl
model = YOLO(path)

# Define search space
search_space = {
    "lr0": (1e-5, 1e-1),
    "degrees": (0.0, 45.0),
}

if __name__ == '__main__':
    #freeze_support()
    model.tune(
        data="train.yaml",
        epochs=30,
        iterations=300,
        optimizer="auto",
        space=search_space,
        plots=True,
        save=False,
        val=True,
    )