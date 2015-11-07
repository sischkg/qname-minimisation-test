$TTL 300
@	IN SOA	ns1.example.com. hostmaster.example.com. (
					0	; serial
					1D	; refresh
					1H	; retry
					1W	; expire
					3H )	; minimum
	NS	ns1
www	A	192.168.33.14
ns1	A	192.168.33.14
yyy.zzz	A	192.168.33.14

