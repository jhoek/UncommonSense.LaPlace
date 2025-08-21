function Get-LaPlaceRestaurant
{
    [Parameter(Mandatory, Position = 0)]
    param
    (
        [string]$ID
    )

    $Content = Invoke-WebRequest -Uri "https://www.laplace.com/locaties/$ID"
    | Select-Object -ExpandProperty Content

    if ($Content -match '<script id="__NEXT_DATA__" type="application/json">(.*)</script>')
    {
        $Data = $Matches[1]
        | ConvertFrom-Json
        | Select-Object -ExpandProperty props
        | Select-Object -ExpandProperty pageProps
        | Select-Object -ExpandProperty data

        [PSCustomObject]@{
            Name      = $Data.Title
            Latitude  = $Data.position.Latitude
            Longitude = $Data.position.Longitude
            Address   = @($Data.Address.Street, (@($Data.Address.HouseNr, $Data.Address.HouseSub) -join '') | Where-Object { $_ }) -join ' '
            Postcode  = $Data.Address.PostalCode
            City      = $Data.Address.City
            Country   = $Data.Address.Country
            PhoneNo   = $Data.Contact.Phone
            OpeningHours = [PSCustomObject]@{
                Monday = $Data.OpeningHours.Monday | ForEach-Object { [PSCustomObject]@{
                    From = [TimeSpan]$_.FromTime
                    To = [TimeSpan]$_.ToTime
                }}
            }
        }
    }
}
