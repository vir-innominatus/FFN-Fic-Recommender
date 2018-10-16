% Load data
clear
close all


load('FFN_fic_info_31MAR2017.mat','IDs','titles','favs')

num_fics = 3e4;
fname = 'feature_vecs30k';

        
% Extract the IDs for the top fics
[favs,sort_ind] = sort(favs,'descend');
IDs = IDs(sort_ind(1:num_fics));
titles = titles(sort_ind(1:num_fics));

% Load author fav list
load('FFN_author_favs.mat','data')
num_users = 66602;%length(data);
user_weights = [data(1:num_users).weight];
clear data


save([fname '_info.mat'],'IDs','titles','user_weights');
