# Перенос отключеных пользователей в OU Архив
# путь для лог-файла
$logFile = "C:\logs\logfile_move_disabled_users.txt"  
# Указываем OU Архива
$OUArchive = 'OU=Archive,DC=myCompany,DC=local'
# Получаем текущую дату
$currentDate = Get-Date
# Пишем дату выполнения скрипта в лог-файл
Add-Content -Path $logFile -Value $currentDate
# Указываем список OU к проверке через запятую
$ouList = @("OU=myCompany,DC=myCompany,DC=local", 
            "OU=test,DC=myCompany,DC=local")
# заводим цикл для каждой ou
foreach ($ou in $ouList){
    Write-Host 'searching in OU ' $ou
    Add-Content -Path $logFile -Value $ou
    # Получаем список пользователей 
    $users = Get-ADUser -Filter * -SearchBase $ou -Properties DistinguishedName | Select-Object Name, UserPrincipalName, DistinguishedName, Enabled
    #Цикл для каждой УЗ
    foreach ($user in $users){
        # Переменная для записи в лог и отображения в консоли пользователя 
        $userCheck = $user.UserPrincipalName
        # Переменная для отображения полного текущего пути пользователя 
        $userDN = $user.DistinguishedName
        # Проверяем что уз отключена
        if ($user.Enabled -lt 'False')
            {
            Write-Host 'Moving user' $userCheck 'to OU' $OUArchive
            $logEntry = "Moving user: $($userDN) to OU $($OUArchive)"
            Add-Content -Path $logFile -Value $logEntry
            $userMove = $user.DistinguishedName 
            Move-ADObject -Identity $userMove -TargetPath $OUArchive
            }
    }
}