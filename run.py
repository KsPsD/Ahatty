from tensorflow.keras.models import load_model
import joblib

from transformers import AutoTokenizer, AutoModelForSequenceClassification
from transformers import BertForSequenceClassification, BertTokenizer
import torch
from flask_restful import Resource, Api

import easydict

import logging
import random
from argparse import ArgumentParser
from itertools import chain
from pprint import pformat
import warnings
import time
import torch
import torch.nn.functional as F

from transformers import OpenAIGPTLMHeadModel, OpenAIGPTTokenizer, GPT2LMHeadModel, GPT2Tokenizer
from train import SPECIAL_TOKENS, build_input_from_segments, add_special_tokens_
from utils import get_dataset, download_pretrained_model
import json

dataset_path = 'data/persona_label.json'
with open(dataset_path, "r", encoding="utf-8") as f:
    persona_label = json.loads(f.read())


app = Flask(__name__)


args = easydict.EasyDict({
    "model": 'gpt2',
    "dataset_path": "data/en_book_conversational.json",
    "dataset_cache": "./dataset_cache",
    "model_checkpoint": "/home/ubuntu/server/transfer-learning-conv-ai/runs/Jun04_18-39-17_ime-502_gpt2",
    "temperature": 0.7,
    "top_k": 0,
    "top_p": 0.9,
    "max_history": 2,
    "device": "cuda" if torch.cuda.is_available() else "cpu",
    "no_sample": True,
    "max_length": 20,
    "min_length": 1,
    "seed": 0
})
if args.model_checkpoint == "":
    if args.model == 'gpt2':
        raise ValueError(
            "Interacting with GPT2 requires passing a finetuned model_checkpoint")
    else:
        args.model_checkpoint = download_pretrained_model()


if args.seed != 0:
    random.seed(args.seed)
    torch.random.manual_seed(args.seed)
    torch.cuda.manual_seed(args.seed)
    # logger.info("Get pretrained model and tokenizer")
tokenizer_class, model_class = (GPT2Tokenizer, GPT2LMHeadModel) if args.model == 'gpt2' else (
    OpenAIGPTTokenizer, OpenAIGPTLMHeadModel)
tokenizer = tokenizer_class.from_pretrained(args.model_checkpoint)
model = model_class.from_pretrained(args.model_checkpoint)
model.to(args.device)
add_special_tokens_(model, tokenizer)

# logger.info("Sample a personality")
dataset = get_dataset(tokenizer, args.dataset_path, args.dataset_cache)
personalities = [dialog["personality"]
                 for dataset in dataset.values() for dialog in dataset]
personality = random.choice(personalities)
contents = [tokenizer.decode(i) for i in personality]
book = {}
chapter = ""

for data in persona_label:
    for unit, persona in data.items():
        while persona[0] not in tokenizer.decode(chain(*personality)):
            personality = random.choice(personalities)

        book[unit] = personality


personality = random.choice(personalities)

for unit, pers in book.items():
    if personality[0] in pers:
        chapter = unit

        # print(f"personality: {personality}")
        # print("_________________________")
        # print(pers)


# print(book)
print(f" chapter: {chapter}")
# label={unit:personality for data in persona_label for unit, personality  in data.items()}
# label_key = list(label.keys())
# select = random.choice(label_key)

# print(label[select])


# for per in personalities:
#     per_decode = tokenizer.decode(chain(*per))
#     start=time.time()
#     while per_decode[0] not in label[select]:
#         select=random.choice(label_key)
#     print("end :", time.time() - start)
#     contents.append({per:select})

SPELL_API_KEY = "6e93cb58ed3b4ad594947f95c0c32600"
SPELL_params = {
    'mkt': 'en-us',
    'mode': 'proof'
}
SPELL_headers = {
    'Content-Type': 'application/x-www-form-urlencoded',
    'Ocp-Apim-Subscription-Key': SPELL_API_KEY,
}

M_tokenizer = AutoTokenizer.from_pretrained("bert-base-cased-finetuned-mrpc")
M_model = AutoModelForSequenceClassification.from_pretrained(
    "bert-base-cased-finetuned-mrpc")

C_model = BertForSequenceClassification.from_pretrained(
    "/home/ubuntu/server/transfer-learning-conv-ai/data/CoLAoutput")
C_tokenizer = BertTokenizer.from_pretrained(
    "/home/ubuntu/server/transfer-learning-conv-ai/data/CoLAoutput")


chatbot = ChatBot(args, tokenizer, model, personalities,
                  personality, contents, chapter)

print(chatbot.contents)

CoLA = AFL(C_model, C_tokenizer, "CoLA")
MRPC = AFL(M_model, M_tokenizer, "MRPC")
Redundancy = AFL(M_model, M_tokenizer, "Redundancy")


@app.route('/prediction', methods=['POST'])
def prediction():
    sentence = request.get_json()  # json 데이터를 받아옴

    # sentence = request.get_json()#json 데이터를 받아옴
    result_conv = chatbot.return_message(sample_json=sentence)
    result_mrpc = MRPC.return_prediction(chatbot, sample_json=sentence)
    result_cola = CoLA.return_prediction(chatbot, sample_json=sentence)
    result_spell = AFL.spell_check(
        sentence, SPELL_API_KEY, SPELL_params, SPELL_headers)
    result_redundancy = Redundancy.return_prediction(chatbot, result_conv)
    print(result_redundancy)
    AFL.count += 1
    print(chatbot.history)

    results = {'sentence': result_conv, 'similarity': result_mrpc, 'correct': result_cola, 'contents': chatbot.contents, 'count': AFL.count,
               'spell': result_spell if result_spell else ['nothing to change!'], 'isChanged': AFL.changed_flag, "chapter": chatbot.chapter}

    AFL.changed_flag = False

    if AFL.count >= 2:  # 나중에 5턴
        CoLA_avg = CoLA.average()
        MRPC_avg = MRPC.average()

        if CoLA_avg > 70 and MRPC_avg > 65 and AFL.changed_flag == False:
            chatbot.personality = AFL.change_content(chatbot, book)
            AFL.count = 0
        elif result_redundancy > 0:
            print("너무 똑같아서 바꿈")
            chatbot.personality = AFL.change_content(chatbot, book)
            Redundancy.answer = []

            AFL.count = 0

        # chatbot.history=[] 일단은 놔둬 보기로 모델 보고

    return jsonify(results)  # 받아온 데이터를 다시 전송


@app.route('/first', methods=['GET'])
def first():
    return jsonify({'chapter': chatbot.chapter})


# def change_content():
if __name__ == "__main__":
    app.run(host='0.0.0.0')
