program pFTP;

{$I ICSDEFS.INC}
{$IFDEF VER350}  // RAD Studio Alexandria Architect v11.2
    // Sorry, Delphi 1 does not support console mode programs;
{$ENDIF}
{$APPTYPE CONSOLE}
{$IFNDEF NOFORMS}
{$ENDIF}
{$R pftp.res} // Intigrate Main Icon

uses
  Classes, SysUtils, strutils, IdFTP, IdGlobal, IdFTPCommon;

const
  pFTPVersion  = 1;
  Copyright    = 'Console FTP-Server v1.0 - Open Source build with Embarcadero® RAD Studio 11 Version 28';

var
   CurrentDir : string;

type
    TConsoleFTPServer = class(TComponent)
    protected
         IdFTP1: TIdFTP;
   public
        // standard constructor for all classes that inherit from TComponent
        constructor Create(AOwner: TComponent); override;
        destructor  Destroy; override;
        procedure   Execute;
        procedure   printout(txt:string);
        procedure   Connect(Cmdln:string);
        procedure   listdir(param1:string);
        procedure   ChangeDir(DirName: String);
        procedure   UploadF(cmdln1: string);
        procedure   DownloadF(cmdln1,param3: string);
        procedure   RenameF(cmdln1: string);
        procedure   DeleteF(param1: string);
        procedure   CreateDir(param1: string);
        procedure   RemoveDir(param1: string);
        procedure   chmod(cmdln:string);
        procedure   getcurrentD;
        procedure   setcurrentD(cmdln:string);
        procedure   gethostcurrentD;
        procedure   createLocdir(cmdln:string);
        procedure   RmLocdir(cmdln:string);
        procedure   LsLocdir(cmdln:string);
        procedure   RenameLF(cmdln:string);
        procedure   DeleteLF(cmdln:string);
        procedure   help(cmdln:string);
    end;

constructor TConsoleFTPServer.Create(AOwner: TComponent);
begin
  (*  is a correct way to dynamically create a TIdFTP component in Delphi,
      typically within the context of a TForm or a similar component that
      can serve as the owner.*)
    inherited Create(AOwner);
   IdFTP1:= TIdFTP.Create(Self);
   IdFTP1.Passive := False;
   IdFtp1.Intercept := nil;
end;

destructor TConsoleFTPServer.Destroy;
begin
  (* Removing the FTP client component from memory and freeing up resources,
     which is important after use to avoid memory leaks – similar to Free or
     FreeAndNil to delete the object and set the pointer to nil, ensuring
     clean memory management in VCL applications.*)
    if Assigned(IdFTP1) then begin
       IdFTP1.Destroy;
       IdFTP1 := nil;
    end;
    inherited Destroy;
end;

procedure TConsoleFTPServer.Execute;
var
  cmd, cmdln : string;
  i : byte;
begin
  // first step : analyze the parameter line
  if ParamCount <> 0 then
  begin
    for i := 1 to paramcount do
    begin
      Cmdln := Cmdln + ' '+ ParamStr(i);
    end ;
    Cmdln := trim(Cmdln)+ ' ';
    connect(CmdLn);
  end
  else
    printout('');
    printout('pftp: no hostname specified; use "open [user@]host [port] [-pw password]" to connect');
    printout('************************************************************************************');
    printout('');
    printout('Connect  : predefined in the program (procedure TConApplication.Connect..)');
    printout('Port     : 21');
    printout('User     : anonymous');
    printout('Password : topsecret');
    printout('Host     : localhost');
    printout('');
    printout('Use "help" for more information');
    printout('');

  // second step : command line received analysis and execution
  repeat
    write('pFTP:>');
    flush(output);
    readln(Cmdln);
    sleep(50);
    Cmdln := trim(Cmdln)+ ' ';
    Cmd := (leftstr(Cmdln,pos(' ',Cmdln)-1 ));
    Cmdln := trimleft(midstr(Cmdln,pos(' ',Cmdln),100));
    if Cmd = '!dir'   then lsLocdir(Cmdln)            else
    if Cmd = '!mkdir' then createLocdir(Cmdln)        else
    if Cmd = '!rmdir' then RmLocdir(Cmdln)            else
    if Cmd = '!ren'   then RenameLF(Cmdln)            else
    if Cmd = '!del'   then deleteLF(Cmdln)            else
    if Cmd = 'cd'     then changedir(Cmdln)           else
    if Cmd = 'chmod'  then chmod(cmdln)               else //modif attributs
    if Cmd = 'del'    then deleteF(Cmdln)             else
    if Cmd = 'dir'    then listdir(cmdln)             else
    if Cmd = 'get'    then downloadF(cmdln,'Replace') else
    if Cmd = 'help'   then help(Cmd)                  else
    if Cmd = 'lcd'    then SetCurrentD(Cmdln)         else
    if Cmd = 'lpwd'   then GetCurrentD                else
    if Cmd = 'ls'     then listdir(cmdln)             else
    if Cmd = 'mkdir'  then CreateDir(Cmdln)           else
    if Cmd = 'mv'     then RenameF(Cmdln)             else
    if Cmd = 'open'   then connect(Cmdln)             else
    if Cmd = 'put'    then UploadF(cmdln)             else
    if Cmd = 'pwd'    then gethostcurrentD            else
    if Cmd = 'reget'  then downloadF(cmdln,'Resume')  else
    if Cmd = 'ren'    then RenameF(Cmdln)             else
    if Cmd = 'reput'  then UploadF(cmdln)             else
    if Cmd = 'rm'     then DeleteF(Cmdln)             else
    if Cmd = 'rmdir'  then RemoveDir(Cmdln)           else
    if Cmd = 'quit'   then break                      else
    if Cmd = 'exit'   then break                      else
    if Cmd = 'Bye'    then break                      else
      printout('pFTP: unknown command "'+cmdln+'"') ;

  until false;
  writeln('end of pFTP session');
  flush(output);
  sleep(1000);
end;

(*  the correct method for retrieving the current working directory
    on an FTP server.*)
procedure  TConsoleFTPServer.gethostcurrentD;
begin
  if IdFTP1.Connected then
  begin
    try
      try
        currentdir := idftp1.RetrieveCurrentDir ;
        printout('Remote directory is now '+currentdir);
      except
        on E : Exception do begin
          printout(AnsireplaceText('pFTP:  '+E.Message,#13+#10,'   '));
      end;
    end;
    finally
    end;
  end
  else
    printout('pFTP: not connected to a host; use "open user@host"');
 end;

 // functionality for renaming files on an FTP server
procedure TConsoleFTPServer.RenameLF(cmdln:string);
var
  param1, param2 : string;
begin
  param1 := trim(leftstr(Cmdln,pos(' ',Cmdln)-1 ));
  param2 := trim(midstr(Cmdln,pos(' ',Cmdln),100));
    try
      try
        if not sysutils.renamefile(param1,param2)then
        printout('pFTP: wrong file names : '+ param1 + ' '+ param2);
      except
        on E : Exception do begin
          printout(AnsireplaceText('pFTP:  '+E.Message,#13+#10,'   '));
      end;
    end;
    finally
    end;
end;

// functionality for deleting files on an FTP server
procedure TConsoleFTPServer.DeleteLF(cmdln:string);
begin
  try
    try
      if not sysutils.deletefile(trim(cmdln))then
      printout('pFTP: wrong file name : '+ cmdln);
    except
      on E : Exception do begin
        printout(AnsireplaceText('pFTP:  '+E.Message,#13+#10,'   '));
    end;
  end;
  finally
  end;
end;

(* to search the file system on the server side and format the
   results in the appropriate FTP list format.*)
procedure TConsoleFTPServer.LsLocdir(cmdln:string);
var
  Info      : TSearchRec;
  ligne,tmp : string;
begin
  if trim(cmdln)= '' then cmdln := '*.*'
  else cmdln := trim(cmdln);
  If FindFirst(getcurrentdir+'\'+cmdln,faAnyFile,Info)=0 Then
  Begin
    Repeat
      ligne := leftstr(datetimetostr(FileDateToDateTime(info.Time)),16)+'    ';
      tmp := rightstr('                '+inttostr(info.Size),12);
      tmp := leftstr(tmp,6)+' '+midstr(tmp,7,3)+' '+rightstr(tmp,3);
      if ((info.FindData.dwFileAttributes or 16) = 16) then ligne := ligne + '<DIR>         '
      else
      ligne := ligne + tmp;
      printout(ligne+' ' +info.Name);
    Until FindNext(Info)<>0;
    FindClose(Info);
  end;
end;

(* RmDir (from the system unit) is used to remove an empty directory on
   the local system, but for an FTP server you need to use an FTP
   component that supports the FTP command RMD (or DELE for files) to
   delete folders on the remote server.*)
procedure TConsoleFTPServer.RmLocdir(cmdln:string);
begin
  try
    try
      if not sysutils.removedir(trim(cmdln))then
      printout('pFTP: wrong file name : '+ cmdln);
    except
      on E : Exception do begin
        printout(AnsireplaceText('pFTP: '+E.Message,#13+#10,'   '));
    end;
  end;
  finally
  end;
end;

(* function from the System.IOUtils unit (for a local log directory)
   or the MakeDir method of an FTP component (e.g., TIdFTPServer or TIdFTP)
   for a remote directory.*)
procedure TConsoleFTPServer.createLocdir(cmdln:string);
begin
  if pos(':\',cmdln) = 0 then cmdln := getcurrentdir + '\'+ cmdln;
  try
    try
      if not sysutils.createdir(trim(cmdln))then
      printout('pftp: wrong file name : '+ cmdln);
    except on
      E : Exception do begin
      printout(AnsireplaceText('pftp: '+E.Message,#13+#10,'   '));
    end;
  end;
  finally
  end;
end;

// get the current working directory from an FTP server
procedure TConsoleFTPServer.setcurrentD(cmdln:string);
begin
    try
      try
        if not SetCurrentDir(trim(cmdln))then
        printout('pFTP: wrong file name : '+ cmdln);
        printout('Current local directory : '+ getcurrentdir);
      except
        on E : Exception do begin
          printout(AnsireplaceText('pFTP: '+E.Message,#13+#10,'   '));
      end;
    end;
    finally
    end;
end;

procedure TConsoleFTPServer.getcurrentD;
var
  txt:string;
begin
  txt := GetCurrentDir;
  printout('Current local directory : '+ txt);
end;

(*  standard way to send a CHMOD command to an FTP server, for both a
    client and an Indy-based server, is by using the SITE command.*)
procedure TConsoleFTPServer.chmod(cmdln:string);
var
  param1, param2:string;
begin
  param1 := trim(leftstr(Cmdln,pos(' ',Cmdln)-1 ));
  param2 := trim(midstr(Cmdln,pos(' ',Cmdln),100));
  if IdFTP1.Connected then
  begin
    try
      try
        IdFTP1.Site('chmod '+ param1 + ' '+ param2);
      except
        on E : Exception do begin
          printout(AnsireplaceText('pFTP: '+E.Message,#13+#10,'   '));
      end;
    end;
    finally
    end;
  end
  else printout('pFTP: not connected to a host; use "open user@host"');
end;

// connected to the ftp server
procedure TConsoleFTPServer.Connect(cmdln:string);
var
  cmd:string;
begin
  IdFTP1.port     := 21;
  IdFTP1.Username := 'anonymous';
  IdFTP1.Password := 'topsecret';
  IdFTP1.host     := 'localhost';
  IdFTP1.port     := 21;

  Cmd := (leftstr(Cmdln,pos(' ',Cmdln)-1 ));
  Cmdln := trimleft(midstr(Cmdln,pos(' ',Cmdln),100));
  // case user@host [21] [-pw password]
  if pos('@',Cmd) <> 0 then
  begin
    IdFTP1.username := leftstr(Cmd,pos('@',Cmd)-1);
    IdFTP1.host := midstr(Cmd,pos('@',Cmd)+1,100);
    Cmd := (leftstr(Cmdln,pos(' ',Cmdln)-1 ));
    Cmdln := trimleft(midstr(Cmdln,pos(' ',Cmdln),100));
    if Cmd = '-pw' then IdFTP1.password := (leftstr(Cmdln,pos(' ',Cmdln)-1 ))
    else
    begin
      if Cmd <> '' then IdFTP1.port := strtoint(Cmd);
      Cmd := (leftstr(Cmdln,pos(' ',Cmdln)-1 ));
      Cmdln := trimleft(midstr(Cmdln,pos(' ',Cmdln),100));
      if Cmd = '-pw' then IdFTP1.password := (leftstr(Cmdln,pos(' ',Cmdln)-1 ));
    end;
  end
  else
  begin
    if (trim(Cmd) <> '') then    // case host + [port]
    begin
      IdFTP1.Host := Cmd;
      if (trim(Cmdln) <> '') then IdFTP1.Port := strtoint(Cmdln);
      IdFTP1.Username := 'anonymous';
      IdFTP1.Password := 'topsecret';
    end;
  end;
  printout('user : '+IdFTP1.username+' |host : '+IdFTP1.host+' |port : '+
                     IntToStr(IdFTP1.port)+' |pass : '+IdFTP1.password);
  if IdFTP1.Connected then
  begin
    try
      try
  //      if TransferrignData then IdFTP1.Abort;
        currentdir := '';
        IdFTP1.Quit;
      except
        on E : Exception do  begin
          printout(Ansireplacetext('pFTP:++ '+E.Message,#13+#10,'   '));
      end;
    end;
    finally
    end;
  end
  else with IdFTP1 do
  begin
    try
      try
        IdFTP1.Connect;
        currentdir := idftp1.RetrieveCurrentDir ;
      except
        on E : Exception do  begin
          printout(AnsireplaceText('pFTP: '+E.Message,#13+#10,'   '));
      end;
    end;
    finally
    end;
    if IdFTP1.Connected then printout('Remote worling directory is '+ CurrentDir  );
  end;
end;

// Directory listing
procedure TConsoleFTPServer.listdir(param1:string);
Var
  LS: TStringList;
  i : integer;
begin
  param1 := trim(param1);
  if IdFTP1.Connected then
  begin
    LS := TStringList.Create;
    try
      try
        IdFTP1.TransferType := ftASCII;
        IdFTP1.List(LS);
        IdFTP1.List(LS,param1);
        if ((rightstr(currentdir,1) <> '/') and (leftstr(param1,1) <> '/')) then
                param1 := '/'+param1;
        printout('Listing directory '+currentdir+param1);
        for i := 0 to   ls.Count -1 do
          printout(LS[i]);
      except
        on E : Exception do begin
          printout(AnsireplaceText('pFTP: '+E.Message,#13+#10,'   '));
      end;
    end;
    finally
    end;
    LS.Free;
  end
  else printout('pFTP: not connected to a host; use "open user@host"');
end;

// the directory change functionality for a ftp server
procedure TConsoleFTPServer.ChangeDir(DirName: String);
begin
  if IdFTP1.Connected then
  begin
    try
      try
        IdFTP1.ChangeDir(trim(DirName));
        currentdir := idftp1.RetrieveCurrentDir ;
        printout('Remote directory is now '+currentdir);
      except
        on E : Exception do begin
          printout(AnsireplaceText('pFTP: '+E.Message,#13+#10,'   '));
      end;
    end;
    finally
    end;
  end
  else printout('pFTP: not connected to a host; use "open user@host"');
end;

// renaming files on an FTP server
procedure TConsoleFTPServer.RenameF(cmdln1: string);
var
  param1,param2 : string;
begin
  Param1 := trim(leftstr(Cmdln1,pos(' ',Cmdln1)-1 ));
  Param2 := trim(midstr(Cmdln1,pos(' ',Cmdln1),100));
  if IdFTP1.Connected then
  begin
    try
      try
        if ((param1 <> '') and (param2 <> '')) then idftp1.Rename(param1, param2);
      except
        on E : Exception do begin
          printout(AnsireplaceText('pFTP: '+E.Message,#13+#10,'   '));
      end;
    end;
    finally
    end;
  end
  else printout('pFTP: not connected to a host; use "open user@host"');
end;

// upload files to the ftp server
procedure TConsoleFTPServer.UploadF(cmdln1: string);
var
  Param1, Param2 : string;
begin
  // put filename, host-filename
  Param1 := trim(leftstr(Cmdln1,pos(' ',Cmdln1)-1 ));
  Param2 := trim(midstr(Cmdln1,pos(' ',Cmdln1),100));
  if param2 = '' then param2 := param1;
  printout('local: '+Param1+' => remote: '+param2);
  if IdFTP1.Connected then begin
    if param1 <> '' then
    begin
      try
        try
          IdFTP1.TransferType := ftBinary;
          IdFTP1.Put(param1,ExtractFileName(param2));
        except
          on E : Exception do begin
            printout(AnsireplaceText('pFTP: '+E.Message,#13+#10,'   '));
        end;
      end;
      finally
      end;
    end;
  end
  else printout('pFTP: not connected to a host; use "open user@host"');
end;

// download files from ftp server
procedure TConsoleFTPServer.DownloadF(cmdln1,param3: string);
var
  Param1, Param2 : string;
begin
  // get filename, local-filename
  Param1 := trim(leftstr(Cmdln1,pos(' ',Cmdln1)-1 ));
  Param2 := trim(midstr(Cmdln1,pos(' ',Cmdln1),100));
  if param2 = '' then param2 := param1;
  printout('remote: '+Param1+' => local: '+param2);
  if IdFTP1.Connected then
  begin
    try
      try
        IdFTP1.TransferType := ftBinary;
        // BytesToTransfer := IdFTP1.Size(param1);
        // bytestotransfer :=idFTP1.DirectoryListing.items[i].size ;
        if FileExists(param2) then
        begin
          if param3 = 'Resume'  then
          begin
            // BytesToTransfer := BytesToTransfer - FileSizeByName(Param2);
            IdFTP1.Get(param1,param2, false, true);
          end
          else
          begin
            if param3 = 'Replace' then
              IdFTP1.Get(param1,param2, true)
            else
              if param3 = 'Cancel' then
              begin
                printout('Transfert Canceled');
                exit;
              end;
          end;
        end
        else
          idFTP1.Get(param1, param2, false);
      except
        on E : Exception do  begin
          printout(AnsireplaceText('pFTP: '+E.Message,#13+#10,'   '));
      end;
    end;
    finally
    end;
  end
  else printout('pftp: not connected to a host; use "open user@host"');
end;

// delete file
procedure TConsoleFTPServer.DeleteF(param1: string);
begin
  if IdFTP1.Connected then
  begin
    try
      try
        idftp1.Delete(trim(param1));
      except
        on E : Exception do  begin
          printout(ansireplaceText('pFTP: '+E.Message,#13+#10,'   '));
      end;
    end;
    finally
    end;
  end
  else printout('pFTP: not connected to a host; use "open user@host"');
end;

// removing directory from ftp server
procedure TConsoleFTPServer.RemoveDir(param1: string);
begin
  if IdFTP1.Connected then
  begin
    try
      try
        idftp1.RemoveDir(trim(param1));

     (* If you are using the RemoveDir method of the Indy component
        TIdFTP (as a client), you should be aware that most FTP servers
        only allow the deletion of a directory if it is empty.*)
        // ChangeDir(idftp1.RetrieveCurrentDir);
      except
        on E : Exception do  begin
          printout(AnsireplaceText('pFTP: '+E.Message,#13+#10,'   '));
      end;
    end;
    finally
    end;
  end
  else printout('pFTP: not connected to a host; use "open user@host"');
end;

// create directory on ftp server
procedure TConsoleFTPServer.CreateDir(param1: string);
begin
  if trim(param1) <> '' then
  begin
    if IdFTP1.Connected then
    begin
      try
        try
           IdFTP1.MakeDir(trim(param1));
        except
          on E : Exception do begin
            printout(AnsireplaceText('pFTP: '+E.Message,#13+#10,'   '));
        end;
      end;
      finally
      end;
    end
    else printout('pFTP: not connected to a host; use "open user@host"');
  end
  else printout('pFTP: no Directory name');
end;

(*  logging status information or listing directory contents from an FTP server *)
procedure TConsoleFTPServer.printout(txt:string);
begin
  writeln(txt);
  flush(output);
end;

// the console help command list
procedure TConsoleFTPServer.help(cmdln:string);
begin
printout('');
printout('to launch pftp :');
printout(' pFTP [user@]host [21] [-pw password]');
printout(' pFTP host [port]');
printout('');
printout('all pFTP commands :');
printout(' !dir   list contents of current directory in local client');
printout(' !dir  [selection-criteria]');
printout('');
printout(' !mkdir create a directory in local client');
printout(' !mkdir New-Directory');
printout('');
printout(' !rmdir remove a directory in local client');
printout(' !rmdir Directory');
printout('');
printout(' !ren   rename a file in local client');
printout(' !ren   Old-file New-file');
printout('');
printout(' !del   remove a file in local client');
printout(' !del   File');
printout('');
printout(' bye    finish your FTP session');
printout('');
printout(' cd     change your remote working directory');
printout(' cd     Sub-directory');
printout('');
printout(' chmod  change file permissions and modes');
printout(' chmod  Attrib file');
printout('');
printout(' del    delete a file');
printout(' del    File');
printout('');
printout(' dir    list contents of a remote directory');
printout(' dir    [Sub-directory]');
printout('');
printout(' exit   finish your FTP session');
printout('');
printout(' get    download a file from the server to your local machine');
printout(' get    Host-file [local-file]');
printout('');
printout(' help   print this help');
printout('');
printout(' lcd    change local working directory');
printout(' lcd    Sub-directory');
printout('');
printout(' lpwd   print current local working directory');
printout(' lpwd   ');
printout('');
printout(' ls     list contents of a remote directory');
printout(' ls     [Sub-directory] ');
printout('');
printout(' mkdir  create a directory on the remote server');
printout(' mkdir  New-directory');
printout('');
printout(' mv     move or rename a file on the remote server');
printout(' mv     Old-file new-file');
printout('');
printout(' open   connect to a host');
printout(' open   [User@]host [port] [-pw password]');
printout('');
printout(' put    upload a file from your local machine to the server');
printout(' put    Local-file [host-file]');
printout('');
printout(' pwd    print your remote working directory');
printout(' pwd    ');
printout('');
printout(' quit   finish your FTP session');
printout('');
printout(' reget  continue downloading a file');
printout(' reget  Host-file [local-file]');
printout('');
printout(' ren    move or rename a file on the remote server');
printout(' ren    Old-file New-file ');
printout('');
printout(' reput  continue uploading a file');
printout(' reput  Local-file [host-file]');
printout('');
printout(' rm     delete a file on remote server');
printout(' rm     Host-file');
printout('');
printout(' rmdir  remove a directory on the remote server');
printout(' rmdir  Host-directory');
end;

var
    ConApp : TConsoleFTPServer;
begin
    WriteLn(CopyRight);
    WriteLn;
    ConApp := TConsoleFTPServer.Create(nil);
    try
        ConApp.Execute;
    finally
        ConApp.Destroy;
    end;

 {
 procedure TMainForm.IdFTP1Disconnected(Sender: TObject);
begin
  StatusBar1.Panels[1].Text := 'Disconnected.';
end;

procedure TMainForm.AbortButtonClick(Sender: TObject);
begin
  AbortTransfer := true;
end;

procedure TMainForm.IdFTP1Status(axSender: TObject; const axStatus: TIdStatus;
  const asStatusText: String);
begin
  DebugListBox.ItemIndex := DebugListBox.Items.Add(asStatusText);
  StatusBar1.Panels[1].Text := asStatusText;
  checkWaitStatus(asStatusText);
end;

procedure TMainForm.IdFTP1Work(Sender: TObject; AWorkMode: TWorkMode;
  const AWorkCount: Integer);
Var
  S: String;
  TotalTime: TDateTime;
  H, M, Sec, MS: Word;
  DLTime: Double;
begin
  TotalTime :=  Now - STime;
  DecodeTime(TotalTime, H, M, Sec, MS);
  Sec := Sec + M * 60 + H * 3600;
  DLTime := Sec + MS / 1000;
  if DLTime > 0 then
 //   AverageSpeed := }{(AverageSpeed + }{(AWorkCount / 1024) / DLTime}{) / 2}{;

  if AverageSpeed > 0 then begin
    Sec := Trunc(((ProgressBar1.Max - AWorkCount) / 1024) / AverageSpeed);

    S := Format('%2d:%2d:%2d', [Sec div 3600, (Sec div 60) mod 60, Sec mod 60]);

    S := 'Time remaining ' + S;
  end
  else S := '';

  S := FormatFloat('0.00 KB/s', AverageSpeed) + '; ' + S;
  case AWorkMode of
    wmRead: StatusBar1.Panels[1].Text := 'Download speed ' + S;
    wmWrite: StatusBar1.Panels[1].Text := 'Uploade speed ' + S;
  end;

  if AbortTransfer then IdFTP1.Abort;
  ProgressBar1.Position := AWorkCount;
  AbortTransfer := false;
end;

procedure TMainForm.IdFTP1WorkBegin(Sender: TObject; AWorkMode: TWorkMode;
  const AWorkCountMax: Integer);
begin
  TransferrignData := true;
  AbortButton.Enabled := true;
  AbortTransfer := false;
  STime := Now;
  if AWorkCountMax > 0 then ProgressBar1.Max := AWorkCountMax
  else ProgressBar1.Max := BytesToTransfer;
  AverageSpeed := 0;
end;

procedure TMainForm.IdFTP1WorkEnd(Sender: TObject; AWorkMode: TWorkMode);
begin
  AbortButton.Enabled := false;
  StatusBar1.Panels[1].Text := 'Transfer complete.';
  BytesToTransfer := 0;
  TransferrignData := false;
  ProgressBar1.Position := 0;
  AverageSpeed := 0;
end;
}

end.

