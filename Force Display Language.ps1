$LangList = Get-WinUserLanguageList
$MarkedLang = $LangList | where LanguageTag -eq "LANGUAGETAG"
$LangList.Remove($MarkedLang)
Set-WinUserLanguageList $LangList -Force