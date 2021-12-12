# Conversational AI for Education
> The conversational AI chatbot app using pre-trained OpenAI GPT-2 model for
beginners who want to learn English. I mainly used  [Hugging Face's](https://github.com/huggingface/transfer-learning-conv-ai) training code which used transfer Learning from an OpenAI GPT and GPT-2 Transformer language model.

## Demo
- Full demo video  [ [link](https://youtu.be/wQf57Zkly0A) ]
- Final Report  [ [link](./documents/final_report.pdf) ]

### Chat with Voice Recognition
#### Situation: Currency Exchange
You can see the result of **Similarity** and **Correct**. Similarity means whether you speak well according to the situation. Correct means how much you talk with grammar.

<img src="./image/main.gif" width="400x"/>


<br/>

### AFL
AFL can check Similarity and Correct.

<img src="./image/AFL.gif" width="400x" />

<br/>


### Quiz
You can easily review the textbook by solving it.

<img src="./image/front-view.gif" />

## Introduction
- Presentation [ [slide](https://drive.google.com/file/d/1aKTveAp5rdqOjbpVT-CFu0GioQ4GMEt1/view?usp=sharing) | [video](https://youtu.be/eyggIxctkF0) ]

- Summary paper [ [kor](https://drive.google.com/drive/u/0/folders/1y1SoWDfAhpzr551PpXJm3POBo7b3WKCb) | [eng](https://drive.google.com/file/d/105vMI1IkXChRjkYUAzhL9lGUbG5zzY4i/view?usp=sharing) ]


## Project Process
<img src="./image/project_process.png" />

## Dataset
### ConvAI2 Data
<img src="./image/convai_dataset.png" />

### Project Data
<img src="./image/dataset.png" />

## Models
### Conversational AI
- Open AI GPT
- Open AI GPT2

### AFL
> AFL stands for Assessment For Learning. This word to refer to a way of evaluating users on an achievement basis, away from traditional learning evaluation methods.

Therefore, the project aimed to score user evaluations for continuous learning and motivation using MRPC, CoLA dataset, and Spell Check API.

- MRPC (Microsoft Research Paraphrase Corpus)
- CoLA (Corpus of Linguistic Acceptability)
- Bing Spell Check API 


## Fine-tuning
- AI Hub Korean-English translation corpus was used for fine tuning. [ [link](https://aihub.or.kr/aidata/87) ]
- Plus, We add the situation data made by English text book.



## Parameter Optimization

| **Argument**                | **Default value** | **Modified Value** |                       **Description**                        |
| :-------------------------- | ----------------- | ------------------ | :----------------------------------------------------------: |
| Model                       | Open AI GPT       | **GPT2**           |                      Open AI GPT, GPT2                       |
| Num_candidates              | 2                 | **6**              |              candidate group for Next Utterance              |
| Max_history                 | 4                 | **2**              |       Number of previous utterances to keep in history       |
| Gradient_accumulation_steps | 8                 | **4**              | Used to troubleshoot memory problems on GPU during Optimization |
| Epochs                      | 1                 | **30**             |                       Number of Epochs                       |
| Train_batch_size            | 4                 | **2**              |                   Batch size for training                    |
| Valid_batch_size            | 4                 | **2**              |                  Batch size for validation                   |


## Evaluation

<img src="./image/model.png" />

## Reference
