INSERT INTO domains (name, type) values ('example.com', 'NATIVE');
INSERT INTO records (domain_id, name, content, type,ttl,prio)
VALUES (1,'example.com','ns1.example.com hostmaster.example.com 0 86400 3600 604800 10800','SOA',300,NULL);

INSERT INTO records (domain_id, name, content, type,ttl,prio)
VALUES (1,'example.com','ns1.example.com.','NS',300,NULL);
INSERT INTO records (domain_id, name, content, type,ttl,prio)
VALUES (1,'www.example.com','192.168.33.13','A',300,NULL);
INSERT INTO records (domain_id, name, content, type,ttl,prio)
VALUES (1,'ns1.example.com','192.168.33.13','A',300,NULL);
INSERT INTO records (domain_id, name, content, type,ttl,prio)
VALUES (1,'yyy.zzz.example.com','192.168.33.13','A',300,NULL);

