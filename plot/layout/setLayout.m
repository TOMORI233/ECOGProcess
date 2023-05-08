temIMG = imread("cc_AC_sulcus_large.jpg");
cc_AC_sulcus_large = temIMG(1:5:end, 1:5:end, :);

temIMG = imread("cc_PFC_sulcus_large.jpg");
cc_PFC_sulcus_large = temIMG(1:5:end, 1:5:end, :);

temIMG = imread("cc_AC_sulcus_square.jpg");
cc_AC_sulcus_square = temIMG(1:3:end, 1:3:end, :);

temIMG = imread("cc_PFC_sulcus_square.jpg");
cc_PFC_sulcus_square = temIMG(1:3:end, 1:3:end, :);

temIMG = imread("xx_AC_sulcus_square.jpg");
xx_AC_sulcus_square = temIMG(1:3:end, 1:3:end, :);

temIMG = imread("xx_PFC_sulcus_square.jpg");
xx_PFC_sulcus_square = temIMG(1:3:end, 1:3:end, :);

save('layout.mat', 'cc_AC_sulcus_large','cc_PFC_sulcus_large', ...
    'cc_AC_sulcus_square', 'cc_PFC_sulcus_square', ...
    'xx_AC_sulcus_square', 'xx_PFC_sulcus_square');
