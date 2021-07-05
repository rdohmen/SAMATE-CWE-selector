unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, FileUtil;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    ListBox1: TListBox;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    SelectDirectoryDialog2: TSelectDirectoryDialog;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public
    InputPath, OutputPath: string;
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }



procedure TForm1.Button1Click(Sender: TObject);
var
  cweList: TStringList;
  cweNumber: string;

  procedure ScanFolder(const Path: string);
  var
    sPath: string;
    rec: TSearchRec;
    p1, p2: integer;
    dir,
    s: string;
    sl:TStringList;
    i: integer;
    unsafe:boolean;
  begin
    sPath := IncludeTrailingPathDelimiter(Path);
    if FindFirst(sPath + '*.*', faAnyFile, rec) = 0 then
    begin
      repeat
        // TSearchRec.Attr contain basic attributes (directory, hidden,
        // system, etc). TSearchRec only supports a subset of all possible
        // info. TSearchRec.FindData contains everything that the OS
        // reported about the item during the search, if you need to
        // access more detailed information...

        if (rec.Attr and faDirectory) <> 0 then
        begin
          // item is a directory
          if (rec.Name <> '.') and (rec.Name <> '..') then
            ScanFolder(sPath + rec.Name);
        end
        else
        begin
          // item is a file
          //\CWE_*.php
          //cweNumber := copy(rec.Name, 5, 3);
          p1 := pos('_', rec.Name);
          if p1 > 0 then
          begin
            s := copy(rec.Name, p1 + 1, length(rec.Name) - p1);
            p2 := pos('_', s);
            if p2 > 0 then
            begin

              // the location of the CWE-number is in between the _'s
              cweNumber := copy(rec.Name, p1 + 1, p2 - 1);
              if (cweList.IndexOf(cweNumber) <> -1) or checkbox2.checked then
              begin
                Listbox1.items.Add(rec.Name);

                dir:=outputpath + '\' + cwenumber;
                if not directoryexists(dir) then
                  mkdir(dir);

                if checkbox1.checked then begin
                  sl:=Tstringlist.create;
                  sl.LoadFromFile( path + '\' +  rec.Name );

                  unsafe:=false;
                  for i:=0 to sl.count-1 do begin
                    if pos( 'Unsafe sample',sl[i])=1 then
                      unsafe:=true;
                    end;

                  if unsafe then begin
                    dir:=outputpath + '\' + cwenumber + '\unsafe\' ;
                    if not directoryexists(dir) then
                      mkdir(dir);

                    copyfile(path + '\' +  rec.Name, outputpath + '\' + cwenumber + '\unsafe\' + rec.Name);
                    end
                  else begin
                    dir:=outputpath + '\' + cwenumber + '\safe\' ;
                    if not directoryexists(dir) then
                      mkdir(dir);

                    copyfile(path + '\' +  rec.Name, outputpath + '\' + cwenumber + '\safe\' + rec.Name);
                    end;
                  end
                else begin

                  copyfile(path + '\' +  rec.Name, outputpath + '\' + cwenumber + '\' + rec.Name);
                //ShowMessage(inputpath + '\' + rec.Name + '=>' + outputpath + '\' + rec.Name);
                  end;
              end;
            end;
          end;

        end;
      until FindNext(rec) <> 0;
      FindClose(rec);
    end;
  end;

begin
  button1.enabled:=false;
  button2.enabled:=false;
  button3.enabled:=false;

  cweList := TStringList.Create;
  cweList.delimitedText := edit1.Text;

  listbox1.Clear;
  ScanFolder(Inputpath);
  Label5.Caption := 'Number of files: ' + IntToStr(Listbox1.Count);

  button1.enabled:=true;
  button2.enabled:=true;
  button3.enabled:=true;

end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  if SelectDirectoryDialog1.Execute then
  begin
    OutputPath := SelectDirectoryDialog1.Filename;
    Label2.Caption := 'Folder with Samate files (input): ' + OutputPath;
    Button1.Enabled := True;
  end;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  if SelectDirectoryDialog2.Execute then
  begin
    InputPath := SelectDirectoryDialog2.Filename;
    Label3.Caption := 'Folder for selected files (output): ' + InputPath;
    Button1.Enabled := True;
  end;
end;

procedure TForm1.CheckBox2Click(Sender: TObject);
begin
  edit1.enabled := not checkbox2.checked;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Inputpath := 'C:\Users\Docent\Desktop\ou\grad\000';
  Label3.Caption := 'Folder for selected files (output): ' + InputPath;

  OutputPath := 'C:\Users\Docent\Desktop\ou\grad\laz\laz select CWE';
  Label2.Caption := 'Folder with Samate files (input): ' + OutputPath;
end;

end.
