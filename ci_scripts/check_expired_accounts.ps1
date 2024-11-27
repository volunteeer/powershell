#check_expired_accounts
# Проверка домена на наличее учётных записей с истёкшим сроком действия.
# d.pavlov
$logFile = "C:\logs\logfile_expired_users_check.txt"  # Укажите путь для лог-файла
# Получаем текущую дату
$currentDate = Get-Date
Add-Content -Path $logFile -Value $currentDate
# Получаем список всех учетных записей пользователей в домене
$users = Get-ADUser -Filter * -Properties AccountExpirationDate
# Проверяем каждую учетную запись
foreach ($user in $users) {
    #Проверяем что стутус Аккаунта Enabled
    if ($user.Enabled -eq $true){
        #Находим уз с установленной датой истечения
        if ($user.AccountExpirationDate -ne $null) {
            # Если дата истечения меньше или равна текущей
            if ($user.AccountExpirationDate -le $currentDate) {
                # Отключаем учетную запись
                Disable-ADAccount -Identity $user
                # Записываем информацию о заблокированной учетной записи в лог
                $logEntry = "User: $($user.SamAccountName) - Expiration Date: $($user.AccountExpirationDate), - DN: $($user.DistinguishedName) - Disabled on: $currentDate"
                #Записываем в Лог
                Add-Content -Path $logFile -Value $logEntry
                # Выводим сообщение в консоль
                Write-Host "User $($user.SamAccountName) will be disabled due to expiration."
            }
        } 
    }
}
# Пишем в лог
Write-Host 'No more expired account found'
Add-Content -Path $logFile -Value 'No more expired account found'