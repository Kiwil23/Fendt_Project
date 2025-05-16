import cv2

from inference import do_inference
import time

imgList = []
img = cv2.imread("./Hund.jpg")
img2 = cv2.imread("./Katze.jpg")
imgList.append(img)
imgList.append(img2)

complete_start = time.time()

for i in imgList:
    single_start = time.time()
    do_inference(i)
    single_inference_time = time.time() - single_start
    print(f"Single ITime is: {single_inference_time}")

complete_inference = time.time() - complete_start

print("")
print(f"Complete ITime is: {complete_inference}")   
       