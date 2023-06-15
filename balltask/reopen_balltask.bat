call %HOMEPATH%\anaconda3\Library\bin\conda.bat activate psychopy
set participant=%1
set run=%2
set feedback_on=%3
set condition=%4
set anchor=%5

python rt-network_feedback.py %participant% %run% %feedback_on% %condition% %anchor%
