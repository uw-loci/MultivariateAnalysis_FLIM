%% plots for pollengrain_output from pollensegmentation2

[nfiles, npollen] = size(outputdata2);
outputdata_cell = table2cell(outputdata2);

m=['+' , 'o' , '*' , '.' , 'x' , 'square' , 'diamond' , 'v' ,'^' , '>' , '<' , 'pentagram' , 'hexagram' ] ;
%c = [];
    figure()
    hold on;
for pollen_index = 1:npollen-1 % last segmented pollen looks bad

    for file_index = 1:nfiles

    %mean_ = outputdata2(1,1).pollen_1{1}.mean ; 
    %y_val = outputdata_cell{file_index,pollen_index}.mean ;
    %scatter( file_index, y_val );%,'r','marker', m(pollen_index) );
    %y_val = outputdata_cell{file_index,pollen_index}.std / (outputdata_cell{file_index,pollen_index}.mean *outputdata_cell{file_index,pollen_index}.area^2 );
    y_val = outputdata_cell{file_index,pollen_index}.std / (outputdata_cell{file_index,pollen_index}.mean);
    x_val = outputdata_cell{file_index,pollen_index}.mean ;

    scatter( x_val, y_val );%,'r','marker', m(pollen_index) );

    end


end

%%

% outputdata.Properties.VariableNames(3:11)
means_only = outputdata(:,3:11) ;  % mean
%means_only = outputdata(:,12:20) ; % median

means_only = table2array(means_only); 
scatter(mean(means_only) , std(means_only) ./ mean(means_only));
hold on;