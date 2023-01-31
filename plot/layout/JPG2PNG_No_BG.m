outputPath = ".\PNG\";
mkdir(outputPath);
nameStr = ["cc_AC_sulcus_square", "cc_PFC_sulcus_square", "xx_AC_sulcus_square", "xx_PFC_sulcus_square"];
for i = 1 : length(nameStr)
IM = imread(strcat(nameStr(i), ".jpg"));
BW = imbinarize(rgb2gray(IM), 0.8);
imwrite(IM, strcat(outputPath, nameStr(i), ".png"), "png", "Alpha", double(~BW));
end
