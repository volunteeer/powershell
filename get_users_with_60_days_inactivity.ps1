# Указываем OU и количество дней для фильтрации
$OU = "OU=users,DC=mycompany,DC=local"  # Замените на свой путь к OU

$DaysInactive = 60
# Получаем текущую дату
$CurrentDate = Get-Date
# Указываем путь для экспорта CSV
$ExportPath = "C:\temp\InactiveUsers.csv"  

# Ищем пользователей в указанном OU
Get-ADUser -Filter * -SearchBase "$OU" -Properties LastLogonDate, PasswordLastSet, LastBadPasswordAttempt |
    Where-Object {
        # Проверяем, что LastLogonDate существует и больше, чем 60 дней
        $_.LastLogonDate -ne $null -and ($CurrentDate - $_.LastLogonDate).Days -gt $DaysInactive
    } |
    # Выбираем данные для экспорта в CSV 
    Select-Object DistinguishedName, SamAccountName, LastLogonDate, PasswordLastSet, LastBadPasswordAttempt |
    # Экспортируем в CSV
    Export-Csv -Path $ExportPath -NoTypeInformation -Force

Write-Host "Экспорт завершен! Данные сохранены в $ExportPath"
