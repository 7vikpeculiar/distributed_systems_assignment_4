## Problem 1 (Token in a ring problem)
- The idea is to spawn N processes and give the token to process 0
- Each token is passed by process i to process i+1
- The N-1 process passes it to process 0 
- To Name the processes as 0,1,2...N-1; register is used, as register cant handle integers directly, Pid I is converted to string and finally an 
  atom
- Each process on getting the token, writes to the Output file 
- Process 0 first sends the token, and recieves it from process N-1 and then prints it.
- All other processes print as soon as the token is received and forward the token to the next process

## Problem 2 (Parallelized merge sort)
- The idea is to split the original list to N pieces each piece is individually sorted and finally all the results are combined
- Given L length list and N processes
- The main process spawns N=16 children
- The first N-1 processes get L/N-1 elements, whereas the last processes gets the left over L%N-1 elements
- Each process calls merge sort recursively and uses the inbuilt merge function
- After each processes is done it sends its sorted list to the parent
- The parent then merges them starting with the empty list and merging the incoming list 
- After all lists are merged into a single list, the parent process writes it into a file


