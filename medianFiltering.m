% ��ֵ�˲���(5*5)
function y = medianFiltering(A)
sizeA = size(A);
mA = sizeA(1);
nA = sizeA(2);
y = A;
for i=3:mA-2
    for j=3:nA-2
        temp_5x5 = A(i-2:i+2,j-2:j+2);%��ȡ5x5����
        temp = sort(temp_5x5); %����
        y(i,j) = temp(13);%��ֵ
    end
end
end
