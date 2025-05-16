from ultralytics import YOLO
from pathlib import Path


# load pretrained model
path = Path().resolve()
path = path.joinpath("YOLO_models\yolo11s.pt")  #TODO der Buchstabe hinter der 11 gibt die Modellgröße an, verfügbar sind n, s, m, l, xl
model = YOLO(path)

#resumePath = Path().resolve()
#resumePath = resumePath.joinpath("runs\\detect\\train\\weights\\last.pt")
#resumeModel = YOLO(resumePath)

if __name__ == '__main__':
    #to resume replace model with resumeModel
    results = model.train(
        data="train.yaml",
        epochs=60,
        batch=-1,
        imgsz=640,
        device=0,
        optimizer="auto",
        lr0=1e-2,
        lrf=1e-2,
        val=True,
        plots=True,
        #multiscaling
        #multi_scale=True,  # Enable multi-scale training
        #scale=0.5,  # Scale factor range for multi-scale training
        #resume
        #resume=True,
    )

    #results = resumeModel.train(resume=True, data="train.yaml")