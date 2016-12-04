'''
author:you2mu
msr，msrcr算法的实现
R(x,y) = ∑w(exp(log(I)-log(I*F)))  多尺度
'''


import numpy as np
import scipy.ndimage as image
import scipy.fftpack as fft
import matplotlib.pyplot as plt

img = image.imread('origin.jpg')
img = np.double(img)

def gaussian(r,c,sigma):  #r为高斯半径，sigma为高斯核
    x, y = np.mgrid[-(r-1)/2:(r-1)/2+1,-(c-1)/2:(c-1)/2+1]
    gauss = (1/(2*np.pi*sigma**2))*np.exp(-(x**2+y**2)/(2*sigma))
    return gauss

def msr(i,kernel):
    fkernel = fft.fft2(kernel)
    fkernel = fft.fftshift(fkernel)
    I = fft.fft2(i)
    R = fft.ifft2(I * fkernel)
    R = np.abs(R)
    min1 = np.min(R)
    R = np.log(i + 1) - np.log(R - min1 + 1)
    return R

def main():
    result = []
    r, c, _ = img.shape
    gauss15 = gaussian(r, c, 15)
    gauss80 = gaussian(r, c, 80)
    gauss250 = gaussian(r, c, 250)
    mg = img[:,:,0] + img[:,:,1] + img[:,:,2] 
    for i in range(3):
        t = img[:,:,i]  
        t = np.double(t)
        g = (np.log(125 * t + 1) - np.log(mg + 1)) * 46
        result15 = msr(t, gauss15)
        result80 = msr(t, gauss80)
        result250 = msr(t, gauss250)
        m = (result15 + result80 + result250)/3 
        min1 = np.min(m)
        max1 = np.max(m)
        m = np.uint8(255 * (m - min1) / (max1 - min1))  #msr
        
        r = 192 * (g * m - 30)
        min1 = np.min(r)
        max1 = np.max(r)
        r = np.uint8(255 * (r - min1) / (max1 - min1))
        result.append(r)
    result = np.dstack((result[0], result[1], result[2]))
    return result
msrcr = main()
plt.imsave('out.jpg',msrcr)
plt.imshow(msrcr)
plt.show()
