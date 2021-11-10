# Oracle DB 부하 테스트 방안 

# 목차 

### 가. 성능시험 환경 구성 
* [1. 장비 및 SW 환경](#ch-1-1)
* [2. 성능 모니터링 준비](#ch-1-2)
### 나. DB 부하 테스트 수행
* [1. 부하용 스키마 생성](#ch-2-1)
* [2. 부하 수행](#ch-2-2)
### 다. 부하테스트 결과 수집  
* [1. 부하용 VM (리포트 겸용)](#ch-3-1)
* [2. DB Node의 AWR 자료 취득](#ch-3-2)
### 라. 부하테스트 결과 보고 및 분석
* [1. 부하용 VM](#ch-4-1)
* [2. DB 노드](#ch-4-2)
### 마. Appendix
* [1. 환경변수](#ch-5-1)
* [2. SSH User Equivalence Configuration](#ch-5-2)
* [3. 일반 사용자로 sudo 사용 ( 패스워드없이 )](#ch-5-3)
* [4. Oracle Linux 7에서 로컬 yum repository 설정](#ch-5-4)

# 가. 성능시험 환경 구성 
<img src="./images/img839.png" alt="BMT환경" />

## 1. 장비 및 SW 환경 <a id="ch-1-1"></a>


### A. 부하용 vm ( RHEL 7.9 또는 OL 7.9 ) ( Report 용도 포함 )

#### 1) python3 & pip3 설치 

* SW 설치 
```
yum install python3 -y
pip3 install --upgrade pip 
```

* 환경변수
```bash
echo "alias python=python3" >> ~/.bash_profile
echo "alias pip=pip3" >> ~/.bash_profile
source ~/.bash_profile
```

#### 2) Swingbench 

* 필수 Software
   + [JDK 1.8 다운로드](https://www.oracle.com/java/technologies/downloads/#java8)

* [Swingbench 2.6](http://www.dominicgiles.com/swingbench.html)
   + [다운로드](https://github.com/domgiles/swingbench-public/releases/download/production/swingbenchlatest.zip)
   + 압축 파일 해제 ( 예: /home/oracle 위치에서 압축해제)

* 환경변수 설정 (option)
```bash
export SB_HOME=/home/oracle/swingbench
```

* 플랫폼별 수행 위치 (BMT를 위해 임의로 생성한 것임)
   + Unix Home
/home/oracle/swingbench/unix

   + X86 Home
/home/oracle/swingbench/x86

* 대량 부하시 Swingbench launcher 의 Memory 조정 가능
swingbench/launcher/launcher.xml

    <jvmargset id="base.jvm.args">
        <jvmarg line="-Xmx1024m"/>
        <jvmarg line="-Xms512m"/>
        <!--<jvmarg line="-Djava.util.logging.config.file=log.properties"/>-->
   </jvmargset>

#### 3) Visual-AWR ( Oracle Internal )
* 다운로드 
* Visual AWR 관련 python 패키지 설치 
```bash
[oracle@racnode1 ~]$ sudo pip install pandas lxml html5lib beautifulsoup4 cchardet PTable
[oracle@racnode1 ~]$ mkdir visual-awr; cd visual-awr
[oracle@racnode1 visual-awr]$ unzip ../visual-awr-4.0.zip
```

#### 4) dstat 
* 부하용 VM 에서 DB 서버로의 network 발생량 등 확인용 
```bash
[oracle@racnode1 ~]$ sudo yum install -y dstat
```

### B. DB 서버  ( Oracle 19.13 RAC ) 

#### 1) 장비별 OS
 * X86 (VMware 7) OL 7.9 (UEK)
 * Unix                Solaris 11.14
     - Unix 의 경우 Bare Metal 과 OVM Server for SPARC 모두 수행 
##### Oracle Database 구성 <img src="./images/img843.png" alt="Oracle Database 구성" />

#### 2) Autonomous Health Framework (AHF) Update  
AHF 는 RAC 의 경우 GI Home 에 설치되어 있으며 새 버젼 설치시 기존 정보 참고함 (root 권한 권장)
<img src="./images/img843.png" alt="Autonomous Health Framework" />

* 사전 설치 
```bash
sudo yum install -y perl-Digest-MD5 perl-Data-Dumper
```

* AHF 다운로드 : Oracle Automatic Health Framework (AHF) latest
  Autonomous Health Framework (AHF) - Including TFA and ORAchk/EXAchk (Doc ID 2550798.1)
  + [AHF 21.3 for Linux](https://updates.oracle.com/Orion/Services/download/AHF-LINUX_v21.3.0.zip?aru=24481521&patch_file=AHF-LINUX_v21.3.0.zip)
  + [AHF 21.3 for Solaris SPARC 64](https://updates.oracle.com/Orion/Services/download/AHF-SOLARIS.SPARC64_v21.3.0.zip?aru=24481520&patch_file=AHF-SOLARIS.SPARC64_v21.3.0.zip)
```bash
mkdir ora_ahf; cd ora_ahf
unzip ../AHF-LINUX_v21.3.0.zip
./ahf_setup [-ahf_loc install_dir] [-data_dir data_dir]
```

#### 3) OSWatcher 실행 
: AHF 내 포함되어 있음 
 
#### 4) orachk 실행 
: AHF 내 포함되어 있음 

BMT 수행/전후 실행 결과 

## 2. 성능 모니터링 준비 <a id="ch-1-2"></a>

* 플랫폼 별 준비 ( Unix, X86 )

### A. 부하용 vm 성능 모니터링

```bash
dstat -t -cmgdrnlyp -N total  --output dstat_$(date +"%Y%m%d").txt 
또는 
nohup dstat -t -cmgdrnlyp -N total  --output dstat_$(date +"%Y%m%d").txt &
```

### B. DB서버용 성능 모니터링

#### 1) OSWatcher
AHF 내에 포함되어 있으며 root 계정으로 실행을 권장
```bash
cd /opt/oracle.ahf/tfa/ext/oswbb
nohup ./startOSWbb.sh 60 10 &
```
>참고 : 
>./startOSWbb.sh <ARG1> <ARG2> <ARG3> <ARG4>
>ARG1 = 스냅샷 간격(초).
>ARG2 = 저장할 아카이브 데이터의 시간.
>ARG3 = (선택 사항) 각 파일이 생성된 후 자동으로 압축하는 압축 유틸리티의 이름 (gzip 등)
>ARG4 = (선택 사항) 아카이브 디렉토리를 저장할 대체(기본값 아님) 위치.

* ./startOSWbb.sh
  : (디폴트) 30초 48시간 동안 데이터를 아카이브 파일에 저장 
* ./stopOSWbb.sh

#### 2) oratop
```bash
$ORACLE_HOME/suptools/oratop/oratop / as sysdba
```

#### 3) AWR info 및 스냅샷 주기 확인 
: AWR 주기를 변경할지 / 부하테스트 수행 전/후 Snapshot 생성할 지 결정 

##### 1. AWR repository 크기 확인 및 계산 
Default : Snapshot 주기 1시간, 보관 8일
```sql
@?/rdbms/admin/awrinfo.sql

AWR Interval (mins), Retention 일수, Num Instances, 평균 Active Sessions, Datafile 수
@?/rdbms/admin/utlsyxsz.sql
```

##### 2. AWR Snapshot 주기 확인 및 변경
```sql
set lines 100 
col snap_interval for a30
col retention for a50
SELECT DBID, SNAP_INTERVAL, RETENTION FROM DBA_HIST_WR_CONTROL;

set lines 100
SELECT SNAP_ID, DBID, INSTANCE_NUMBER, TO_CHAR(BEGIN_INTERVAL_TIME, 'YYYY/MM/DD HH24:MI'),
TO_CHAR(END_INTERVAL_TIME, 'YYYY/MM/DD HH24:MI') FROM DBA_HIST_SNAPSHOT
ORDER BY DBID, INSTANCE_NUMBER, SNAP_ID;
```

##### 3. AWR Snapshot 주기 30분, 보관은 15일로 설정
```sql
EXEC DBMS_WORKLOAD_REPOSITORY.MODIFY_SNAPSHOT_SETTINGS(RETENTION=>60*24*15,INTERVAL=>30);

SELECT DBID, SNAP_INTERVAL, RETENTION FROM DBA_HIST_WR_CONTROL;
```

# 나. DB 부하 테스트 수행

   플랫폼 별 준비 ( Unix, X86 )

## 1. 부하테스트 시나리오 <a id="ch-2-1"></a>

### A. 부하테스트 시나리오 1 
    <img src="./images/img841.png" alt="시나리오1" />

### B. 부하테스트 시나리오 2 
    <img src="./images/img842.png" alt="시나리오2" />


## 2. 부하용 Schema 생성 <a id="ch-2-2"></a>


### A. SOE Schema & 데이타 생성

각 Schema 생성 결과물도 저장 

```bash
date; $SB_HOME/bin/oewizard -cl -scale   10 -ts SOE10   -u soe10   -p soe10  -tc 16  -nopart -df +DATA  -cs //racnode-scan/orclpdb -dbap oracle -drop   -c oewizard.xml ; date
date; $SB_HOME/bin/oewizard -cl -scale   10 -ts SOE10   -u soe10   -p soe10  -tc 16  -nopart -df +DATA  -cs //racnode-scan/orclpdb -dbap oracle -create -c oewizard.xml ; date
```

### B. SH Schema & 데이타 생성

```bash
date; $SB_HOME/bin/shwizard -cl -scale   10 -ts SH10    -u sh10    -p sh10                    -df +DATA   -cs //racnode-scan/orclpdb -dbap oracle -drop   -c shwizard.xml ; date
date; $SB_HOME/bin/shwizard -cl -scale   10 -ts SH10    -u sh10    -p sh10                    -df +DATA   -cs //racnode-scan/orclpdb -dbap oracle -create -c shwizard.xml ; date
```
>
>Option : 
>1. -scale, -tc, 
>2. -nopart / -part,  
>3. -create / -drop 
>4. -async_on / -async_off
>5. -bigfile / -normalfile
>6. -allindexes / -noindexes
>7. -rangepart , -hashpart, -compositepart
>8. -compress / -nocompress, -oltpcompress / -hcccompress
>ETC. -constraints, -debug, -generate, -idf, -its, -ro, -sp

### C. sbutil 사용법 로 invalid object / table 통계 확인 

#### 1) Invalid Object 확인 
```bash
./sbutil -soe -u soe10 -p soe10 -cs //racnode-scan/orclpdb -val
./sbutil -sh  -u sh10  -p sh10  -cs //racnode-scan/orclpdb -val
```
#### 2) Table 통계정보 확인 
```bash
./sbutil -soe -u soe10 -p soe10 -cs //racnode-scan/orclpdb -tables
./sbutil -sh  -u sh10  -p sh10  -cs //racnode-scan/orclpdb -tables
```
#### 3) 통계정보 재생성 
```bash
./sbutil -soe -u soe10 -p soe10 -cs //racnode-scan/orclpdb -stats
./sbutil -sh -u sh10 -p sh10 -cs //racnode-scan/orclpdb -stats
```

## 3. 부하 수행 <a id="ch-2-3"></a>

### A. Platform 별 결과 저장 디렉토리

Unix, X86 결과 파일은 따로 저장

Unix Home
```bash
/home/oracle/swingbench/unix
```
X86 Home
```bash
/home/oracle/swingbench/x86
```
### B. SOE 부하 수행 


#### 1) charbench 수행 
```bash
cd /home/oracle/swingbench/x86
date; $SB_HOME/bin/charbench -uc   50  -rt  00:05 -bs 00:01 -be 00:04 -ld  50  -min   0  -max   0 -stats full   -u soe10    -p soe10   -r ../x86/soe_scale10_50user_$(date +"%Y%m%d").xml    -c ../configs/SOE_Server_Side_V2.xml -f -dbap oracle -dbau "sys as sysdba" -cs //racnode-scan/orclpdb -cpuuser oracle -cpupass oracle -cpuloc racnode1 -v  users,tpm,tps,cpu ; date
```

### C. SH 부하 수행 

#### 1) charbench 수행 
```bash
cd /home/oracle/swingbench/x86
date; $SB_HOME/bin/charbench -uc   50  -rt  00:05 -bs 00:01 -be 00:04 -ld  50  -min   0  -max   0 -stats full   -u sh10    -p sh10     -r ../x86/sh_scale010_050user_$(date +"%Y%m%d").xml   -c ../configs/Sales_History.xml -f -dbap oracle -dbau "sys as sysdba" -cs //racnode-scan/orclpdb -cpuuser oracle -cpupass oracle -cpuloc racnode1 -v  users,tpm,tps,cpu ; date
```
>Option : 
>1. -be / -bs 
>2. -co 
>3. -nr 
>4. -stats full / simple
>5. -v  trans|cpu|disk|dml|errs|tpm|tps|users|resp|vresp|tottx|trem
>6. -wc 


# 다. 부하테스트 결과 수집  


## 1. Report 장비 ( 부하용 VM ) <a id="ch-3-1"></a>


### A. 플랫폼 별 결과 디렉토리 준비 ( Unix, X86 )


### B. Swingbench 자료 
```bash
$SWINGBENCH_HOME/x86
$SWINGBENCH_HOME/unix
```
* soe_scale10_50user.xml
* sh_scale010_050user.xml

파일들에서 결과 값만 추출해 표로 작성 
```bash
python ../utils/parse_results.py -r scale10_50user.xml soe_scale10_50user.xml -o soe10.csv
python ../utils/parse_results.py -r sh_scale010_010user.xml sh_scale010_010user00001.xml -o sh10.csv
```
### C. OSWatcher 자료 
각 DB Node 들 oswbb 의 archive 디렉토리내 모든 디렉토리 (일부 필요없지만... )
```bash
/opt/oracle.ahf/tfa/ext/oswbb/archive/* 
```
DB 노드별로 리포트 서버로 복사해옴
```bash
/home/oracle/visual-awr/input/
[oracle@ora19 input]$ scp -r root@racnode1:/opt/oracle.ahf/tfa/ext/oswbb/archive racnode1-osw
[oracle@ora19 input]$ scp -r root@racnode2:/opt/oracle.ahf/tfa/ext/oswbb/archive racnode2-osw
```
## 2. AWR 자료 <a id="ch-3-2"></a>
각 DB Node 들에서 취합됨 

### A. Visual-AWR script 설명 
   : Visual-AWR Assets 디렉토리아래의 script 활용
```bash
visual-awr/assets/mkawrscript.sql
visual-awr/assets/getawr.sql
```
### B. AWR 정보 취득

#### 1) AWR snapshot 정보 취득
DBA 권한으로 CDB 에 접속
```sql
[oracle@racnode2 assets]$ sqlplus sys/oracle@orcl as sysdba
SQL> @mkawrscript.sql
DB Id       : 
inst_num  :
num_days :
begin_snap : 
end_snap:
```
getawr.sql 생성됨 

#### 2) AWR Report 취득
```sql 
@getawr.sql
Beginning AWR generation...
Creating AWR report awrrpt_20211107_0600-20211107_0701_INST_1_18-19.html for INST#1 from snapshot 18 to 19...
Creating AWR report awrrpt_20211107_0701-20211107_0800_INST_1_19-20.html for INST#1 from snapshot 19 to 20...
```
#### 3) AWR Report 전송 
:  AWR Report 는 Report 서버로 전송
Visual-AWR 분석을 위해 input 디렉토리 밑에 서버별로 저장 
```bash
/home/oracle/visual-awr/input/racnode1
/home/oracle/visual-awr/input/racnode2
```
# 라. 부하테스트 결과 보고 및 분석

## 1.  부하용 VM <a id="ch-4-1"></a>

### OS 자원/성능 (네트워크 포함) 정보 
: dstat output file ( dstat_$(date +"%Y%m%d").txt )

## 2. DB 노드 <a id="ch-4-2"></a>

### Visual-AWR HTML 결과 확인 
<visual-awr>/html/report/ 아래 생성된 HTML 리포트를 구글 크롬 (강력 권장) 으로 열어본다.


# 마. Appendix 

## 1. 환경변수 <a id="ch-5-1"></a>

### A. DB 노드용 .bash_profile

#### 1) oracle 계정 .bash_profile 일부
```bash
# User specific aliases and functions
export ORACLE_HOSTNAME=racnode1.example.com
export ORACLE_UNQNAME=orcl
export ORACLE_BASE=/u01/app/oracle
export GRID_BASE=/u01/app/grid
export GRID_HOME=/u01/app/19.3.0/grid
export DB_HOME=$ORACLE_BASE/product/19.3.0/dbhome_1
export ORACLE_HOME=$DB_HOME
export TNS_ADMIN=$ORACLE_HOME/network/admin
export ORACLE_SID=ORCL1
export ORACLE_TERM=xterm
export ASM_SID=+ASM1

export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib
export CLASSPATH=$ORACLE_HOME/JRE:$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib
export BASE_PATH=/bin:/usr/sbin:$PATH
export PATH=$ORACLE_HOME/bin:$BASE_PATH
export DISPLAY=rac01:2

stty erase ^H

alias grid_env='. /home/oracle/grid_env'
alias db_env='. /home/oracle/db_env'
alias sa='sqlplus / as sysasm'
alias sp='sqlplus / as sysdba'
alias oratop='$ORACLE_HOME/suptools/oratop/oratop / as sysdba'

alias adump='cd $GRID_BASE/diag/asm/+asm/$ASM_SID/trace'
alias bdump='cd $ORACLE_BASE/diag/rdbms/$ORACLE_UNQNAME/$ORACLE_SID/trace'
alias t_asmlog='tail -f $GRID_BASE/diag/asm/+asm/$ASM_SID/trace/alert_$ASM_SID.log'
alias t_crsdlog='tail -f $GRID_BASE/diag/crs/$HOSTNAME/crs/trace/alert.log'
alias t_asmcmdlog='tail -f $GRID_BASE/diag/asmcmd/user_grid/$HOSTNAME/alert/alert.log'
alias t_dblog='tail -f $ORACLE_BASE/diag/rdbms/$ORACLE_UNQNAME/$ORACLE_SID/trace/alert_$ORACLE_SID.log'

alias v_asmlog='vi $GRID_BASE/diag/asm/+asm/$ASM_SID/trace/alert_$ASM_SID.log'
alias v_crsdlog='vi $GRID_BASE/diag/crs/$HOSTNAME/crs/trace/alert.log'
alias v_asmcmdlog='vi $GRID_BASE/diag/asmcmd/user_grid/$HOSTNAME/alert/alert.log'
alias v_dblog='vi $ORACLE_BASE/diag/rdbms/$ORACLE_UNQNAME/$ORACLE_SID/trace/alert_$ORACLE_SID.log'

alias python=python3
alias pip=pip3
```

#### 2) grid 계정 .bash_profile 일부
```bash
# Oracle specific aliases and functions
export ORACLE_HOSTNAME=racnode1.example.com
export ORACLE_UNQNAME=orcl
export ORACLE_BASE=/u01/app/oracle
export GRID_BASE=/u01/app/grid
export GRID_HOME=/u01/app/19.3.0/grid
export DB_HOME=$ORACLE_BASE/product/19.3.0/dbhome_1
export ORACLE_HOME=$GRID_HOME
export ORACLE_SID=+ASM1
export ORACLE_TERM=xterm
export ASM_SID=$ORACLE_SID

export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib
export CLASSPATH=$ORACLE_HOME/JRE:$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib
export BASE_PATH=/usr/sbin:$PATH
export PATH=$ORACLE_HOME/bin:$BASE_PATH

alias grid_env='. /home/oracle/grid_env'
alias db_env='. /home/oracle/db_env'
alias sa='sqlplus / as sysasm'
alias sp='sqlplus / as sysdba'

stty erase ^H

alias adump='cd $GRID_BASE/diag/asm/+asm/$ASM_SID/trace'
alias bdump='cd $ORACLE_BASE/diag/rdbms/$ORACLE_UNQNAME/$ORACLE_SID/trace'
alias t_asmlog='tail -f $GRID_BASE/diag/asm/+asm/$ASM_SID/trace/alert_$ASM_SID.log'
alias t_crsdlog='tail -f $GRID_BASE/diag/crs/$HOSTNAME/crs/trace/alert.log'
alias t_asmcmdlog='tail -f $GRID_BASE/diag/asmcmd/user_grid/$HOSTNAME/alert/alert.log'
alias t_dblog='tail -f $ORACLE_BASE/diag/rdbms/$ORACLE_UNQNAME/$ORACLE_SID/trace/alert_$ORACLE_SID.log'

alias v_asmlog='vi $GRID_BASE/diag/asm/+asm/$ASM_SID/trace/alert_$ASM_SID.log'
alias v_crsdlog='vi $GRID_BASE/diag/crs/$HOSTNAME/crs/trace/alert.log'
alias v_asmcmdlog='vi $GRID_BASE/diag/asmcmd/user_grid/$HOSTNAME/alert/alert.log'
alias v_dblog='vi $ORACLE_BASE/diag/rdbms/$ORACLE_UNQNAME/$ORACLE_SID/trace/alert_$ORACLE_SID.log'
```

#### 3) grid_env
```bash
export ORACLE_SID=+ASM1
export ORACLE_HOME=$GRID_HOME
export PATH=$ORACLE_HOME/bin:$BASE_PATH

export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib
export CLASSPATH=$ORACLE_HOME/JRE:$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib
```

#### 4) db_env
```bash
export ORACLE_SID=ORCL1
export ORACLE_HOME=$DB_HOME
export PATH=$ORACLE_HOME/bin:$BASE_PATH

export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib
export CLASSPATH=$ORACLE_HOME/JRE:$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib
```

### B. 부하용VM  .bash_profile
```bash
# User specific aliases and functions
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=$ORACLE_BASE/product/19.3.0/client_1
export TNS_ADMIN=$ORACLE_HOME/network/admin
export ORACLE_TERM=xterm

export NLS_LANG=AMERICAN_AMERICA.AL32UTF8
export LANG=en_US.utf8

export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib
export CLASSPATH=$ORACLE_HOME/JRE:$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib
export BASE_PATH=/usr/sbin:$PATH
export PATH=$ORACLE_HOME/bin:/home/oracle/sqlcl/bin:$ORACLE_HOME/perl/bin:$BASE_PATH
export SB_HOME=/home/oracle/swingbench
```

## 2. SSH User Equivalence Configuration <a id="ch-5-2"></a>

### A. Manual Key-Based Authentication 

#### 1) Node1번 / 2번 ssh key 생성
```bash
su - oracle
mkdir ~/.ssh
chmod 700 ~/.ssh
/usr/bin/ssh-keygen -t rsa # Accept the default settings.
```

#### 2) Public  Key 복사 

##### Node 1번
```bash
cd ~/.ssh
cat id_rsa.pub >> authorized_keys
scp authorized_keys racnode2:/home/oracle/.ssh/
```

##### Node 2번
```bash
cd ~/.ssh
cat id_rsa.pub >> authorized_keys
scp authorized_keys racnode1:/home/oracle/.ssh/
```
```bash
ssh racnode1 date
ssh racnode2 date
```

### B. sshUserSetup.sh (Oracle Method)
$ ./sshUserSetup.sh 

## 3. 일반 사용자로 sudo 사용 ( 패스워드없이 )<a id="ch-5-3"></a>

```bash
vi /etc/sudoers

root 		ALL=(ALL)  ALL
oracle       ALL=(ALL)       NOPASSWD: ALL
```

## 4. Oracle Linux 7에서 로컬 yum repository 설정<a id="ch-5-4"></a>
* 관리원은 DB 서버에서 outbound network 차단

#### 1) DVD 또는 ISO 를 마운트 

#### 2) 미디어 내용 전체를 localrepo 디렉토리에 복사
```bash
# mkdir -p /localrepo
# cp -rv /run/media/root/OL-7.9\ Server.x86_64/Packages/ /localrepo/
```

#### 3) 기존 repo 파일명 변경
```bash
# cd /etc/yum.repos.d/
# mv public-yum-ol7.repo public-yum-ol7.repobak 
```

#### 4) local repositor 용 파일 생성 
```bash
# vi /etc/yum.repos.d/local.repo

# OL 7용
[local]
name=localrepository
baseurl=file:///localrepo/
enabled=1
gpgcheck=0
```

#### 5) Local Repository 업데이트
```bash
# createrepo /localrepo/
```

#### 6)  확인 및 테스트 
```bash
# yum clean all
# yum repolist
# yum install python3
```

## 5. ODA X82HA 의 Database Shape 별 성능 수치 자료 ( BMT 결과 아님 ) 
https://www.oracle.com/a/ocom/docs/engineered-systems/database-appliance/oda-x82ha-perf-wp-5972834.pdf


