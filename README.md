Intro
------
Scripts for running [Responder.py](https://github.com/SpiderLabs/Responder) in an Android (rooted) device. 


Prerequisites
------
* Rooted android phone
* [NetHunter](https://www.kali.org/kali-linux-nethunter/) or [qPython](https://play.google.com/store/apps/details?id=org.qpython.qpy&hl=en) installed


Usage	
------
```
git clone git@github.com:nvssks/Android-Responder.git
cd Android-Responder
git submodule update --init --recursive
git apply ResponderSettings.patch
```
Delete ResponderSettings.patch
Copy everything in Android - Responder needs to be in the same $DIR as the scripts

* Android:
```
~$ su -c sh $DIR/startTether.sh
~$ su -c sh $DIR/stopTether.sh
```
* Kali NetHunter:
```
~$ su -c bootkali
root@kali:/# bash $DIR/startTether.sh
root@kali:/# bash $DIR/stopTether.sh
```


Results
------
Video shows a Windows 10 lock screen (fresh install) connected to an Android device running Responder.py. Host laptop is not connected to any other network (wifi or ethernet).
[![Video](https://img.youtube.com/vi/Wdavavcon68/0.jpg)](https://www.youtube.com/watch?v=Wdavavcon68)


Considerations
------
- For Android v4.? use /storage/emulated/0/[*] instead of /sdcard
  

Credits
------
* [Responder](https://github.com/SpiderLabs/Responder)
* [Responder Latest](https://github.com/lgandx/Responder)
* https://room362.com/post/2016/snagging-creds-from-locked-machines/
* [@whitslack](http://forum.xda-developers.com/member.php?u=2684937), http://forum.xda-developers.com/showthread.php?t=2127850
* [@mubix](https://room362.com/post/2016/snagging-creds-from-locked-machines/)
* Special thanks: [@ikoz](https://twitter.com/ikoz), [@xtsop](https://twitter.com/xtsop)