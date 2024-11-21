import os
from openai import OpenAI
os.environ["OPENAI_API_KEY"] = "nicetrylol"

#import json


#input better be a string
def doEverything(input):
    content1 = "Generate a meme caption for this image description in under 20 words:"
    content2 = input
    content = content1 + content2
    



    client = OpenAI(
    # This is the default and can be omitted
    api_key=os.environ.get("OPENAI_API_KEY"),
        )

    chat_completion = client.chat.completions.create(
    messages=[
        {
            "role": "user",
            "content": content,
        }
    ],
    model="gpt-3.5-turbo",
    )


    text = chat_completion.choices[0].message.content

    #print(text)
    return text


#toPrint = doEverything("a guy eating a banana")
#print(toPrint)