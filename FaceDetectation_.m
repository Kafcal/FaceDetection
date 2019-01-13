function y = FaceDetectation_(image_name)
% ����ͼƬ��Ϣ��ȡ
testImageName=strcat(image_name);
test_img = imread(testImageName);
test_size = size(test_img);
test_m = test_size(1);
test_n = test_size(2);
test_cbcr = rgb2ycbcr(test_img);
test_cb = test_cbcr(:,:,2);
test_cr = test_cbcr(:,:,3);

% ��ֵ�˲�(5*5)
filter_cb = medianFiltering(test_cb);
filter_cr = medianFiltering(test_cr);

% ���ƶȼ���
M = [mean_cb mean_cr]';  %Ϊ��ɫ��YCbCr��ɫ�ռ��������ֵ
P = zeros(test_m, test_n);  %���ƶȾ���
for i = 1:test_m
    for j = 1:test_n
        x = double([filter_cb(i,j), filter_cr(i,j)]');
        index = -0.5*(x-M)'*(C\(x-M));
        P(i,j) = exp(index);
    end
end

%��һ��
max_P = max(P(:));
P = P / max_P;

% ��ֵ�ָ�

%��ֵ��ͼ��ʾ
BW_ = zeros(test_m, test_n);
for i = 1:test_m
    for j = 1:test_n
        if (P(i,j) >= 0.45)
            BW_(i, j) = 1;
        end
    end
end

% ���ղ���
se = strel('square',3);
BW = imopen(BW_, se);
BW = imclose(BW, se);

% �����
BW = imfill(BW, 'holes');

% ��ʴ�����Ͳ���
sel = strel('square',8);
BW = imerode(BW, sel);
BW = imdilate(BW, sel);

% ����������ȡ
[L, num] = bwlabel(BW, 4);
for i = 1:num
    [r,c] = find(L==i); % ���Ϊi�Ķ�����к������ꡣ
    len = max(r) - min(r) + 1;
    wid = max(c) - min(c) + 1;
    area_sq = len * wid;  % ���
    row_num = size(r, 1); % ����

    % �ų�����������
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
imshow(testImageName), title('ԭʼͼƬ');
subplot(2,1,2);
imshow(L), title('��ֵ��ͼ');

% �þ���Ȧ������
figure(f2);
imshow(test_img);
width = c_max-c_min;
height = min(r_max-r_min,width*1.4);
hold on
rectangle('Position',[r_min c_min width height],'LineWidth',4,'EdgeColor','r');

end

