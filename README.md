# Console-ftp-Client:

</br>

![Compiler](https://github.com/user-attachments/assets/a916143d-3f1b-4e1f-b1e0-1067ef9e0401) ![10 Seattle](https://github.com/user-attachments/assets/c70b7f21-688a-4239-87c9-9a03a8ff25ab) ![10 1 Berlin](https://github.com/user-attachments/assets/bdcd48fc-9f09-4830-b82e-d38c20492362) ![10 2 Tokyo](https://github.com/user-attachments/assets/5bdb9f86-7f44-4f7e-aed2-dd08de170bd5) ![10 3 Rio](https://github.com/user-attachments/assets/e7d09817-54b6-4d71-a373-22ee179cd49c)  ![10 4 Sydney](https://github.com/user-attachments/assets/e75342ca-1e24-4a7e-8fe3-ce22f307d881) ![11 Alexandria](https://github.com/user-attachments/assets/64f150d0-286a-4edd-acab-9f77f92d68ad) ![12 Athens](https://github.com/user-attachments/assets/59700807-6abf-4e6d-9439-5dc70fc0ceca)  
![Components](https://github.com/user-attachments/assets/d6a7a7a4-f10e-4df1-9c4f-b4a1a8db7f0e) ![None](https://github.com/user-attachments/assets/30ebe930-c928-4aaf-a8e1-5f68ec1ff349)  
![Discription](https://github.com/user-attachments/assets/4a778202-1072-463a-bfa3-842226e300af) ![Console FTP-Client](https://github.com/user-attachments/assets/4f72f13f-1ce3-4429-9de4-d99b085a4ee3)  
![Last Update](https://github.com/user-attachments/assets/e1d05f21-2a01-4ecf-94f3-b7bdff4d44dd) ![122025](https://github.com/user-attachments/assets/2123510b-f411-4624-a2fc-695ffb3c4b70)  
![License](https://github.com/user-attachments/assets/ff71a38b-8813-4a79-8774-09a2f3893b48) ![Freeware](https://github.com/user-attachments/assets/1fea2bbf-b296-4152-badd-e1cdae115c43)  

</br>


The File Transfer Protocol (FTP) is a standard [communication protocol](https://en.wikipedia.org/wiki/Communication_protocol) used for the transfer of computer files from a [server](https://en.wikipedia.org/wiki/Server_(computing)) to a [client](https://en.wikipedia.org/wiki/Client_(computing)) on a computer network. FTP is built on a [client–server model](https://en.wikipedia.org/wiki/Client%E2%80%93server_model) architecture using separate control and data connections between the client and the server. FTP users may authenticate themselves with a plain-text sign-in protocol, normally in the form of a username and password, but can connect anonymously if the server is configured to allow it. For secure transmission that protects the username and password, and encrypts the content, FTP is often [secured](https://en.wikipedia.org/wiki/File_Transfer_Protocol#Security) with [SSL/TLS](https://en.wikipedia.org/wiki/SSL/TLS) ([FTPS](https://en.wikipedia.org/wiki/FTPS)) or replaced with [SSH File Transfer Protocol](https://en.wikipedia.org/wiki/SSH_File_Transfer_Protocol) (SFTP).

</br>

![Console FTP](https://github.com/user-attachments/assets/cc8a5871-afcf-476f-8af0-663ab356c59d)

</br>

Console-FTP-Client is a program that can control an FTP server without any visible Windows windows. The console commands are predefined and can be changed or modified as desired. You can also integrate as many commands as you like to extend the functionality. To use the console commands, simply link them to the corresponding functions. Just be careful not to duplicate any console commands; otherwise, you can let your imagination run wild.

Line 320 defines the user login, which enables the client to log in and therefore needs to be changed.

# Command list:

</br>

| command | function | description |
| :------------ | :------------ | :------------ |
| ```!dir```     | ```lsLocdir(Cmdln)```     | The command lsLockdir is not a standard, recognized command in general FTP console usage. The standard FTP command for listing files and directories on a remote server is ls or dir.     |
| ```!mkdir```     | ```createLocdir(Cmdln)```     | The mkdir command in FTP is used to create a new directory on the remote server. Depending on the FTP client and server, there are some variations of the mkdir command that can be utilized: mkdir <directory> : This basic command creates a new directory with the specified name.     |










