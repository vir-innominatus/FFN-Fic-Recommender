clear
close all

Srecs = load('feature_vecs30k_info','IDs');
num_fics = length(Srecs.IDs);
fname = 'Fic_Recommender.xlsx';

%% Load FFN data 
fprintf('Loading FFN data\n');
Sffn = load('FFN_fic_info_31MAR2017.mat','IDs','authors', ...
    'characters','favs','follows','published','complete', ...
    'chapters','words','titles','reviews');
Ssum = load('FFN_fic_info_31MAR2017_summaries.mat','summaries');


%% gets url and index in larger list of IDs
urls = cell(num_fics,1);
ind = zeros(num_fics,1);
for ii = 1:num_fics
    urls{ii} = ['https://www.fanfiction.net/s/' num2str(Srecs.IDs(ii))];
    ind(ii) = find(Sffn.IDs==Srecs.IDs(ii));
end

% Convert dates
factor = datenum('01/01/1970')*24*60*60;
dates = datestr((Sffn.published(ind) + factor)/(24*60*60),'dd-mmm-yyyy');

% Convert complete
base = {'Incomplete';'Complete'};
completeness = base(Sffn.complete(ind)+1);



%% Make Info table

fprintf('Making excel files\n');
var_names = {'Row','ID','Title','Author','Summary','Characters','Chapters','Words', ...
    'Review','Favs','Follows','Published','Complete','URL'};

T = table((1:num_fics)',Srecs.IDs,Sffn.titles(ind),Sffn.authors(ind), ...
    Ssum.summaries(ind),Sffn.characters(ind),Sffn.chapters(ind), ...
    Sffn.words(ind),Sffn.reviews(ind),Sffn.favs(ind),Sffn.follows(ind), ...
    dates,completeness,urls,'VariableNames',var_names);

writetable(T,fname,'Sheet','Fic Info');
%% Read in weights and Rows

load weight_matrix30k indexes weights

writetable(array2table(indexes),fname,'Sheet','Indexes','WriteVariableNames',false);
writetable(array2table(weights),fname,'Sheet','Weights','WriteVariableNames',false);

