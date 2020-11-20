import serial
import sys
import glob
import serial
import struct
import cv2 as cv
import time
import numpy as np
import time
def serial_ports():
    """ Lists serial port names

        :raises EnvironmentError:
            On unsupported or unknown platforms
        :returns:
            A list of the serial ports available on the system
    """
    if sys.platform.startswith('win'):
        ports = ['COM%s' % (i + 1) for i in range(256)]
    elif sys.platform.startswith('linux') or sys.platform.startswith('cygwin'):
        # this excludes your current terminal "/dev/tty"
        ports = glob.glob('/dev/tty[A-Za-z]*')
    elif sys.platform.startswith('darwin'):
        ports = glob.glob('/dev/tty.*')
    else:
        raise EnvironmentError('Unsupported platform')

    result = []
    for port in ports:
        try:
            s = serial.Serial(port)
            s.close()
            result.append(port)
        except (OSError, serial.SerialException):
            pass
    return result
#print(serial_ports())
ser = serial.Serial('COM30',115200,timeout=10,bytesize=8,stopbits=1)
img1=cv.imread("6.jpg")
img=img1
cv.imshow("image",img)
cv.waitKey(0)
print(img.shape)
img2=np.zeros((250,250,3))
t3=time.time()
for i in range(3):
  for t in range(1,500,2):
    for tt in range(1,500,2):
      if(t!=499 and tt!=499):
        g=(img[t,tt,i]*4)+(img[t-1,tt,i]*2)+(img[t,tt-1,i]*2)+(img[t+1,tt,i]*2)+(img[t,tt+1,i]*2)+(img[t-1,tt-1,i])+(img[t-1,tt+1,i])+(img[t+1,tt-1,i])+(img[t+1,tt+1,i])
        g=g//16
        img2[t//2,tt//2,i]=g
      else:
        img2[t//2,tt//2,i]=img[t,tt,i]
t4=time.time()
img2=img2.astype('uint8')
cv.imshow("image",img2)
cv.waitKey(0)
print(img)
for k in range(2):
   print(1)
   a = ser.read()
   start = struct.unpack("B", a)
   print(start[0], k)
   ser.flush()
   while(start[0]!=240):
       a = ser.read()
       start = struct.unpack("B", a)
       ser.flush()
   print(a,k)
   if(start[0]==240):
    ser.write(struct.pack('>B', 1))
   ser.flush()
   print(1)
   a = ser.read()
   start = struct.unpack("B", a)
   print(start[0], k)
   ser.flush()
   while (start[0] != 240):
       a = ser.read()
       start = struct.unpack("B", a)
       ser.flush()
   print(a, k)
   if (start[0] == 240):
       ser.write(struct.pack('>B', 244))
   ser.flush()
s=0
tx=0
picture=np.zeros((250,250,3))
for i in range(3):
    for k in range(500):
      for kk in range(500):
       print(1)
       a = ser.read()
       start = struct.unpack("B", a)
       print(start[0], k)
       ser.flush()
       while(start[0]!=240):
           a = ser.read()
           start = struct.unpack("B", a)
           ser.flush()
       print(a)
       if(start[0]==240):
        ser.write(struct.pack('>B', img[k,kk,i]))
       ser.flush()
    t0=time.time()
    for k in range(250):
      for kk in range(250):
          b=ser.read()
          g=struct.unpack("B", b)
          if(k+kk==0):
              t1=time.time()
          print(g[0])
          if(g[0]!=k%256):
              s=s+1
          picture[k,kk,i]=g[0]
          ser.flush()
    tx=tx+t1-t0
picture=picture.astype('uint8')
ser.close()
print(picture.shape)
cv.imshow("Image",picture)
cv.waitKey(0)
cv.destroyAllWindows()
print("Processing time:",tx)
print("computer time",t4-t3)
print(sum(sum(sum(abs(picture-img2)))))