# Перенос отключеных Компьютеров в OU Archive
# путь для лог-файла
$logFile = "C:\logs\logfile_move_disabled_computers.txt"  
# Указываем OU для отключенных Компьютеров
$OUDisabled = 'OU=disabledPC,DC=myCompany,DC=local'
# Получаем текущую дату
$currentDate = Get-Date
# Пишем дату выполнения скрипта в лог-файл
Add-Content -Path $logFile -Value $currentDate
# Указываем список OU к проверке через запятую
$ouList = @("OU=myCompany,DC=myCompany,DC=local", 
            "OU=test1,DC=myCompany,DC=local", 
            "OU=test2,DC=myCompany,DC=local",
            "OU=test3,DC=myCompany,DC=local",
            "OU=servers,DC=myCompany,DC=local")
# заводим цикл для каждой ou
foreach ($ou in $ouList){
    Write-Host 'searching in OU ' $ou
    Add-Content -Path $logFile -Value $ou
    # Получаем список компьютеров 
    $computers = Get-ADComputer -Filter * -SearchBase $ou -Properties DistinguishedName | Select-Object Name, DistinguishedName, Enabled
    #Цикл для каждой УЗ в OU
    foreach ($Computer in $Computers){
        # Переменная для записи в лог и отображения в консоли компьютера 
        $ComputerCheck = $Computer.Name
        # Переменная для отображения полного текущего пути компьютера 
        $ComputerDN = $Computer.DistinguishedName
        # Проверяем что компmютер отключен
        if ($Computer.Enabled -lt 'False')
            {
            Write-Host 'Moving Computer' $ComputerCheck 'to OU' $OUDisabled
            $logEntry = "Moving Computer: $($ComputerDN) to OU $($OUDisabled)"
            Add-Content -Path $logFile -Value $logEntry
            $ComputerMove = $Computer.DistinguishedName 
            Move-ADObject -Identity $ComputerMove -TargetPath $OUDisabled
            }
    }
}
   $logEntry = "Нет отключенных компьютеров для перемещения."
    Write-Host "Нет отключенных компьютеров для перемещения."
