#!/usr/bin/bash
##
## Ulisses Manzo Castello
## Programa modificado da versão de Vagner Cezarino
##

# Imprime um controle do cron
date1=`date +%Y%m%d%H%M`
touch /root/Scritp_Backup/CRON_INICIADO_EM_${date1}.log
# Nao esquecer do LC_TIME, variavel que eh diferente no cron
# do que na linha de comando. ( portugues na linha de comando e ingles no cron )
#30 9 * * * LC_TIME=pt_BR.UTF-8 /root/Scritp_Backup/backupvms.sh &>> /root/Scritp_Backup/cron.log
echo " -- FIM__Controle_cron --"

# Day of week - Dias da semana
dow0="domingo"
dow1="segunda"
dow2="terça"
dow3="quarta"
dow4="quinta"
dow5="sexta"
dow6="sabado"
echo " -- FIM__Day_of_week --"

# Separação dos backups em dias comforme variáveis (dow0 até dow6)
bkp0=("Clone" "Printerserver")
bkp1=("Amanda" "Ipcontrol")
bkp2=("Acads" "Solidworks")
bkp3=("Redmine" "Ldap")
bkp4=("Nagios" "Apache")
bkp5=("Sql")
bkp6=("Laboratorio")
echo " -- FIM__Separacao_dos_backups --"


# Incicializacao de variaveis usadas no programa
# Dia da semana ( exemplo: segunda )
backupDay=`date +%A` 
# Inicia a variavel arrayvms com algum valor inicial
arrayvms=${bkp0[*]}
# Pega o valor de uso e espaco em disco da particao montada windows QNAP
espaco=$(df --output=pcent /mnt/backup | sed '1d;s/^ //;')
dtbkp=`date +%Y%m%d` # data completa do backup para nome dos arquivos.
dataarq=`date +%Y%m%d` # data para numenclatura do arquivo de log.
datain2=`date +%s` # data usada para subtracao de tempo final da execução do script
bkpdestino=/mnt/backup # Caminho para armazenamento do backup
HORA=`date +%H%M`
i=0 # Contador de VMs para resumo final do backup no log
echo " -- FIM__Inicializacao_das_variaveis PARTE1 --"


storageSnapshot="b49119f2-ea53-ddca-02f8-aeaadd36128a" # Storage XenServer que armazena as VMs.
pathBackup="//10.140.2.77/vmachinebackup" #Caminho de rede do servidor e pasta de Backup
arqLog="/mnt/backup/_log/bkpvms${dataarq}.log" #Arquivo de log, criar a subpasta _log na pasta de backup
numBackups="1,2d" # Quantidade de backups antigos (2 dia=2d) em retenção no Servidor de bkp
winUser="admin" # Usuario com permissão de escrita no servidor de backup
winPwd="245EBE672002" # Senha do usuário do servidor de backup
particao="/dev/mapper/VG_XenStorage--c7a6d2d6--829b--8acf--38f8--fba02ca3eb56-MGT"
maxStorageUse=80 #Valor máximo de uso da storage local para prosseguir com backup (em %)
echo " -- FIM__Inicializacao_das_variaveis PARTE2 --"

#--------------------------------


##---- MONTA PARTICAO

if test -d /mnt/backup; then echo " --EXISTE DIRETORIO--"; else mkdir -p /mnt/backup; fi;
#mount -t cifs -o username=${winUser},password=${winPwd},domain=${winDomain} ${pathBackup} /mnt/backup -vvv
mount -t cifs -o username="admin",password="222HGF654" //10.140.2.77/vmachinebackup /mnt/backup -vvv
echo " -- FIM__Da_montagem_da_particao_windows_QNAP --"

##---- FIM DA MONTAGEM


# Verifica se a particao (/mnt/backup) esta montada
if test -f /mnt/backup/conecta.txt; then {
        echo "   ---Conectado ao servidor de backup - arquivo conecta.txt encontrado"
} else {
        echo "   ---ERRO Conectando ao servidor de backup"
        exit 1
} fi;
echo " -- FIM__Teste_de_montagem_QNAP --"


# Mensagem Iniciando Backup --> Direcionado para o LOG
echo "Iniciando backup em ${dtbkp}..." >> ${arqLog}
echo " ---HORA = ${HORA}..." >> ${arqLog}
echo " -- VARIAVEL LC_TIME -- "
echo ${LC_TIME}
echo ${LC_TIME} >> ${arqLog}
echo ${backupDay}
echo ${backupDay} >> ${arqLog}
echo "   ---ESPACO EM DISCO DA PARTICAO WINDOWS --> " ${espaco} >> ${arqLog}
echo "   ---ESPACO EM DISCO DA PARTICAO WINDOWS --> " ${espaco}
echo " "
echo " ---IMPRIME BACKUPDAY"
echo ${backupDay}
echo " ---IMPRIME PRIMEIRO ELEMENTO DA ARRAYVMS"
echo ${arrayvms}
echo " ---IMPRIME DOW2";
echo ${dow2}
echo " "
echo " -- FIM__Inicio_do_log_e_variaveis_informativas --"



# Compara dias da semana e seleciona o backup correto.
echo " "
echo "   ---> CHEGOU NOS IFs_encadeados - selecao do BACKUP correto - conforme o dia da SEMANA"
echo " "
if [ "$backupDay" == "$dow0" ]; then
	echo " "
        echo "HOJE EH --> ${backupDay}"
        arrayvms=${bkp0[*]}
	echo "NOSSA ARRAYVMS AGORA EH --> ${arrayvms}"
	echo " "
elif [ "$backupDay" == "$dow1" ]; then
        echo " "
        echo "HOJE EH --> ${backupDay}"
        arrayvms=${bkp1[*]}
        echo "NOSSA ARRAYVMS AGORA EH --> ${arrayvms}"
        echo " "
elif [ "$backupDay" == "$dow2" ]; then
        echo " "
        echo "HOJE EH --> ${backupDay}"
        arrayvms=${bkp2[*]}
        echo "NOSSA ARRAYVMS AGORA EH --> ${arrayvms}"
        echo " "
elif [ "$backupDay" == "$dow3" ]; then
        echo " "
        echo "HOJE EH --> ${backupDay}"
        arrayvms=${bkp3[*]}
        echo "NOSSA ARRAYVMS AGORA EH --> ${arrayvms}"
        echo " "
elif [ "$backupDay" == "$dow4" ]; then
        echo " "
        echo "HOJE EH --> ${backupDay}"
        arrayvms=${bkp4[*]}
        echo "NOSSA ARRAYVMS AGORA EH --> ${arrayvms}"
        echo " "
elif [ "$backupDay" == "$dow5" ]; then
        echo " "
        echo "HOJE EH --> ${backupDay}"
        arrayvms=${bkp5[*]}
        echo "NOSSA ARRAYVMS AGORA EH --> ${arrayvms}"
        echo " "
elif [ "$backupDay" == "$dow6" ]; then
        echo " "
        echo "HOJE EH --> ${backupDay}"
        arrayvms=${bkp6[*]}
        echo "NOSSA ARRAYVMS AGORA EH --> ${arrayvms}"
        echo " "
 

fi

echo "   ---> SAIU DOS IFs_encadeados"

echo " --- IMPRIME ARRAY OF STRINGS... "

echo " --- IMPRIME EM UMA UNICA LINHA TODOS ELEMENTOS DA ARRAYVMS ---"
for val in "${arrayvms[*]}"; do
    echo $val
done
echo " -- FIM__IFs_encadeados --"


#--------------------------------------------------

# Verifica %uso da Storage de armazenamento local
usoStorage=`df -h ${particao} | tail -1 | awk '{print $5}'| sed "s/%//g"`
echo "Storage local esta com "${usoStorage}"% de uso!" >> ${arqLog}
echo "Storage local esta com "${usoStorage}"% de uso!"
if [ "${usoStorage}" -gt "${maxStorageUse}" ]; then {
        echo "Processo abortado!" >> ${arqLog}
        echo "Storage local esta com "${usoStorage}"% de uso! Processo abortado!"
        exit 1
} fi;
echo " -- FIM__Porcentagem_de_uso_do_disco_local --"

#--------------------------------------------------

# Inicio do processo de LOGS ###############################################################
echo "==============================================================================" >> ${arqLog}
# Lista VMs a para backup no Log
echo "Backup das VMs: " >> ${arqLog}
echo "${arrayvms[*]}" >> ${arqLog}
echo " -- FIM__Inicio_do_processo_de_LOGS --"

#--------------------------------------------------


### ******************************************************************************************************************************
echo " --INICIO DO FOR PRINCIPAL-- "
echo " --FOR PARTE 1-- "
# For de backup ####################################################################
for vmname in ${arrayvms[*]}
do {
        #Inicia variáveis
        echo " ---PASSAGEM PELO FOR--- "
        i=$(($i+1))
        echo "   ---IMPRIMINDO i = "
        echo ${i}
        dhvm=`date +%d/%m/%Y_%H:%M:%S` # data completa de informacao de cada etapa.
        echo "   ---IMPRIMINDO dhvm = "
        echo ${dhvm}
        datain=`date +%s` # data usada para subtracao de tempo de cada vm.
        # Aguarda 10 segundos antes de iniciar o bkp.
        sleep 1
        echo "==============================================================================" >> ${arqLog}
        echo "Iniciando backup da VM ${vmname} em ${dhvm}" >> ${arqLog}
        data=`date +%c` # Data e hora atual.

        #Verifica se existe snapshot previo da VM e apaga
        echo "1. Verificando snapshot prévio em ${data}" >> ${arqLog}
        snapOld=$(xe snapshot-list snapshot-of=$(xe vm-list name-label=${vmname} --minimal) name-label="${vmname}_backup" --minimal | sed 's/,/ /g')
        echo "   ---IMPRIME SNAPSHOT OLD --> " ${snapOld}
       for A in $snapOld ; do
               xe snapshot-destroy uuid=$A >> ${arqLog}
       done


 #Cria novo snapshot da VM
        echo "2. Cria snapshot da maquina em ${data}" >> ${arqLog}
        idvm=`xe vm-snapshot vm=${vmname} new-name-label=${vmname}_backup` &>> ${arqLog}
        if [ $? -eq 0 ]; then {
                echo "  Id Snapshot criado: ${idvm}" >> ${arqLog}

                #Converte Snapshot criado para Template
                data=`date +%c` # Data e hora atual.
                xe template-param-set is-a-template=false uuid=${idvm} &>> ${arqLog}
                if [ $? -eq 0 ]; then {
                        echo "3. Snapshot convertido em template em ${data}" >> ${arqLog}
                } else {
                        echo "3. ERRO na criação do template." >> ${arqLog}
                        exit 1
                } fi;



#### ***********************************************************************************************

echo " --FOR PARTE 2-- "

                #Converte Template criado para VM
                data=`date +%c` # Data e hora atual.
                cvvm=`xe vm-copy vm=${vmname}_backup sr-uuid=${storageSnapshot} new-name-label=${vmname}_${dtbkp}` &>> ${arqLog}
                if [ $? -eq 0 ]; then {
                        echo "4. Template convertido em VM em ${data}" >> ${arqLog}
                } else {
                        echo "4. ERRO na conversão do template da VM ${vmname}." >> ${arqLog}
                        exit 1
                } fi;

                #Exporta VM para unidade de backup
                data=`date +%c` # Data e hora atual.
                if test -d ${bkpdestino}/${vmname}; then { # Se existir o diretorio
                        # Se existe arquivo xva igual na pasta, apaga
                        if test -f ${bkpdestino}/${vmname}/${vmname}_${dtbkp}.xva; then {
                                echo "TEM ARQUIVO IGUAL NA PASTA"
                                rm -f ${bkpdestino}/${vmname}/${vmname}_${dtbkp}.xva
                        } fi;
                        xe vm-export vm=${cvvm} filename="${bkpdestino}/${vmname}/${vmname}_${dtbkp}.xva" &>> ${arqLog}
                } else { # Se não existir o diretorio, cria um.
                        mkdir -p ${bkpdestino}/${vmname}
                        echo "   Criando diretorio ${bkpdestino}/${vmname}" >> ${arqLog}
                        xe vm-export vm=${cvvm} filename="${bkpdestino}/${vmname}/${vmname}_${dtbkp}.xva" &>> ${arqLog}
                } fi;
                if [ $? -eq 0 ]; then {
                        echo "5. Exportação concluida em ${data}." >> ${arqLog}
                } else {
                        echo "5. ERRO na exportação da VM ${vmname}." >> ${arqLog}
                        exit 1
                } fi;

                #Apaga VM e VDI temporários
                data=`date +%c` # Data e hora atual.
                xe vm-uninstall vm=${cvvm} force=true &>> ${arqLog}
                if [ $? -eq 0 ]; then {
                        echo "6. VM e VDI temporários apagados com sucesso em ${data}." >> ${arqLog}
                } else {
                        echo "6. ERRO ao deletar VM e VHD na VM ${vmname}." >> ${arqLog}
                        exit 1
                } fi;



#### ***********************************************************************************************
echo " --FOR PARTE 3-- "



#Apaga Snapshot
                data=`date +%c` # Data e hora atual.
                xe vm-uninstall --force uuid=${idvm} &>> ${arqLog}
                if [ $? -eq 0 ]; then {
                        echo "7. Snapshot apagado em ${data}." >> ${arqLog}
                } else {
                        echo "7. ERRO ao deletar Snapshot." >> ${arqLog}
                        exit 1
                } fi;

                #Apaga backups antigos
                data=`date +%c` # Data e hora atual.
                ls -td1 ${bkpdestino}/${vmname}/* | sed -e ${numBackups} | xargs -d '\n' rm -rif &>> ${arqLog}
                if [ $? -eq 0 ]; then {
                        echo "8. Backups antigos apagados em ${data}." >> ${arqLog}
                        echo "   Concluido Backup VM ${vmname} em ${data}." >> ${arqLog}
                } else {
                        echo "8. ERRO ao excluir backups antigos." >> ${arqLog}
                        exit 1
                } fi;

                #Calcula tempo de execução do backup da VM
                dataoud=`date +%s` #data final de execução
                seg=$((${dataoud} - ${datain}))
                min=$((${seg}/60))
                seg=`printf %02d $((${seg}-${min}*60))`
                hor=`printf %02d $((${min}/60))`
                min=`printf %02d $((${min}-${hor}*60))`
                echo "Tempo estimado: ${hor}:${min}:${seg}" >> ${arqLog}
                echo "==============================================================================" >> ${arqLog}
                bkpOk=${bkpOk}" "${vmname}
        } else {
                #Erro na criação do Snapshot - VM não localizada
                echo "1. ERRO: Não foi possível criar o Snapshot da VM ${vmname}." >> ${arqLog}
                echo "==============================================================================" >> ${arqLog}
                echo " " >> ${arqLog}
                bkpErr=${bkpErr}" "${vmname}
        } fi;

} done;


#### ***********************************************************************************************

echo " -- FIM__Das_3_etapas_do_FOR_principal --"


#--------------------------------------------------

#Apaga arquivos de log 15 dias
data=`date +%c` # Data e hora atual.
ls -td1 ${bkpdestino}/_log/* | sed -e "1,15d" | xargs -d '\n' rm -vrif &>> ${arqLog}
if [ $? -eq 0 ]; then {
        echo "9. Arquivos de logs antigos apagados em ${data}." >> ${arqLog}
} fi;
echo " -- FIM__Apagar_logs_antigos --"

#--------------------------------------------------


#--------------------------------------------------

#Calcula tempo total de todos os backups do dia
dataoud=`date +%s` #data final de execução
seg=$((${dataoud} - ${datain2}))
min=$((${seg}/60))
seg=`printf %02d $((${seg}-${min}*60))`
hor=`printf %02d $((${min}/60))`
min=`printf %02d $((${min}-${hor}*60))`
echo " -- FIM__Calculo_de_tempo --"

#--------------------------------------------------



#--------------------------------------------------

#Grava informações finais no Log
echo " " >> ${arqLog}
echo "Resumo:" >> ${arqLog}
echo "Total de VMs selecionadas no dia: ${i}" >> ${arqLog}
echo "VMs Ok   : ${bkpOk}" >> ${arqLog}
echo "VMs ERRO : ${bkpErr}" >> ${arqLog}
echo "Tempo Total Estimado: ${hor}:${min}:${seg}" >> ${arqLog}
echo "==============================================================================" >> ${arqLog}
echo "Desconectado do servidor de backup"
echo " -- FIM__Informacoes_finais_de_LOG --"

#--------------------------------------------------

### -----------

#Desmonta unidade de backup
#umount /mnt/backup
exit 0

### -----------



} done;



