%Lookup author favs

clear
close all

fname = 'feature_vecs32k';
load([fname '_info.mat'],'IDs','titles');

% # of rows determines how many files there will ultimately be
rows_per_file = 4000;

% Constants to be calculate
num_files = ceil(length(IDs)/rows_per_file);

% Load author fav list
load('FFN_author_favs.mat','data')
num_users = 66602;
all_favIDs = {data(1:num_users).fav_IDs};
clear data

% Make matrices and save each to separate file
for iF = 1:num_files
    L = false(rows_per_file,num_users);
    offset = (iF-1)*rows_per_file;
    for iA = 1:rows_per_file   
        for iU = 1:num_users            
            L(iA,iU) = ismember(IDs(iA+offset),all_favIDs{iU});
        end
    
        if mod(iA,100)==0
            fprintf('Finished row %d for file %d\n',iA,iF);
        end
    end
    
    save(['Feature vector files\' fname '_' num2str(iF) '.mat'],'L');
    fprintf('Saved file: %s\n',[fname '_' num2str(iF) '.mat']);   
end

%Append the rows_per_fil varaible to info
save([fname '_info.mat'],'rows_per_file','-append');