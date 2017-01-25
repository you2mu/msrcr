%带色彩回复的多尺度retinex
%img为输入的图像,img为RGB图像
%d为对比度，对比度的可以为任意实数
%nscals为尺度的数量,scals>=1
%maxscals为最大尺度数 maxscals>=0

%使用：
%img = imread(pathname);
%result = msrcr(img,d,nscals,maxscals);
%imshow(result)

function result = msrcr(img,d,nscals,maxscals)
img = double(img);
ssr = 0;
r = size(img,1);
c = size(img,2);
g = img(:,:,1) + img(:,:,2) + img(:,:,3);
scals = processcals(nscals,maxscals);
for m = 1:3    %3channel RGB
    t = img(:,:,m);
    T = fft2(t);
    for n = 1:nscals    %遍历scals
        gauss = gaussian(r,c,scals(n));
        gauss = fft2(gauss,size(t,1),size(t,2));
        gauss = fftshift(gauss);
        R = ifft2(T.*gauss);
        R = abs(R);
        ssr = ssr + log(t+1) - log(R+1);
    end
    msri = ssr/nscals;   %msr
    c = (log(125*t+1) - log(g+1))*46;
    msrcr = msri.*c;     %这里还可以在处理G(msri.*c+b)  G,b  msrcr
    min1 = mean(mean(msrcr)) - std(std(msrcr))*d;     %取值方式
    max1 = mean(mean(msrcr)) + std(std(msrcr))*d;
    range = max1 - min1;
    if range ==0
        range =1;
    end
    result(:,:,m) = uint8(255*(msrcr-min1)/range); 
end
end

function gauss = gaussian(r,c,sigma)
%r为行，c为列，simga为尺度参数
[x,y] = meshgrid(-(r-1)/2:r/2,-(c-1)/2:c/2);
gauss = exp(-(x.^2+y.^2)/(2*sigma*sigma));
gauss = gauss/sum(gauss(:));   
end

function a = processcals(nscals,maxscals)
%scals为尺度的数量，maxscals为最大的尺度
%默认尺度为均匀分布
a = [];
size_step = maxscals/nscals;
for i = 0:nscals-1
    a = [a,15 + i*size_step];    %返回的数据的处理
end
end
