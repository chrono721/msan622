Homework 2: Interactivity
==============================

| **Name**  | Charles Yip  |
|----------:|:-------------|
| **Email** | ckyip@dons.usfca.edu |

Planned Dataset
------------------------------
A raw text file of all of the federalist papers. I might include additional information about the authors or possibly other information regarding the federalist papers as I see fit. 

Planned Tools
------------------------------
Below are a list of tools that I will FOR SURE to use for the final project:
- 'R'
- 'ggplot2'
- 'shiny'
- 'scales'
- 'wordcloud'

Below are a lit of tools that I MIGHT use for the final project. Some of these might not be for visualizations, but for a transformation of the data:
- 'tm'
- 'glm'
- 'maps'
- 'Python'

Planned Techniques
------------------------------
Below are a list of 4 techniques that I plan to implement. Note that this might not be all of the ideas I will implement:

1. Small Multiples plot: This will compare the word frequencies over the span of time. I would implement  this using a barplot in shiny and then subset it by the authors. This will allow you to compare the word frequencies between the known authors against the unknown authors in order to notice the similarity. If  there is time and space in the visualization, I also will plan to use this to compare the use frequency in other works the authors have written as well. 

2. Comparitive Word Cloud: This will compare the word frequencies between the authors, allowing us to see the more commonly used words that have been used. The word size will represent the word frequencies while the color will represent which author the word belonged to. In addition, it might also be interesting to look at a wordcloud that compares each paper with each other, however, I will be careful so that it doesn't look too cluttered.

3. Time Series lines: This will show word trends in an author's writing over time. I plan to implement some very simple algorithm that will be able to determine if the time series for a particular word over time is increasing, decreasing, or not changing. I will then plot these lines on a lot where the user will be able to compare and contrast these words. Ideally, I would use other pieces of work, and then highlight exactly where the "expected" word fequencies of the author's paper should lie based on the curves. 

4.  A phrase net: This will help to analyze bi-grams and tri-grams within the raw text. Ideally this will help us distinguish between the authors by creating uniquely different phrase nets for each person. More text might need to be used in order to create a good phrase net. It might be interesting to analyze formal writing versus informal writing (these papers against letters written to friends and family). Perhaps this would be best done as a network visualization rather than using manyeyes.


Planned Interactions
------------------------------

1. Small Multiples plot 
> Plan to include choices for color, size, number of words, number of authors to compare
> I might include the ordering of words, and have you be able to pan between the different alphabetized words.

2.  Word Cloud
> Plan to let user change number of comparitive words, color, and what exactly you are comparing. 

3. Time series lines
> Plan to include choices for the words, color, range of years
> Allow one to subset by POS, Authors, etc.

4. Phrase Net
> Select what joining word to use
> Select color, and the weight of the connecting lines. 


Planned Interface:
------------------------------

Please refer to the Template.pdf for a look at a rough sketch of the visualizations. 
