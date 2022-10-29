echo $'nameserver 192.168.122.1' > /etc/resolv.conf

apt update
apt install bind9 -y

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
eden    IN      A       192.180.2.3
www.eden        IN      CNAME   eden.wise.c02.com.
operation IN    NS      ns1
@       IN      AAAA    ::1' > /etc/bind/c02/wise.c02.com

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