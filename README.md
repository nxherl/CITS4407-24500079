# CITS4407-24500079
CITS4407 Sem 1 2025 Assignment 2


This repository is created for completing CITS4407 assignment 2 SEM 1 2025. 

Following is the assignment details

 
Submission deadline: 11:59pm, Monday 19 May 2025.
Value: 20% of CITS4407.
To be done individually.
Version: 1.0
Date:  13 April 2025
No AI tools are to be used for this assignment.
  
This assignment will involve creating three Shell scripts, which will use Unix tools covered in this unit and/or calls to other Shell scripts. The top-level scripts are expected to have specific names – discussed below. Please make sure you use those script names, as these are the names which the testing software will use to test your script. (Subsidiary scripts can have whatever name you wish.)
Put the top-level scripts, plus any other scripts which you have created, into a directory, and then zip the directory, so your submission is a single package consisting of a zip file. If you have used git (see below), copy the entire .git repo into that directory. An alternative to zip is to use the Linux program tar to create a tar file from the directory. Submit the zip or tar file via the submission portal that is linked in the in the LMS item following this description.  No other file format will be accepted.
  
Board Games or Bored Games: which style of board-game rules
Kaggle (www.kaggle.com)  is a remarkable web-based, data science resource, which contains a huge number of different datasets and tutorials on tools. (Highly recommended.) One particular dataset is the Board Games Geek dataset (https://www.kaggle.com/datasets/andrewmvd/board-games), which lists 20,000+ board games and for each game, a range of data including the average rating from BGG users, a measure of the game’s complexity, and information about the game’s mechanics (i.e. style of play) and “Domain”, i.e. the broad type. The research questions are:

    What is the most popular domain and most popular playing style (based on average rating).
    What is the correlation between publication year and average rating, e.g. newer games being preferred over older ones.
    What is the correlation between game complexity and average rating.

 
 
Checking Data Quality
The first step of any data analysis is to check the data quality. That is, scan the data for any oddities, otherwise known as “eyeballing the data”.  The most common of these issues is missing data.
 
Handling empty cells
The first thing you’ll notice is that the spreadsheet, represented as a textfile, uses semicolon ‘;’ as the column separator, rather the more common comma or tab characters. Your first task is to a Bash script called empty_cells, which, given a text file version of a spreadsheet and the expected separator character, returns via standard output a list of the column titles (taken from the first line) the number of empty cells found in that column.
Running empty_cells on the complete dataset, bgg_dataset.txt, the following counts are reported:
/ID: 16
Name: 0
Year Published: 1
Min Players: 0
Max Players: 0
Play Time: 0
Min Age: 0
Users Rated: 0
Rating Average: 0
BGG Rank: 0
Complexity Average: 0
Owned Users: 23
Mechanics: 1598Domains: 10159
 
Data Cleaning
Once you have a fair idea what the issues are with the dataset, the next step is to either deal with an issue, e.g. empty IDs or decide to ignore it, but then be careful later.
 
You are to create a script called preprocess, which sends to standard output a cleaned version of the input file, where the following transformations have taken place:

    Convert the semicolon separator to the  <tab> character
    Convert the Microsoft line endings to Unix line endings
    Change format of floating-point numbers to use ‘.’ rather than ‘,’ as the decimal point.
    Deal with non-ASCII characters by deleting them from the output. For example CO2 in a game title is rendered as CO. (Hint: one way is to use the tr command.)
    While other empty cells can be ignored for now, new unique IDs need to be created for the 16 empty IDs. How you do this is up to you, but one way is to find the largest integer ID in the input file, and then continue numbering past that.

 
Linked to this description you will find a sample of the first 100 lines (sample.txt) and a small sample, sample1.txt, that has some empty cells. You will also find the cleaned versions sample.tsv and sample1.tsv .
 
 
The Analysis
 
Armed with clean input data, create a script  called analysis, which uses data from the input file to answer the four research questions listed above. Keep in mind the presence of empty Domain and/or Mechanics cells.
 
If you are unsure how to compute Pearson corelation, please see this tutorial https://www.cuemath.com/data/how-to-calculate-correlation-coefficient/  )
 
For example, when analysis is run on the cleaned input file sample.tsv (the cleaned version of sample.txt) that result is:
 
The most popular game mechanics is Hand Management found in 48 games
The most style of game is Strategy Games found in 77 games
 
The correlation between the year of publication and the average rating is 0.226
The correlation between the complexity of a game and its average rating is 0.426
 
 
Two additional sets of test-files can be found as linked documents:

    tiny_sample.txt, its cleaned version tiny_sample.tsv and a worked version tiny_sample.xls
    sample1.txt, which contains some empty cells, and the cleaned version  sample1.tsv
