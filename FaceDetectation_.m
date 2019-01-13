function y = FaceDetectation_(image_name)
% 样本图片信息提取
testImageName=strcat(image_name);
test_img = imread(testImageName);
test_size = size(test_img);
test_m = test_size(1);
test_n = test_size(2);
test_cbcr = rgb2ycbcr(test_img);
test_cb = test_cbcr(:,:,2);
test_cr = test_cbcr(:,:,3);

% 中值滤波(5*5)
filter_cb = medianFiltering(test_cb);
filter_cr = medianFiltering(test_cr);

% 相似度计算
M = [mean_cb mean_cr]';  %为肤色在YCbCr颜色空间的样本均值
P = zeros(test_m, test_n);  %相似度矩阵
for i = 1:test_m
    for j = 1:test_n
        x = double([filter_cb(i,j), filter_cr(i,j)]');
        index = -0.5*(x-M)'*(C\(x-M));
        P(i,j) = exp(index);
    end
end

%归一化
max_P = max(P(:));
P = P / max_P;

% 阈值分割

%二值化图显示
BW_ = zeros(test_m, test_n);
for i = 1:test_m
    for j = 1:test_n
        if (P(i,j) >= 0.45)
            BW_(i, j) = 1;
        end
    end
end

% 开闭操作
se = strel('square',3);
BW = imopen(BW_, se);
BW = imclose(BW, se);

% 填洞操作
BW = imfill(BW, 'holes');

% 腐蚀和膨胀操作
sel = strel('square',8);
BW = imerode(BW, sel);
BW = imdilate(BW, sel);

% 特征区域提取
[L, num] = bwlabel(BW, 4);
for i = 1:num
    [r,c] = find(L==i); % 标记为i的对象的行和列坐标。
    len = max(r) - min(r) + 1;
    wid = max(c) - min(c) + 1;
    area_sq = len * wid;  % 面积
    row_num = size(r, 1); % 行数

    % 排除非脸部区域
    if (len/wid<0.8) || (len/wid>2.4) || row_num<200 || row_num/area_sq<0.55 || area_sq<640
        for j = 1:row_num
            L(r(j),c(j)) = 0;
        end
    end
end

[r, c] = find(L~=0);
r_max = max(r);
r_min = min(r);
c_max = max(c);
c_min = min(c);


f1 = figure;
f2 = figure;

figure(f1);
subplot(2,1,1);
imshow(testImageName), title('原始图片');
subplot(2,1,2);
imshow(L), title('二值化图');

% 用矩形圈出人脸
figure(f2);
imshow(test_img);
width = c_max-c_min;
height = min(r_max-r_min,width*1.4);
hold on
rectangle('Position',[r_min c_min width height],'LineWidth',4,'EdgeColor','r');

end

