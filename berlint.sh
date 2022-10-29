echo $'nameserver 192.168.122.1' > /etc/resolv.conf

apt update
apt install bind9 -y

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

service bind9 restart