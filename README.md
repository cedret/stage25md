## Menu while/do avec bash

````
#!/bin/bash
echo -n "

1. healthchk
2. bpipwd
3. cust_usage_check
4. other scripts automatic

enter choice [1 | 2 | 3 | 4 ]: "
read numchoice

while [ !($numchoice -ge 1) && !($numchoice -le 4) ]
do
echo -n "you entered incorrect, try again: "
read numchoice
done
````
