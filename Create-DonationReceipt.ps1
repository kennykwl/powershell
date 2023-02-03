<# I volunteer at a Non Profit during my free time and help them out wherever possible.
   As a non profit, we need to send out Donation receipts.  This script will extract 
   users info from a csv file, open a donation receipt template, look for the tag
   #name and #total on the template.docx file, replacing them with the donor's name and 
   donor's total, then save the Tax Document as a pdf file.  There are still a lot of 
   improvement that I can make on this script, but this works as expect for now and will 
   save us a lot of time manually generating these receipts.
#>

$filepath = ".\donation2022.csv"
$csv = Import-Csv $filepath

$grouped = $csv | Group-Object name

$donors = @()
foreach ($g in $grouped) {
  $donor = New-Object psobject -Property @{
    Name = $g.Name
    Total = ($g.Group | Measure-Object -Property amount -Sum).Sum
  }
  $donors += $donor
}

function wordSearch($currentValue, $replaceValue){
    $objSelection = $objWord.Selection
    $FindText = $currentValue
    $MatchCase = $false
    $MatchWholeWord = $true
    $MatchWildcards = $false
    $MatchSoundsLike = $false
    $MatchAllWordForms = $false
    $Forward = $true
    $wrap = $wdFindContinue
    $wdFindContinue = 1
    $Format = $false
    $ReplaceWith = $hash[$value]
    $ReplaceAll = 2

    $objSelection.Find.Execute($FindText, $MatchCase, $MatchWholeWord, $MatchWildcards, $MatchSoundsLike, $MatchAllWordForms, $Forward, $wrap, $Format, $ReplaceWith, $ReplaceAll)
    }

$objWord = New-Object -ComObject word.application
$objWord.Visible = $False
foreach($donor in $donors){

  $objDoc = $objWord.Documents.Open(".\Template_2022.docx")
  $objSelection = $objWord.Selection
  $hash = @{"#name" = "$($donor.name)"; "#total"="$($donor.total)"}
  foreach($value in $hash.Keys) {
    $currentValue = $value
    $replaceValue = $hash[$value]

    wordSearch $currentValue $replaceValue

    }
    $path = ".\$($donor.name)-2022.pdf"
    $objDoc.saveas($path, 17)
    $objdoc.close($false)
}
