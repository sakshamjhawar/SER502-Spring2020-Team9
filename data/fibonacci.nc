int x = 0;
int y = 1;
int z = 0;
print x;
print y;
for(int i = 0; i < 8 ; i++) {
  z = x + y;
  print z;
  y = x;
  x = z;
};
End