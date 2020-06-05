from flask import Flask, request, jsonify
from flask_ngrok import run_with_ngrok
from AFL import AFL
from ChatBot import ChatBot
from flask import Flask, render_template, session, redirect, url_for, session ,request
from flask_wtf import FlaskForm
from wtforms import TextField,SubmitField
from wtforms.validators import NumberRange

from tensorflow.keras.models import load_model
import joblib

from transformers import AutoTokenizer, AutoModelForSequenceClassification
from transformers import BertForSequenceClassification,BertTokenizer
import torch
from flask_restful import Resource, Api

import easydict

import logging
import random
from argparse import ArgumentParser
from itertools import chain
from pprint import pformat
import warnings

import torch
import torch.nn.functional as F

from transformers import OpenAIGPTLMHeadModel, OpenAIGPTTokenizer, GPT2LMHeadModel, GPT2Tokenizer
from train import SPECIAL_TOKENS, build_input_from_segments, add_special_tokens_
from utils import get_dataset, download_pretrained_model




app = Flask(__name__)
  


args = easydict.EasyDict({
        "model": 'openai-gpt',
        "dataset_path": "data/en_book_conversational.json",
        "dataset_cache": "./dataset_cache",
        "model_checkpoint":"/home/ubuntu/server/transfer-learning-conv-ai/runs/May26_10-33-33_ime-502_openai-gpt",
        "temperature": 1,
        "top_k": 70,
        "top_p": 0.5,
        "max_history": 2,
        "device" : "cuda" if torch.cuda.is_available() else "cpu",
        "no_sample": True,
        "max_length": 20, 
        "min_length" :1, 
        "seed": 0
})  
if args.model_checkpoint == "":
    if args.model == 'gpt2':
        raise ValueError("Interacting with GPT2 requires passing a finetuned model_checkpoint")
else:
    args.model_checkpoint = download_pretrained_model()
    if args.seed != 0:
        random.seed(args.seed)
        torch.random.manual_seed(args.seed)
        torch.cuda.manual_seed(args.seed)
    # logger.info("Get pretrained model and tokenizer")
    tokenizer_class, model_class = (GPT2Tokenizer, GPT2LMHeadModel) if args.model == 'gpt2' else (OpenAIGPTTokenizer, OpenAIGPTLMHeadModel)
    tokenizer = tokenizer_class.from_pretrained(args.model_checkpoint)
    model = model_class.from_pretrained(args.model_checkpoint)
    model.to(args.device)
    add_special_tokens_(model, tokenizer)
    # logger.info("Sample a personality")
    dataset = get_dataset(tokenizer, args.dataset_path,args.dataset_cache)
    personalities = [dialog["personality"] for dataset in dataset.values() for dialog in dataset]
    personality = random.choice(personalities)
    history=[]
    contents=[tokenizer.decode(i) for i in personality]
  # for i in personality:
  #   contents.append(tokenizer.decode(i))
  # print(contents)

SPELL_API_KEY='4e7548f95f7d4667bff5325b2d2c299b'
SPELL_params = {
        'mkt':'en-us',
        'mode':'proof'
             }
SPELL_headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Ocp-Apim-Subscription-Key': SPELL_API_KEY,
        }

M_tokenizer = AutoTokenizer.from_pretrained("bert-base-cased-finetuned-mrpc")
M_model = AutoModelForSequenceClassification.from_pretrained("bert-base-cased-finetuned-mrpc")

C_model =  BertForSequenceClassification.from_pretrained("/home/ubuntu/server/transfer-learning-conv-ai/data/CoLAoutput")
C_tokenizer= BertTokenizer.from_pretrained("/home/ubuntu/server/transfer-learning-conv-ai/data/CoLAoutput")  


chatbot=ChatBot(args,tokenizer,model,personalities,personality,contents)



CoLA =AFL(C_model,C_tokenizer,contents,"CoLA")
MRPC =AFL(M_model,M_tokenizer,contents,"MRPC")


@app.route('/prediction', methods = ['POST'])
def prediction():
    if AFL.count >=1:
        chatbot.personality = AFL.change_content(CoLA,MRPC,chatbot)
        AFL.count =0
    sentence = request.get_json()#json 데이터를 받아옴
    result_conv=chatbot.return_message(sample_json=sentence)
    result_mrpc =MRPC.return_prediction(sample_json=sentence)
    result_cola =CoLA.return_prediction(sample_json=sentence)
    result_spell= AFL.spell_check(sentence,SPELL_API_KEY,SPELL_params,SPELL_headers)
    AFL.count+=1
    results={'sentence': result_conv,'similarity':result_mrpc,'correct':result_cola ,'contents':chatbot.contents ,'count':AFL.count,'spell': result_spell if result_spell!=[] else ['good job'] ,'isChanged':AFL.changed_flag }
    AFL.changed_flag=False
    return jsonify(results)# 받아온 데이터를 다시 전송
 

# @app.route('/prediction/change')
# def change_content(): 
if __name__ == "__main__":
    app.run(host='0.0.0.0')