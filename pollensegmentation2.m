function [out] = pollensegmentation2(folder, ccvlist) 

n_files = length(ccvlist);

img_data  = readmatrix(strcat(folder,'\',ccvlist(1)),"FileType","text");
img_label = bwlabel(medfilt2(imbinarize(img_data),[3,3]), 8);

n_pollen = max(img_label(:)) ;

pollen_  = cell([n_files,n_pollen]);


for file_index = 1:n_files

    currentfile = strcat(folder,'\',ccvlist(file_index));
    currentdata = readmatrix(currentfile,"FileType","text");

    if file_index==1 % make mask for single image
        currentdata_binary = imbinarize(currentdata);
        labeledImage = bwlabel(medfilt2(currentdata_binary,[3,3]), 8);
    end
    
    for label_index = 1:max(labeledImage(:))

        mask_intensity = labeledImage==label_index; % using ccv vals bcs intensity is missing
        mask_threshold = ((currentdata>0)|(currentdata<8000));
        mask = mask_intensity & mask_threshold;

        pollen = struct();
        pollen.mean    = mean(currentdata(mask));
        pollen.median  = median(currentdata(mask));
        pollen.std     = std(currentdata(mask));
        pollen.area    = numel(mask(mask));

        pollen_{file_index,label_index} = {pollen};
        %pollen_ {file_index,label_index} = pollen.mean;
        
    end 

    out = cell2table(pollen_);

end