%img = imread(pathname)
%nscals为尺度的数目
%maxscal为尺度最大值 默认尺度为均匀分布
% s 1 ,s 2 the percentage of clipping pixels on each side
function result = msrcp(img,nscals,maxscal,s1,s2)
img = double(img);
R = img(:,:,1);
G = img(:,:,2);
B = img(:,:,3);
diff = 0;
r = size(img,1);
c = size(img,2);
t = (R+G+B)/3;
T = fft2(t);
scals = processcals(nscals,maxscal);
for m =1:r
    for n = 1:c
        if t(m,n) < 1
            t(m,n) = 1;
        end
    end
end
for i = 1:nscals
    gauss = gaussian(r,c,scals(i));
    gauss = fft2(gauss,r,c);
    gauss = fftshift(gauss);
    rr = ifft2(T.*gauss);
    rr = abs(rr);
    diff = diff + log(t) - log(rr);
end
diff = diff/nscals;
diff = scb(diff,1.5,1.5);
%simplestcolorbalance
for m = 1:r
    for n = 1:c
        factor = diff(m,n)/(t(m,n));
        if factor>3
            factor = 3;
        end
        Rout(m,n) = factor*R(m,n);
        Gout(m,n) = factor*G(m,n);
        Bout(m,n) = factor*B(m,n);
        if (Rout(m,n)>255 || Bout(m,n)>255 || Gout(m,n)>255)
            Max = R(m,n);
            if (G(m,n)>Max)
                Max = G(m,n);
            end
            if (B(m,n)>Max)
                Max = B(m,n);
            end
            factor = 255/Max;
            Rout(m,n) = factor*R(m,n);
            Gout(m,n) = factor*G(m,n);
            Bout(m,n) = factor*B(m,n);
    end
    end
end
%result(:,:,1) = uint8(Rout);
%result(:,:,2) = uint8(Gout);
%result(:,:,3) = uint8(Bout);
result = cat(3,uint8(Rout),uint8(Gout), uint8(Bout));
end

function a = processcals(nscals,maxscal)
%默认采用均匀分布
a = [];
size_step = maxscal/nscals;
for i = 0:nscals-1
    a = [a,15 + i*size_step];    
end
end

function gauss = gaussian(r,c,sigma)
[x,y] = meshgrid(-(r-1)/2:r/2,-(c-1)/2:c/2);
gauss = exp(-(x.^2+y.^2)/(2*sigma*sigma));
gauss = gauss/sum(gauss(:));   
end

function output = scb(input,s1,s2)
r = size(input,1);
c = size(input,2);
imgsize = r*c;
sortinput = sort(input(:));
per1 = int64(imgsize*s1/100);  %注意溢出 int64
min1 = sortinput(per1);
per2 = int64(imgsize*s2/100);
max1 = sortinput(imgsize - per2 -1);
%只需要求得max与min
if max1<min1
    for m = 1:r
        for n = 1:c
            output(m,n) = max1;
        end
    end
else
    scale = 255/(max1-min1);
    for m = 1:r
        for n = 1:c
            if(input(m,n)<min1)
                output(m,n) = 0;
            elseif(input(m,n)>max1)
                output(m,n) = 255;
            else
                output(m,n) = scale*(input(m,n)-min1);
            end
        end
    end
end
end

