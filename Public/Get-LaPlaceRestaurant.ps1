function Get-LaPlaceRestaurant
{
    [Parameter(Mandatory, Position = 0)]
    param
    (
        [string]$ID
    )

    $Content = Invoke-WebRequest -Uri "https://www.laplace.com/locaties/$ID"
    | Select-Object -ExpandProperty Content

    if ($Content -match '<script\ type="application/ld\+json">(.*?)</script>')
    {
        $Data = $Matches[1] | ConvertFrom-Json

        [PSCustomObject]@{
            Name      = $Data.Name.Trim()
            Latitude  = $Data.geo.Latitude
            Longitude = $Data.geo.Longitude
            Address   = $Data.Address.StreetAddress.Trim()
            Postcode  = $Data.Address.PostalCode.Trim()
            City      = $Data.Address.AddressLocality.Trim()
            Country   = $Data.Address.AddressCountry.Trim()
            PhoneNo   = $Data.Telephone.Trim()
            OpeningHours = $Data.OpeningHoursSpecification | ForEach-Object {
                [PSCustomObject]@{
                    DayOfWeek = [System.DayOfWeek]($_.DayOfWeek -replace '^https://schema.org/', '')
                    Opens = $_.Opens
                    Closes = $_.Closes
                }
            }
            SpecialOpeningHours = $Data.SpecialOpeningHours | ForEach-Object {
                [PSCustomObject]@{
                    ValidFrom = $_.ValidFrom
                    ValidThrough = $_.ValidThrough
                    Opens = $_.Opens
                    Closes = $_.Closes
                }
            }
        }
    }
}
