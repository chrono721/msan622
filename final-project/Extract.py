

import os
import numpy as np
import csv

from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.feature_extraction.text import CountVectorizer
from nltk.tokenize.regexp import RegexpTokenizer
from nltk.stem.porter import PorterStemmer
from nltk.stem import WordNetLemmatizer
from nltk import pos_tag
from nltk import tokenize
from nltk.corpus import stopwords 

import urllib
import re


##GET DATA
#FedPapFile = urllib.urlopen("http://www.gutenberg.org/cache/epub/18/pg18.txt")
#FedPapRaw = FedPapFile.read()
#FedPapFile.close()

os.chdir("C:/Users/Charles/Desktop")
FedPapFile = open("pg18.txt")
FedPapRaw = FedPapFile.read()
FedPapFile.close()

pattern = re.compile(r'''(?xs)               # re.VERBOSE and re.DOTALL
                                             #
            FEDERALIST[. ]+No\.\s[0-9]       # start matching here on 
                                             # FEDERALIST No. #
                                             # (note some have a 
                                             # . after FEDERALIST
                                             #
            .*?                              # anything (non-greedy)
                                             #
                                             # finally a lookahead match
                                             # on next essay number or 
                                             # string at end of file
            (?=((FEDERALIST[. ]+No\.\s[0-9]) | 
             (End\ of\ the\ Project\ Gutenberg\ Etext\ of\ the\ 
                Federalist\ Papers\,\ by\ )) ) 
            ''')

FedPapList = list(tokenize.regexp_tokenize(FedPapRaw, pattern))  # was tokenize.regexp, but method does not exist


# convert \r and \n to " "
FedPapListWithoutControlChars = [re.sub("\r|\n", " ", essay) for essay in FedPapList]

# convert multiple spaces to a single space
FedPapListWithoutSpaces = [re.sub("\s+", " ", essay) for essay in FedPapListWithoutControlChars]

FedPapList = FedPapListWithoutSpaces[:]


# make list of names of essays (necessary b/c of 2 versions of Federalist 70)
BOTHLIST = []
FedPapNameList = []
i = 0
for essay in FedPapList:
    BOTHLIST.append([])
    name_search = re.search("FEDERALIST[. ]+No\.\s[0-9]{1,2}", essay)
    FedPapNameList.append( name_search.group() )
    BOTHLIST[i].append(FedPapNameList[i])
    i+=1

# make list of authors
FedPapAuthorList = []
i=0
for essay in FedPapList:
    author_search = re.search("(HAMILTON|JAY|MADISON)(\s(AND|OR)\s(MADISON))?",
                              essay)
    FedPapAuthorList.append( author_search.group() )
    BOTHLIST[i].append(FedPapAuthorList[i])
    i+=1


# keep just the text of the essays
pattern = re.compile(r'''
             (To\ the\ People\ of\ the\ State\ of\ New\ York)
             .*?                              # anything non-greedy
          $                                # end of string
             ''', re.VERBOSE)
for i in range(len(FedPapList)):
    text_search = re.search(pattern, FedPapList[i])
    FedPapList[i] = text_search.group()

#FedPapNameList: Names
#FedPapAuthorList: Authors
#FedPapList : Text

#OUTPUT THE DATA
titles = ["PAPER_NAME", "AUTHOR"]
write = [titles] + BOTHLIST
with open('basic.csv', 'w') as fp:
    a = csv.writer(fp, delimiter=',')
    a.writerows(write)

################################
Pstem = PorterStemmer()
WNL = WordNetLemmatizer()

def stem_tokens(tokens, stemmer):
    stemmed = []
    for item in tokens:
        if stemmer.lemmatize(item) == 'ha':
            print(item)
        stemmed.append(stemmer.lemmatize(item))
    return stemmed

def tokenize(text):
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
                                   #stop_words='english',
                                   decode_error = 'ignore',
                                   min_df=5)

#del FedPapList[70]
X = count_Vectorizer.fit_transform(FedPapList)
X = X.toarray()
X = X.astype(float)
X = X.tolist()
vocab = tfidf_Vectorizer.get_feature_names()
write = [vocab] + X

with open('counts.csv', 'w') as fp:
    a = csv.writer(fp, delimiter=',')
    a.writerows(write)


vocab = tfidf_Vectorizer.get_feature_names()
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




#NETWORK GRAPH DATA EXTRACTION
stopwords_list = stopwords.words("english")
#Change this for other words
#list_middle_words = ['and','to','for','of','from', 'upon']
list_middle_words = ['and']
for word in list_middle_words:
    stopwords_list.remove(word)

FedPapList_splits = []
for paper in FedPapList:
    text = paper.split()
    paper_text = []
    for word in text:
        newword = word.strip(',.?\"!:)(;1234567890')
        newword = newword.lower()
        if newword not in stopwords_list:
            paper_text.append(newword)
    FedPapList_splits.append(paper_text)

adjacency_matrices = {}
for word in list_middle_words:
    adjacency_matrices[word] = []

#CHANGE THE AUTHOR LIST, THE CONNECTING WORD, AND THE FILE NAME
#AUTHOR_HAM = [i for i, x in enumerate(FedPapAuthorList) if x == "HAMILTON"]
#AUTHOR_MADISON = [i for i, x in enumerate(FedPapAuthorList) if x == "MADISON"]
#AUTHOR_UNKNOWN = [i for i, x in enumerate(FedPapAuthorList) if x == "HAMILTON OR MADISON"]
AUTHOR_ALL = range(len(FedPapAuthorList))

FedPapList_subset = []
for paper_no in AUTHOR_ALL:
    FedPapList_subset.append(FedPapList_splits[paper_no])

for paper in FedPapList_subset:
    for i in range(len(paper)-2):
        trigram = [paper[i], paper[i+1], paper[i+2]]
        if trigram[1] in list_middle_words:
            adjacency_matrices[trigram[1]].append(trigram)

#Construct the adjacency matrix
unique_words_and = []
for trigram in adjacency_matrices['and']:
    if trigram[0] not in unique_words_and:
        unique_words_and.append(trigram[0])
    if trigram[2] not in unique_words_and:
        unique_words_and.append(trigram[2])

A_Matrix_and = []
for i in range(len(unique_words_and)):
    A_Matrix_and.append([])
    for j in range(len(unique_words_and)):
        A_Matrix_and[i].append(0)

for trigram in adjacency_matrices['and']:
    A_Matrix_and[unique_words_and.index(trigram[0])][unique_words_and.index(trigram[2])] += 1

write = [unique_words_and] + A_Matrix_and
with open('network_and_ALL.csv', 'w') as fp:
    a = csv.writer(fp, delimiter=',')
    a.writerows(write)

adjacency_matrices['and'][1]