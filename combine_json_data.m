% jsondecode
clear
close all

% Read through JSON files and convert to struct with jsondecode
data = [];
for ii = 0:829
    json_str = fileread(['Author Favs Data\FFN_author_favs' num2str(ii) '.json']);
    data = [data; jsondecode(json_str)];
end

% Calcualte user weights. This is a penalty for favoriting a lot of fics 
% so users that only favorite a couple of fics aren't drowned out by the  
% users that favorite hundreds or thousands of fics.
for jj = 1:length(data)
    data(jj).weight = 1/(20+length(data(jj).fav_IDs));
end
save FFN_author_favs data