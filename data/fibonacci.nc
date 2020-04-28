int x = 0;
int y = 1;
int z = 0;
print "Fibonacci series till 10th term";
print x;
print y;
for(int i = 0; i < 8 ; i++) {
  z = x + y;
  print z;
  y = x;
  x = z;
};

End