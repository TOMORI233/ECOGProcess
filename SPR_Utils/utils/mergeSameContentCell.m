function cellRez = mergeSameContentCell(Cell)
% description: this function is to merge a cell consist of multi
%              same-field structures.
% for example: A is a cell containing two structures, A{1} is a structure
%              with fields ["a", "b", "c"], length is 5, A{2} should be also consist of
%              ["a", "b", "b"], length is 10, so the length of returned value Struct is 15 
    N = numel(Cell);
    cellRez = [];
    for i = 1 : N
        temp = Cell{i};
        cellRez = [cellRez; temp];
    end
end