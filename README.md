# E4980A_16Channel_Extension_MATLAB_Arduino
Using a low-cost multiplexer and arduino to extend the E4980A LCR Meter to up to 16 Channels

This is a project derived from one of my previous on E4980A LCR Meter.
https://github.com/DesmondZuo/E4980A_MATLAB_Monitor

This rep contains code supporting the extension of the Agilent E4980A LCR Meter to up to 16 channels

Hardware requirement: 1 * E4980A, 1 * Arduino Uno, and 1 * Sparkfun 16 Channel Mux
Software requirement: Everything from the E4980A_MATLAB_Monitor project (Link above), and the Arduino supporting package for MATLAB.

An error will occur when downloading the supporting package from the MATLAB IDE, see the following link for solution.
https://www.youtube.com/watch?v=uEjDhID3H4c

In the MATLAB code I used 9 channels and achieved a fastest sampling frequency of 2.85hz (0.35s iterating through 9 channels)

If you have any questions, feel free to contact me via desmondzuo@gmail.com

Runze Zuo, University of Toronto, Computer Engineering 3rd Year Undergrad.
