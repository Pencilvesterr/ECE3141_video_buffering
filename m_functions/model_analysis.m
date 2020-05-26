clc; clear all; close all;

transmission_rate = 100*1e3;  %(bytes/s)
max_buffer_size = 2000*1e3 ;  % (Bytes)
encoded_data = importdata('../data/jarrasic_park_encoded_mp4_low.txt')';

[success, buffering_time] = simulate_buffer(encoded_data, transmission_rate, max_buffer_size, true);