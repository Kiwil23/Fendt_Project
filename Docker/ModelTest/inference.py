from ultralytics import YOLO

# Load model once, outside the function
model = YOLO("/ModelTest/yolo11n.pt")
model.to('cuda')  # Move model to GPU

def do_inference(img):
    predictions = model(img, augment=False)

    result = []
    for prediction in predictions:
        summary = prediction.summary()
        for single_obj in summary:
            # print(single_obj)
            result.append([single_obj['box']['x1'],
                           single_obj['box']['y1'],
                           single_obj['box']['x2'],
                           single_obj['box']['y2'],
                           single_obj['class'],
                           single_obj['confidence']
                           ])

    return result