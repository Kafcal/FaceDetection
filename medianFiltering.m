% 中值滤波器(5*5)
function y = medianFiltering(A)
sizeA = size(A);
mA = sizeA(1);
nA = sizeA(2);
y = A;
for i=3:mA-2
    for j=3:nA-2
        temp_5x5 = A(i-2:i+2,j-2:j+2);%提取5x5区域
        temp = sort(temp_5x5); %排序
        y(i,j) = temp(13);%中值
    end
end
end
