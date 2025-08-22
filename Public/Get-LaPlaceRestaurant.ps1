function Get-LaPlaceRestaurant
{
    [Parameter(Mandatory, Position = 0)]
    param
    (
        [string]$ID
    )

    $Content = Invoke-WebRequest -Uri "https://www.laplace.com/locaties/$ID"
    | Select-Object -ExpandProperty Content

    if ($Content -match '<script id="__NEXT_DATA__" type="application/json">(.*?)</script>')
    {
        $OpeningHoursExtra = $Matches[1]
        | ConvertFrom-Json
        | Select-Object -ExpandProperty props
        | Select-Object -ExpandProperty pageProps
        | Select-Object -ExpandProperty data
        | Select-Object -ExpandProperty OpeningHoursExtra
        | ForEach-Object {
            [PSCustomObject]@{
                Name        = $_.Name.Trim()
                FromDate    = [dateonly]$_.FromDate
                ThroughDate = [dateonly]$_.ToDate
                Closed      = $_.Closed
            }
        }
    }

    if ($Content -match '<script\ type="application/ld\+json">(.*?)</script>')
    {
        $Data = $Matches[1] | ConvertFrom-Json

        [PSCustomObject]@{
            Name                = $Data.Name.Trim()
            Latitude            = $Data.geo.Latitude
            Longitude           = $Data.geo.Longitude
            Address             = $Data.Address.StreetAddress.Trim()
            Postcode            = $Data.Address.PostalCode.Trim()
            City                = $Data.Address.AddressLocality.Trim()
            Country             = $Data.Address.AddressCountry.Trim()
            PhoneNo             = $Data.Telephone.Trim()
            OpeningHours        = $Data.OpeningHoursSpecification | ForEach-Object {
                [PSCustomObject]@{
                    DayOfWeek = [System.DayOfWeek]($_.DayOfWeek -replace '^https://schema.org/', '')
                    Opens     = [timespan]$_.Opens
                    Closes    = [timespan]$_.Closes
                }
            }
            SpecialOpeningHours = $Data.SpecialOpeningHours | ForEach-Object {
                $FromDate = [dateonly]$_.ValidFrom
                $ToDate = [dateonly]$_.ValidThrough
                $OpeningHoursExtra1 = $OpeningHoursExtra | Where-Object FromDate -EQ $FromDate | Where-Object ThroughDate -EQ $ToDate

                [PSCustomObject]@{
                    Description  = $OpeningHoursExtra1 | Select-Object -ExpandProperty Name
                    ValidFrom    = $FromDate
                    ValidThrough = $ToDate
                    Closed       = $OpeningHoursExtra1 | Select-Object -ExpandProperty Closed
                    Opens        = [timespan]$_.Opens
                    Closes       = [timespan]$_.Closes
                }
            }
        }
    }
}
