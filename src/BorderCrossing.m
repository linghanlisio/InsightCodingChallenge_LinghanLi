%Find input data file
input = '/input/Border_Crossing_Entry_Data_small.csv';

%Create a datastore
ds = tabularTextDatastore(input);
ds.SelectedVariableNames = {'Border','Date','Measure','Value'};

%Read data
C=read(ds);

%Find unique borders
UBorder = flipud(unique(C.Border));
NBorder = size(UBorder,1);

%Find unique means of crossing
UMeasure = flipud(unique(C.Measure));
NMeasure = size(UMeasure,1);

%Find time info
UDate = sort(unique(C.Date),'descend');
NDate = size(UDate,1);

%Calculate total crossings
for i = 1:NBorder
    for j = 1:NMeasure
        for k = 1:NDate
            TotalCrossings(i,j,k) = sum(C.Value(strcmp(C.Border,UBorder(i)) & strcmp(C.Measure,UMeasure(j)) & strcmp(string(C.Date),string(UDate(k)))));
        end    
    end
end

%Calculate running monthly average
Average1 = round(movmean(TotalCrossings,[0 1],3));
Average2 = Average1(:,:,2:end);
Average = cat(3,Average2,zeros(NBorder,NMeasure));

%Only consider nonzero elements in TotalCrossings
index = find(TotalCrossings);
[I1,I2,I3] = ind2sub([NBorder,NMeasure,NDate],index);

%Write data
varNames = {'Border','Date','Measure','Value','Average'};
T1 = table(UBorder(I1),UDate(I3),UMeasure(I2),TotalCrossings(index),Average(index),'VariableNames',varNames);
%Sort rows
T2 = sortrows(T1,{'Date','Value','Measure','Border'},{'descend','descend','descend','descend'});
writetable(T2,'/output/report.csv');