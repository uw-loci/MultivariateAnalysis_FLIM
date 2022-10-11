%% plots for pollengrain_output from pollensegmentation2

[nfiles, npollen] = size(outputdata2);
outputdata_cell = table2cell(outputdata2);

m=['+' , 'o' , '*' , '.' , 'x' , 'square' , 'diamond' , 'v' ,'^' , '>' , '<' , 'pentagram' , 'hexagram' ] ;
c = []
    figure()
    hold on;
for pollen_index = 1:npollen

    for file_index = 1:nfiles

    %mean_ = outputdata2(1,1).pollen_1{1}.mean ; 
    %y_val = outputdata_cell{file_index,pollen_index}.mean ;
    %scatter( file_index, y_val );%,'r','marker', m(pollen_index) );
    y_val = outputdata_cell{file_index,pollen_index}.std / (outputdata_cell{file_index,pollen_index}.mean *outputdata_cell{file_index,pollen_index}.area^2 );
    x_val = outputdata_cell{file_index,pollen_index}.mean ;

    scatter( x_val, y_val );%,'r','marker', m(pollen_index) );

    end
end


