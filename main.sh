#!/bin/bash
file_mod(){

file_chg_cntr=0

USR=`cat config | grep file -A4 | grep user | cut -f 2 -d :`
GRP=`cat config | grep file -A4 | grep group | cut -f 2 -d :`
#FLE=`cat config | grep File -A4 | grep file | cut -f 2 -d :`
PRM=`cat config | grep file -A4 | grep perm | cut -f 2 -d :`


if [ ! -f $FLE ] || [ -z $FLE ]
then
 echo "file does not exsists"
else
file_chg_cntr=0

  if [ -z $USR ]
  then
    USR=`stat -c "%U" $FLE`
  fi

  if [ -z $GRP ]
  then
    GRP=`stat -c "%G" $FLE`
  fi

  if [ -z $PRM ]
  then
    PRM=`stat -c "%a" $FLE`
  fi

ACT_USR=`stat -c "%U" $FLE`
ACT_GRP=`stat -c "%G" $FLE`
ACT_PRM=`stat -c "%a" $FLE`

  if [ $USR != $ACT_USR ]
  then
    chown $USR $FLE > /dev/null 2>&1
    if [ $? -eq 0 ]
    then
     let "file_chg_cntr=file_chg_cntr+1"
    fi
  fi

  if [ $GRP != $ACT_GRP ]
  then
    chown :$GRP $FLE > /dev/null 2>&1
    if [ $? -eq 0 ]
    then
     let "file_chg_cntr=file_chg_cntr+1"
    fi
  fi

  if [ $PRM != $ACT_PRM ]
  then
    chmod $PRM $FLE > /dev/null 2>&1
    if [ $? -eq 0 ]
    then
     let "file_chg_cntr=file_chg_cntr+1"
    fi
  fi

fi

echo "File Module changes for $FLE  [$file_chg_cntr]"

}

################

pkg_mod(){

#PKG_NAME=`cat config | grep package -A2 | grep name | cut -f 2 -d :`
PKG_STATE=`cat config | grep package -A2 | grep state | cut -f 2 -d :`

if [ -z $PKG_STATE ]
then
 PKG_STATE="present"
fi

pkg_chg_cntr=0

if [ -z $PKG_NAME ]
then
  echo "No package provide, it is mandatory field"
else
 ACT_PKG_STATE=`dpkg -s $PKG_NAME > /dev/null 2>&1 ; echo $?`
 if [ $ACT_PKG_STATE -eq 1 ] && [ $PKG_STATE == "present" ]
 then
   echo "installing appliacation"
   apt install $PKG_NAME -y > /dev/null 2>&1
   let "pkg_chg_cntr=pkg_chg_cntr+1"
 fi
 if [ $ACT_PKG_STATE -eq 0 ] && [ $PKG_STATE == "absent" ]
 then
   echo "uninstalling application"
   apt remove $PKG_NAME -y > /dev/null 2>&1
   apt purge $PKG_NAME -y > /dev/null 2>&1
   let "pkg_chg_cntr=pkg_chg_cntr+1"
 fi

fi

echo "Package Module changes for $PKG_NAME [$pkg_chg_cntr]"

}

##########33


srvc_mod(){
srvc_chg_cntr=0
SRVC_STATE=`cat config | grep service -A2 | grep status | cut -f 2 -d :`

if [ -z $SRVC_STATE ]
then
 SRVC_STATE="stop"
fi

ACT_SRCV_STATE=`pgrep $SRVC_NAME > /dev/null 2>&1 ; echo $?`
if [ $ACT_SRCV_STATE -eq 1 ] && [ $SRVC_STATE == "start" ]
then
  echo "starting service"
  systemctl start $SRVC_NAME > /dev/null 2>&1
  let "srvc_chg_cntr=srvc_chg_cntr+1"
fi
if [ $ACT_SRCV_STATE -eq 0 ] && [ $SRVC_STATE == "stop" ]
then
  echo "stoping the service"
  systemctl stop $SRVC_NAME > /dev/null 2>&1
  let "srvc_chg_cntr=srvc_chg_cntr+1"
fi
if [ $SRVC_STATE == "restart" ]
then
  echo "restarting service"
  let "srvc_chg_cntr=srvc_chg_cntr+1"
fi

echo "Service Module changes for $SRVC_NAME [$srvc_chg_cntr]"

}
######################

cp_mod(){
cp_chg_cntr=0
CP_FLE_NAME=`cat config | grep copy -A2 | grep name | cut -f 2 -d :| tr -d "[:space:]"`
CP_FLE_DEST=`cat config | grep copy -A2 | grep dest | cut -f 2 -d :`

if [ -z $CP_FLE_NAME ] || [ -z $CP_FLE_DEST ]
then
  echo "both filename and destination dir are mandatory fields"
else
  if [ -d $CP_FLE_DEST ]
   then
    CP_FLE_HASH=`md5sum /tmp/srv/$CP_FLE_NAME | cut -f 1 -d " "`
    if [ -f $CP_FLE_DEST/$CP_FLE_NAME ]
    then
     CP_FLE_DEST_HASH=`md5sum $CP_FLE_DEST/$CP_FLE_NAME | cut -f 1 -d " "`
     if [ $CP_FLE_HASH != $CP_FLE_DEST_HASH ]
     then
        echo "copying"
        cp /tmp/srv/$CP_FLE_NAME $CP_FLE_DEST
        let "cp_chg_cntr=cp_chg_cntr+1"
        echo "Copy Module changes for $CP_FLE_NAME [$cp_chg_cntr]"
      else
        echo "files are already in sync"
        echo "Copy Module changes for $CP_FLE_NAME [$cp_chg_cntr]"
     fi
    else
       cp /tmp/srv/$CP_FLE_NAME $CP_FLE_DEST
       let "cp_chg_cntr=cp_chg_cntr+1"
       echo "Copy Module changes for $CP_FLE_NAME [$cp_chg_cntr]"
   fi
  else
    echo "dir not present"
  fi
fi


}


file(){

files=`cat config | grep file -A4 | grep name | cut -f 2 -d : | tr "," "\n"`
for f in $files
do
 export FLE=$f
 file_mod
done
}

package(){

package_list=`cat config | grep package -A2 | grep name | cut -f 2 -d : | tr "," "\n"`
for p in $package_list
do
 export PKG_NAME=$p
 pkg_mod
done

}

service(){

service_list=`cat config | grep service -A2 | grep name | cut -f 2 -d : | tr "," "\n"`
for s in $service_list
do
 export SRVC_NAME=$s
 srvc_mod
done

}

copy(){

 cp_mod
}

MODS=`cat config | grep "Mods to use" -A4 | grep -v "Mods to use"`

for func in $MODS
do
 $func
done
