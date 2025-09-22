# تشغيل flutter run على جهازين متوصلين في نفس الوقت

# الجهاز الأول (INE LX1r)
Start-Process powershell -ArgumentList "-NoExit", "cd `"$PWD`"; flutter run -d 2JN4C18C05006637"

# الجهاز التاني (RMX3890)
Start-Process powershell -ArgumentList "-NoExit", "cd `"$PWD`"; flutter run -d d79d740a"
