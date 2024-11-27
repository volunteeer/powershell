# путь для лог-файла
$logFile = "C:\logs\logfile_expired_passwords_send_email.txt"  
#Конфигурация SMTP Поменять на свои
$smtpServer = "mailserver.mycompany.com"
$from = "noreply@mycompany.com"
$subject = "Истекает срок действия пароля"
# Получаем текущую дату
$currentDate = Get-Date
#Указываем количество дней за сколько проверять
$warnDays = (get-date).adddays(5)
# Пишем дату выполнения скрипта в лог-файл
Add-Content -Path $logFile -Value $currentDate
# Указываем список OU к проверке через запятую
$ouList = @("OU=Admin,DC=myCompany,DC=local", 
            "OU=dep1,DC=myCompany,DC=local", 
            "OU=dep2,DC=myCompany,DC=local",
            "OU=dep3,DC=myCompany,DC=local")
# заводим цикл для каждой ou
foreach ($ou in $ouList){
    $Users = Get-ADUser -SearchBase $ou -filter {Enabled -eq $True -and PasswordNeverExpires -eq $False} -Properties msDS-UserPasswordExpiryTimeComputed, EmailAddress, Name | select Name, @{Name ="ExpirationDate";Expression= {[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}}, EmailAddress
        foreach ($user in $users){
            if (($user.ExpirationDate -lt $warnDays) -and ($currentDate -lt $user.ExpirationDate)){
            #Конвертируем дату в Российский формат
            # Преобразуем строку в объект типа DateTime
            $dateTime = [datetime]::ParseExact($user.ExpirationDate, "MM/dd/yyyy HH:mm:ss", $null)
            # Конвертируем в формат
            $rusdate = $dateTime.ToString("dd.MM.yyyy HH:mm:ss")
            #Выводим в консоли пользователей соответвующие кретерию
            Write-Host "Passowrd for user $($user.EmailAddress) will expire at $($rusdate)"
            $wrlog = "Passowrd for user $($user.EmailAddress) will expire at $($rusdate)"
            #Пишем тоже самое(переменную wrlog) в лог
            Add-Content -Path $logFile -Value $wrlog
            #Тело письма
            $body = @"
            <html>
                <body>
                    <p>Уважаемый(ая) $($user.Name),</p>
                    <p>Срок действия вашего пароля истекает $($rusdate)!</p>
                    <p>Для избежания блокировок вашей учётной записи, пожалуйста, измените пароль как можно скорее.</p>
                    <br>
                    <p>С уважением,<br>
                    Служба поддержки<br>
                    </p>
                </body>
            </html>
"@
            #Отправляем письмо
            Send-MailMessage -To $user.EmailAddress -From $from -SmtpServer $smtpserver -Subject $Subject -Body $Body -bodyAsHTML -Encoding ([System.Text.Encoding]::UTF8)
            }    
        }
}