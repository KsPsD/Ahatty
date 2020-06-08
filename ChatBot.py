# 여긴 챗봇 클래스
import logging
import random
from argparse import ArgumentParser
from itertools import chain
from pprint import pformat
import warnings
#######
import torch
import torch.nn.functional as F
import easydict

from transformers import OpenAIGPTLMHeadModel, OpenAIGPTTokenizer, GPT2LMHeadModel, GPT2Tokenizer
from train import SPECIAL_TOKENS, build_input_from_segments, add_special_tokens_
from utils import get_dataset, download_pretrained_model
from time import sleep
import time
import random


class ChatBot:

    def __init__(self, args, tokenizer, model, personalities, personality, contents, chapter):

        self.args = args
        self.tokenizer = tokenizer
        self.model = model
        self.personalities = personalities
        self.personality = personality
        self.history = []
        self.contents = contents
        self.chapter = chapter
#   args = easydict.EasyDict({
#         "model": 'openai-gpt',
#         "dataset_path": "data/en_book_conversational.json",
#         "dataset_cache": "./dataset_cache",
#         "model_checkpoint":"/content/drive/My Drive/transfer-learning-conv-ai/runs/May26_10-33-33_ime-502_openai-gpt",
#         "temperature": 1,
#         "top_k": 70,
#         "top_p": 0.5,
#         "max_history": 2,
#         "device" : "cuda" if torch.cuda.is_available() else "cpu",
#         "no_sample": True,
#         "max_length": 20,
#         "min_length" :1,
#         "seed": 0
# })
#   if args.model_checkpoint == "":
#     if args.model == 'gpt2':
#       raise ValueError("Interacting with GPT2 requires passing a finetuned model_checkpoint")
#   else:
#     args.model_checkpoint = download_pretrained_model()
#     if args.seed != 0:
#       random.seed(args.seed)
#       torch.random.manual_seed(args.seed)
#       torch.cuda.manual_seed(args.seed)
#     # logger.info("Get pretrained model and tokenizer")
#     tokenizer_class, model_class = (GPT2Tokenizer, GPT2LMHeadModel) if args.model == 'gpt2' else (OpenAIGPTTokenizer, OpenAIGPTLMHeadModel)
#     tokenizer = tokenizer_class.from_pretrained(args.model_checkpoint)
#     model = model_class.from_pretrained(args.model_checkpoint)
#     model.to(args.device)
#     add_special_tokens_(model, tokenizer)
#     # logger.info("Sample a personality")
#     dataset = get_dataset(tokenizer, args.dataset_path,args.dataset_cache)
#     personalities = [dialog["personality"] for dataset in dataset.values() for dialog in dataset]
#     personality = random.choice(personalities)
#     history=[]
#     contents=[]
#     for i in personality:
#       contents.append(tokenizer.decode(i))
#     print(contents)

    def return_message(self, sample_json):
        sentence = sample_json['text']
        # while True:
        raw_text = sentence
        while not raw_text:
            print('Prompt should not be empty!')
            raw_text = sentence

        self.history.append(self.tokenizer.encode(raw_text))
        with torch.no_grad():
            start = time.time()
            out_ids = sample_sequence(
                self.personality, self.history, self.tokenizer, self.model, self.args)
            print(time.time()-start)
            self.history.append(out_ids)
            self.history = self.history[-(2*self.args.max_history+1):]
            out_text = self.tokenizer.decode(out_ids, skip_special_tokens=True)
        return out_text


def top_filtering(logits, top_k=0., top_p=0.9, threshold=-float('Inf'), filter_value=-float('Inf')):
    """ Filter a distribution of logits using top-k, top-p (nucleus) and/or threshold filtering
        Args:
            logits: logits distribution shape (vocabulary size)
            top_k: <=0: no filtering, >0: keep only top k tokens with highest probability.
            top_p: <=0.0: no filtering, >0.0: keep only a subset S of candidates, where S is the smallest subset
                whose total probability mass is greater than or equal to the threshold top_p.
                In practice, we select the highest probability tokens whose cumulative probability mass exceeds
                the threshold top_p.
            threshold: a minimal threshold to keep logits
    """
    assert logits.dim() == 1  # Only work for batch size 1 for now - could update but it would obfuscate a bit the code
    top_k = min(top_k, logits.size(-1))
    if top_k > 0:
        # Remove all tokens with a probability less than the last token in the top-k tokens
        indices_to_remove = logits < torch.topk(logits, top_k)[
            0][..., -1, None]
        logits[indices_to_remove] = filter_value

    if top_p > 0.0:
        # Compute cumulative probabilities of sorted tokens
        sorted_logits, sorted_indices = torch.sort(logits, descending=True)
        cumulative_probabilities = torch.cumsum(
            F.softmax(sorted_logits, dim=-1), dim=-1)

        # Remove tokens with cumulative probability above the threshold
        sorted_indices_to_remove = cumulative_probabilities > top_p
        # Shift the indices to the right to keep also the first token above the threshold
        sorted_indices_to_remove[...,
                                 1:] = sorted_indices_to_remove[..., :-1].clone()
        sorted_indices_to_remove[..., 0] = 0

        # Back to unsorted indices and set them to -infinity
        indices_to_remove = sorted_indices[sorted_indices_to_remove]
        logits[indices_to_remove] = filter_value

        indices_to_remove = logits < threshold
        logits[indices_to_remove] = filter_value

        return logits


def sample_sequence(personality, history, tokenizer, model, args, current_output=None):

    special_tokens_ids = tokenizer.convert_tokens_to_ids(SPECIAL_TOKENS)
    if current_output is None:
        current_output = []

    for i in range(args.max_length):
        instance = build_input_from_segments(
            personality, history, current_output, tokenizer, with_eos=False)

        input_ids = torch.tensor(
            instance["input_ids"], device=args.device).unsqueeze(0)
        token_type_ids = torch.tensor(
            instance["token_type_ids"], device=args.device).unsqueeze(0)

        logits = model(input_ids, token_type_ids=token_type_ids)
        if isinstance(logits, tuple):  # for gpt2 and maybe others
            logits = logits[0]
        logits = logits[0, -1, :] / args.temperature
        logits = top_filtering(logits, top_k=args.top_k, top_p=args.top_p)
        probs = F.softmax(logits, dim=-1)

        prev = torch.topk(probs, 1)[
            1] if args.no_sample else torch.multinomial(probs, 1)
        if i < args.min_length and prev.item() in special_tokens_ids:
            while prev.item() in special_tokens_ids:
                if probs.max().item() == 1:
                    warnings.warn(
                        "Warning: model generating special token with probability 1.")
                    break  # avoid infinitely looping over special token
                prev = torch.multinomial(probs, num_samples=1)

        if prev.item() in special_tokens_ids:
            break
        current_output.append(prev.item())

    return current_output
