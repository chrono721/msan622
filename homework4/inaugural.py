
import os
import numpy as np
import csv

from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.feature_extraction.text import CountVectorizer
from nltk.tokenize.regexp import RegexpTokenizer
from nltk.stem.porter import PorterStemmer
from nltk.stem import WordNetLemmatizer
from nltk import pos_tag

os.chdir("C:/Users/Charles/Desktop/Inaugural/")

#LOAD DATASETS

from nltk.corpus import inaugural
titles = inaugural.fileids()

addresses = []
for title in titles:
    f = inaugural.open(title)
    text = f.read().encode('UTF-8')
    addresses.append(text)

Pstem = PorterStemmer()
WNL = WordNetLemmatizer()

def stem_tokens(tokens, stemmer):
    stemmed = []
    for item in tokens:
        stemmed.append(stemmer.lemmatize(item))
    return stemmed

def tokenize(text):
    #This regex is edited to accept character words only.
    str_ = "[A-Za-z]+"
    regex_tokens = RegexpTokenizer(str_)
    tokens = regex_tokens.tokenize(text.lower())   
    stems = stem_tokens(tokens, WNL)
    return stems


count_Vectorizer = CountVectorizer(tokenizer=tokenize,
                                   strip_accents='UTF-8',
                                   preprocessor=lambda text: text,
                                   stop_words='english',
                                   decode_error = 'ignore',
                                   min_df=5)
tfidf_Vectorizer = TfidfVectorizer(tokenizer=tokenize,
                                   strip_accents='unicode',
                                   preprocessor=lambda text: text,
                                   use_idf=True,
                                   stop_words='english',
                                   decode_error = 'ignore',
                                   min_df=5)

X = count_Vectorizer.fit_transform(addresses)
X = X.toarray()
X = X.astype(int)
X = X.tolist()
vocab = count_Vectorizer.get_feature_names()
write = [vocab] + X

with open('counts.csv', 'w') as fp:
    a = csv.writer(fp, delimiter=',')
    a.writerows(write)


Y = tfidf_Vectorizer.fit_transform(addresses)
Y = Y.toarray()
Y = Y.astype(float)
Y = Y.tolist()
vocab = tfidf_Vectorizer.get_feature_names()
write = [vocab] + Y

with open('tfidf.csv', 'w') as fp:
    a = csv.writer(fp, delimiter=',')
    a.writerows(write)

Z = []
for title in titles:
    Z.append(title.strip(".txt").split("-"))

vocab = ["Year","President"]
write = [vocab] + Z
with open('info.csv', 'w') as fp:
    a = csv.writer(fp, delimiter=',')
    a.writerows(write)

#POS TAGGING
vocab = count_Vectorizer.get_feature_names()
TAGS = pos_tag(vocab)
POS = []
tag_names = [u'IN', u'JJ', u'JJR', 
             u'JJS', u'MD', u'NN',
             u'NNS', u'RB', u'VB',
             u'VBD', u'VBG', u'VBN', 
             u'VBP', u'VBZ']
#nltk.help.upenn_tagset()
tag_map = ['preposition', 'adjective', 'adjective', 
           'adjective','modal', 'noun',
           'noun','adverb','verb',
           'verb_past','verb','verb_past',
           'verb','verb']
for pair in TAGS:
    p = list(pair)
    if p[1] in tag_names:
        p[1] = tag_map[tag_names.index(p[1])]
    POS.append(p)

vocab = ["Word","POS"]
write = [vocab] + POS
with open('word.csv', 'w') as fp:
    a = csv.writer(fp, delimiter=',')
    a.writerows(write)

