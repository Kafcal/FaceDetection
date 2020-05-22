img = imread('~/Downloads/11.jpg');
[height,width,a] = size(img);
matrix = (img(:,:,1)>250)|(img(:,:,2)>=250)|(img(:,:,2)>=190); % 选择白色的像素点
matrix(0.2*height:height,0.25*width:0.75*width) = 0;  % 中间人像区域保持不变
se = strel('disk',3);
matrix = imclose(matrix,se);  % 关操作平滑边缘
imshow(matrix)
[a,b] = find(matrix ==1);
blue = [67,142,219];
red = [255,0,0];
color = red;
for i = 1:size(a)
    img(a(i),b(i),1) = color(1);
    img(a(i),b(i),2) = color(2);
    img(a(i),b(i),3) = color(3);
end
%平滑处理
g1=medfilt2(img(:,:,1));%%红
g2=medfilt2(img(:,:,2));%%绿
g3=medfilt2(img(:,:,3));%%蓝
img1(:,:,1) = g1;
img1(:,:,2) = g2;
img1(:,:,3) = g3;
imshow(img1);
imwrite(img1,'证件照-b.jpg')
