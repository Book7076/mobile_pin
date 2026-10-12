$headers = @{
    "apikey" = "sb_publishable_vRJxWBRq9NDVSs5mxu8HmA_8xztvUXK"
    "Authorization" = "Bearer sb_publishable_vRJxWBRq9NDVSs5mxu8HmA_8xztvUXK"
}
$rows = Invoke-RestMethod -Uri "https://brywmczfvtbhkgaamrsr.supabase.co/rest/v1/swipes?select=restaurant_id,direction,created_at&limit=50" -Headers $headers -Method Get
Write-Host "Total swipes found in Supabase: $($rows.Count)"
$grouped = $rows | Group-Object -Property restaurant_id
$grouped | ForEach-Object {
    Write-Host "Restaurant ID: $($_.Name) - Count: $($_.Count)"
    $right = ($_.Group | Where-Object { $_.direction -eq "right" }).Count
    $left = ($_.Group | Where-Object { $_.direction -eq "left" }).Count
    Write-Host "   Right (Like): $right | Left (Dislike): $left"
}
