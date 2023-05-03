for ($i=1; $i -lt 255;$i++) {
    ping -n 1 10.0.0.$i >> C:\Temp\hosts_IP.txt
    }