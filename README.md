# TTT4145 - Radiokommunikasjon term project @ NTNU
Simulink 2024 implementation of the M17 digital radio protocol physical and data link layers, adapted to work with the ADALM-PLUTO SDR platform. Of the data link layer, only the packet mode is implemented. 

## About M17

M17 is an open-source digital radio protocol designed for amateur radio and professional applications. More information can be found at https://m17project.org/about/.

## Custom Modifications
The following modification were introduced:
* QPSK is used instead of 4-FSK
* The symbol rate is doubled, to counter the frequency drift of the ADALM-PLUTO during the symbol time. For improved error detection and to match the datarate of the original protocol, each frame is sent twice. 

## Getting Started
To run the project, open [AdalmPlutoVoice.prj](AdalmPlutoVoice.prj). Parameters of transmitter and receiver are set in [source/plutoradio_init.m](source/plutoradio_init.m). <br>
To run the transmitter, open [source/transmitter/ADALM_PLUTO_transmitter.slx](source/transmitter/ADALM_PLUTO_transmitter.slx) <br>
To run the receiver, open [source/receiver/ADALM_PLUTO_receiver.slx](source/receiver/ADALM_PLUTO_receiver.slx) <br>

## AUTHORS
Roberto Scardia and Fredrik Kihl
