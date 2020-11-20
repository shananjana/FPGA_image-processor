import serial
import sys
import glob
import serial
import struct
import cv2 as cv
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
print(1)
a = ser.read()
start = struct.unpack("B", a)
print(start[0])
ser.flush()
while(start[0]!=240):
       a = ser.read()
       start = struct.unpack("B", a)
if(start[0]==240):
    ser.write(struct.pack('>B', 100))
ser.flushInput()
ser.flushOutput()
b=ser.read()
g=struct.unpack("B", b)
print(g[0])
ser.close()
