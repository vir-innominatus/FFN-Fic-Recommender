clear
close all

% Read in excel file as table
T = readtable('FFN_fic_info_18OCT2018.xlsx');

% Create variables for each column. This just allows us to save time later
% by only loading the variables we want from this huge file.

% Strings
headers = T.Properties.VariableNames;
titles = T.Title;
authors = T.Author;
summaries = T.Summary;
ratings = T.Rating;
languages = T.Language;
genres = T.Genre;
characters = T.Characters;

% Numbers
IDs = T.IDs;
chapters = T.Chapters;
words = T.Words;
reviews = T.Reviews;
favs = T.Favorites;
follows = T.Follows;
complete = T.Complete;
updated = T.Updated_UTC_;
published = T.Published_UTC_;


%Save summaries separately to keep file under 100 MB
save FFN_fic_info_18OCT2018_summaries summaries
clear summaries T
save FFN_fic_info_18OCT2018 

