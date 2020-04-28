int x = 20;
print "Numbers are:";
for i in range(1,21) {
  print i;
};

int result = 0;
do {
  result = result + x;
  x = x - 1;
} while (x != 0);
print "Sum is:";
print result;
End
