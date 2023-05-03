#Open Script manually and insert result of first command into second
cscript.exe "$Env:Programfiles\Microsoft Office\Office16\ospp.vbs" /dstatus

#Last 5 characters of installed product key: VMFTK
cscript.exe "$Env:Programfiles\Microsoft Office\Office16\ospp.vbs" /unpkey:xxxxx
