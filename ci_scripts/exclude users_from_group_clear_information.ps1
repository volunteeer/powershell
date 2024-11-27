#Убрать пользователей из групп и удалить признаки принадлежности к филиалу, контактный телефон,менеджера
# путь для лог-файла
$logFile = "C:\logs\logfile_remove_attributes_disabled_users.txt"  
# Указываем OU c отключенными УЗ
$OU = 'OU=Archive,DC=myCompany,DC=local'
# Получаем текущую дату
$currentDate = Get-Date
# Пишем дату выполнения скрипта в лог-файл
Add-Content -Path $logFile -Value $currentDate
#Получаем список пользователей в OU
$users = Get-ADUser -Filter *  -SearchBase $OU -Properties MemberOf | Select-Object Name, DistinguishedName, MemberOf, Enabled, SamAccountName, c, co
#Цикл для каждой записи в OU
# Цикл для каждой записи в OU
foreach ($user in $users) {
    # Проверяем, состоит ли пользователь в группах
    if ($user.MemberOf -ne '$null') {
        #Записываем в лог
        Write-Host "User $($user.Name) member of groups:"
        Write-Host $user.MemberOf
        $wrlog = "Remove $($user.Name) from groups: $($user.MemberOf)"
        Add-Content -Path $logFile -Value $wrlog
        # Удаляем пользователя из всех групп, в которых он состоит
        foreach ($group in $user.MemberOf) {
            # Получаем только имя группы из DistinguishedName
            $groupName = (Get-ADGroup -Identity $group).Name
            Remove-ADGroupMember -Identity $group -Members $user.SamAccountName -Confirm:$false
        }
        Write-Host "Remove $($user.Name) from groups - Done! "
    }
    #Удаяем атрибуты
    Set-ADUser test44 -Clear l, company, department, manager, co, C, postalCode, st, ipphone, physicalDeliveryOfficeName, title, facsimileTelephoneNumber, pager, telephoneNumber, description, homephone, mobile
}
#Записываем в лог
Write-Host "Remove attributes for users - Done"
$wrlog = "Remove attributes for users - Done"
Add-Content -Path $logFile -Value $wrlog

