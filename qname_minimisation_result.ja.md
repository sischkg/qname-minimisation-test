# QNAME-MINIMISATIONに対する権威サーバの応答の比較

* PowerDNSのPeter van Dijk(@Habbie)さんから、PowerDNSではレコードを登録後に`pdnssec  recitfy-zone`コマンドを実行するようにとアドバイスを頂きましたので、rectify-zone実行後の結果を追記しました。

## 環境

### クライアント

* OS: Ubuntu Mate 15.04
* DNSクライアント: DiG 9.10.3

### サーバ

* OS: CentOS 6.7 on VirtualBox
* 権威DNSサーバ

   - Bind: 9.10.2-P3
   - NSD: 4.1.3
   - PowerDNS Authoritative Server 3.4.7(MySQL Backend)
   - knotDNS 1.6.4

* OS: Microsoft Windows 2008R2
* OS: Microsoft Windows 2012R2

## 調査内容

各DNSサーバ上にゾーンexample.comを設定します。その設定ファイルは、以下のとおりです。
QNAME-Minimisationなresolverが、yyy.zzz.example.comのAを引けるかどうかを調べます。
resolverはキャッシュサーバではなく、digコマンドで代用します。

ここでは、[draft-ietf-dnsop-qname-minimisation-07](https://tools.ietf.org/html/draft-ietf-dnsop-qname-minimisation-07)
のAppendix Aに記載されている*An algorithm to find the zone cut*を実行します。

    $TTL 300
    @    IN SOA ns1.example.com. hostmaster.example.com. (
                                        0       ; serial
                                        1D      ; refresh
                                        1H	; retry
                                        1W	; expire
                                        3H )	; minimum
           IN NS  ns1
    www     IN A   <DNSサーバのIPアドレス>
    ns1     IN A   <DNSサーバのIPアドレス>
    yyy.zzz IN A   <DNSサーバのIPアドレス>


* [Bindの設定ファイル](https://github.com/sischkg/qname-minimisation-test/tree/master/config/bind)
* [NSDの設定ファイル](https://github.com/sischkg/qname-minimisation-test/tree/master/config/nsd)
* [PowerDNSの設定ファイル](https://github.com/sischkg/qname-minimisation-test/tree/master/config/powerdns)
* [knotDNSの設定ファイル](https://github.com/sischkg/qname-minimisation-test/tree/master/config/knot)

### 前提条件

既にキャッシュには、example.comのNSレコードとそのAレコードが存在します。

    example.com.   IN  NS  ns1.example.com.
    example.com.   IN  A   <DNSサーバのIPアドレス>

## 結果

()付きの数字は、[draft-ietf-dnsop-qname-minimisation-07](https://tools.ietf.org/html/draft-ietf-dnsop-qname-minimisation-07)
のAppendix Aのものです。

### Bind / NSD / knotDNS / Windoes 2012R2

1. クエリを受信

   QNAME = yyy.zzz.example.com.
   TYPE  = A

2. QNAMEはキャッシュに存在しない(0)

3. `PARENT = example.com.` (1)

4. `CHILD = example.com. = PARENT` (2)

5. `CHILD != QNAME` (3)

6. CHILDにラベルを１つ追加 (4)

    CHILD = zzz.example.com.

7. CHILDのNS RRsetはキャッシュにない(5)

8. ns1.example.com.に`CHILD = zzz.example.com`のNSをクエリ (6)

    $ dig @<DNSサーバのIPアドレス> zzz.example.com.  NS +norec

   * [Bindに対するクエリとレスポンス](https://github.com/sischkg/qname-minimisation-test/blob/master/results/bind/bind_01_zzz.example.com_ns.txt)
   * [NSDに対するクエリとレスポンス](https://github.com/sischkg/qname-minimisation-test/blob/master/results/nsd/nsd_01_zzz.example.com_ns.txt)
   * [knotDNSに対するクエリとレスポンス](https://github.com/sischkg/qname-minimisation-test/blob/master/results/knot/knot_01_zzz.example.com_ns.txt)
   * [Windows 2012R2に対するクエリとレスポンス](https://github.com/sischkg/qname-minimisation-test/blob/master/results/win2012r2/win2012r2_01_zzz.example.com_ns.txt)

9. 応答はNOERROR/NODATA answerであるため、応答キャッシュに保存し、(3)へ (6d)

10. `CHILD != QNAME` (3)

11. CHILDにラベルを１つ追加 (4)

    CHILD = yyy.zzz.example.com.

12. CHILDのNS RRsetはキャッシュにない (5)

13. ns1.example.com.に`CHILD = yyy.zzz.example.com`のNSをクエリ (6)

    $ dig @<DNSサーバのIPアドレス> yyy.zzz.example.com. NS +norec

   * [Bindに対するクエリとレスポンス](https://github.com/sischkg/qname-minimisation-test/blob/master/results/bind/bind_02_yyy.zzz.example.com_ns.txt)
   * [NSDに対するクエリとレスポンス](https://github.com/sischkg/qname-minimisation-test/blob/master/results/nsd/nsd_02_yyy.zzz.example.com_ns.txt)
   * [knotDNSに対するクエリとレスポンス](https://github.com/sischkg/qname-minimisation-test/blob/master/results/knot/knot_02_yyy.zzz.example.com_ns.txt)
   * [Windows 2012R2に対するクエリとレスポンス](https://github.com/sischkg/qname-minimisation-test/blob/master/results/win2012r2/win2012r2_02_yyy.zzz.example.com_ns.txt)

14. 応答はNOERROR/NODATA answerであるため、応答キャッシュに保存し、(3)へ (6d)

15. `CHILD == QNAME` のためCHILD(=QNAME)のAをクエリして終了 (3)

    $ dig @<DNSサーバのIPアドレス> yyy.zzz.example.com. A +norec

   * [Bindに対するクエリとレスポンス](https://github.com/sischkg/qname-minimisation-test/blob/master/results/bind/bind_03_yyy.zzz.example.com_a.txt)
   * [NSDに対するクエリとレスポンス](https://github.com/sischkg/qname-minimisation-test/blob/master/results/nsd/nsd_03_yyy.zzz.example.com_a.txt)
   * [knotDNSに対するクエリとレスポンス](https://github.com/sischkg/qname-minimisation-test/blob/master/results/knot/knot_03_yyy.zzz.example.com_a.txt)
   * [Windows 2012R2に対するクエリとレスポンス](https://github.com/sischkg/qname-minimisation-test/blob/master/results/win2012r2/win2012r2_03_yyy.zzz.example.com_a.txt)


### PowerDNS / Windows 2008R2

1. クエリを受信

   QNAME = yyy.zzz.example.com.
   TYPE  = A

2. QNAMEはキャッシュに存在しない(0)

3. `PARENT = example.com.` (1)

4. `CHILD = example.com. = PARENT` (2)

5. `CHILD != QNAME` (3)

6. CHILDにラベルを１つ追加 (4)

    CHILD = zzz.example.com.

7. CHILDのNS RRsetはキャッシュにない(5)

8. ns1.example.com.に`CHILD = zzz.example.com`のNSをクエリ (6)

    $ dig @<DNSサーバのIPアドレス> zzz.example.com.  NS +norec

   * [PowerDNSに対するクエリとレスポンス](https://github.com/sischkg/qname-minimisation-test/blob/master/results/powerdns/powerdns_01_zzz.example.com_ns.txt)
   * [Windows 2008R2に対するクエリとレスポンス](https://github.com/sischkg/qname-minimisation-test/blob/master/results/win2008r2/win2008r2_01_zzz.example.com_ns.txt)

9. 応答はNXDOMAINであるため、応答キャッシュに保存し、終了 (6c)


### PowerDNS ( pdnssec rectify-zone実行済み )

Backend(MySQL)にレコードを追加したあとに、`pdnssec rectify-zone`コマンドを実行します。

    $ pdnssec rectify-zone example.com
    Non DNSSEC zone, only adding empty non-terminals

このコマンド実行後に、PowerDNSはNOERRORを返すようになります。

1. クエリを受信

   QNAME = yyy.zzz.example.com.
   TYPE  = A

2. QNAMEはキャッシュに存在しない(0)

3. `PARENT = example.com.` (1)

4. `CHILD = example.com. = PARENT` (2)

5. `CHILD != QNAME` (3)

6. CHILDにラベルを１つ追加 (4)

    CHILD = zzz.example.com.

7. CHILDのNS RRsetはキャッシュにない(5)

8. ns1.example.com.に`CHILD = zzz.example.com`のNSをクエリ (6)

    $ dig @<DNSサーバのIPアドレス> zzz.example.com.  NS +norec

   * [PowerDNSに対するクエリとレスポンス](https://github.com/sischkg/qname-minimisation-test/blob/master/results/powerdns/powerdns_rectify_01_zzz.example.com_ns.txt)

9. 応答はNOERROR/NODATA answerであるため、応答キャッシュに保存し、(3)へ (6d)

10. `CHILD != QNAME` (3)

11. CHILDにラベルを１つ追加 (4)

    CHILD = yyy.zzz.example.com.

12. CHILDのNS RRsetはキャッシュにない (5)

13. ns1.example.com.に`CHILD = yyy.zzz.example.com`のNSをクエリ (6)

    $ dig @<DNSサーバのIPアドレス> yyy.zzz.example.com. NS +norec

   * [PowerDNSに対するクエリとレスポンス](https://github.com/sischkg/qname-minimisation-test/blob/master/results/powerdns/powerdns_rectify_02_yyy.zzz.example.com_ns.txt)

14. 応答はNOERROR/NODATA answerであるため、応答キャッシュに保存し、(3)へ (6d)

15. `CHILD == QNAME` のためCHILD(=QNAME)のAをクエリして終了 (3)

    $ dig @<DNSサーバのIPアドレス> yyy.zzz.example.com. A +norec

   * [PowerDNSに対するクエリとレスポンス](https://github.com/sischkg/qname-minimisation-test/blob/master/results/powerdns/powerdns_rectify_03_yyy.zzz.example.com_a.txt)

#### pdnssec rectify-zone

PowerDNS(MySQL backend)にて`pdnssec  rectify-zone`を実行すると、recordsテーブルへ`zzz.example.com`に対応する行が追加されます。

実行前

    mysql> select * from records;
    +----+-----------+---------------------+------+------------------------------------------------------------------+------+------+-------------+----------+-----------+------+
    | id | domain_id | name                | type | content                                                          | ttl  | prio | change_date | disabled | ordername | auth |
    +----+-----------+---------------------+------+------------------------------------------------------------------+------+------+-------------+----------+-----------+------+
    |  1 |         1 | example.com         | SOA  | ns1.example.com hostmaster.example.com 0 86400 3600 604800 10800 |  300 | NULL |        NULL |        0 | NULL      |    1 |
    |  2 |         1 | example.com         | NS   | ns1.example.com.                                                 |  300 | NULL |        NULL |        0 | NULL      |    1 |
    |  3 |         1 | www.example.com     | A    | 192.168.33.13                                                    |  300 | NULL |        NULL |        0 | NULL      |    1 |
    |  4 |         1 | ns1.example.com     | A    | 192.168.33.13                                                    |  300 | NULL |        NULL |        0 | NULL      |    1 |
    |  5 |         1 | yyy.zzz.example.com | A    | 192.168.33.13                                                    |  300 | NULL |        NULL |        0 | NULL      |    1 |
    +----+-----------+---------------------+------+------------------------------------------------------------------+------+------+-------------+----------+-----------+------+
    5 rows in set (0.00 sec)

実行後

    mysql> select * from records;
    +----+-----------+---------------------+------+------------------------------------------------------------------+------+------+-------------+----------+-----------+------+
    | id | domain_id | name                | type | content                                                          | ttl  | prio | change_date | disabled | ordername | auth |
    +----+-----------+---------------------+------+------------------------------------------------------------------+------+------+-------------+----------+-----------+------+
    |  1 |         1 | example.com         | SOA  | ns1.example.com hostmaster.example.com 0 86400 3600 604800 10800 |  300 | NULL |        NULL |        0 | NULL      |    1 |
    |  2 |         1 | example.com         | NS   | ns1.example.com.                                                 |  300 | NULL |        NULL |        0 | NULL      |    1 |
    |  3 |         1 | www.example.com     | A    | 192.168.33.13                                                    |  300 | NULL |        NULL |        0 | NULL      |    1 |
    |  4 |         1 | ns1.example.com     | A    | 192.168.33.13                                                    |  300 | NULL |        NULL |        0 | NULL      |    1 |
    |  5 |         1 | yyy.zzz.example.com | A    | 192.168.33.13                                                    |  300 | NULL |        NULL |        0 | NULL      |    1 |
    | 11 |         1 | zzz.example.com     | NULL | NULL                                                             | NULL | NULL |        NULL |        0 | NULL      |    1 |
    +----+-----------+---------------------+------+------------------------------------------------------------------+------+------+-------------+----------+-----------+------+

最後に`id = 11,  namae = "zzz.example.com"`の行が追加されています。

