Describe 'UncommonSense.LaPlace' {
	Context 'Get-LaPlaceRestaurant' {
		It 'Retrieves LaPlace Muiden restaurant information' {
            $Restaurant = Get-LaPlaceRestaurant -ID 'la-place-muiden-de-hackelaar-a1'
            $Restaurant.Name | Should -Be 'La Place Muiden De Hackelaar A1/A6'
            $Restaurant.Latitude | Should -Be 52.322832
            $Restaurant.Longitude | Should -Be 5.081649
            $Restaurant.Address | Should -Be 'Rijksweg A1 NZ 3'
            $Restaurant.PostCode | Should -Be '1398 PW'
            $Restaurant.City | Should -Be 'Muiden'
            $Restaurant.Country | Should -Be 'NL'
            $Restaurant.PhoneNo | Should -Be '+31630314327'
		}
	}
}
