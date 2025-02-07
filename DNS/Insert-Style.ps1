function Insert-Style{
<#
.SYNOPSIS
Insert Style block into html

.DESCRIPTION

.PARAMETER domainNames

.EXAMPLE

.NOTES

#>

    param(
    [Parameter(Mandatory=$True)]
    [array]$htmlTable
    )

$insertStyle = @"
<head>
<style>
table {
	font-family: arial, sans-serif;
	border-collapse: collapse;
	width: 100%;

	white-space: nowrap;
	word-break: keep-all;
}

table td {
	border: 2px solid rgb(185, 166, 166);
	padding: 5px;
}
	
th.Title {
  width: 100px;
  background-color: #a5aeb1;
  padding: 10px;
  text-align: left;

}

td.TitleStatus {
	width: 80px;
	text-align: right;
	padding-right: 10px;
	}

tr:nth-child(odd) {
	background-color: #b7c4e3 ;
	
	}
	
tr:nth-child(even) {
	background-color: #b7d4e3 ;
	}

tr {
  border-bottom: 1px solid #ddd;
	}

tr td:first-child {
	text-align: right;
}

</style>
"@

    $resultHTML =  $htmlTable -replace "<head>",$insertStyle

    # return result
    return $resultHTML

}