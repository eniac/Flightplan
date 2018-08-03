Run memecahedtest.sh for testing

Currently the way to send multiple packets is quite tricky. It is achieved on the wrapper (the .hpp file). My idea is to invokethe MemCore twice with the same input packets. Thus I need a state variable as input and output tuple to indicate whether this packets need be processed twice or not. 
Another way for further hardware implementation, as suggeseted by Hans, I could output the two packets at once and put the remained in a buffer. 
