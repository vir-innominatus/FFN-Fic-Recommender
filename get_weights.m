%Main script of this project. Gets the weights needed for the recommender
clear
close all

fics_to_process = [20001:21000]; %Which fics to process 
num_neighbors = 200; %How many neighbors to save
fics_between_saves = 200; %How often to save
fname = 'weight_matrix30k_200NN';

%Load info 
Sinfo = load('feature_vecs30k_info','IDs','user_weights','rows_per_file');
user_weights = Sinfo.user_weights;
rows_per_file = Sinfo.rows_per_file;
num_fics = length(Sinfo.IDs);
num_files = num_fics/rows_per_file;
clear Sinfo

% Load weight data if it exists
if exist([fname '.mat'],'file')
    Sdata = load(fname,'indexes','weights');
else
    Sdata = struct;
    Sdata.indexes = zeros(num_fics,num_neighbors);
    Sdata.weights = zeros(num_fics,num_neighbors);
end
 
% Main loop
count = 0;
for iFic = fics_to_process
    
    if any(Sdata.weights(iFic,:))
        fprintf('Skipping fic %d. Already in database\n',iFic)
        continue
    end
    
    % Print out time per fic
    tic
    
    % Get which L matrix and the row in that matrix (essentially computing mod)    
    file_ind = floor(iFic/rows_per_file);
    row_ind = iFic - rows_per_file*file_ind;
    
    %Handle edge cases
    if row_ind==0
        row_ind=2000;
    end
    if file_ind==num_files
        file_ind = file_ind-1;
    end
    
    % Get users that like current fic
    load(['Feature vector files\feature_vecs30k_' num2str(file_ind+1) '.mat'],'L');
    current_fic = L(row_ind,:);
    
    %Skip if no users like fic
    if ~any(current_fic)
        fprintf('Skipping fic %d. No user favorites\n',iFic)
        continue
    end

    % Iterate through all other fics by sequentially loading matrices
    temp_weights = zeros(num_fics,1);
    for iL = 1:num_files
        
        %Load file
        load(['Feature vector files\feature_vecs30k_' num2str(iL) '.mat'],'L');

        %Rows of temp_weights to fill
        ind = (iL-1)*rows_per_file + (1:rows_per_file);
        
        % This is the main line. The operation current_fic & L works even
        % though current_fic is a single row and L is a matrix. The
        % operation is applied to each row of L, as if we used bsxfun.
        temp_weights(ind)= sum(user_weights .* (current_fic & L) ,2) ./ ...
                           sum(user_weights .* (current_fic | L) ,2) ;  
       fprintf('Finished file %d for fic %d\n',iL,iFic);

    end

    %Now get nearest neighbors
    [biggest_weights,ind_weights] = maxk(temp_weights,num_neighbors+1);
    Sdata.indexes(iFic,:) = ind_weights(2:end)';
    Sdata.weights(iFic,:) = biggest_weights(2:end)';  
    
    %Print out fic and time
    count = count + 1;
    fprintf('Finished fic %d\n',iFic)
    toc
    
    % Save file early. Reload old file and add the newly calculated rows
    if mod(count,fics_between_saves)==0
        temp_fname = [fname '_' num2str(iFic)];
        if exist([fname '.mat'],'file')

            %Add new rows to old data
            Sold = load(fname,'indexes','weights');
            new_rows = Sdata.indexes(:,1)>0;
            Sold.indexes(new_rows,:) = Sdata.indexes(new_rows,:);
            Sold.weights(new_rows,:) = Sdata.weights(new_rows,:);

            %Save
            save(temp_fname,'-struct','Sold');
            fprintf('Temp save at row %d: %s\n',iFic,fname);
        else
            save(temp_fname,'-struct','Sdata');
            fprintf('Temp save at row %d: %s\n',iFic,fname);
        end
    end
        
    
end

%Final save: Reload file and add the newly calculated rows
if exist([fname '.mat'],'file')
    
    %Add new rows to old data
    Sold = load(fname,'indexes','weights');
    new_rows = Sdata.indexes(:,1)>0;
    Sold.indexes(new_rows,:) = Sdata.indexes(new_rows,:);
    Sold.weights(new_rows,:) = Sdata.weights(new_rows,:);
    
    %Save
    save(fname,'-struct','Sold');
    fprintf('Final save: %s. Finished rows %d to %d\n',fname, ...
        fics_to_process(1),fics_to_process(end));
else
    save(fname,'-struct','Sdata');
    fprintf('Final save: %s. Finished rows %d to %d\n',fname, ...
        fics_to_process(1),fics_to_process(end));
end

