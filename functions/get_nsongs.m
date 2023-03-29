function Nsongs = get_nsongs(data_split)

Nsongs = 50;
switch data_split
    case 'Dev'
        dataNaN=[1 18 29 38 49];
    case 'Test'
        dataNaN=[6 34 36 40];
end

Nsongs = Nsongs - length(dataNaN);

end

