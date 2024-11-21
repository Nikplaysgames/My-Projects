import os
from PIL import Image, ImageFont, ImageDraw
import requests
import imageai
#from imageai.detection import ObjectDetection
#import openai
from openai import OpenAI

os.environ["REPLICATE_API_TOKEN"] = "eee"
os.environ["OPENAI_API_KEY"] = "eee"

import replicate
import ChatMyGPT
import textwrap



path = "IMG_1778.jpg"    #path of the image
#imageText = "" #text to put on from the api
Rcol = 255
Gcol = 255
Bcol = 255
imageProcessOutput = ""
memeText = ""
saveLocation = "meme-image10.jpg"



def draw_multiple_line_text(image, text, font, text_color, text_start_height, fontSize):
   
    draw = ImageDraw.Draw(image)
    image_width, image_height = image.size
    y_text = text_start_height
    lines = textwrap.wrap(text, width=40)
    for line in lines:
        throw1, throw2, line_width, line_height = font.getbbox(line)
        draw.text(((image_width - line_width) / 2, y_text), 
                  line, font=font, fill=text_color)
        y_text += line_height


def OverlayImage():
    img = Image.open(path)
    width, height = img.size
   # print(width)
   # print("    ")
   # print(height)
    fontSize = (width/20)


    Im = ImageDraw.Draw(img)
    fill_color = (Rcol,Gcol,Bcol)

    dafont = ImageFont.truetype('impact.ttf', fontSize)   
    
    
   # print("font done")
    draw_multiple_line_text(img, memeText, dafont, fill_color, (height/10)*7, fontSize)
  
    #Im.text((width/15, (height/10)*6), memeText, font=dafont, fill=fill_color, align='center')
    
    #img.show()

    img.save(saveLocation)
   

def ProcessImage():
    output = replicate.run(
    "andreasjansson/blip-2:f677695e5e89f8b236e52ecd1d3f01beb44c34606419bcc19345e046d8f786f9",
    input= {"image": open(path, "rb"), "prompt": "Describe this image in 20 words or less"}
    )
    #print(output)
    global imageProcessOutput
    imageProcessOutput = output

def getMemeText():
    global memeText
    memeText = ChatMyGPT.doEverything(imageProcessOutput)

def setPath(input):
    global path
    path = input




print("Starting!")
#ProcessImage()

#print(path)
#setPath("meme-image5.jpg")
#print(path)

#print(imageProcessOutput)

#hellothere()
#main()
#OverlayImage(path)


#NOW TO ACTUALLY RUN THE CODE. MWHAHAHHAAHAH

#Step 1: Process the Image

ProcessImage()
print("step 1 finished")
#Step 2: Get the ChatGPT meme

getMemeText()
print("step 2 finished")
#Step 3: Overlay text onto image

OverlayImage()


print("Done!")








