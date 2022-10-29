# Jarkom-Modul-2-C02-2022

## Anggota Kelompok

| Nama | NRP |
| --- | --- |
| Rafiqi Rachmat | 5025201067 |
| Julio Geraldi Soeiono | 5025201079 |

Prefix IP = 192.180

## Topologi

![topologi](https://media.discordapp.net/attachments/221887784108032001/1035922161040367707/unknown.png)

- 192.180.1.2 SSS
- 192.180.1.3 Garden
- 192.180.2.2 Berlint
- 192.180.2.3 Eden
- 192.180.3.2 Wise

## 1

  *WISE akan dijadikan sebagai DNS Master, Berlint akan dijadikan DNS Slave, dan Eden akan digunakan sebagai Web Server. Terdapat 2 Client yaitu SSS, dan Garden. Semua node terhubung pada router Ostania, sehingga dapat mengakses internet (1).*

- Ostania</br>

    ```bash
    iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 192.191.0.0/16 
    ```

- Eden</br>

    ```bash
    echo $'nameserver 192.168.122.1' > /etc/resolv.conf 
    ```

- Wise, Berlint</br>

    ```bash
    echo $'nameserver 192.168.122.1' > /etc/resolv.conf
    apt update
    apt install bind9 -y
    ```

- SSS & Garden</br>

    ```bash
    echo $'nameserver 192.180.3.2\nnameserver 192.180.2.2\nnameserver 192.168.122.1' > /etc/resolv.conf 
    ```

## 2

*Untuk mempermudah mendapatkan informasi mengenai misi dari Handler, bantulah Loid membuat website utama dengan akses wise.yyy.com dengan alias www.wise.yyy.com pada folder wise (2).*

- Wise

```sh
echo 'zone "wise.c02.com" {
        type master;
        file "/etc/bind/c02/wise.c02.com";
}; > /etc/bind/named.conf.local

mkdir /etc/bind/c02

echo ';
; BIND data file for local loopback interface
;
$TTL    604800
@       IN      SOA     wise.c02.com. root.wise.c02.com. (
                     2022102501         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      wise.c02.com.
@       IN      A       192.180.3.2
www     IN      CNAME   wise.c02.com.
@       IN      AAAA    ::1' > /etc/bind/c02/wise.c02.com
```

## 3

*Setelah itu ia juga ingin membuat subdomain eden.wise.yyy.com dengan alias www.eden.wise.yyy.com yang diatur DNS-nya di WISE dan mengarah ke Eden (3).*

- Wise

``` sh
echo ';
; BIND data file for local loopback interface
;
$TTL    604800
@       IN      SOA     wise.c02.com. root.wise.c02.com. (
                     2022102501         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      wise.c02.com.
@       IN      A       192.180.3.2
www     IN      CNAME   wise.c02.com.
eden    IN      A       192.180.2.3
www.eden        IN      CNAME   eden.wise.c02.com.
@       IN      AAAA    ::1' > /etc/bind/c02/wise.c02.com
```

## 4

*Buat juga reverse domain untuk domain utama (4).*

- Wise

```sh
echo 'zone "wise.c02.com" {
        type master;
        file "/etc/bind/c02/wise.c02.com";
};

zone "3.180.192.in-addr.arpa" {
        type master;
        file "/etc/bind/c02/3.180.192.in-addr.arpa";
};' > /etc/bind/named.conf.local

echo ';
; BIND data file for local loopback interface
;
$TTL    604800
@       IN      SOA     wise.c02.com. root.wise.c02.com. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
3.180.192.in-addr.arpa. IN      NS      wise.c02.com.
2                       IN      PTR     wise.c02.com.' >> /etc/bind/c02/3.180.192.in-addr.arpa

service bind9 restart
```

## 5

*Agar dapat tetap dihubungi jika server WISE bermasalah, buatlah juga Berlint sebagai DNS Slave untuk domain utama (5).*

- Berlint

```sh
echo $'nameserver 192.168.122.1' > /etc/resolv.conf

apt update
apt install bind9 -y

zone "wise.c02.com" {
        type slave;
        masters { 192.180.3.2; };
        file "/var/lib/bind/wise.c02.com";
};' >> /etc/bind/named.conf.local
```

- Wise

```sh
echo 'zone "wise.c02.com" {
        type master;
        notify yes;
        also-notify { 192.180.2.2; };
        allow-transfer { 192.180.2.2; };
        file "/etc/bind/c02/wise.c02.com";
};

zone "3.180.192.in-addr.arpa" {
        type master;
        file "/etc/bind/c02/3.180.192.in-addr.arpa";
};' > /etc/bind/named.conf.local
```

## 6

*Karena banyak informasi dari Handler, buatlah subdomain yang khusus untuk operation yaitu operation.wise.yyy.com dengan alias www.operation.wise.yyy.com yang didelegasikan dari WISE ke Berlint dengan IP menuju ke Eden dalam folder operation (6).*

- Wise

```sh
echo 'options {
        directory "/var/cache/bind";

        // If there is a firewall between you and nameservers you want
        // to talk to, you may need to fix the firewall to allow multiple
        // ports to talk.  See http://www.kb.cert.org/vuls/id/800113

        // If your ISP provided one or more IP addresses for stable 
        // nameservers, you probably want to use them as forwarders.  
        // Uncomment the following block, and insert the addresses replacing 
        // the all-0s placeholder.

        // forwarders {
        //      0.0.0.0;
        // };

        //========================================================================
        // If BIND logs error messages about the root key being expired,
        // you will need to update your keys.  See https://www.isc.org/bind-keys
        //========================================================================
        //dnssec-validation auto;
        allow-query{any;};
        auth-nxdomain no;    # conform to RFC1035
        listen-on-v6 { any; };
};' > /etc/bind/named.conf.options

echo ';
; BIND data file for local loopback interface
;
$TTL    604800
@       IN      SOA     wise.c02.com. root.wise.c02.com. (
                     2022102501         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      wise.c02.com.
@       IN      A       192.180.3.2
www     IN      CNAME   wise.c02.com.
eden    IN      A       192.180.2.3
www.eden        IN      CNAME   eden.wise.c02.com.
operation IN    NS      ns1
@       IN      AAAA    ::1' > /etc/bind/c02/wise.c02.com
```

- Berlint

```sh
echo 'zone "operation.wise.c02.com" {
        type master;
        file "/etc/bind/c02/operation.wise.c02.com";
};

zone "wise.c02.com" {
        type slave;
        masters { 192.180.3.2; };
        file "/var/lib/bind/wise.c02.com";
};' >> /etc/bind/named.conf.local

echo 'options {
        directory "/var/cache/bind";

        // If there is a firewall between you and nameservers you want
        // to talk to, you may need to fix the firewall to allow multiple
        // ports to talk.  See http://www.kb.cert.org/vuls/id/800113

        // If your ISP provided one or more IP addresses for stable 
        // nameservers, you probably want to use them as forwarders.  
        // Uncomment the following block, and insert the addresses replacing 
        // the all-0s placeholder.

        // forwarders {
        //      0.0.0.0;
        // };

        //========================================================================
        // If BIND logs error messages about the root key being expired,
        // you will need to update your keys.  See https://www.isc.org/bind-keys
        //========================================================================
        //dnssec-validation auto;
        allow-query{any;};
        auth-nxdomain no;    # conform to RFC1035
        listen-on-v6 { any; };
};' >> /etc/bind/named.conf.options

mkdir /etc/bind/c02

echo ';
; BIND data file for local loopback interface
;
$TTL    604800
@       IN      SOA     operation.wise.c02.com. root.operation.wise.c02.com. (
                     2022100601         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      operation.wise.c02.com.
@       IN      A       192.180.2.3
www     IN      CNAME   operation.wise.c02.com.
@       IN      AAAA    ::1' > /etc/bind/c02/operation.wise.c02.com
```

## Kendala yang dihadapi

Saat pengerjaan praktikum salah melihat jadwal sehingga mengira hari terakhir pengerjaan adalah hari sabtu