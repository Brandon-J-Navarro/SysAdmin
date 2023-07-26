#How to append text to a file when using sudo command on Linux or Unix

#Method 1: Use tee command
#The tee command read from standard input (such as keyboard) and write to standard output (such as screen) and files. The syntax is as follows
echo 'text' | sudo tee -a /path/to/file
echo '192.168.1.254 router' | sudo tee -a /etc/hosts

#Sample outputs:
#Password:
#192.168.1.254   router

#This solution is simple and you avoided running bash/sh shell with root privileges. Only append or write part needed root permission. Now use the cat command (or bat command if you want to see fancy outputs):
cat /etc/hosts

#Bash: append to file with sudo and tee
#Want to append text to more than one file while using sudo? Try:
echo 'data' | sudo tee -a file1 file2 fil3

#Verify that you just appended to a file as sudo with cat command:
#cat file1
#cat file2

#We can append to a file with the sudo command:
cat my_file.txt | sudo tee -a existing_file.txt > /dev/null

#It is a good idea to redirect tee output to /dev/null when appending text. 
#In other words, use >/dev/null when you don’t want tee command to write to the standard output such as screen.

#Understanding the tee command options
#-a OR --append : Append to the given FILEs, do not overwrite
#-i OR --ignore-interrupts : Ignore interrupt signals
#-p : Diagnose errors writing to non pipes
#See tee command man page by typing the following man command or help command:
man tee
tee --help # GNU/Linux

#Method 2: Use bash/sh shell
#The syntax is:
sudo sh -c 'echo text >> /path/to/file'
sudo -- sh -c "echo 'text foo bar' >> /path/to/file"
sudo -- bash -c 'echo data >> /path/to/file'
sudo bash -c 'echo data text >> /path/to/file'

#For example:
sudo sh -c 'echo "192.168.1.254 router" >> /etc/hosts'

#The -c option is passed to the sh/bash to read commands from the argument string. 
#Please note that you are running bash/sh shell with root privileges and redirection took place in that shell session. 
#However, quoting complex command can be problem. Hence, the tee command method recommended to all.
