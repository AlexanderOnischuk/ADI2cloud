@echo off
chcp 1251 > nul
COLOR 0A
TITLE Шифрование/Дешифрование бекапов: Adi,Afi
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Скрипт создания более безопасного бекапа(ADI/AFI) для облаков.
:: Этот скрипт желательно спрятать в шифруемый 16-битный архив, также и как сам бекап.
:: ToDo: +1.Доработать действия с дешифровкой файла.
::       2.Возможно перевести интерфейс на английский. Протестировать скрипт на различных ПК.
::       +3.Возможно при архивировании бекапа, в архив добавлять текстовый файл в котором будет оригинальное имя файла и расширение. Чтобы не забыть! Все равно архив шифруем!
::          3.A.В текстовый файл записывать не полный путь, а ИмяФайла.Расширение
::       +4.Скрипт создает во временных уникальный каталог и работает только с ним, в конце удаляет его со всеми остальными временными файлами.
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Обьявляем необходимые переменные если нужно:
:: set arc="C:\Program Files\WinRAR\Rar.exe"
set d=A-B0-F2E-C1D3

:: Запускаем меню выбора действия
echo -----------------------------------
echo ADI2cloud - ver.1.2
echo Created by ALExorON (c), 29.VI.2018
echo -----------------------------------
echo Шифровать - 1
echo Дешифровать - 2
set /p "param=Выберите вариант действия: "
goto metka%param% 



:metka1 
:: Выбираем имя бекапа
SetLocal EnableExtensions
for /f "tokens=2 delims=:" %%i in ('chcp') do set sPrevCP=%%i& chcp 1251 >nul
for /f "usebackq delims=" %%i in (`mshta.exe "about:<input type=file id=F><script>F.click();new ActiveXObject('Scripting.FileSystemObject').GetStandardStream(1).WriteLine(F.value);close();</script>" ^|more`) do (
  set file=%%i
)
chcp %sPrevCP% >nul
if defined file (
    echo Selected file: %file%
) else (
    echo File not selected!
)

:: Копируем выбранный файл в новое имя
mkdir "%temp%\%d%"
copy /y "%file%" "%temp%\%d%\%date%.mp3"
echo %file%>"%temp%\%d%\orig.txt"

:: Запрашиваем пароль для шифрования архива
call :inputbox "Введите пароль для архива (желательно более 16-битный):" "Input password"
:InputBox
set input=
set heading=%~2
set message=%~1
echo wscript.echo inputbox(WScript.Arguments(0),WScript.Arguments(1)) >"%temp%\%d%\input.vbs"
for /f "tokens=* delims=" %%a in ('cscript //nologo "%temp%\%d%\input.vbs" "%message%" "%heading%"') do set input=%%a

:: Шифруем и архивируем файл
RAR.exe A -m5 -s -t -k -ep -ma4 -hp%Input% "%temp%\%d%\budget.rar" "%temp%\%d%\%date%.mp3" "%temp%\%d%\orig.txt"

:: Архив опять переименовываем для запутывания дешифровки. Старый архив удаляем и ставим атрибут "Только для чтения"
copy /y "%temp%\%d%\budget.rar" "%temp%\%d%\%date%.avi"
::del /f /q "%temp%\budget.rar"
::del /f /q "%temp%\orig.txt"
::attrib +R "%temp%\%date%.avi"

:: Сохраняем файл в нужный каталог. И удаляем временный
setlocal
for /f "tokens=2 delims=:" %%i in ('chcp') do (
    set sPrevCP=%%i
    chcp 1251 >nul
)
for /f "usebackq delims=" %%i in (
    `@"%systemroot%\system32\mshta.exe" "javascript:var objShellApp = new ActiveXObject('Shell.Application');var Folder = objShellApp.BrowseForFolder(0, 'Куда сохранить файл?',1, '::{20D04FE0-3AEA-1069-A2D8-08002B30309D}');try {new ActiveXObject('Scripting.FileSystemObject').GetStandardStream(1).Write(Folder.Self.Path)};catch (e){};close();" ^
    1^|more`
) do set sFolderName=%%i
chcp %sPrevCP% >nul
if defined sFolderName (
    echo Selected directory: %sFolderName%
) else (
    echo Directory not select.
)
copy /y "%temp%\%d%\%date%.avi" "%sFolderName%\%date%.avi"
::del /f /q "%temp%\%date%.avi"
::del /f /q "%temp%\input.vbs"
rmdir /s /q "%temp%\%d%\"

:: В завершение выводим диалоговое окно - обо успешном завершении.
SetLocal EnableExtensions
call :msg "Бекап успешно подготовлен для Clouds."
pause > nul
Exit
:msg
::  chcp 866 >NUL& for /F "delims=" %%a in ("%~1") do chcp 1251 >NUL& call :convert "%%~a"& chcp 866 >NUL& Exit
:convert
  set "text=%~1"
  (@for %%a in ("%text:\n=" "%") do @echo.%%~a) | msg *
exit
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::



:metka2 
:: Выбираем бекап
SetLocal EnableExtensions
for /f "tokens=2 delims=:" %%i in ('chcp') do set sPrevCP=%%i& chcp 1251 >nul
for /f "usebackq delims=" %%i in (`mshta.exe "about:<input type=file id=F><script>F.click();new ActiveXObject('Scripting.FileSystemObject').GetStandardStream(1).WriteLine(F.value);close();</script>" ^|more`) do (
  set file=%%i
)
chcp %sPrevCP% >nul
if defined file (
    echo Selected file: %file%
) else (
    echo File not selected!
)

:: Копируем во временный каталог для дальнейших действий
mkdir "%temp%\%d%"
copy /y "%file%" "%temp%\%d%\%date%.rar"

:: Запрашиваем пароль для дешифровки архива
call :inputbox "Введите пароль для архива (желательно более 16-битный):" "Input password"
:InputBox
set input=
set heading=%~2
set message=%~1
echo wscript.echo inputbox(WScript.Arguments(0),WScript.Arguments(1)) >"%temp%\%d%\input.vbs"
for /f "tokens=* delims=" %%a in ('cscript //nologo "%temp%\%d%\input.vbs" "%message%" "%heading%"') do set input=%%a

:: Распаковываем файл
RAR.exe E -o+ -hp%Input% "%temp%\%d%\%date%.rar" "%temp%\%d%\"

:: Выбираем каталог куда нужно скопировать бекап
setlocal
for /f "tokens=2 delims=:" %%i in ('chcp') do (
    set sPrevCP=%%i
    chcp 1251 >nul
)
for /f "usebackq delims=" %%i in (
    `@"%systemroot%\system32\mshta.exe" "javascript:var objShellApp = new ActiveXObject('Shell.Application');var Folder = objShellApp.BrowseForFolder(0, 'Куда сохранить файл?',1, '::{20D04FE0-3AEA-1069-A2D8-08002B30309D}');try {new ActiveXObject('Scripting.FileSystemObject').GetStandardStream(1).Write(Folder.Self.Path)};catch (e){};close();" ^
    1^|more`
) do set sFolderName=%%i
chcp %sPrevCP% >nul
if defined sFolderName (
    echo Selected directory: %sFolderName%
) else (
    echo Directory not select.
)

:: Копируем готовый бекап в нужное место
copy /y "%temp%\%d%\%date%.mp3" "%sFolderName%\AriDnee.afi"
copy /y "%temp%\%d%\orig.txt" "%sFolderName%\OriginalSource.txt"

:: Удаляем временые файлы
::del /f /q "%temp%\%date%.rar"
::del /f /q "%temp%\%date%.mp3"
::del /f /q "%temp%\orig.txt"
::del /f /q "%temp%\input.vbs"
rmdir /s /q "%temp%\%d%\"

:: В завершение выводим диалоговое окно - обо успешном завершении.
SetLocal EnableExtensions
call :msg "Бекап успешно восстановлен! \nИсходное имя файла и расширение внутри файла: OriginalSource.txt."
pause > nul
Exit
:msg
::  chcp 866 >NUL& for /F "delims=" %%a in ("%~1") do chcp 1251 >NUL& call :convert "%%~a"& chcp 866 >NUL& Exit
:convert
  set "text=%~1"
  (@for %%a in ("%text:\n=" "%") do @echo.%%~a) | msg *

exit
