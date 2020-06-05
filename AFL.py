from ChatBot import ChatBot
import torch
import torch.nn.functional as F
import numpy as np
import random
import requests
import json
class AFL:
    count=0
    changed_flag=False

    def __init__(self, model, tokenizer, contents,name):
        self.model = model
        self.tokenizer= tokenizer
        self.score=[]
        self.contents =contents
        self.name = name

    def return_prediction(self,sample_json):
        sen_1 = sample_json['text']
        out_put= []
        if self.name == "MRPC":
      # personalities=["may i help you yes please.", "do you have long - sleeve shirts?", "yes", "they are right here. how much are they? ","they are 15 dollars each do you have any larger sizes what about these?", "there are larger and more colorful.", "this one looks good. can i try this on? sure." ,"the fitting room is over there.", "what do you think? that looks really good on you", "thanks.", "i will take this"] 

            classes = ["not paraphrase", "is paraphrase"]
            for i in self.contents:
                sequence_persona=i
                paraphrase = self.tokenizer.encode_plus(sen_1, sequence_persona, return_tensors="pt")
                paraphrase_classification_logits = self.model(**paraphrase)[0]
                paraphrase_results = torch.softmax(paraphrase_classification_logits, dim=1).tolist()[0]
                out_put.append(paraphrase_results[1])
            out_put=np.array(out_put)
            out_put_max=np.max(out_put)
            self.score.append(round(out_put_max*100))
      # if AFL.count==10:
      #   avg =average(self.score,AFL.count)
      #   return avg
      
            results = {"max_value":round(out_put_max*100)}

            return round(out_put_max*100)

        elif self.name == "CoLA":
            classes = ["wrong", "correct"]
            paraphrase = self.tokenizer.encode_plus(sen_1, return_tensors="pt")
            paraphrase_classification_logits = self.model(**paraphrase)[0]
            paraphrase_results = torch.softmax(paraphrase_classification_logits, dim=1).tolist()[0]
            self.score.append(round(paraphrase_results[1] * 100))
      # if AFL.count==10:
      #   avg =average(self.score,AFL.count)
      #   return avg
      # results = {classes[1]: paraphrase_results[1]}
            print(self.score)
            return round(paraphrase_results[1] * 100)

    def spell_check(x,api_key,param,header):
        result=[]
        api_key = api_key
        example_text = x # the text to be spell-checked
        endpoint = "https://api.cognitive.microsoft.com/bing/v7.0/SpellCheck"
        data = {'text': example_text}
        params = param
        headers = header
        response = requests.post(endpoint, headers=headers, params=params, data=data)
        json_response = response.json()
        if json_response['flaggedTokens']:
            for i in range(0,len(json_response['flaggedTokens'])):
                max=0
                max_word=''
                for j in range(0,len(json_response['flaggedTokens'][i]['suggestions'])):
                    if max < json_response['flaggedTokens'][i]['suggestions'][j]['score']:
                        max = json_response['flaggedTokens'][i]['suggestions'][j]['score']
                        max_word=json_response['flaggedTokens'][i]['suggestions'][j]['suggestion']
                        result.append(f"{json_response['flaggedTokens'][i]['token']}-->{max_word}")
        return result
  
    def average(self):
        return sum(self.score)/AFL.count
  
    @classmethod
    def change_content(cls,CoLA,MRPC,chatbot):
        CoLA_avg = CoLA.average()
        MRPC_avg = MRPC.average()
        
        print(CoLA_avg,MRPC_avg)
        personality =chatbot.personality
        if CoLA_avg >80 and MRPC_avg > 70 and AFL.changed_flag ==False :
            contents=[]
            personality = random.choice(chatbot.personalities)
            
            for i in personality:
                contents.append(chatbot.tokenizer.decode(i))
            
            AFL.changed_flag=True
            print(chatbot.contents)
            print('_____________')
            print(contents)
            return personality
        else:
            return personality

        